-- Migration: DS-160 Questions Table with Multiple Explanation Formats
-- Purpose: Store DS-160 questions with multiple ways to explain each one
-- Date: 2026-01-20

-- Drop old inserts if table already exists (for clean migration)
DROP TABLE IF EXISTS ds160_questions CASCADE;

-- Table for DS-160 questions
CREATE TABLE ds160_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Question metadata
    field_key TEXT NOT NULL UNIQUE,
    section TEXT NOT NULL,
    section_order INT NOT NULL,
    
    -- MULTIPLE WAYS TO ASK THE SAME QUESTION
    question_formal TEXT NOT NULL,    -- "Indique su apellido paterno y materno"
    question_friendly TEXT NOT NULL,  -- "¿Cómo te apellidas?"
    question_simple TEXT NOT NULL,    -- "Escribe tu apellido como aparece en tu pasaporte"
    question_context TEXT NOT NULL,   -- "Esto se compara con tu pasaporte para verificar tu identidad"
    
    -- AI ASSISTANCE
    tips TEXT[] NOT NULL DEFAULT '{}',
    common_mistakes TEXT[] DEFAULT '{}',
    example_good TEXT NOT NULL,
    example_bad TEXT,
    clarification_prompts TEXT[] DEFAULT '{}',
    
    -- VALIDATION
    validation_regex TEXT,
    validation_error TEXT,
    
    -- INPUT TYPE
    input_type TEXT NOT NULL DEFAULT 'text',
    options JSONB,
    
    -- LOGIC
    required BOOLEAN DEFAULT true,
    depends_on TEXT,
    depends_on_value TEXT,
    skip_if_ocr BOOLEAN DEFAULT false,
    
    -- METADATA
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_ds160_section ON ds160_questions(section, section_order);
ALTER TABLE ds160_questions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read" ON ds160_questions FOR SELECT USING (true);

-- =====================================================
-- SEED: ALL DS-160 QUESTIONS WITH MULTIPLE EXPLANATIONS
-- =====================================================

-- PERSONAL (OCR fields - skip if already captured)
INSERT INTO ds160_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, common_mistakes, example_good, example_bad, skip_if_ocr, input_type) VALUES
('surname', 'personal', 1,
 'Indique su apellido paterno y materno como aparece en su pasaporte.',
 '¿Cómo te apellidas? Necesito tu apellido exactamente como está en tu pasaporte.',
 'Escribe tu apellido. Cópialo de tu pasaporte tal cual.',
 'El oficial consular compara esto con tu pasaporte. Si hay diferencia, pueden rechazar tu solicitud.',
 ARRAY['Usa MAYUSCULAS', 'Incluye TODOS tus apellidos', 'Cópialo exactamente del pasaporte'],
 ARRAY['Escribir solo un apellido', 'Usar minúsculas', 'Abreviar apellidos'],
 'GARCÍA LÓPEZ', 'garcia', true, 'text'),

('given_name', 'personal', 2,
 'Indique su nombre(s) de pila como aparece en su pasaporte.',
 '¿Cuál es tu nombre? Todos los nombres que aparezcan en tu pasaporte.',
 'Escribe tu nombre. Si tienes dos nombres, escribe los dos.',
 'Debe coincidir exactamente con tu pasaporte. El sistema verifica automáticamente.',
 ARRAY['Incluye TODOS tus nombres', 'MAYUSCULAS', 'Sin apodos'],
 ARRAY['Escribir apodo', 'Omitir segundo nombre', 'Usar diminutivos'],
 'MARÍA ELENA', 'Mari', true, 'text'),

('birth_date', 'personal', 3,
 'Indique su fecha de nacimiento.',
 '¿Cuándo naciste?',
 '¿Qué día, mes y año naciste?',
 'Se verifica con tu pasaporte y acta de nacimiento.',
 ARRAY['Formato: día/mes/año', 'Verifica en tu pasaporte'],
 ARRAY['Confundir mes y día', 'Error de año'],
 '15/03/1990', '03/15/1990', true, 'date'),

('birth_city', 'personal', 4,
 'Indique la ciudad o localidad donde nació.',
 '¿En qué ciudad naciste?',
 '¿Dónde naciste? Solo la ciudad, no el estado.',
 'Esta información está en tu acta de nacimiento. Ayuda a verificar tu identidad.',
 ARRAY['Solo la ciudad, no el estado', 'Como aparece en acta de nacimiento'],
 ARRAY['Poner el estado en vez de la ciudad', 'Poner el hospital'],
 'Guadalajara', 'Jalisco', false, 'text'),

('nationality', 'personal', 5,
 'Indique su nacionalidad actual.',
 '¿De qué país eres ciudadano?',
 '¿Qué nacionalidad dice tu pasaporte?',
 'Es el país que emitió tu pasaporte. Si tienes doble nacionalidad, usa la del pasaporte con el que viajas.',
 ARRAY['La del pasaporte que usas', 'Si tienes dos, la del pasaporte de viaje'],
 ARRAY['Confundir residencia con nacionalidad'],
 'Mexicana', 'Estados Unidos', true, 'text');

-- CONTACT (No OCR - must ask all)
INSERT INTO ds160_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, common_mistakes, example_good, example_bad, input_type) VALUES
('email', 'contact', 1,
 'Proporcione su dirección de correo electrónico.',
 '¿Cuál es tu email? Uno que revises seguido.',
 'Dame tu correo electrónico.',
 'Aquí te enviarán confirmaciones y recordatorios importantes de tu cita.',
 ARRAY['Usa uno que revises diario', 'Evita correos de trabajo si cambias de empleo'],
 ARRAY['Email con typos', 'Email que no revisas'],
 'maria.garcia@gmail.com', 'mgarcia@empresaquevender.com', 'text'),

('phone', 'contact', 2,
 'Indique su número de teléfono celular con código de país.',
 '¿Cuál es tu celular? Incluye el código de México (+52).',
 'Dame tu número de celular con el +52 adelante.',
 'Pueden llamarte para confirmar cita o si hay cambios. Es muy importante que contestes.',
 ARRAY['Formato: +52 55 1234 5678', 'Número donde SIEMPRE contestes'],
 ARRAY['Olvidar código de país', 'Poner número de casa fijo'],
 '+52 55 1234 5678', '5512345678', 'text'),

('address', 'contact', 3,
 'Proporcione su dirección de residencia actual completa.',
 '¿Dónde vives? Dame tu dirección completa.',
 'Escribe tu dirección: calle, número, colonia.',
 'Esta es tu dirección oficial. Aquí pueden enviarte documentos físicos.',
 ARRAY['Incluye número exterior e interior', 'Incluye colonia', 'Dirección donde realmente vives'],
 ARRAY['Poner dirección de trabajo', 'Dirección incompleta'],
 'Av. Insurgentes Sur 1234, Int. 5B, Col. Del Valle', 'Insurgentes 1234', 'text'),

('city', 'contact', 4,
 'Indique la ciudad donde reside actualmente.',
 '¿En qué ciudad vives?',
 '¿En qué ciudad está tu casa?',
 'Ciudad de residencia actual, no donde naciste.',
 ARRAY['Donde vives AHORA', 'No donde naciste'],
 ARRAY['Poner ciudad de nacimiento'],
 'Ciudad de México', 'Guadalajara (si no vives ahí)', 'text'),

('postal_code', 'contact', 5,
 'Indique su código postal.',
 '¿Cuál es tu código postal?',
 '¿Cuál es el CP de tu casa? Son 5 números.',
 'Ayuda a ubicar tu dirección exacta.',
 ARRAY['5 dígitos en México', 'Puedes buscarlo en Google: "código postal [tu colonia]"'],
 ARRAY['Código incorrecto', 'Código de trabajo'],
 '03100', '0310', 'text');

-- TRAVEL (Critical questions)
INSERT INTO ds160_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, common_mistakes, example_good, example_bad, input_type, options) VALUES
('purpose_of_trip', 'travel', 1,
 'Seleccione el propósito principal de su viaje a Estados Unidos.',
 '¿Para qué quieres ir a Estados Unidos? Sé honesto, no hay respuesta "mala".',
 '¿A qué vas? ¿Vacaciones, trabajo, ver familia?',
 'Esta es LA PREGUNTA MÁS IMPORTANTE. El cónsul verificará que tu respuesta sea consistente con tu perfil.',
 ARRAY['Sé HONESTO - mentir es peor', 'Si vas a vacacionar, di "turismo"', 'Si tienes reuniones de trabajo, eso es "negocios"', 'Visitar familia es válido'],
 ARRAY['Decir "turismo" cuando vas a trabajar', 'Mentir sobre el propósito'],
 'Turismo', 'Voy a buscar trabajo',
 'select', '[{"value":"tourism","label":"Turismo / Vacaciones","explanation":"Pasear, conocer, comprar, visitar lugares"},{"value":"business","label":"Negocios / Reuniones","explanation":"Juntas, conferencias, negociar contratos (NO TRABAJAR)"},{"value":"visit_family","label":"Visitar Familia","explanation":"Ver parientes que viven allá"},{"value":"medical","label":"Tratamiento Médico","explanation":"Consultas, cirugías, tratamientos"}]'::jsonb),

('stay_duration', 'travel', 2,
 'Indique la duración estimada de su estancia en días.',
 '¿Cuántos días piensas quedarte? Sé realista.',
 '¿Cuántos días estarás en Estados Unidos?',
 'El cónsul verifica que sea razonable. Turismo típico: 7-21 días. Puedes quedarte menos pero NO más.',
 ARRAY['Sé realista', 'Turismo normal: 7-15 días', 'Máximo legal: 180 días', 'Puedes quedarte menos que lo declarado'],
 ARRAY['Decir 6 meses sin justificación', 'Tiempo muy corto (1-2 días)'],
 '14 días', '180 días',
 'text', null),

('us_address', 'travel', 3,
 'Proporcione la dirección donde se hospedará en Estados Unidos.',
 '¿Dónde vas a quedarte? Hotel, Airbnb, casa de familiar...',
 '¿Dónde vas a dormir cuando estés allá?',
 'Puede ser aproximado. Si aún no reservas hotel, pon la ciudad donde planeas quedarte.',
 ARRAY['Puede ser hotel o casa de familiar', 'Si no sabes, pon: "Hotel por reservar en [ciudad]"', 'Si vas con familia, pon su dirección'],
 ARRAY['Dejar vacío', 'Poner dirección inventada'],
 'Hotel por reservar en Miami Beach, FL', 'No sé todavía',
 'text', null),

('previous_us_travel', 'travel', 4,
 '¿Ha viajado a Estados Unidos anteriormente?',
 '¿Has ido a Estados Unidos antes?',
 '¿Ya fuiste alguna vez a Estados Unidos?',
 'Tener viajes previos donde cumpliste las reglas es MUY POSITIVO. Les demuestra que no te quedaste.',
 ARRAY['Viajes anteriores son buenos', 'Si nunca has ido, no es negativo tampoco'],
 ARRAY['Olvidar mencionar viajes anteriores'],
 'Sí, en 2019 por 10 días', 'No',
 'boolean', null);

-- WORK (Critical for ties)
INSERT INTO ds160_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, common_mistakes, example_good, example_bad, input_type) VALUES
('occupation', 'work', 1,
 'Indique su ocupación o profesión actual.',
 '¿A qué te dedicas? ¿En qué trabajas?',
 '¿Cuál es tu trabajo?',
 'Tu empleo demuestra "arraigo" - que tienes razones para regresar. Es muy importante.',
 ARRAY['Sé específico: "Contador Público" mejor que "Empleado"', 'Si eres estudiante, pon "Estudiante de [carrera]"', 'Si no trabajas, explica por qué'],
 ARRAY['Ser muy vago: "empleado"', 'No mencionar profesión'],
 'Ingeniero de Software', 'Empleado',
 'text'),

('employer_name', 'work', 2,
 'Indique el nombre de su empleador actual.',
 '¿Para qué empresa o persona trabajas?',
 '¿Cómo se llama donde trabajas?',
 'Tener empleo estable demuestra que regresarás. Pueden verificar llamando a la empresa.',
 ARRAY['Nombre oficial de la empresa', 'Si eres freelance: "Trabajo Independiente"', 'Si tienes negocio propio: nombre del negocio'],
 ARRAY['Decir "Desempleado" sin explicar', 'Nombre incompleto'],
 'Tecnologías ABC S.A. de C.V.', 'Mi trabajo',
 'text'),

('monthly_salary', 'work', 3,
 'Indique su ingreso mensual aproximado.',
 '¿Cuánto ganas al mes? Aproximadamente está bien.',
 '¿Cuánto dinero ganas cada mes?',
 'Esto demuestra que puedes pagar tu viaje y NO necesitas trabajar ilegalmente en EE.UU.',
 ARRAY['Puedes dar un rango', 'Incluye bonos regulares', 'NO MIENTAS - pueden pedir comprobantes'],
 ARRAY['Exagerar mucho', 'Decir que no ganas nada'],
 '$35,000 - $45,000 MXN mensuales', '$200,000 MXN',
 'text'),

('years_employed', 'work', 4,
 'Indique cuánto tiempo lleva en su empleo actual.',
 '¿Cuánto tiempo llevas en ese trabajo?',
 '¿Desde cuándo trabajas ahí?',
 'La estabilidad laboral es muy positiva. Mientras más tiempo, mejor.',
 ARRAY['Tiempo exacto o aproximado', 'Si llevas poco, menciona duración de empleos anteriores'],
 ARRAY['Mentir sobre antigüedad'],
 '3 años 2 meses', '1 semana',
 'text');

-- FAMILY (Ties to home country)
INSERT INTO ds160_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, common_mistakes, example_good, example_bad, input_type, options, depends_on, depends_on_value) VALUES
('marital_status', 'family', 1,
 'Seleccione su estado civil actual.',
 '¿Eres soltero, casado, divorciado...?',
 '¿Estás casado o soltero?',
 'Tu familia es un "lazo" que te une a tu país. Esposo/a e hijos son razones fuertes para regresar.',
 ARRAY['Responde tu estado ACTUAL', 'Unión libre = "Other/Common Law Marriage"'],
 ARRAY['Mentir sobre estado civil'],
 'Casado/a', 'Es complicado',
 'select', '[{"value":"single","label":"Soltero/a"},{"value":"married","label":"Casado/a"},{"value":"divorced","label":"Divorciado/a"},{"value":"widowed","label":"Viudo/a"},{"value":"common_law","label":"Unión Libre"}]'::jsonb, null, null),

('spouse_name', 'family', 2,
 'Indique el nombre completo de su cónyuge.',
 '¿Cómo se llama tu esposo/a?',
 '¿Cuál es el nombre de tu esposo/a?',
 'Si estás casado, el cónsul quiere saber que tienes familia esperándote.',
 ARRAY['Nombre completo como en identificación', 'Incluye todos los apellidos'],
 ARRAY['Solo poner primer nombre'],
 'Juan Carlos Pérez Rodríguez', 'Juan',
 'text', null, 'marital_status', 'married'),

('relatives_in_us', 'family', 3,
 '¿Tiene familiares directos residiendo en Estados Unidos?',
 '¿Tienes familia en Estados Unidos? Padres, hermanos, hijos...',
 '¿Tienes parientes viviendo en Estados Unidos?',
 'Tener familia allá NO es malo, pero el cónsul querrá ver que tienes más razones aquí que allá.',
 ARRAY['Sé honesto', 'Tener familia allá no te descalifica', 'Pero debes demostrar lazos fuertes AQUÍ'],
 ARRAY['Ocultar familia que tienen - SIEMPRE se enteran'],
 'Sí, un tío que es ciudadano', 'No (cuando sí tienes)',
 'boolean', null, null, null);

-- SECURITY (Sensitive but required)
INSERT INTO ds160_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, common_mistakes, example_good, example_bad, input_type) VALUES
('visa_denied', 'security', 1,
 '¿Le han negado alguna vez una visa de Estados Unidos?',
 '¿Alguna vez te negaron la visa?',
 '¿Te han rechazado una visa antes?',
 'Una negación anterior NO te descalifica automáticamente. Muchos obtienen visa al segundo intento.',
 ARRAY['Sé honesto - ellos tienen registro', 'Si te negaron, explica qué cambió desde entonces', 'Una negación + circunstancias mejoradas = no es problema'],
 ARRAY['Mentir - SIEMPRE tienen registro', 'No explicar qué mejoró'],
 'Sí, en 2020. Desde entonces obtuve empleo estable y compré casa.', 'No (si sí te negaron)',
 'boolean'),

('overstay', 'security', 2,
 '¿Alguna vez permaneció en Estados Unidos más tiempo del autorizado?',
 '¿Alguna vez te quedaste más tiempo del que te permitían?',
 '¿Te pasaste de la fecha cuando tenías que irte de Estados Unidos?',
 'Esto es serio pero no imposible de superar. Honestidad es clave.',
 ARRAY['Ellos tienen registro exacto', 'Si fue hace tiempo y tienes buen caso, puedes obtener visa'],
 ARRAY['Mentir - tienen registro de cada entrada/salida'],
 'Sí, en 2015 por 2 semanas debido a emergencia médica documentada.', 'No (si sí te quedaste)',
 'boolean'),

('criminal_record', 'security', 3,
 '¿Ha sido arrestado, acusado o condenado por algún delito?',
 '¿Has tenido problemas con la ley? ¿Arresto, multas, demandas?',
 '¿La policía te ha detenido alguna vez por algo?',
 'Ciertas infracciones menores no afectan. Delitos graves sí complican. Honestidad es crucial.',
 ARRAY['Infracciones de tránsito menores generalmente no cuentan', 'Si fue algo menor hace años, explícalo', 'NUNCA mientas'],
 ARRAY['Mentir - pueden investigar'],
 'No', 'No (si sí tienes antecedentes)',
 'boolean');

COMMENT ON TABLE ds160_questions IS 'Preguntas DS-160 con múltiples formas de explicarlas. Actualizables sin deploy.';
