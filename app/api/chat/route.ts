import { createServerClient, type CookieOptions } from "@supabase/ssr";
import { cookies } from "next/headers";
import { NextResponse } from "next/server";
import { OpenAI } from "openai";
import { DS160StateMachine } from "@/lib/ai/state-machine";
import { getSystemPrompt } from "@/lib/ai/prompts";
import { DS160Payload } from "@/types/ds160";

// OpenAI initialized lazily inside handler to prevent build crashes
// const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY }); // REMOVED

export async function POST(req: Request) {
    try {
        const openai = new OpenAI({
            apiKey: process.env.OPENAI_API_KEY,
        });

        const cookieStore = await cookies();
        // 1. Auth Check (Use getCurrentUser to support Dev Mode)
        const { getCurrentUser } = await import("@/lib/auth/current-user");
        const { data: { user }, error: authError } = await getCurrentUser();

        if (authError || !user) {
            return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
        }

        // 2. Setup Supabase Client (Use Service Role for Dev Users to bypass RLS)
        const isDevUser = user.id.startsWith('00000000-0000-0000-0000-0000000000');
        const supabaseKey = isDevUser
            ? process.env.SUPABASE_SERVICE_ROLE_KEY!
            : process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

        const supabase = createServerClient(
            process.env.NEXT_PUBLIC_SUPABASE_URL!,
            supabaseKey,
            {
                cookies: {
                    get(name: string) { return cookieStore.get(name)?.value; },
                    set(name: string, value: string, options: CookieOptions) { cookieStore.set({ name, value, ...options }); },
                    remove(name: string, options: CookieOptions) { cookieStore.set({ name, value: "", ...options }); },
                },
            }
        );

        // 3. Process User Input (if any)
        const { answer, duration, locale, context } = await req.json();

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
                    },
                    client_metadata: { locale }
                }])
                .select()
                .single();

            if (createError) throw new Error(createError.message);
            application = newApp;
        }

        // 2.5: Inject Context Data (OCR + Triage) if provided on first load
        if (context) {
            let updates: any = {};
            let payloadUpdates: any = application.ds160_payload || { ds160_data: { personal: {}, travel: {}, work_history: {}, security_questions: {} } };

            // Ensure structure exists
            if (!payloadUpdates.ds160_data) payloadUpdates.ds160_data = { personal: {} };
            if (!payloadUpdates.ds160_data.personal) payloadUpdates.ds160_data.personal = {};
            if (!payloadUpdates.ds160_data.passport) payloadUpdates.ds160_data.passport = {};

            // Passport Image URL Persistence
            if (context.passport_image_path) {
                updates.passport_image_url = context.passport_image_path;
            }

            // Sync Personal Data from OCR
            const personal = payloadUpdates.ds160_data.personal;
            if (context.surname) personal.surnames = context.surname;
            if (context.givenName) personal.given_names = context.givenName;
            if (context.dob) personal.dob = context.dob;
            if (context.sex) personal.sex = context.sex;
            if (context.country) personal.nationality = context.country;

            // Sync Passport Data from OCR
            const passport = payloadUpdates.ds160_data.passport;
            if (context.passportNumber) passport.passport_number = context.passportNumber;
            if (context.expiration) passport.expiration_date = context.expiration;

            // Sync Triage Data (Questions from Triage Flow)
            // Questions usually mapped to q1, q2, q3 etc in variable names
            // We'll map them if present.
            if (context.q1) payloadUpdates.primary_occupation = context.q1;
            if (context.q2) payloadUpdates.has_refusals = context.q2 === 'yes';
            // Add more mappings as Triage Flow evolves

            // Perform Update
            await supabase.from("applications").update({
                ...updates,
                ds160_payload: payloadUpdates
            }).eq("id", application.id);

            // Update local application object so StateMachine sees the new data immediately
            application = { ...application, ...updates, ds160_payload: payloadUpdates };
        }

        const payload = application.ds160_payload as DS160Payload;
        const sm = new DS160StateMachine(payload, supabase, locale); // Pass locale

        // Update locale if changed or missing
        if (!application.client_metadata || application.client_metadata.locale !== locale) {
            await supabase
                .from("applications")
                .update({
                    client_metadata: {
                        ...application.client_metadata,
                        locale
                    }
                })
                .eq("id", application.id);
        }

        const currentStep = await sm.getNextStep();
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

            let valRes: any = { isValid: false }; // Default
            let bypassAI = false;

            console.log(`[Chat] Processing Question: ${currentStep.field}, Type: ${currentStep.type}`);
            console.log(`[Chat] User Answer: ${answer}`);

            // SHORT-CIRCUIT: Exact Match for Select Options
            if (currentStep.options) {
                const normalizedAnswer = answer.trim().toLowerCase();
                const matchedOption = currentStep.options.find((o: any) =>
                    o.value.toLowerCase() === normalizedAnswer ||
                    o.label.toLowerCase() === normalizedAnswer
                );

                if (matchedOption) {
                    console.log(`[Chat] Short-Circuit Match: ${matchedOption.label} -> ${matchedOption.value}`);
                    valRes = {
                        isValid: true,
                        extractedValue: matchedOption.value,
                        english_proficiency: null,
                        sentiment: 'neutral',
                        isHelpRequest: false
                    };
                    bypassAI = true;
                }
            }

            if (!bypassAI) {
                let queryContext = currentStep.question;
                if (currentStep.options) {
                    const optionsStr = currentStep.options.map((o: any) => `"${o.label}" (Value: ${o.value})`).join(', ');
                    queryContext += `\nValid Options: [${optionsStr}]`;
                }

                const validatorPrompt = validatorPromptTemplate
                    .replace('{question}', queryContext)
                    .replace('{input}', answer);

                const validationCompletion = await openai.chat.completions.create({
                    model: "gpt-4o-mini",
                    messages: [
                        { role: "system", content: validatorPrompt }
                    ],
                    response_format: { type: "json_object" }
                });

                valRes = JSON.parse(validationCompletion.choices[0].message.content || '{}');
            }

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

        // RE-INSTANTIATE SM WITH UPDATED PAYLOAD TO ENSURE FRESH STATE
        const smNext = new DS160StateMachine(payload, supabase, locale);

        // 4. Get Next Question (after update)
        const nextStep = await smNext.getNextStep();

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
        return NextResponse.json({
            error: error instanceof Error ? error.message : "Unknown Internal Error",
            details: JSON.stringify(error)
        }, { status: 500 });
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
        data.personal.nationality,
        data.contact?.phone_primary,
        data.contact?.email_address,
        data.passport?.passport_number,

        // Triage Fields
        payload.primary_occupation,
        payload.monthly_income,
        payload.triage_has_children,
        payload.triage_property,

        data.travel.purpose_code,
        data.travel.paying_entity,
        data.work_history.current_job?.employer_name,

        // Security
        data.security_questions?.security_health,
        data.security_questions?.security_criminal
    ];

    filled = requiredFields.filter(f => f && f.toString().length > 0).length;
    // Total is dynamic based on flow, but for now we use the core set
    const total = requiredFields.length;

    return Math.min(100, Math.round((filled / total) * 100));
}
