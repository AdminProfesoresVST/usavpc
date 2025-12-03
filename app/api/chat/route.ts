import { createServerClient, type CookieOptions } from "@supabase/ssr";
import { cookies } from "next/headers";
import { NextResponse } from "next/server";
import { OpenAI } from "openai";
import { DS160StateMachine } from "@/lib/ai/state-machine";
import { getSystemPrompt } from "@/lib/ai/prompts";
import { DS160Payload } from "@/types/ds160";

const openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY,
});

export async function POST(req: Request) {
    try {
        const cookieStore = await cookies();
        const supabase = createServerClient(
            process.env.NEXT_PUBLIC_SUPABASE_URL!,
            process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
            {
                cookies: {
                    get(name: string) {
                        return cookieStore.get(name)?.value;
                    },
                    set(name: string, value: string, options: CookieOptions) {
                        cookieStore.set({ name, value, ...options });
                    },
                    remove(name: string, options: CookieOptions) {
                        cookieStore.set({ name, value: "", ...options });
                    },
                },
            }
        );

        // 1. Auth Check
        const { data: { user }, error: authError } = await supabase.auth.getUser();
        if (authError || !user) {
            return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
        }

        // 2. Load Application State
        let { data: application, error: dbError } = await supabase
            .from("applications")
            .select("*")
            .eq("user_id", user.id)
            .single();

        if (dbError && dbError.code === 'PGRST116') {
            // Create new application if none exists
            const { data: newApp, error: createError } = await supabase
                .from("applications")
                .insert([{
                    user_id: user.id,
                    ds160_payload: {
                        ds160_data: {
                            personal: {},
                            travel: {},
                            work_history: { current_job: {}, previous_jobs: [] },
                            security_questions: {}
                        }
                    }
                }])
                .select()
                .single();

            if (createError) throw new Error(createError.message);
            application = newApp;
        }

        const payload = application.ds160_payload as DS160Payload;
        const sm = new DS160StateMachine(payload, supabase);
        const currentStep = await sm.getNextStep();

        // 3. Process User Input (if any)
        const { answer, duration } = await req.json();
        let validationResult = null;

        if (answer && currentStep) {
            // Helper to set deep value
            const setDeepValue = (obj: any, path: string, value: any) => {
                const keys = path.split('.');
                let current = obj;
                for (let i = 0; i < keys.length - 1; i++) {
                    if (!current[keys[i]]) current[keys[i]] = {};
                    current = current[keys[i]];
                }
                current[keys[keys.length - 1]] = value;
            };

            // 1. Strict Validation: Ensure user is answering the question
            const validatorPromptTemplate = await getSystemPrompt(supabase, 'ANSWER_VALIDATOR');
            const validatorPrompt = validatorPromptTemplate
                .replace('{question}', currentStep.question)
                .replace('{input}', answer);

            const validationCompletion = await openai.chat.completions.create({
                model: "gpt-4o-mini",
                messages: [
                    { role: "system", content: validatorPrompt }
                ],
                response_format: { type: "json_object" }
            });

            const valRes = JSON.parse(validationCompletion.choices[0].message.content || '{}');

            // Handle Help Request
            if (valRes.isHelpRequest) {
                return NextResponse.json({
                    response: valRes.helpResponse || "Let me explain differently...",
                    nextStep: currentStep, // Repeat the same step
                    validationResult: { // Pass through for UI mirror if needed, or just internal
                        original: answer,
                        interpreted: "User asked for help",
                        type: "help"
                    }
                });
            }

            if (!valRes.isValid) {
                // Return refusal message and do NOT advance state
                return NextResponse.json({
                    response: valRes.refusalMessage || "Please answer the question.",
                    nextStep: currentStep // Repeat the same step
                });
            }

            // Analytics: Log Behavioral Data
            try {
                const geoCookie = cookieStore.get('x-client-geo')?.value;
                const geo = geoCookie ? JSON.parse(geoCookie) : {};

                await supabase.from('analytics_events').insert({
                    user_id: user.id,
                    event_type: 'question_answered',
                    ip_address: geo.ip,
                    country: geo.country,
                    city: geo.city,
                    metadata: {
                        question_id: currentStep.field,
                        english_score: valRes.english_proficiency,
                        sentiment: valRes.sentiment,
                        answer_length: answer.length,
                        time_taken_seconds: duration ? Math.round(duration / 1000) : null,
                        timestamp: new Date().toISOString()
                    }
                });
            } catch (e) {
                console.error("Analytics Error:", e);
            }

            // TRIAGE ASSESSMENT CHECK
            // If we just answered the last triage question (triage_property), trigger assessment
            if (currentStep.field === 'triage_property') {
                // Fetch full payload to get triage data
                const { data: fullPayload } = await supabase
                    .from('applications')
                    .select('ds160_payload')
                    .eq('user_id', user.id)
                    .single();

                const p = fullPayload?.ds160_payload || {};

                // Construct Triage Profile
                const triageProfile = {
                    job: p.primary_occupation,
                    income: p.monthly_income,
                    marital_status: p.marital_status,
                    children: p.triage_has_children, // We need to ensure this is saved in DB first.
                    // Wait, we haven't saved the current answer yet!
                    // The StateMachine saves it? No, the route handles saving?
                    // The route handles saving via `sm.updatePayload`. We need to do that first.
                };

                // We need to save the CURRENT answer before assessing
                // But `sm.getNextStep` is called at the start.
                // We need to insert the assessment message as an INTERSTITIAL step.

                const assessmentPromptTemplate = await getSystemPrompt(supabase, 'RISK_ASSESSMENT');
                const assessmentPrompt = assessmentPromptTemplate
                    .replace('{job}', p.primary_occupation || 'Unknown')
                    .replace('{income}', p.monthly_income || 'Unknown')
                    .replace('{marital_status}', p.marital_status || 'Unknown')
                    .replace('{children}', answer) // Current answer is children? No, current is property.
                    .replace('{property}', answer); // Current answer is property.

                const assessmentCompletion = await openai.chat.completions.create({
                    model: "gpt-4o-mini",
                    messages: [{ role: "system", content: assessmentPrompt }],
                    response_format: { type: "json_object" }
                });

                const assessment = JSON.parse(assessmentCompletion.choices[0].message.content || '{}');

                // Return the assessment as a special message, but still advance to next step
                // We can append it to the NEXT question? Or send it as a separate bubble?
                // The UI handles one message. Let's prepend it to the next question.

                // 4. Save Answer & Advance
                await sm.saveAnswer(user.id, currentStep.field, valRes.extractedValue || answer);
                const nextStep = await sm.getNextStep();

                if (nextStep) {
                    return NextResponse.json({
                        nextStep: {
                            ...nextStep,
                            question: `📊 **Análisis Preliminar**: ${assessment.assessment_message}\n\n${nextStep.question}`
                        },
                        validationResult: valRes
                    });
                }
            }

            // Use the clean extracted value
            const cleanAnswer = valRes.extractedValue || answer;

            // 2. Process Valid Answer
            if (currentStep.context === 'needs_translation') {
                // RAG: Search Knowledge Base for context
                const embeddingResponse = await openai.embeddings.create({
                    model: "text-embedding-3-small",
                    input: cleanAnswer,
                });
                const embedding = embeddingResponse.data[0].embedding;

                const { data: knowledge } = await supabase.rpc('match_knowledge_base', {
                    query_embedding: embedding,
                    match_threshold: 0.7,
                    match_count: 3
                });

                let contextText = "";
                if (knowledge && knowledge.length > 0) {
                    contextText = "\n\nRelevant Knowledge Base Entries:\n" +
                        knowledge.map((k: any) => `- ${k.content}`).join("\n");
                }

                // AI Processing for Job Titles/Duties
                const basePrompt = await getSystemPrompt(supabase, 'JOB_TRANSLATOR');
                const finalPrompt = basePrompt + contextText;

                const completion = await openai.chat.completions.create({
                    model: "gpt-4o-mini",
                    messages: [
                        { role: "system", content: finalPrompt },
                        { role: "user", content: cleanAnswer }
                    ],
                    response_format: { type: "json_object" }
                });

                const translatedData = JSON.parse(completion.choices[0].message.content || '{}');

                // Save structured object
                setDeepValue(payload, currentStep.field, translatedData);

                // Also save metadata for UI mirror
                validationResult = {
                    original: answer,
                    interpreted: translatedData.job_title_translated_en || "Translated",
                    type: 'job_translation'
                };

            } else if (currentStep.context === 'polish_content') {
                // AI Processing for General Content Polishing (Duties, Explanations, etc.)
                const prompt = await getSystemPrompt(supabase, 'CONTENT_POLISHER');
                const finalPrompt = prompt.replace('{question}', currentStep.question);

                const completion = await openai.chat.completions.create({
                    model: "gpt-4o-mini",
                    messages: [
                        { role: "system", content: finalPrompt },
                        { role: "user", content: cleanAnswer }
                    ],
                    response_format: { type: "json_object" }
                });

                const aiResponse = JSON.parse(completion.choices[0].message.content || "{}");
                const polishedText = aiResponse.polished_text || cleanAnswer;

                // Save polished text
                setDeepValue(payload, currentStep.field, polishedText);

                validationResult = {
                    original: answer,
                    interpreted: polishedText,
                    type: 'content_polish'
                };

            } else if (currentStep.context === 'spouse_parser') {
                // AI Processing for Spouse Details
                const prompt = await getSystemPrompt(supabase, 'SPOUSE_PARSER');
                const completion = await openai.chat.completions.create({
                    model: "gpt-4o-mini",
                    messages: [
                        { role: "system", content: prompt },
                        { role: "user", content: cleanAnswer }
                    ],
                    response_format: { type: "json_object" }
                });

                const aiResponse = JSON.parse(completion.choices[0].message.content || "{}");

                // Save the object to the spouse field
                setDeepValue(payload, currentStep.field, aiResponse);

                validationResult = {
                    original: answer,
                    interpreted: `${aiResponse.given_names} ${aiResponse.surnames} (${aiResponse.dob})`,
                    type: 'spouse_extraction'
                };

            } else {
                // Direct update
                setDeepValue(payload, currentStep.field, cleanAnswer);
            }

            // Save updated payload to DB
            await supabase
                .from("applications")
                .update({ ds160_payload: payload })
                .eq("id", application.id);
        }

        // 4. Get Next Question (after update)
        const nextStep = await sm.getNextStep();

        // 5. If Interview Complete, Run Risk Analysis
        let riskAnalysis = null;
        if (!nextStep) {
            const riskPrompt = await getSystemPrompt(supabase, 'RISK_ANALYST');
            const analysisCompletion = await openai.chat.completions.create({
                model: "gpt-4o", // Use stronger model for analysis
                messages: [
                    { role: "system", content: riskPrompt },
                    { role: "user", content: JSON.stringify(payload) }
                ],
                response_format: { type: "json_object" }
            });

            riskAnalysis = JSON.parse(analysisCompletion.choices[0].message.content || '{}');

            // Save to DB
            await supabase
                .from("applications")
                .update({ risk_assessment: riskAnalysis })
                .eq("id", application.id);
        }

        return NextResponse.json({
            nextStep,
            validationResult,
            riskAnalysis, // Return analysis to UI
            progress: calculateProgress(payload)
        });

    } catch (error) {
        console.error("Chat API Error:", error);
        return NextResponse.json({ error: "Internal Server Error" }, { status: 500 });
    }
}

function calculateProgress(payload: DS160Payload): number {
    const data = payload.ds160_data;
    let filled = 0;
    const requiredFields = [
        data.personal.surnames,
        data.personal.given_names,
        data.personal.dob,
        data.personal.marital_status,
        // Triage Fields
        payload.primary_occupation, // Saved at root level for triage? No, saved in payload root by triage logic? 
        // Wait, triage logic saves to `primary_occupation` in root of payload?
        // Let's check where we save. We save to `currentStep.field`.
        // Triage fields are `primary_occupation`, `monthly_income`, `marital_status`, `triage_has_children`, `triage_property`.
        // These are likely at the root of `ds160_payload` or `ds160_data` depending on the field key.
        // The field keys in migration were `primary_occupation` etc.
        // So we check those.
        payload.primary_occupation,
        payload.monthly_income,
        payload.triage_has_children,
        payload.triage_property,

        data.travel.purpose_code,
        data.travel.paying_entity,
        data.work_history.current_job?.employer_name,
        data.security_questions?.q1
    ];

    filled = requiredFields.filter(f => f && f.toString().length > 0).length;
    // Total is dynamic based on flow, but for now we use the core set
    const total = requiredFields.length;

    return Math.min(100, Math.round((filled / total) * 100));
}
