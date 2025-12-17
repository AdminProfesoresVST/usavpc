import { createServerClient, type CookieOptions } from "@supabase/ssr";
import { cookies } from "next/headers";
import { NextResponse } from "next/server";
import { openai } from "@ai-sdk/openai";
import { streamObject } from "ai";
import { simulatorSchema } from "@/lib/ai/simulator-schema";
import { DS160StateMachine } from "@/lib/ai/state-machine";
import { getSystemPrompt } from "@/lib/ai/prompts";
import { DS160Payload } from "@/types/ds160";

// OpenAI initialized lazily inside handler to prevent build crashes
// const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY }); // REMOVED

import { DS160Payload } from "@/types/ds160";

export const runtime = 'edge'; // Bypass Netlify 10s Serverless Timeout

// ALGORITHM: Calculate Initial Risk Score based on DS-160 Data (Section 214(b) Profile)
function calculateInitialRiskScore(payload: DS160Payload | null): number {
    if (!payload?.ds160_data) return 40; // Default Skeptical if no data

    let score = 50; // Neutral Start

    const personal = payload.ds160_data.personal || {};
    const work = payload.ds160_data.work_education || {};

    // 1. AGE FACTOR
    // Risk: Young Adults (18-29) have highest overstay rates.
    // Low Risk: Children (<18) and Seniors (>60).
    // Context: We assume 'dob' format YYYY-MM-DD
    if (personal.dob) {
        const birthYear = new Date(personal.dob).getFullYear();
        const currentYear = new Date().getFullYear();
        const age = currentYear - birthYear;

        if (age >= 18 && age <= 29) score -= 10; // High Risk Zone
        else if (age > 60) score += 10; // Low Risk
        else score += 5; // Prime Working Age (Stable)
    }

    // 2. TIES TO HOME: MARRIAGE
    const marital = personal.marital_status;
    if (marital === 'M' || marital === 'C') score += 10; // Married/Common Law = Tie
    else if (marital === 'S') score -= 5; // Single = Mobile (Risk)

    // 3. ECONOMIC TIES: EMPLOYMENT
    // We check primary occupation.
    const job = payload.primary_occupation;
    if (job === 'U') score -= 15; // Unemployed = High Risk
    if (job === 'S') score += 5; // Student = Medium Risk (check ties)
    if (job === 'E' || job === 'B') score += 10; // Employed/Business = Strong Tie

    // 4. INCOME (Solvency)
    // Assume monthly_income is numeric string
    const income = parseInt(payload.monthly_income || "0");
    if (income > 2000) score += 5;
    if (income > 5000) score += 5;

    // 5. HISTORY
    if (payload.has_previous_visa) score += 15; // Proven track record
    if (payload.has_refusals) score -= 15; // Previous Denial = High Scrutiny

    // Clamp 20-80 (Never start approved/denied)
    return Math.max(20, Math.min(80, score));
}

export async function POST(req: Request) {
    try {
        const openaiInstance = new OpenAI({ // Renamed to avoid alias conflict
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

                // CALCULATE DYNAMIC SCORE
                const initialScore = calculateInitialRiskScore(application.ds160_payload);

                // RESET STATE ON INITIAL LOAD (Fixes "Instant Win" bug)
                await supabase.from("applications").update({
                    simulator_history: newHistory,
                    simulator_score: initialScore, // Data-Driven Score (20-80)
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

            const simulatorPromptContent = `
                 You are a HARSH & SKEPTICAL US Visa Consul.
                 You are ALSO a helpful Coach (hidden persona).
                 
                 Mode: SIMULATOR.
                 
                 Current Score: ${currentScore} / 100.
                 Turns Used: ${currentTurns} / ${MAX_TURNS}.
                 MINIMUM TURNS BEFORE VERDICT: 5.
                 
                 RULES:
                 1. START SKEPTICAL (Score 40). User must EARN the visa.
                 2. DO NOT APPROVE EARLY. You MUST ask at least 5 questions to verify consistency.
                 3. If Turns < 5, ACTION must be "CONTINUE" (unless user admits crime/fraud).
                 
                 STATISTICAL RISK MATRIX (Apply these Invisible Penalties):
                 1. "The Young/Single Burden": If User is < 30 AND Single/Unmarried -> DEDUCT 15 POINTS INITIAL RISK. (High Statistical Overstay Rate).
                 2. "The Blank Passport": If User has NO previous international travel -> DEDUCT 10 POINTS (No track record).
                 3. "The Tweener": If User is 22-28, not studying, new job -> HIGH RISK.
                 4. "Solo Traveler": If traveling alone for "Tourism" -> Moderate Risk.
                 

                 PSYCHOLOGICAL PROFILING (INSIDER SECRETS - FORMER CONSULS):
                 1. "The Scripted Answer Trap": 
                    - IF answer is too perfect, robotic, or sounds memorized -> DEDUCT 10 POINTS (Suspect Coaching).
                    - PREFER natural, slightly messy but honest answers.
                 
                 2. "The 'Why Now?' Anomaly":
                    - IF User is > 30 and has NEVER traveled, and suddenly wants to go to Disney -> HIGH SUSPICION. ASK: "Why now? Why not before?"
                 
                 3. "The Anchor Relative Rule":
                    - IF User mentions "Brother/Sister/Parent" in USA with "Green Card" or "Citizen" -> DEDUCT 10 POINTS (Immigrant Intent Risk).
                    - UNLESS User proves SUPER STRONG ties to home.
                 
                 4. "When in Doubt, Deny (214b)":
                    - Consular Officers are protected by law. If you are 51% unsure -> DENY.
                    - DO NOT give benefit of doubt. The burden of proof is on the User.
                 
                 YOUR GOAL:
                 You must overcome the "Presumption of Immigrant Intent" (Section 214(b)).
                 Money is NOT enough. Ties (Family, Property, Long-term Job) are REQUIRED.
                 
                 DATA BUCKETS TO FILL:
                 [Age/MaritalStatus, Occupation/Tenure, PreviousTravel, TripPurpose, WhoPays, FamilyTies].
                 
                 LOOP LOGIC:
                    - Check if you have all Data Buckets filled.
                    - If MISSING data (especially Age/Status/Travel), ASK about it.
                 
                 TERMINATION LOGIC (WHEN TO STOP):
                 - STOP ONLY IF:
                   A) Score drops below 20 (Clear Rejection / Risk).
                   B) Score rises above 95 (Clear Approval).
                   C) ALL Data Buckets are filled AND you have formed a verdict.
                   D) You have asked at least 5 questions.
                 
                 - DO NOT APPROVE if Turns < 5. KEEP DIGGING.
                 
                 DATA POINTS TO GATHER (Check History):
                 Use this Matrix to determine your next question.
                 
                 CRITICAL RULE: CHECK HISTORY FIRST.
                 - BEFORE asking a question, check if the User has already answered it (even partially).
                 - If User said "Disney", DO NOT ASK "What is your purpose?". ACCEPT IT and ask "Who are you going with?" (Category 4).
                 
                 RESILIENCE & RESUME PROTOCOL: 
                 - The user might say "Hola" or "Hello" if the connection dropped.
                 - IF History shows the User's LAST message was a valid answer (e.g., "40mil", "Profesor"), IGNORE the "Hola".
                 - MARK that data as KNOWN.
                 - SILENTLY acknowledge it and move to the NEXT Data Point.
                 - DO NOT say "Understood". Just ask the next logical question.
                 
                 SCAN: Check history for "Job", "Salary", "Time". If present, do not ask again.
                 PROGRESSION: Move through categories. Do not get stuck.


                 OBJECTIVE: You are a Consul. Your goal is to gather specific DATA POINTS to determine visa eligibility.
                 
                 CORE PRINCIPLE: INTELLIGENT LISTENING
                 - Users answer in many different ways.
                 - If the User's answer implies a data point, MARK IT AS KNOWN.
                 - DO NOT ask for information you already have.
                 - Example: If User says "Voy solo", then "Companion" is KNOWN (None). Do NOT ask "Who are you with?".
                 - Example: If User says "Yo pago", then "Payer" is KNOWN (Self). Do NOT ask "Who pays?".

                 DATA POINTS TO GATHER (Iterate through these logically):

                 1. JOB & TIES (Arraigo Laboral):
                    - Current Occupation
                    - Time in Role
                    - Salary
                    - Specific Duties (if vague)

                 2. TRIP DETAILS:
                    - Purpose (Turismo, Negocios, etc.)
                    - Destination (Specific city/place)
                    - Duration of Stay
                    - Travel Date

                 3. COMPANIONS & FUNDING:
                    - Travel Companions (Who is going?)
                    - Payer (Who is paying? Self or Sponsor?)
                    - Solvency (Cash on hand, Credit cards)

                 4. U.S. TIES:
                    - Family in USA? (Who, Status, Location)

                 5. HOME TIES:
                    - Marital Status
                    - Children (Who do they live with?)

                 6. HISTORY:
                    - Previous Travel?
                    - Previous Visa Denials?

                 INTERACTION STYLE:
                 - Be skeptical but professional.
                 - If answer is suspicious, Drill Down.
                 - If answer is solid, Move to next Data Point.
                 - KEEP IT MOVING. Do not loop.
                 - REGLA DE ORO: ASK ONE QUESTION AT A TIME. DO NOT BOMBARD THE USER.
                 - NEVER ask 2+ questions in one message. Split them up.

                 CATEGORÍA 8: SEGURIDAD (Security)
                 - "¿Tiene intenciones de buscar trabajo en EEUU?" (Confrontation).
                 - "¿Ha tenido problemas con la policía?" (Inadmissibility).

                 TASK:
                 1. ANALYZE INPUT: Check if user Answer Matches "Red Flags" in the Matrix.
                 2. EVALUATE ANSWER: Assign a SCORE DELTA (-10 to +10).
                    - Bad/Vague Answer ("I don't know") = -10 (Red Flag).
                    - Good/Strong Answer ("I have a job at X for 5 years") = +5.
                    - Lie Detected = -20 (Instant Fail).
                 3. SELECT NEXT QUESTION (if Game Continues).
                 4. CHECK TERMINATION:
                    - If Score <= 30 => TERMINATE (DENIED).
                    - If Score >= 90 => TERMINATE (APPROVED).
                    - If Turns >= ${MAX_TURNS} => TERMINATE (Verdict based on Score).
                 5. ADAPT TO LANGUAGE: Reply in User's Language.
                 6. LOOP PREVENTION: If user says "I don't know", ACCEPT IT as a Skeptic, Note the Risk, and PIVOT to next Category.

                 OUTPUT format: JSON.
                 {
                    "reasoning": "Explain step-by-step why you chose this. E.g. 'User said Alone, so Question 4 is answered. Moving to Funding.'",
                    "known_data": { 
                        "job": "detected_value_or_null", 
                        "time_in_role": "detected_value_or_null", 
                        "salary": "detected_value_or_null",
                        "purpose": "detected_value_or_null",
                        "payer": "detected_value_or_null"
                    },
                    "response": "The Consul's verbal response (question) OR Verdict Message.",
                    "feedback": "Optional coaching tip explaining the score change",
                    "score_delta": number,
                    "action": "CONTINUE" | "TERMINATE_APPROVED" | "TERMINATE_DENIED",
                    "current_score": number
                 }
             `;

            // Construct Messages for AI
            // Include DB History + Current Answer
            const effectiveHistory = [...dbHistory];
            if (answer) {
                effectiveHistory.push({ role: "user", content: answer });
            }

            const result = streamObject({
                model: openai('gpt-5-mini'),
                schema: simulatorSchema,
                system: simulatorPromptContent,
                messages: effectiveHistory.map((m: any) => ({ role: m.role, content: m.content })),
                maxTokens: 4000, // Use standard maxTokens, sdk maps it
                onFinish: async ({ object: finalObj }) => {
                    if (!finalObj) return;

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
                        simulator_score: finalObj.current_score || currentScore, // Use AI's calc or fallback
                        simulator_turns: currentTurns + 1
                    }).eq("id", application.id);
                }
            });

            return result.toTextStreamResponse();
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
                        const optionsStr = currentStep.options.map((o: any) => `"${o.label}" (Value: ${o.value})`).join(', ');
                        queryContext += `\nValid Options: [${optionsStr}]`;
                    }

                    // Construct robust context for the AI
                    // We don't rely on placeholders in the DB prompt anymore.
                    // We send the Context/Rules as System, and the actual Data as User.

                    const validationCompletion = await openai.chat.completions.create({
                        model: "gpt-4o-mini",
                        messages: [
                            { role: "system", content: validatorPromptTemplate }, // The Rules/Persona
                            { role: "user", content: `QUESTION CONTEXT:\n${queryContext}\n\nUSER INPUT:\n"${answer}"\n\nValidate and parse this answer.` }
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
                            question: `📊 **Análisis Preliminar**: ${assessment.assessment_message}\n\n${nextStep.question}`
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
                        ? `He interpretado esto como **"${displayVal}"**. ¿Es correcto para el formulario?`
                        : `I interpreted this as **"${displayVal}"**. Is this correct for the form?`,
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
                        ? `He mejorado tu respuesta para que suene más profesional:\n\n**"${polishedText}"**\n\n¿Estás de acuerdo?`
                        : `I polished your answer to sound more professional:\n\n**"${polishedText}"**\n\nDo you agree?`,
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
                            ? `He mejorado tu respuesta: **"${valRes.displayValue}"**. ¿Te parece bien?`
                            : `I improved your answer to: **"${valRes.displayValue}"**. Is this okay?`,
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
