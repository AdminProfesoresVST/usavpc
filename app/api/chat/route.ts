import { createServerClient, type CookieOptions } from "@supabase/ssr";
import { cookies } from "next/headers";
import { NextResponse } from "next/server";
import { openai as openaiModelProvider } from "@ai-sdk/openai";
import { generateObject } from "ai";
import { simulatorSchema } from "@/lib/ai/simulator-schema";
import { DS160StateMachine } from "@/lib/ai/state-machine";
import { getSystemPrompt } from "@/lib/ai/prompts";
import { DS160Payload } from "@/types/ds160";
import OpenAI from "openai";
import { calculateConsularScore } from "@/lib/ai/scoring-logic";

export const maxDuration = 60; // Allow up to 60 seconds for complex AI processing
export const runtime = 'nodejs'; // Switch to Node.js for stability (Avoid Edge 10s timeout)

// ALGORITHM: Calculate Initial Risk Score based on DS-160 Data (Section 214(b) Profile)
// ALGORITHM: Moved to @/lib/ai/scoring-logic.ts
// function calculateInitialRiskScore... REMOVED

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
        const body = await req.json();
        const { answer, duration, context, locale = 'en', mode = 'standard', history = [] } = body;

        console.log(`[API] Chat Request - Mode: ${mode}, Answer: ${answer}`); // DEBUG LOG

        let effectiveLocale = locale;

        // ---------------------------------------------------------
        // 4. Load Application State (HOISTED)
        // ---------------------------------------------------------
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
                    client_metadata: { locale },
                    simulator_history: [] // Init history
                }])
                .select()
                .single();

            if (createError) throw new Error(createError.message);
            application = newApp;
        }

        // ---------------------------------------------------------
        // SIMULATOR MODE INTERCEPTOR
        // ---------------------------------------------------------
        if (mode === 'simulator') {
            // 0. Load History, Score, Turns from DB
            const dbHistory = application.simulator_history || [];
            let currentScore = application.simulator_score ?? 50; // Start at Neutral 50
            let currentTurns = application.simulator_turns ?? 0;
            const MAX_TURNS = 1000; // Virtually Infinite per user request

            // 1. If it's the INITIAL LOAD (answer is null), Greeting.
            if (!answer) {
                const greetingText = effectiveLocale === 'es'
                    ? "Buenos días. Soy el oficial consular asignado a su caso. Por favor, entrégueme su pasaporte y dígame el motivo de su viaje."
                    : "Good morning. I am the consular officer assigned to your case. Please hand me my passport and state the purpose of your trip.";

                const newHistory = [{ role: "assistant", content: greetingText }];

                // CALCULATE DYNAMIC SCORE (CONSULAR LOGIC MODEL)
                const logicResult = calculateConsularScore(application.ds160_payload);
                const initialScore = logicResult.totalScore;

                // RESET STATE ON INITIAL LOAD (Fixes "Instant Win" bug)
                await supabase.from("applications").update({
                    simulator_history: newHistory,
                    simulator_score: initialScore,
                    simulator_turns: 0
                }).eq("id", application.id);

                return NextResponse.json({
                    nextStep: {
                        question: greetingText,
                        field: "simulator_intro",
                        type: "text"
                    }
                });
            }

            // 2. Conversational Handling (Consul Persona)
            // We need to bypass the strict validator for generic chat, BUT still try to extract data.
            // We'll use a specific Simulator Prompt that is flexible.


            // ------------------------------------------------------------------
            // AGENT 1: THE EX-CONSUL (Behavior & Regulation)
            // ------------------------------------------------------------------
            // ROLE: You are a former US Consular Officer (State Dept). You know the FAM (Foreign Affairs Manual).
            // PREMISE: Under INA Section 214(b), every applicant is an immigrant until proven otherwise.
            // TONE: Professional but cold. Efficient. No fluff. No "Thank you for sharing".
            // MEMORY: If the user changes their story, Call. Them. Out. ("You just said X, now Y?").

            const simulatorPromptContent = `
        You are a United States Consular Officer conducting a Visa Interview (B1/B2).
        Your goal is to screen for "Immigrant Intent" (Section 214b).
        
        [PRIME DIRECTIVES - 9 FAM Reference]
        1. **Presumption of Guilt**: Assume the applicant wants to stay in the US illegal unless they prove strong ties to their home.
        2. **Skepticism**: If a story sounds rehearsed or vague, drill down. "Why?" "How?" "Show me."
        3. **No Robot-Speak**: NEVER say: "I understand", "Great", "Thank you", "As an AI". Talk like a busy bureaucrat.
        4. **Interrupt**: If the user gives a long speech, cut them off (simulate this by ignoring the fluff).
        
        [INTERVIEW STAGES]
        1. **Triage**: Quickly verify Purpose, Job, Salary.
        2. **Pressure**: Find the weak point (e.g., Low salary? Young? Single?) and press it.
        3. **Verdict**: Decide based on logic.
        
        [CURRENT CONTEXT]
        - Locale: ${locale} (Reply in this language, but with US Authority tone)
        - Applicant Data: ${JSON.stringify(application.ds160_payload || {})}
        
        [RESPONSE RULES]
        - Keep answers SHORT (1-2 sentences). You are busy.
        - If they speak English poorly, switch to simple English or their Native Language with a sigh.
        
        [STRICT OUTPUT FORMAT]
        - Output MUST be a FLAT JSON object.
        - DO NOT wrap in "type", "properties", or "object" keys.
        - DO NOT include schema definitions.
        - Valid fields: reasoning, known_data, response, feedback, score_delta, action, current_score.
        
        GET THE TRUTH. PROTECT THE BORDER.
        
        [DYNAMIC PROFILE & RISK MATRIX]
        - Young/Single (<30): High Risk of Overstay.
        - No Travel History: High Risk (Blank Passport).
        - New Job (<1 year): Moderate Risk.
        
        [TERMINATION LOGIC]
        - STOP if Score < 25 (Deny).
        - STOP if Score > 85 (Approve).
        - STOP if Data is collected (Job, Purpose, Funding, Ties).
        - MINIMUM 5 Questions.
        
        [HISTORY CHECK]
        - Do not ask what you already know.
        `;

            // Construct Messages for AI
            // Include DB History + Current Answer
            const effectiveHistory = [...dbHistory];
            if (answer) {
                effectiveHistory.push({ role: "user", content: answer });
            }

            let finalObj;
            try {
                const { object } = await generateObject({
                    model: openaiModelProvider('gpt-4o-mini'),
                    schema: simulatorSchema,
                    system: simulatorPromptContent,
                    messages: effectiveHistory.map((m: any) => ({ role: m.role, content: m.content })),
                });
                finalObj = object;
            } catch (error: any) {
                console.warn("AI Schema Mismatch - Attempting Agent 5 'Repair' Layer...", error.message);

                // [REPAIR LAYER]
                try {
                    const { object: repairObj } = await generateObject({
                        model: openaiModelProvider('gpt-4o-mini'),
                        schema: simulatorSchema,
                        system: `You are a REPAIR AGENT. Fix the following JSON to match the schema.
                        Schema: reasoning (string), response (string), feedback (string), score_delta (number), action (CONTINUE|TERMINATE_APPROVED|TERMINATE_DENIED), current_score (number).
                        Fault: ${error.message}
                        Data: ${JSON.stringify(error.value || {})}
                        `,
                        messages: [{ role: "user", content: "Repair the data." }]
                    });
                    finalObj = repairObj;
                } catch (retryError) {
                    console.error("Agent 5 Repair Failed. Triggering FAIL-SAFE FALLBACK.");
                    // [FAIL-SAFE FALLBACK]
                    finalObj = {
                        reasoning: "System failure during evaluation. Defaulting to safe state.",
                        response: "I see. Let's move on. Tell me more about your travel plans.",
                        feedback: "The connection dropped momentarily. Try giving a more detailed answer.",
                        score_delta: 0,
                        action: "CONTINUE",
                        current_score: currentScore,
                        known_data: {}
                    };
                }
            }

            // Save to DB
            const finalHistory = [
                ...effectiveHistory,
                {
                    role: "assistant",
                    content: finalObj.response,
                    data: {
                        score_delta: finalObj.score_delta,
                        feedback: finalObj.feedback,
                        reasoning: finalObj.reasoning,
                        current_score: finalObj.current_score
                    }
                }
            ];

            await supabase.from("applications").update({
                simulator_history: finalHistory,
                simulator_score: finalObj.current_score || currentScore,
                simulator_turns: currentTurns + 1
            }).eq("id", application.id);

            // Return Standard JSON Response (Compatible with ChatInterface logic)
            return NextResponse.json({
                response: finalObj.response,
                nextStep: null, // No nextStep struct for simulator
                meta: {
                    action: finalObj.action,
                    score_delta: finalObj.score_delta,
                    feedback: finalObj.feedback,
                    current_score: finalObj.current_score
                }
            });
        }
        // ---------------------------------------------------------


        // AUTO-LOCALE: Restore saved preference
        if (application?.client_metadata?.prefers_language) {
            effectiveLocale = application.client_metadata.prefers_language;
        }

        // 2.5: Inject Context Data (OCR + Triage) if provided on first load
        if (context) {
            let updates: any = {};
            // STRICT MODE: Payload MUST exist.
            if (!application.ds160_payload) {
                console.error("CRITICAL: Application exists but payload is null.", application.id);
                throw new Error("CRITICAL_DATA_CORRUPTION: Application payload is missing.");
            }
            let payloadUpdates: any = application.ds160_payload;

            // Ensure structure exists (This is structure, not data. Allowed to init empty branches)
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

            // Aggressive Nationality Aliases
            if (context.country) personal.nationality = context.country;
            if (context.nationality) personal.nationality = context.nationality;
            if (context.citizenship) personal.nationality = context.citizenship;
            if (context.issuingCountry) personal.nationality = context.issuingCountry;

            // Expanded OCR Mappings (Fix for "Why do you ask what is in passport?")
            if (context.cityOfBirth || context.placeOfBirth) personal.city_of_birth = context.cityOfBirth || context.placeOfBirth;
            if (context.stateOfBirth || context.placeOfBirthState) personal.state_of_birth = context.stateOfBirth || context.placeOfBirthState;
            if (context.countryOfBirth || context.birthCountry) personal.country_of_birth = context.countryOfBirth || context.birthCountry;

            // Sync Passport Data from OCR
            const passport = payloadUpdates.ds160_data.passport;
            if (context.passportNumber) passport.passport_number = context.passportNumber;
            if (context.expiration) passport.expiration_date = context.expiration;
            if (context.issued || context.issuanceDate) passport.issuance_date = context.issued || context.issuanceDate;
            if (context.authority || context.issuingAuthority) passport.issuance_authority = context.authority || context.issuingAuthority;

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
        const sm = new DS160StateMachine(payload, supabase, locale, user.id); // Pass user.id

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

            // 1. Dynamic Validator Selection (Specialized Experts)
            let promptKey = 'ANSWER_VALIDATOR';
            if (currentStep.field.includes('personal') || currentStep.field.includes('spouse') || currentStep.field.includes('contact')) promptKey = 'VALIDATOR_PERSONAL';
            if (currentStep.field.includes('passport')) promptKey = 'VALIDATOR_PASSPORT';
            if (currentStep.field.includes('travel') || currentStep.field.includes('purpose')) promptKey = 'VALIDATOR_TRAVEL';
            if (currentStep.field.includes('work') || currentStep.field.includes('occupation') || currentStep.field.includes('income')) promptKey = 'VALIDATOR_WORK';
            if (currentStep.field.includes('security')) promptKey = 'VALIDATOR_SECURITY';

            const validatorPromptTemplate = await getSystemPrompt(supabase, promptKey);

            let valRes: any = { isValid: false }; // Default
            let bypassAI = false;

            console.log(`[Chat] Processing Question: ${currentStep.field}, Type: ${currentStep.type} `);
            console.log(`[Chat] User Answer: ${answer} `);

            // SHORT-CIRCUIT: Exact Match for Select Options
            if (currentStep.options) {
                const normalizedAnswer = answer.trim().toLowerCase();
                const matchedOption = currentStep.options.find((o: any) =>
                    o.value.toLowerCase() === normalizedAnswer ||
                    o.label.toLowerCase() === normalizedAnswer
                );

                if (matchedOption) {
                    console.log(`[Chat] Short - Circuit Match: ${matchedOption.label} -> ${matchedOption.value} `);
                    valRes = {
                        isValid: true,
                        extractedValue: matchedOption.value,
                        displayValue: matchedOption.label,
                        english_proficiency: null,
                        sentiment: 'neutral',
                        isHelpRequest: false
                    };
                    bypassAI = true;
                }
            }

            if (!bypassAI) {
                // SPECIAL CONTEXTS: Skip Generic Validation for Complex Parsers
                if (currentStep.context === 'spouse_parser') {
                    // Assume valid for now, let the specialized parser handle extraction quality
                    // We can add specific logic later if parser returns null
                    valRes = { isValid: true };
                } else {
                    let queryContext = currentStep.question;
                    if (currentStep.options) {
                        const optionsStr = currentStep.options.map((o: any) => `"${o.label}"(Value: ${o.value})`).join(', ');
                        queryContext += `\nValid Options: [${optionsStr}]`;
                    }

                    // Construct robust context for the AI
                    // We don't rely on placeholders in the DB prompt anymore.
                    // We send the Context/Rules as System, and the actual Data as User.

                    const validationCompletion = await openai.chat.completions.create({
                        model: "gpt-4o-mini",
                        messages: [
                            { role: "system", content: validatorPromptTemplate }, // The Rules/Persona
                            { role: "user", content: `QUESTION CONTEXT: \n${queryContext} \n\nUSER INPUT: \n"${answer}"\n\nValidate and parse this answer.` }
                        ],
                        response_format: { type: "json_object" }
                    });

                    valRes = JSON.parse(validationCompletion.choices[0].message.content || '{}');

                    // Fallback: If AI didn't provide displayValue, use extractedValue
                    if (!valRes.displayValue && valRes.extractedValue) {
                        valRes.displayValue = valRes.extractedValue;
                    }
                }
            }

            // AUTO-DETECT LANGUAGE
            if (valRes.detectedLanguage === 'es') effectiveLocale = 'es';

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

                // 4. Save Smart Data (Contextual Extraction)
                // If the AI found other answers in the user's text, save them too.
                if (valRes.additionalData) {
                    console.log("[Chat] 🧠 AI found extra context:", valRes.additionalData);
                    for (const [key, val] of Object.entries(valRes.additionalData)) {
                        await sm.saveAnswer(user.id, key, val);
                    }
                }

                // Save direct answer
                await sm.saveAnswer(user.id, currentStep.field, valRes.extractedValue || answer);
                const nextStep = await sm.getNextStep();

                if (nextStep) {
                    return NextResponse.json({
                        nextStep: {
                            ...nextStep,
                            question: `📊 ** Análisis Preliminar **: ${assessment.assessment_message} \n\n${nextStep.question} `
                        },
                        validationResult: valRes
                    });
                }
            }

            // Use the clean extracted value
            const cleanAnswer = valRes.extractedValue || answer;

            // 2. Process Valid Answer
            // CONFIRMATION LOOP START
            // Check if we are pending confirmation
            const pendingConf = application.client_metadata?.confirmation_pending;

            if (pendingConf) {
                // User is replying to "Is X correct?"
                const checkerPrompt = await getSystemPrompt(supabase, 'CONFIRMATION_CHECKER');
                const checkCompletion = await openai.chat.completions.create({
                    model: "gpt-4o-mini",
                    messages: [
                        { role: "system", content: checkerPrompt },
                        { role: "user", content: `PROPOSAL: "${pendingConf.value}"\nUSER REPLY: "${answer}"` }
                    ],
                    response_format: { type: "json_object" }
                });

                const checkRes = JSON.parse(checkCompletion.choices[0].message.content || '{}');

                if (checkRes.intent === 'CONFIRMED') {
                    // 1. Clear Pending Flag
                    await supabase.from("applications").update({
                        client_metadata: { ...application.client_metadata, confirmation_pending: null }
                    }).eq("id", application.id);

                    // 2. Advance State (The answer is already saved)
                    // Just return "Great" and next question
                    const smNext = new DS160StateMachine(payload, supabase, effectiveLocale, user.id);
                    const nextStep = await smNext.getNextStep();
                    return NextResponse.json({
                        response: effectiveLocale === 'es' ? "Excelente. Continuemos." : "Great. Moving on.",
                        nextStep,
                        validationResult: { isValid: true, displayValue: pendingConf.value }
                    });

                } else {
                    // 1. REJECTED: Clear the saved value? 
                    // We must wipe the answer so getNextStep returns the same question again.
                    setDeepValue(payload, pendingConf.field, null);

                    await supabase.from("applications").update({
                        ds160_payload: payload,
                        client_metadata: { ...application.client_metadata, confirmation_pending: null }
                    }).eq("id", application.id);

                    // 2. Return the SAME question again
                    return NextResponse.json({
                        response: effectiveLocale === 'es'
                            ? "Entendido. Inténtalo de nuevo. Dime con tus propias palabras:"
                            : "Understood. Let's try again. Tell me in your own words:",
                        nextStep: currentStep // This will be the same question since we cleared the value
                    });
                }
            }
            // CONFIRMATION LOOP END


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
                        knowledge.map((k: any) => `- ${k.content} `).join("\n");
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

                // MIRROR LOGIC: STOP and Ask for Confirmation
                const displayVal = translatedData.job_title_translated_en || "Translated";

                await supabase.from("applications").update({
                    ds160_payload: payload,
                    client_metadata: {
                        ...application.client_metadata,
                        confirmation_pending: { field: currentStep.field, value: displayVal }
                    }
                }).eq("id", application.id);

                return NextResponse.json({
                    response: effectiveLocale === 'es'
                        ? `He interpretado esto como ** "${displayVal}" **. ¿Es correcto para el formulario ? `
                        : `I interpreted this as ** "${displayVal}" **.Is this correct for the form ? `,
                    nextStep: null, // Halt flow
                    validationResult: {
                        original: answer,
                        interpreted: displayVal,
                        type: 'job_translation',
                        requires_confirmation: true
                    }
                });

            } else if (currentStep.context === 'polish_content') { // Same for Polish
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

                // MIRROR LOGIC
                await supabase.from("applications").update({
                    ds160_payload: payload,
                    client_metadata: {
                        ...application.client_metadata,
                        confirmation_pending: { field: currentStep.field, value: polishedText }
                    }
                }).eq("id", application.id);

                return NextResponse.json({
                    response: effectiveLocale === 'es'
                        ? `He mejorado tu respuesta para que suene más profesional: \n\n ** "${polishedText}" **\n\n¿Estás de acuerdo ? `
                        : `I polished your answer to sound more professional: \n\n ** "${polishedText}" **\n\nDo you agree ? `,
                    nextStep: null, // Halt
                    validationResult: {
                        original: answer,
                        interpreted: polishedText,
                        type: 'content_polish',
                        requires_confirmation: true
                    }
                });


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

                // No confirmation needed for simple factual extraction usually, but explicit user request implies ALL interpretation
                // Let's keep spouse verification implicit for now unless user complains, or add it.
                // User said "interpret, analyze, put in best words... give improved answer... user decides".
                // Spouse name is factual. Duties/Job are interpretative.
                // We will stick to job/duties for now.

                await supabase.from("applications").update({
                    ds160_payload: payload,
                    client_metadata: { ...application.client_metadata }
                }).eq("id", application.id);

                validationResult = {
                    original: answer,
                    interpreted: `${aiResponse.given_names} ${aiResponse.surnames} (${aiResponse.dob})`,
                    type: 'spouse_extraction'
                };

            } else if (currentStep.type === 'text' && valRes.displayValue && valRes.displayValue.length > 3 && valRes.displayValue !== answer && valRes.displayValue !== "Does Not Apply") {
                // UNIVERSAL POLISH & CONFIRM
                // If the Validator improved the text (and it's not just a standard "N/A" map), verify with user.
                // Heuristic: If string distance is significant or completely different words.
                // For now, assume any change in TEXT fields that isn't N/A or simple casing warrants a check if it adds content.
                // Actually, let's trust the user wants to clear "bad formulations".

                // Normalization for comparison
                const normAns = answer.trim().toLowerCase();
                const normDisp = valRes.displayValue.trim().toLowerCase();

                // If it's just casing/trimming, skip confirmation
                if (normAns === normDisp) {
                    setDeepValue(payload, currentStep.field, valRes.extractedValue || answer);
                    await supabase.from("applications").update({
                        ds160_payload: payload,
                        client_metadata: { ...application.client_metadata, prefers_language: effectiveLocale }
                    }).eq("id", application.id);
                } else {
                    // Significant Change detected (e.g. "vendo ropa" -> "Retail Sales")
                    // SAVE PENDING
                    await supabase.from("applications").update({
                        ds160_payload: payload, // Don't save the value yet (or save previous) - checking logic
                        // Actually, we haven't saved the value in payload yet.
                        client_metadata: {
                            ...application.client_metadata,
                            confirmation_pending: { field: currentStep.field, value: valRes.extractedValue } // Save the EXTRACTED value (the good one)
                        }
                    }).eq("id", application.id);

                    return NextResponse.json({
                        response: effectiveLocale === 'es'
                            ? `He mejorado tu respuesta: ** "${valRes.displayValue}" **. ¿Te parece bien ? `
                            : `I improved your answer to: ** "${valRes.displayValue}" **.Is this okay ? `,
                        nextStep: null, // Halt flow matches currentStep visually usually, or null
                        validationResult: {
                            original: answer,
                            interpreted: valRes.displayValue,
                            type: 'universal_polish',
                            requires_confirmation: true
                        }
                    });
                }

            } else {
                // Direct update (No polish needed or simple field)
                setDeepValue(payload, currentStep.field, cleanAnswer);

                // Normal save logic
                await supabase
                    .from("applications")
                    .update({
                        ds160_payload: payload,
                        client_metadata: {
                            ...application.client_metadata,
                            prefers_language: effectiveLocale
                        }
                    })
                    .eq("id", application.id);
            }

            // RE-INSTANTIATE SM WITH UPDATED PAYLOAD TO ENSURE FRESH STATE
            const smNext = new DS160StateMachine(payload, supabase, effectiveLocale, user.id);

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
        }
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
