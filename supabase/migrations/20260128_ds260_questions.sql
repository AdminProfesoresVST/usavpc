-- Migration: DS-260 Questions Table
-- Purpose: Store DS-260 questions with multiple explanation formats (mirroring ds160_questions)
-- Date: 2026-01-28

-- Drop old table if exists (for clean migration)
DROP TABLE IF EXISTS ds260_questions CASCADE;

-- Table for DS-260 questions (Mirrors structure of ds160_questions)
CREATE TABLE ds260_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Question metadata
    field_key TEXT NOT NULL UNIQUE,
    section TEXT NOT NULL,
    section_order INT NOT NULL,
    
    -- MULTIPLE WAYS TO ASK THE SAME QUESTION
    question_formal TEXT NOT NULL,
    question_friendly TEXT NOT NULL,
    question_simple TEXT NOT NULL,
    question_context TEXT NOT NULL,
    
    -- AI ASSISTANCE
    tips TEXT[] NOT NULL DEFAULT '{}',
    common_mistakes TEXT[] DEFAULT '{}',
    example_good TEXT,
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

CREATE INDEX idx_ds260_section ON ds260_questions(section, section_order);
ALTER TABLE ds260_questions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read" ON ds260_questions FOR SELECT USING (true);

-- =====================================================
-- SEED: ALL DS-260 QUESTIONS
-- =====================================================

-- SECCIÓN 1: Personal Information (Parte 1)
INSERT INTO ds260_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, input_type, options, required, skip_if_ocr) VALUES
('surnames', 'personal_1', 1, 
 'Indique sus apellidos exactamente como aparecen en el pasaporte.',
 '¿Cuáles son tus apellidos? Escríbelos tal cual están en tu pasaporte.',
 'Escribe tus apellidos.',
 'Esta información debe coincidir exactamente con tu documento de viaje para evitar problemas.',
 ARRAY['Usa mayúsculas preferiblemente', 'Copialo directo del pasaporte'],
 'text', NULL, true, true),

('given_names', 'personal_1', 2, 
 'Indique sus nombres de pila exactamente como aparecen en el pasaporte.',
 '¿Cuáles son tus nombres? Escríbelos tal cual están en tu pasaporte.',
 'Escribe tus nombres.',
 'Incluye todos tus nombres si tienes más de uno.',
 ARRAY['No uses apodos', 'Incluye segundo nombre si tienes'],
 'text', NULL, true, true),

('full_name_native', 'personal_1', 3, 
 'Nombre completo en alfabeto nativo (si aplica).',
 'Escribe tu nombre en tu alfabeto original si es diferente al nuestro (ej. caracteres chinos, árabes). Si no, selecciona "No aplica".',
 'Tu nombre en tu idioma original si usas otro alfabeto.',
 'Para la mayoría de los solicitantes de habla hispana, esto no aplica.',
 ARRAY['Si usas alfabeto latino, selecciona No Aplica'],
 'text', NULL, false, false),

('dob', 'personal_1', 4, 
 'Fecha de nacimiento.',
 '¿Cuándo naciste?',
 'Tu fecha de nacimiento.',
 'Debe coincidir con la de tu pasaporte.',
 ARRAY['Día/Mes/Año'],
 'date', NULL, true, true),

('city_of_birth', 'personal_1', 5, 
 'Ciudad de nacimiento.',
 '¿En qué ciudad naciste?',
 'Escribe la ciudad donde naciste.',
 'Tal como aparece en tu acta de nacimiento.',
 ARRAY['Solo la ciudad, evita abreviaturas'],
 'text', NULL, true, true),

('state_of_birth', 'personal_1', 6, 
 'Estado o Provincia de nacimiento.',
 '¿En qué estado o provincia naciste?',
 'El estado donde naciste.',
 'Si tu país no tiene estados, puedes indicarlo.',
 ARRAY['Estado completo'],
 'text', NULL, true, true),

('country_of_birth', 'personal_1', 7, 
 'País o Región de nacimiento.',
 '¿En qué país naciste?',
 'El país de tu nacimiento.',
 'Selecciona el país de la lista.',
 ARRAY['Selecciona de la lista oficial'],
 'text', NULL, true, true);

-- SECCIÓN 1: Personal Information (Parte 2)
INSERT INTO ds260_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, input_type, options, required, depends_on, depends_on_value, skip_if_ocr) VALUES
('nationality', 'personal_2', 1, 
 'Nacionalidad.',
 '¿Cuál es tu nacionalidad actual?',
 'Tu nacionalidad.',
 'Generalmente corresponde al pasaporte que estás usando/tramitando.',
 ARRAY['País actual de ciudadanía'],
 'text', NULL, true, NULL, NULL, true),

('other_nationality', 'personal_2', 2, 
 '¿Tiene o ha tenido alguna nacionalidad distinta a la indicada anteriormente?',
 '¿Tienes o tuviste alguna otra nacionalidad antes?',
 '¿Otra nacionalidad?',
 'Incluye nacionalidades previas aunque ya no las tengas.',
 ARRAY['Incluye doble nacionalidad'],
 'boolean', NULL, true, NULL, NULL),

('other_passport', 'personal_2', 3, 
 '¿Tiene pasaporte de esa otra nacionalidad?',
 '¿Tienes pasaporte de esa otra nacionalidad?',
 '¿Pasaporte de la otra nacionalidad?',
 'El consulado necesita saber sobre todos tus documentos de viaje.',
 ARRAY['Solo si tienes el documento físico vigente o no'],
 'boolean', NULL, true, 'other_nationality', 'true'),

('permanent_resident_other', 'personal_2', 4, 
 '¿Es residente permanente de un país/región distinto a su nacimiento o nacionalidad?',
 '¿Vives legalmente como residente permanente en otro país que no sea el tuyo?',
 '¿Residencia en otro país?',
 'No incluye visas de turismo, solo residencia permanente.',
 ARRAY['Solo estatus de residencia permanente'],
 'boolean', NULL, true, NULL, NULL);


-- SECCIÓN 2: Address and Phone Information
INSERT INTO ds260_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, input_type, options, required, depends_on, depends_on_value) VALUES
('present_address', 'contact', 1, 
 'Dirección actual completa (Calle, cludad, provincia, código postal, país).',
 '¿Cuál es tu dirección actual completa?',
 'Tu dirección completa.',
 'Donde vives físicamente en este momento.',
 ARRAY['Incluye calle y número', 'Código postal correcto'],
 'textarea', NULL, true, NULL, NULL),

('residence_start_date', 'contact', 2, 
 'Fecha desde la cual ha residido en esta dirección.',
 '¿Desde cuándo vives ahí?',
 '¿Fecha de inicio en esta casa?',
 'Mes y año aproximado es suficiente si no recuerdas el día exacto.',
 ARRAY['Mes y Año'],
 'date', NULL, true, NULL, NULL),

('lived_elsewhere_since_16', 'contact', 3, 
 '¿Ha vivido en otro lugar distinto a su dirección actual desde los 16 años?',
 '¿Has vivido en otra casa desde que cumpliste 16 años?',
 '¿Otras direcciones desde los 16?',
 'Necesitamos tu historial de direcciones para verificación de seguridad.',
 ARRAY['Incluye años de estudiante si viviste fuera', 'Domicilios anteriores'],
 'boolean', NULL, true, NULL, NULL),

('previous_addresses', 'contact', 4, 
 'Liste todas las direcciones anteriores donde ha vivido desde los 16 años (con fechas Desde y Hasta).',
 'Por favor lista dónde más has vivido, con fechas aproximadas.',
 'Direcciones anteriores.',
 'Es importante para el chequeo de antecedentes.',
 ARRAY['Orden cronológico inverso suele ayudar'],
 'textarea', NULL, true, 'lived_elsewhere_since_16', 'true'),

('primary_phone', 'contact', 5, 
 'Número de teléfono principal.',
 '¿Cuál es tu número de teléfono principal?',
 'Tu teléfono principal.',
 'Donde te puedan contactar más fácilmente.',
 ARRAY['Incluye código de país'],
 'text', NULL, true, NULL, NULL),

('secondary_phone', 'contact', 6, 
 'Número de teléfono secundario.',
 '¿Tienes otro número de teléfono?',
 'Teléfono secundario.',
 'Opcional, pero útil como respaldo.',
 ARRAY['Puede ser casa o celular alterno'],
 'text', NULL, false, NULL, NULL),

('work_phone', 'contact', 7, 
 'Número de teléfono del trabajo.',
 '¿Cuál es el número de tu trabajo?',
 'Teléfono del trabajo.',
 'Si aplica. Si no trabajas, déjalo vacío.',
 ARRAY['Número directo o con extensión'],
 'text', NULL, false, NULL, NULL),

('email', 'contact', 8, 
 'Dirección de correo electrónico.',
 '¿Cuál es tu correo electrónico?',
 'Tu email.',
 'Este será el medio principal de comunicación para actualizaciones.',
 ARRAY['Usa uno que revises frecuentemente', 'Verifica que no haya errores de dedo'],
 'text', NULL, true, NULL, NULL),

('social_media_presence', 'contact', 9, 
 '¿Tiene presencia en redes sociales? (Plataformas usadas en los últimos 5 años).',
 '¿Usas redes sociales? Facebook, Twitter, Instagram, etc.',
 '¿Redes sociales?',
 'Es un requisito de seguridad. Solo necesitamos el nombre de usuario, NUNCA contraseñas.',
 ARRAY['Facebook, Instagram, LinkedIn, etc.', 'Solo nombre de usuario'],
 'boolean', NULL, true, NULL, NULL),

('social_media_list', 'contact', 10, 
 'Liste las plataformas y sus nombres de usuario/identificadores.',
 'Escribe la red social y tu usuario para cada una.',
 'Lista de redes sociales.',
 'Ejemplo: Facebook: juan.perez; Instagram: @juanperez',
 ARRAY['No des contraseñas', 'Solo redes públicas o principales'],
 'textarea', NULL, true, 'social_media_presence', 'true');

-- SECCIÓN 3: Family Information (Parte 1: Parents)
INSERT INTO ds260_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, input_type, options, required, depends_on, depends_on_value) VALUES
('father_name_dob', 'family_parents', 1, 
 'Nombre del padre, fecha y ciudad de nacimiento.',
 '¿Cómo se llama tu papá y cuándo/dónde nació?',
 'Datos de tu padre.',
 'Información filiatoria básica.',
 ARRAY['Si no sabes fecha exacta, por "Desconocido" en la fecha'],
 'textarea', NULL, true, NULL, NULL),

('father_living', 'family_parents', 2, 
 '¿Vive su padre?',
 '¿Tu papá vive?',
 '¿Papá vivo?',
 'Si vive, necesitaremos su dirección más adelante.',
 ARRAY['Sí o No'],
 'boolean', NULL, true, NULL, NULL),

('father_address', 'family_parents', 3, 
 'Dirección del padre.',
 '¿Dónde vive tu papá?',
 'Dirección de tu padre.',
 'Si vive contigo, indica "Misma que la mía".',
 ARRAY['Dirección actual'],
 'textarea', NULL, true, 'father_living', 'true'),

('mother_name_dob', 'family_parents', 4, 
 'Nombre de la madre, fecha y ciudad de nacimiento.',
 '¿Cómo se llama tu mamá y cuándo/dónde nació?',
 'Datos de tu madre.',
 'Información filiatoria básica.',
 ARRAY['Nombre de soltera usualmente'],
 'textarea', NULL, true, NULL, NULL),

('mother_living', 'family_parents', 5, 
 '¿Vive su madre?',
 '¿Tu mamá vive?',
 '¿Mamá viva?',
 'Si vive, necesitaremos su dirección.',
 ARRAY['Sí o No'],
 'boolean', NULL, true, NULL, NULL),

('mother_address', 'family_parents', 6, 
 'Dirección de la madre.',
 '¿Dónde vive tu mamá?',
 'Dirección de tu madre.',
 'Si vive contigo, indica "Misma que la mía".',
 ARRAY['Dirección actual'],
 'textarea', NULL, true, 'mother_living', 'true');


-- SECCIÓN 3: Family Information (Parte 2: Spouse)
INSERT INTO ds260_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, input_type, options, required, depends_on, depends_on_value) VALUES
('spouse_name', 'family_spouse', 1, 
 'Nombre completo de su cónyuge actual, fecha y lugar de nacimiento.',
 '¿Cómo se llama tu esposo/a y sus datos de nacimiento?',
 'Datos de tu esposo/a.',
 'Solo si estás casado legalmente.',
 ARRAY['Nombre completo', 'Fecha y lugar nacimiento'],
 'textarea', NULL, false, NULL, NULL), 

('spouse_occupation', 'family_spouse', 2, 
 'Ocupación del cónyuge.',
 '¿A qué se dedica tu esposo/a?',
 'Trabajo de tu esposo/a.',
 'Ocupación actual.',
 ARRAY['Profesión u oficio'],
 'text', NULL, false, NULL, NULL),

('marriage_date_place', 'family_spouse', 3, 
 'Fecha y lugar de matrimonio.',
 '¿Cuándo y dónde se casaron?',
 'Datos del matrimonio.',
 'Según tu acta de matrimonio.',
 ARRAY['Fecha y Ciudad/País'],
 'textarea', NULL, false, NULL, NULL),

('spouse_immigrating', 'family_spouse', 4, 
 '¿Su cónyuge inmigra con usted?',
 '¿Tu esposo/a viene contigo a vivir a EE. UU.?',
 '¿Ella/él viaja contigo?',
 'Para saber si es una solicitud conjunta o derivada.',
 ARRAY['Si viajan juntos o te alcanza después'],
 'boolean', NULL, false, NULL, NULL),

('previous_spouses', 'family_spouse', 5, 
 '¿Tiene cónyuges anteriores? (Nombre, fecha nacimiento, fecha y motivo de terminación).',
 '¿Tuviste esposos/as antes? Necesitamos detalles.',
 'Ex-esposos/as.',
 'Divorcios o viudez previos.',
 ARRAY['Todos los matrimonios anteriores legalmente terminados'],
 'textarea', NULL, false, NULL, NULL);


-- SECCIÓN 3: Family Information (Parte 3: Children)
INSERT INTO ds260_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, input_type, options, required, depends_on, depends_on_value) VALUES
('has_children', 'family_children', 1, 
 '¿Tiene hijos? (Incluya TODOS los hijos naturales, adoptados o hijastros).',
 '¿Tienes hijos (biológicos, adoptados, hijastros)?',
 '¿Hijos?',
 'Debes incluir a TODOS, incluso si no viven contigo o no viajan.',
 ARRAY['Importante no omitir a nadie'],
 'boolean', NULL, true, NULL, NULL),

('children_details', 'family_children', 2, 
 'Liste para cada hijo: Nombre, fecha de nacimiento, lugar de nacimiento.',
 'Danos el nombre, nacimiento y lugar de nacimiento de cada uno.',
 'Detalles de tus hijos.',
 'Uno por uno.',
 ARRAY['Nombre completo', 'Fecha nacimiento'],
 'textarea', NULL, true, 'has_children', 'true'),

('child_immigrating', 'family_children', 3, 
 '¿Este hijo inmigra con usted?',
 '¿Tus hijos vienen contigo?',
 '¿Inmigran contigo?',
 'Para saber si necesitan visa también.',
 ARRAY['Marca para cada hijo'],
 'boolean', NULL, true, 'has_children', 'true');

-- SECCIÓN 4: Previous U.S. Travel
INSERT INTO ds260_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, input_type, options, required, depends_on, depends_on_value) VALUES
('entry_us', 'travel_history', 1, 
 '¿Ha estado alguna vez en EE. UU.?',
 '¿Ya has estado en Estados Unidos antes?',
 '¿Viajes anteriores a EE. UU.?',
 'Incluye cualquier tipo de visita.',
 ARRAY['Turismo, tránsito, trabajo, etc.'],
 'boolean', NULL, true, NULL, NULL),

('entry_us_dates', 'travel_history', 2, 
 'Indique fechas y duración de las estancias.',
 '¿Cuándo fuiste y por cuánto tiempo?',
 'Fechas de viajes.',
 'Las últimas 5 visitas son las más importantes.',
 ARRAY['Fecha entrada aproximada y días de estancia'],
 'textarea', NULL, true, 'entry_us', 'true'),

('issued_us_visa', 'travel_history', 3, 
 '¿Le han emitido una visa de EE. UU. anteriormente?',
 '¿Tenías visa antes?',
 '¿Visa anterior?',
 'Aunque haya expirado.',
 ARRAY['Cualquier tipo de visa'],
 'boolean', NULL, true, NULL, NULL),

('visa_details', 'travel_history', 4, 
 'Número de visa y clasificación.',
 'Dame el número de esa visa y qué tipo era (ej. B1/B2).',
 'Datos de visa anterior.',
 'Está impreso en la visa (folio rojo usualmente).',
 ARRAY['Número de folio', 'Tipo de visa'],
 'text', NULL, true, 'issued_us_visa', 'true'),

('visa_refused', 'travel_history', 5, 
 '¿Le han negado una visa, la entrada o ha retirado su solicitud en un puerto de entrada?',
 '¿Alguna vez te negaron la visa o la entrada?',
 '¿Visa negada?',
 'Es vital ser honesto aquí. Tienen registros de todo.',
 ARRAY['NUNCA mientas en esto', 'Explica brevemente si sí'],
 'boolean', NULL, true, NULL, NULL),

('refusal_explanation', 'travel_history', 6, 
 'Explique las circunstancias.',
 'Cuéntanos qué pasó.',
 'Explicación.',
 'Sé claro y honesto.',
 ARRAY['Motivo y fecha aproximada'],
 'textarea', NULL, true, 'visa_refused', 'true'),

('alien_registration_number', 'travel_history', 7, 
 'Número de Registro de Extranjero (Alien Registration Number) si aplica.',
 '¿Tienes un "A-Number"?',
 'Número A.',
 'Generalmente si has tenido trámites de residencia o permisos de trabajo previos.',
 ARRAY['Empieza con A seguido de números'],
 'text', NULL, false, NULL, NULL);


-- SECCIÓN 5: Work, Education and Training
INSERT INTO ds260_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, input_type, options, required, depends_on, depends_on_value) VALUES
('primary_occupation', 'work_education', 1, 
 'Ocupación principal (Empresa, dirección, funciones).',
 '¿En qué trabajas actualmente? Empresa, dirección y qué haces.',
 'Ocupación actual.',
 'Tu fuente de ingresos principal.',
 ARRAY['Sé detallado en tus funciones'],
 'textarea', NULL, true, NULL, NULL),

('previous_employed', 'work_education', 2, 
 '¿Ha tenido empleos anteriores en los últimos 10 años?',
 '¿Trabajaste en otros lugares en los últimos 10 años?',
 '¿Empleos anteriores?',
 'Historial laboral reciente.',
 ARRAY['Solo últimos 10 años'],
 'boolean', NULL, true, NULL, NULL),

('previous_employment_list', 'work_education', 3, 
 'Liste sus empleos anteriores con fechas.',
 'Danos nombre de empresa y fechas de esos trabajos.',
 'Lista de empleos.',
 'Ayuda a verificar antecedentes.',
 ARRAY['Nombre, Puesto, Fechas'],
 'textarea', NULL, true, 'previous_employed', 'true'),

('attended_secondary', 'work_education', 4, 
 '¿Ha asistido a instituciones educativas a nivel secundario o superior?',
 '¿Fuiste a la secundaria, prepa o universidad?',
 '¿Estudios?',
 'Historial académico.',
 ARRAY['Secundaria en adelante'],
 'boolean', NULL, true, NULL, NULL),

('education_list', 'work_education', 5, 
 'Datos de institución, dirección, título y fechas.',
 'Nombre de la escuela, qué estudiaste y fechas.',
 'Lista de escuelas.',
 'Incluye todo nivel superior a primaria.',
 ARRAY['Nombre escuela, Título, Años'],
 'textarea', NULL, true, 'attended_secondary', 'true'),

('traveled_countries', 'work_education', 6, 
 '¿Ha viajado a otros países/regiones en los últimos 5 años?',
 '¿Has visitado otros países en los últimos 5 años?',
 '¿Viajes internacionales?',
 'Historial de viajes.',
 ARRAY['Lista los países'],
 'textarea', NULL, true, NULL, NULL),

('military_service', 'work_education', 7, 
 '¿Ha servido en el ejército?',
 '¿Estuviste en el ejército?',
 '¿Servicio militar?',
 'Incluye servicio obligatorio o voluntario.',
 ARRAY['Rama, rango, fechas'],
 'boolean', NULL, true, NULL, NULL),

('military_details', 'work_education', 8, 
 'Rama, fechas, rango y especialidad.',
 'Detalles de tu servicio militar.',
 'Detalles militares.',
 'Información específica de tu servicio.',
 ARRAY['Rama, Rango, Fechas, Especialidad'],
 'textarea', NULL, true, 'military_service', 'true');

-- SECCIÓN 6: Security and Background (Parte 1: Health)
INSERT INTO ds260_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, input_type, options, required, depends_on, depends_on_value) VALUES
('disease', 'security_health', 1, 
 '¿Tiene alguna enfermedad transmisible de importancia para la salud pública?',
 '¿Tienes alguna enfermedad contagiosa grave (ej. tuberculosis)?',
 '¿Enfermedades contagiosas?',
 'Enfermedades que requieren cuarentena o riesgo público.',
 ARRAY['Tuberculosis, Sífilis, etc.'],
 'boolean', NULL, true, NULL, NULL),

('vaccinations', 'security_health', 2, 
 '¿Tiene documentación de vacunas de acuerdo con leyes de EE. UU.?',
 '¿Tienes tus vacunas al día para EE. UU.?',
 '¿Vacunas?',
 'Requerimiento médico para inmigrantes.',
 ARRAY['Cartilla de vacunación'],
 'boolean', NULL, true, NULL, NULL),

('mental_disorder', 'security_health', 3, 
 '¿Tiene algún trastorno físico o mental que represente amenaza?',
 '¿Tienes algún trastorno que pueda ser peligroso para ti o para otros?',
 '¿Trastornos peligrosos?',
 'Comportamiento dañino asociado.',
 ARRAY['Solo si representa amenaza actual o pasada'],
 'boolean', NULL, true, NULL, NULL),

('drug_addict', 'security_health', 4, 
 '¿Es usted drogadicto o adicto a alguna sustancia?',
 '¿Eres adicto a las drogas?',
 '¿Adicciones?',
 'Abuso de sustancias controladas.',
 ARRAY['Historial médico de adicción'],
 'boolean', NULL, true, NULL, NULL);


-- SECCIÓN 6: Security and Background (Parte 2: Criminal)
INSERT INTO ds260_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, input_type, options, required, depends_on, depends_on_value) VALUES
('arrested_convicted', 'security_criminal', 1, 
 '¿Alguna vez ha sido arrestado o condenado por algún delito, aunque haya sido perdonado?',
 '¿Alguna vez te han arrestado o condenado por un crimen?',
 '¿Antecedentes criminales?',
 'Incluso si los cargos fueron retirados o hubo perdón.',
 ARRAY['Honestidad total requerida'],
 'boolean', NULL, true, NULL, NULL),

('controlled_substances', 'security_criminal', 2, 
 '¿Alguna vez ha violado alguna ley sobre sustancias controladas?',
 '¿Has tenido problemas legales por drogas?',
 '¿Delitos de drogas?',
 'Posesión, tráfico, etc.',
 ARRAY['Cualquier sustancia ilegal'],
 'boolean', NULL, true, NULL, NULL),

('prostitution', 'security_criminal', 3, 
 '¿Viene a EE. UU. para ejercer la prostitución o vicio comercial ilegal?',
 '¿Vienes a involucrarte en prostitución o actividades ilegales?',
 '¿Prostitución?',
 'Incluye antecedentes también.',
 ARRAY['Actividades ilegales'],
 'boolean', NULL, true, NULL, NULL),

('money_laundering', 'security_criminal', 4, 
 '¿Alguna vez ha estado involucrado en lavado de dinero?',
 '¿Has participado en lavado de dinero?',
 '¿Lavado de dinero?',
 'Blanqueo de capitales.',
 ARRAY['Actividad financiera ilícita'],
 'boolean', NULL, true, NULL, NULL),

('human_trafficking', 'security_criminal', 5, 
 '¿Ha cometido o conspirado para cometer trata de personas?',
 '¿Trata de personas?',
 '¿Tráfico humano?',
 'Delito grave.',
 ARRAY['Involucramiento en tráfico humano'],
 'boolean', NULL, true, NULL, NULL);


-- SECCIÓN 6: Security and Background (Parte 3: Security)
INSERT INTO ds260_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, input_type, options, required, depends_on, depends_on_value) VALUES
('espionage_terror', 'security_security', 1, 
 '¿Busca ingresar para espiar, sabotear, violar leyes de exportación o actividades terroristas?',
 '¿Vienes a espiar, sabotear o hacer actos terroristas?',
 '¿Espionaje/Terrorismo?',
 'Seguridad nacional.',
 ARRAY['Actividades contra seguridad de EE. UU.'],
 'boolean', NULL, true, NULL, NULL),

('terrorist_support', 'security_security', 2, 
 '¿Ha prestado apoyo financiero a grupos terroristas?',
 '¿Has dado dinero a terroristas?',
 '¿Financiar terrorismo?',
 'Apoyo material.',
 ARRAY['Donaciones o ayuda a grupos designados'],
 'boolean', NULL, true, NULL, NULL),

('terrorist_member', 'security_security', 3, 
 '¿Es miembro o representante de una organización terrorista?',
 '¿Eres parte de un grupo terrorista?',
 '¿Miembro terrorista?',
 'Afiliación actual o pasada.',
 ARRAY['Membresía en grupos designados'],
 'boolean', NULL, true, NULL, NULL),

('genocide_torture', 'security_security', 4, 
 '¿Ha participado en genocidio, tortura o ejecuciones extrajudiciales?',
 '¿Has participado en genocidios o torturas?',
 '¿Crímenes de lesa humanidad?',
 'Violaciones graves de derechos humanos.',
 ARRAY['Muy grave'],
 'boolean', NULL, true, NULL, NULL),

('child_soldiers', 'security_security', 5, 
 '¿Ha reclutado niños soldados?',
 '¿Has reclutado niños para la guerra?',
 '¿Niños soldados?',
 'Uso de menores en conflicto armado.',
 ARRAY['Reclutamiento forzado'],
 'boolean', NULL, true, NULL, NULL);


-- SECCIÓN 6: Security and Background (Parte 4: Immigration Violations)
INSERT INTO ds260_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, input_type, options, required, depends_on, depends_on_value) VALUES
('immigration_fraud', 'security_immigration', 1, 
 '¿Alguna vez ha buscado obtener una visa por fraude o mentiras?',
 '¿Has mentido para conseguir una visa antes?',
 '¿Fraude migratorio?',
 'Falsificación de documentos o testimonios.',
 ARRAY['Mentir al oficial consular'],
 'boolean', NULL, true, NULL, NULL),

('deported', 'security_immigration', 2, 
 '¿Ha sido deportado o removido de EE. UU. en los últimos 5 o 20 años?',
 '¿Te han deportado de Estados Unidos?',
 '¿Deportación?',
 'Remoción oficial.',
 ARRAY['Expulsión formal'],
 'boolean', NULL, true, NULL, NULL),

('assist_illegal_entry', 'security_immigration', 3, 
 '¿Ha asistido a alguien a entrar ilegalmente a EE. UU.?',
 '¿Has ayudado a alguien a cruzar ilegalmente?',
 '¿Contrabando de personas?',
 'Coyotaje o ayuda a cruce ilegal.',
 ARRAY['Ayudar a familiares cuenta si fue ilegal'],
 'boolean', NULL, true, NULL, NULL),

('illegal_presence', 'security_immigration', 4, 
 '¿Ha estado presente ilegalmente en EE. UU. por más de 180 días?',
 '¿Estuviste ilegalmente allá más de 6 meses?',
 '¿Presencia ilegal > 180 días?',
 'Genera castigos automáticos de 3 o 10 años.',
 ARRAY['Sobrepasar tiempo de visa'],
 'boolean', NULL, true, NULL, NULL);


-- SECCIÓN 6: Security and Background (Parte 5: Miscellaneous)
INSERT INTO ds260_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, input_type, options, required, depends_on, depends_on_value) VALUES
('ineligible_citizenship', 'security_misc', 1, 
 '¿Es inelegible para la ciudadanía de EE. UU.?',
 '¿Eres inelegible para ser ciudadano?',
 '¿Inelegible ciudadanía?',
 'Por razones legales específicas.',
 ARRAY['Generalmente No'],
 'boolean', NULL, true, NULL, NULL),

('evade_draft', 'security_misc', 2, 
 '¿Ha evadido el servicio militar de EE. UU.?',
 '¿Escapaste del servicio militar de EE. UU.?',
 '¿Evadir reclutamiento?',
 'Solo aplica si eras sujeto a reclutamiento.',
 ARRAY['Draft evasion'],
 'boolean', NULL, true, NULL, NULL),

('polygamy', 'security_misc', 3, 
 '¿Viene a practicar la poligamia?',
 '¿Vienes a tener múltiples esposas/os?',
 '¿Poligamia?',
 'Matrimonio múltiple.',
 ARRAY['Ilegal en EE. UU.'],
 'boolean', NULL, true, NULL, NULL),

('public_charge', 'security_misc', 4, 
 '¿Es probable que se convierta en carga pública?',
 '¿Podrías convertirte en una carga para el gobierno?',
 '¿Carga pública?',
 'Si necesitarás ayuda del gobierno para vivir. Requiere Affidavit of Support (I-864).',
 ARRAY['Revisa formulario I-864'],
 'boolean', NULL, true, NULL, NULL);


-- SECCIÓN 7: Social Security Number
INSERT INTO ds260_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, input_type, options, required, depends_on, depends_on_value) VALUES
('applied_ssn', 'ssn', 1, 
 '¿Ha solicitado un número de Seguro Social antes?',
 '¿Ya pediste número de Seguro Social antes?',
 '¿SSN previo?',
 'Si ya tienes uno, repórtalo.',
 ARRAY['Número existente'],
 'boolean', NULL, true, NULL, NULL),

('want_ssn', 'ssn', 2, 
 '¿Desea que la Administración le emita un número y tarjeta?',
 '¿Quieres que te den un número de seguro social al llegar?',
 '¿Solicitar SSN?',
 'Recomendado para poder trabajar legalmente.',
 ARRAY['Marca SÍ para facilitar trámites'],
 'boolean', NULL, true, NULL, NULL),

('consent_disclosure', 'ssn', 3, 
 'Consentimiento para compartir datos.',
 '¿Autorizas compartir tus datos para emitir la tarjeta?',
 '¿Autorización?',
 'Necesario para que te den el SSN.',
 ARRAY['Debes autorizar para recibirlo'],
 'boolean', NULL, true, 'want_ssn', 'true');

COMMENT ON TABLE ds260_questions IS 'Tabla espejo de ds160_questions para el formulario de inmigración DS-260.';
