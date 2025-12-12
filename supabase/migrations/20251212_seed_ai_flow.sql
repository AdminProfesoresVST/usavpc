-- Create tables if they don't exist
CREATE TABLE IF NOT EXISTS public.ai_interview_flow (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_index INTEGER NOT NULL,
    field_key TEXT NOT NULL,
    question_es TEXT NOT NULL,
    question_en TEXT,
    input_type TEXT NOT NULL,
    options JSONB,
    context TEXT,
    required_logic JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.ai_prompts (
    key TEXT PRIMARY KEY,
    prompt TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Enable RLS (and allow read access)
ALTER TABLE public.ai_interview_flow ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_prompts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read ai_interview_flow" ON public.ai_interview_flow FOR SELECT USING (true);
CREATE POLICY "Allow public read ai_prompts" ON public.ai_prompts FOR SELECT USING (true);


-- Seed Prompts (The "Polisher" Logic)
INSERT INTO public.ai_prompts (key, prompt) VALUES
('JOB_TRANSLATOR', 'You are an expert DS-160 Form Filler.
The user will provide their job description in informal terms.
Your task is to TRANSLATE it into a formal US Visa "Primary Occupation" and "Job Title".
Output JSON: { "job_title_translated_en": "string", "primary_occupation_code": "string" }'),

('CONTENT_POLISHER', 'You are a professional editor.
The user will provide a rough answer to a visa question.
Refine it to be clear, professional, concise, and in standard English.
Do NOT change the meaning.
Output JSON: { "polished_text": "string" }'),

('SPOUSE_PARSER', 'Extract spouse details from the input string.
Output JSON: { "given_names": "string", "surnames": "string", "dob": "YYYY-MM-DD" }'),

('RISK_ASSESSMENT', 'Analyze the profile and provide a preliminary risk assessment.
Output JSON: { "assessment_message": "string", "risk_level": "low|medium|high" }')

ON CONFLICT (key) DO UPDATE SET prompt = EXCLUDED.prompt;


-- Seed Interview Flow (The "Idiot Friendly" Questions)
DELETE FROM public.ai_interview_flow; -- Reset flow

INSERT INTO public.ai_interview_flow (order_index, field_key, question_es, question_en, input_type, options, context, required_logic) VALUES
(10, 'ds160_data.personal.marital_status', '¿Cuál es tu estado civil actual?', 'What is your marital status?', 'select', '[{"label":"Soltero/a","value":"S"}, {"label":"Casado/a","value":"M"}, {"label":"Unión Libre","value":"L"}, {"label":"Divorciado/a","value":"D"}, {"label":"Viudo/a","value":"W"}]', NULL, NULL),

(20, 'spouse_details', 'Cuéntame sobre tu pareja: Nombre completo y fecha de nacimiento.', 'Tell me about your spouse: Full name and DOB.', 'text', NULL, 'spouse_parser', '{"field": "ds160_data.personal.marital_status", "operator": "eq", "value": "M"}'),

(30, 'primary_occupation', '¿A qué te dedicas? (Ej: "Soy ingeniero y trabajo en Google" o "Tengo una tienda de ropa")', 'What do you do for work?', 'text', NULL, 'needs_translation', NULL),

(40, 'ds160_data.work_history.current_job.duties', 'Explica qué haces en un día normal de trabajo (Tus responsabilidades principales).', 'Explain your main duties at work.', 'text', NULL, 'polish_content', NULL),

(50, 'monthly_income', '¿Cuál es tu ingreso mensual aproximado en dólares?', 'What is your approximate monthly income in USD?', 'text', NULL, NULL, NULL),

(60, 'ds160_data.travel.purpose_code', '¿Cuál es el motivo principal de tu viaje a EE.UU.?', 'What is the main purpose of your trip?', 'select', '[{"label":"Turismo / Vacaciones","value":"B2"}, {"label":"Negocios / Conferencias","value":"B1"}, {"label":"Tratamiento Médico","value":"B2"}]', NULL, NULL),

(70, 'triage_property', '¿Tienes alguna propiedad a tu nombre? (Casa, terreno, departamento)', 'Do you own any property?', 'boolean', NULL, NULL, NULL);

