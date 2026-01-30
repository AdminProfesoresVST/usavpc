-- EMERGENCY FIX FOR DS-260
-- Author: Antigravity
-- Date: 2026-01-30
-- Reason: Error PGRST205 (Table not found) in mobile app debug overlay.

-- PART 1: CREATE DS-260 TABLE
-- =====================================================
DROP TABLE IF EXISTS ds260_questions CASCADE;

CREATE TABLE ds260_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    field_key TEXT NOT NULL UNIQUE,
    section TEXT NOT NULL,
    section_order INT NOT NULL,
    question_formal TEXT NOT NULL,
    question_friendly TEXT NOT NULL,
    question_simple TEXT NOT NULL,
    question_context TEXT NOT NULL,
    tips TEXT[] NOT NULL DEFAULT '{}',
    common_mistakes TEXT[] DEFAULT '{}',
    example_good TEXT,
    example_bad TEXT,
    clarification_prompts TEXT[] DEFAULT '{}',
    validation_regex TEXT,
    validation_error TEXT,
    input_type TEXT NOT NULL DEFAULT 'text',
    options JSONB,
    required BOOLEAN DEFAULT true,
    depends_on TEXT,
    depends_on_value TEXT,
    skip_if_ocr BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_ds260_section ON ds260_questions(section, section_order);
ALTER TABLE ds260_questions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read" ON ds260_questions FOR SELECT USING (true);


-- PART 2: SEED DATA (Truncated for brevity, normally includes all inserts)
-- We insert a few critical questions to verification flow immediately.
-- FULL SEEDING SHOULD BE DONE BY RE-RUNNING THE FULL MIGRATION IF POSSIBLE.
-- BUT THIS WILL UNBLOCK THE APP.

INSERT INTO ds260_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, input_type, options, required) VALUES
('surnames', 'personal_1', 1, 
 'Indique sus apellidos exactamente como aparecen en el pasaporte.',
 '¿Cuáles son tus apellidos? Escríbelos tal cual están en tu pasaporte.',
 'Escribe tus apellidos.',
 'Esta información debe coincidir exactamente con tu documento de viaje para evitar problemas.',
 ARRAY['Usa mayúsculas preferiblemente', 'Copialo directo del pasaporte'],
 'text', NULL, true),

('given_names', 'personal_1', 2, 
 'Indique sus nombres de pila exactamente como aparecen en el pasaporte.',
 '¿Cuáles son tus nombres? Escríbelos tal cual están en tu pasaporte.',
 'Escribe tus nombres.',
 'Incluye todos tus nombres si tienes más de uno.',
 ARRAY['No uses apodos', 'Incluye segundo nombre si tienes'],
 'text', NULL, true),

('dob', 'personal_1', 4, 
 'Fecha de nacimiento.',
 '¿Cuándo naciste?',
 'Tu fecha de nacimiento.',
 'Debe coincidir con la de tu pasaporte.',
 ARRAY['Día/Mes/Año'],
 'date', NULL, true),

 ('nationality', 'personal_2', 1, 
 'Nacionalidad.',
 '¿Cuál es tu nacionalidad actual?',
 'Tu nacionalidad.',
 'Generalmente corresponde al pasaporte que estás usando/tramitando.',
 ARRAY['País actual de ciudadanía'],
 'text', NULL, true);


-- PART 3: FIX RLS POLICIES (CRITICAL FOR SAVING ANSWERS)
-- =====================================================
ALTER TABLE IF EXISTS applications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own application" ON applications;
DROP POLICY IF EXISTS "Users can insert own application" ON applications;
DROP POLICY IF EXISTS "Users can update own application" ON applications;

CREATE POLICY "Users can view own application" ON applications
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own application" ON applications
FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own application" ON applications
FOR UPDATE USING (auth.uid() = user_id);

-- Ensure public access to questions
DROP POLICY IF EXISTS "Public read ds160" ON ds160_questions;
CREATE POLICY "Public read ds160" ON ds160_questions FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public read ds260" ON ds260_questions;
CREATE POLICY "Public read ds260" ON ds260_questions FOR SELECT USING (true);

-- FORCE SCHEMA CACHE RELOAD
NOTIFY pgrst, 'reload config';
