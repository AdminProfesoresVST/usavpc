-- Triage Flow: Reordering for "Visa Probability" Check

-- 1. Shift existing questions down to make space for Triage (Order 1-10 reserved)
UPDATE ai_interview_flow SET order_index = order_index + 100 WHERE order_index > 0;

-- 2. Move Critical Questions to Triage Phase (Order 1-5)
-- Job
UPDATE ai_interview_flow SET order_index = 1, section = 'triage' WHERE field_key = 'primary_occupation';
-- Salary
UPDATE ai_interview_flow SET order_index = 2, section = 'triage' WHERE field_key = 'monthly_income';
-- Marital Status
UPDATE ai_interview_flow SET order_index = 3, section = 'triage' WHERE field_key = 'marital_status';

-- 3. Insert New Triage Questions
-- Children
INSERT INTO ai_interview_flow (field_key, question_es, input_type, section, order_index, options)
VALUES (
    'triage_has_children',
    '¿Tienes hijos? (Solo responde Sí o No por ahora)',
    'boolean',
    'triage',
    4,
    null
);

-- Property (Assets)
INSERT INTO ai_interview_flow (field_key, question_es, input_type, section, order_index, options)
VALUES (
    'triage_property',
    '¿Eres dueño de tu propia casa o departamento?',
    'boolean',
    'triage',
    5,
    null
);

-- 4. Ensure "Start" questions (Location, Security) come AFTER Triage now?
-- Actually, user probably wants Triage FIRST.
-- But we need 'application_location' to know where they are applying?
-- Let's keep 'application_location' at 0 (Config) if it exists, or move it to 6.
-- Let's put Config at 6, 7.

UPDATE ai_interview_flow SET order_index = 6 WHERE field_key = 'application_location';
UPDATE ai_interview_flow SET order_index = 7 WHERE field_key = 'security_question';

-- 5. Clean up gaps (Optional, but good for tidiness)
-- The rest start at 100+. That's fine.
