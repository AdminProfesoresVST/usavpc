-- Migration: Update DS-160 Master Flow
-- Description: Replaces the simplified interview flow with the Master Transcription provided by the user.
-- Preserves 'triage' and 'config' sections.

-- 1. Clean up old "Simplified" questions (excluding Triage and Config)
DELETE FROM ai_interview_flow 
WHERE section NOT IN ('triage', 'config');

-- 2. Insert Master Transcription Questions

-- SECCIÓN 1: INFORMACIÓN PERSONAL (PARTE 1)
INSERT INTO ai_interview_flow (field_key, question_es, input_type, section, order_index, options) VALUES
('surnames', 'Apellidos (Surnames): Ingrese todos los apellidos exactamente como aparecen en el pasaporte.', 'text', 'personal_1', 101, null),
('given_names', 'Nombres (Given Names): Ingrese todos los nombres exactamente como aparecen en el pasaporte. Si no tiene, ingrese "FNU".', 'text', 'personal_1', 102, null),
('native_name', 'Nombre Completo en Alfabeto Nativo: (Si aplica). Si su idioma nativo no usa el alfabeto romano, escríbalo aquí. Si no, responda "No aplica".', 'text', 'personal_1', 103, null),
('other_names_used', '¿Alguna vez ha utilizado otros nombres? (Alias, apellido de soltera, nombre profesional, religioso).', 'boolean', 'personal_1', 104, null),
('other_names_list', 'Proporcione los otros Apellidos y Nombres utilizados.', 'text', 'personal_1', 105, null), -- Conditional logic handled by AI/Frontend
('telecode_name', '¿Tiene un telecódigo que represente su nombre? (Códigos numéricos para ciertos alfabetos).', 'boolean', 'personal_1', 106, null),
('sex', 'Sexo:', 'select', 'personal_1', 107, '[{"label": "Masculino", "value": "M"}, {"label": "Femenino", "value": "F"}]'),
-- Marital Status is in Triage (Order 3)
('dob', 'Fecha de Nacimiento (Día / Mes / Año):', 'date', 'personal_1', 108, null),
('pob_city', 'Ciudad de Nacimiento:', 'text', 'personal_1', 109, null),
('pob_state', 'Estado/Provincia de Nacimiento (Si no aplica, escriba "No aplica"):', 'text', 'personal_1', 110, null),
('pob_country', 'País/Región de Nacimiento:', 'text', 'personal_1', 111, null);

-- SECCIÓN 2: INFORMACIÓN PERSONAL (PARTE 2)
INSERT INTO ai_interview_flow (field_key, question_es, input_type, section, order_index, options) VALUES
('nationality', 'Nacionalidad (País del pasaporte principal con el que viaja):', 'text', 'personal_2', 201, null),
('other_nationality', '¿Tiene o ha tenido alguna otra nacionalidad distinta a la indicada arriba?', 'boolean', 'personal_2', 202, null),
('other_nationality_details', 'Indique el País/Región y número de pasaporte si aplica.', 'text', 'personal_2', 203, null),
('perm_resident_other', '¿Es residente permanente de un país/región distinto a su nacionalidad de origen?', 'boolean', 'personal_2', 204, null),
('national_id', 'Número de Identificación Nacional (Ej. DNI, Cédula, CURP). Si no tiene, escriba "No aplica".', 'text', 'personal_2', 205, null),
('us_ssn', 'Número de Seguro Social de EE.UU. (US SSN). Si nunca ha tenido, escriba "No aplica".', 'text', 'personal_2', 206, null),
('us_tax_id', 'Número de Identificación Fiscal de EE.UU. (US Taxpayer ID). Si nunca ha tenido, escriba "No aplica".', 'text', 'personal_2', 207, null);

-- SECCIÓN 3: DIRECCIÓN Y TELÉFONO
INSERT INTO ai_interview_flow (field_key, question_es, input_type, section, order_index, options) VALUES
('home_address', 'Dirección Particular Completa (Calle, Número, Ciudad, Estado, CP, País):', 'textarea', 'contact', 301, null),
('mailing_same', '¿Es su dirección de correo (Mailing Address) la misma que su dirección particular?', 'boolean', 'contact', 302, null),
('mailing_address', 'Proporcione la dirección completa de correo donde puede recibir correspondencia física.', 'textarea', 'contact', 303, null),
('phone_primary', 'Número de Teléfono Principal:', 'text', 'contact', 304, null),
('phone_secondary', 'Número de Teléfono Secundario (Opcional):', 'text', 'contact', 305, null),
('phone_work', 'Número de Teléfono del Trabajo (Opcional):', 'text', 'contact', 306, null),
('other_phones', '¿Ha utilizado otros números de teléfono en los últimos 5 años? Si sí, lístelos.', 'text', 'contact', 307, null),
('email_address', 'Dirección de Correo Electrónico (Email Address):', 'email', 'contact', 308, null),
('other_emails', '¿Ha utilizado otras direcciones de correo electrónico en los últimos 5 años? Si sí, lístelas.', 'text', 'contact', 309, null),
('social_media', 'Presencia en Redes Sociales: Liste Plataforma e Identificador de Usuario de los últimos 5 años (Facebook, Instagram, Twitter, LinkedIn, etc.).', 'textarea', 'contact', 310, null);

-- SECCIÓN 4: INFORMACIÓN DEL PASAPORTE
INSERT INTO ai_interview_flow (field_key, question_es, input_type, section, order_index, options) VALUES
('passport_type', 'Tipo de Documento de Viaje:', 'select', 'passport', 401, '[{"label": "Regular", "value": "R"}, {"label": "Oficial", "value": "O"}, {"label": "Diplomático", "value": "D"}]'),
('passport_number', 'Número de Pasaporte:', 'text', 'passport', 402, null),
('passport_book_num', 'Número de Libreta de Pasaporte (Passport Book Number). Si no aplica, escriba "No aplica".', 'text', 'passport', 403, null),
('passport_issuer', 'País/Autoridad que emitió el pasaporte:', 'text', 'passport', 404, null),
('passport_issue_city', 'Ciudad donde se emitió:', 'text', 'passport', 405, null),
('passport_dates', 'Fecha de Emisión y Fecha de Vencimiento (Día/Mes/Año):', 'text', 'passport', 406, null),
('lost_passport', '¿Alguna vez ha perdido o le han robado un pasaporte? Si sí, proporcione detalles.', 'text', 'passport', 407, null);

-- SECCIÓN 5: INFORMACIÓN DEL VIAJE
INSERT INTO ai_interview_flow (field_key, question_es, input_type, section, order_index, options) VALUES
('travel_purpose', 'Propósito del Viaje a EE.UU. (Ej. Turismo, Negocios, Estudio):', 'text', 'travel', 501, null),
('travel_plans', '¿Ha hecho planes de viaje específicos? Si NO, indique fecha estimada de llegada y duración. Si SÍ, indique fechas y vuelos.', 'textarea', 'travel', 502, null),
('us_stay_address', 'Dirección donde se hospedará en EE.UU. (Calle, Ciudad, Estado, CP):', 'textarea', 'travel', 503, null),
('trip_payer', 'Entidad o Persona que Paga el Viaje (Self, Other Person, Company):', 'text', 'travel', 504, null);

-- SECCIÓN 6: COMPAÑEROS DE VIAJE
INSERT INTO ai_interview_flow (field_key, question_es, input_type, section, order_index, options) VALUES
('travel_companions', '¿Hay otras personas viajando con usted? Si sí, indique nombres y relación.', 'textarea', 'travel_companions', 601, null);

-- SECCIÓN 7: INFORMACIÓN DE VIAJES PREVIOS A EE.UU.
INSERT INTO ai_interview_flow (field_key, question_es, input_type, section, order_index, options) VALUES
('previous_us_travel', '¿Ha estado alguna vez en EE.UU.? Si sí, proporcione fechas y duración de los últimos 5 viajes.', 'textarea', 'previous_travel', 701, null),
('us_driver_license', '¿Alguna vez tuvo una licencia de conducir de EE.UU.? Si sí, número y estado.', 'text', 'previous_travel', 702, null),
('previous_us_visa', '¿Ha tenido alguna vez una visa de EE.UU.? Si sí, proporcione fecha de emisión y número de visa anterior.', 'textarea', 'previous_travel', 703, null),
('visa_refusal', '¿Alguna vez le han negado una visa, la entrada a EE.UU. o ha retirado su solicitud? Explique.', 'textarea', 'previous_travel', 704, null),
('immigrant_petition', '¿Alguna vez alguien ha presentado una petición de inmigrante (Residencia) en su nombre?', 'boolean', 'previous_travel', 705, null);

-- SECCIÓN 8: PUNTO DE CONTACTO EN EE.UU.
INSERT INTO ai_interview_flow (field_key, question_es, input_type, section, order_index, options) VALUES
('us_point_of_contact', 'Punto de Contacto en EE.UU. (Nombre de Persona u Organización, Relación, Dirección, Teléfono, Email):', 'textarea', 'us_contact', 801, null);

-- SECCIÓN 9: INFORMACIÓN FAMILIAR (PARIENTES)
INSERT INTO ai_interview_flow (field_key, question_es, input_type, section, order_index, options) VALUES
('father_info', 'Datos del Padre (Apellidos, Nombres, Fecha de Nacimiento, ¿Está en EE.UU.?):', 'textarea', 'family', 901, null),
('mother_info', 'Datos de la Madre (Apellidos, Nombres, Fecha de Nacimiento, ¿Está en EE.UU.?):', 'textarea', 'family', 902, null),
('immediate_relatives', '¿Tiene algún familiar inmediato (Hijo, Hermano, Prometido) en EE.UU.? Si sí, detalles.', 'textarea', 'family', 903, null),
('other_relatives', '¿Tiene algún otro familiar en EE.UU. (Tíos, primos)?', 'boolean', 'family', 904, null);

-- SECCIÓN 10: INFORMACIÓN FAMILIAR (CÓNYUGE)
INSERT INTO ai_interview_flow (field_key, question_es, input_type, section, order_index, options) VALUES
('spouse_info', 'Datos del Cónyuge (Apellidos, Nombres, Fecha Nacimiento, Nacionalidad, Lugar Nacimiento, Dirección):', 'textarea', 'family', 1001, null);

-- SECCIÓN 11: TRABAJO / EDUCACIÓN / CAPACITACIÓN (ACTUAL)
-- Primary Occupation and Income are in Triage (Order 1, 2)
INSERT INTO ai_interview_flow (field_key, question_es, input_type, section, order_index, options) VALUES
('employer_info', 'Nombre del Empleador Actual o Escuela, Dirección completa y Teléfono:', 'textarea', 'work_education', 1101, null),
('job_duties', 'Describa brevemente sus funciones:', 'textarea', 'work_education', 1102, null);

-- SECCIÓN 12: TRABAJO / EDUCACIÓN / CAPACITACIÓN (PREVIO)
INSERT INTO ai_interview_flow (field_key, question_es, input_type, section, order_index, options) VALUES
('previous_employment', '¿Ha estado empleado previamente en los últimos 5 años? Si sí, detalles de cada empleo.', 'textarea', 'work_education', 1201, null),
('education', '¿Ha asistido a alguna institución educativa de nivel secundario o superior? Si sí, detalles.', 'textarea', 'work_education', 1202, null);

-- SECCIÓN 13: INFORMACIÓN ADICIONAL (SEGURIDAD/VARIOS)
INSERT INTO ai_interview_flow (field_key, question_es, input_type, section, order_index, options) VALUES
('additional_questions', 'Responda a lo siguiente: Clan/Tribu, Idiomas, Países visitados (5 años), Organizaciones, Habilidades especializadas (armas/explosivos), Servicio Militar, Grupos insurgentes.', 'textarea', 'security_misc', 1301, null);

-- SECCIÓN 14: SEGURIDAD Y ANTECEDENTES
INSERT INTO ai_interview_flow (field_key, question_es, input_type, section, order_index, options) VALUES
('security_health', 'Salud: ¿Tiene alguna enfermedad transmisible (Tuberculosis) o trastorno mental peligroso? ¿Ha sido adicto a drogas?', 'boolean', 'security', 1401, null),
('security_criminal', 'Criminal: ¿Alguna vez ha sido arrestado, condenado o involucrado en drogas, prostitución, lavado de dinero o trata de personas?', 'boolean', 'security', 1402, null),
('security_security', 'Seguridad: ¿Busca participar en espionaje, terrorismo, genocidio, tortura o violencia política?', 'boolean', 'security', 1403, null),
('security_immigration', 'Inmigración: ¿Alguna vez ha cometido fraude migratorio o ha sido deportado?', 'boolean', 'security', 1404, null),
('security_other', 'Otros: ¿Ha retenido custodia de un niño ciudadano de EE.UU. ilegalmente?', 'boolean', 'security', 1405, null);
