-- Migration: Update DS-160 Master Flow (ENHANCED V2)
-- Description: Replaces the simplified interview flow with the Master Transcription.
-- NOW INCLUDES: Children, Granular Security Questions, and Extended Travel History.

-- 1. Clean up old "Simplified" questions (excluding Triage and Config)
DELETE FROM ai_interview_flow 
WHERE section NOT IN ('triage', 'config');

-- 2. Insert Master Transcription Questions

-- SECCIÓN 1: INFORMACIÓN PERSONAL (PARTE 1)
INSERT INTO ai_interview_flow (field_key, question_es, question_en, input_type, section, order_index, options, required_logic) VALUES
('ds160_data.personal.surnames', 'Apellidos (Surnames): Ingrese todos los apellidos exactamente como aparecen en el pasaporte.', 'Surnames (As in Passport)', 'text', 'personal_1', 101, null, null),
('ds160_data.personal.given_names', 'Nombres (Given Names): Ingrese todos los nombres exactamente como aparecen en el pasaporte. Si no tiene, ingrese "FNU".', 'Given Names (As in Passport)', 'text', 'personal_1', 102, null, null),
('ds160_data.personal.native_name', 'Nombre Completo en Alfabeto Nativo: (Si aplica). Si su idioma nativo no usa el alfabeto romano, escríbalo aquí. Si no, responda "No aplica".', 'Full Name in Native Alphabet', 'text', 'personal_1', 103, null, null),
('ds160_data.personal.other_names_used', '¿Alguna vez ha utilizado otros nombres? (Alias, apellido de soltera, nombre profesional, religioso).', 'Have you ever used other names?', 'boolean', 'personal_1', 104, null, null),
('ds160_data.personal.other_names_list', 'Proporcione los otros Apellidos y Nombres utilizados.', 'List other names used', 'text', 'personal_1', 105, null, '{"field": "ds160_data.personal.other_names_used", "operator": "eq", "value": true}'),
('ds160_data.personal.telecode_name', '¿Tiene un telecódigo que represente su nombre? (Códigos numéricos para ciertos alfabetos).', 'Do you have a telecode?', 'boolean', 'personal_1', 106, null, null),
('ds160_data.personal.sex', 'Sexo:', 'Sex', 'select', 'personal_1', 107, '[{"label": "Masculino", "value": "M"}, {"label": "Femenino", "value": "F"}]', null),
('ds160_data.personal.dob', 'Fecha de Nacimiento:', 'Date of Birth', 'date', 'personal_1', 108, null, null),
('ds160_data.personal.pob_city', 'Ciudad de Nacimiento:', 'City of Birth', 'text', 'personal_1', 109, null, null),
('ds160_data.personal.pob_state', 'Estado/Provincia de Nacimiento (Si no aplica, escriba "No aplica"):', 'State/Province of Birth', 'text', 'personal_1', 110, null, null),
('ds160_data.personal.pob_country', 'País/Región de Nacimiento:', 'Country of Birth', 'text', 'personal_1', 111, null, null);

-- SECCIÓN 2: INFORMACIÓN PERSONAL (PARTE 2)
INSERT INTO ai_interview_flow (field_key, question_es, question_en, input_type, section, order_index, options, required_logic) VALUES
('ds160_data.personal.nationality', 'Nacionalidad (País del pasaporte principal con el que viaja):', 'Nationality', 'text', 'personal_2', 201, null, null),
('ds160_data.personal.other_nationality', '¿Tiene o ha tenido alguna otra nacionalidad distinta a la indicada arriba?', 'Other Nationality?', 'boolean', 'personal_2', 202, null, null),
('ds160_data.personal.other_nationality_list', 'Indique el País/Región y número de pasaporte si aplica.', 'List other nationalities', 'text', 'personal_2', 203, null, '{"field": "ds160_data.personal.other_nationality", "operator": "eq", "value": true}'),
('ds160_data.personal.perm_resident_other', '¿Es residente permanente de un país/región distinto a su nacionalidad de origen?', 'Permanent Resident of other country?', 'boolean', 'personal_2', 204, null, null),
('ds160_data.personal.national_id', 'Número de Identificación Nacional (Ej. DNI, Cédula, CURP). Si no tiene, escriba "No aplica".', 'National ID Number', 'text', 'personal_2', 205, null, null),
('ds160_data.personal.us_ssn', 'Número de Seguro Social de EE.UU. (US SSN). Si nunca ha tenido, escriba "Does Not Apply".', 'US Social Security Number', 'text', 'personal_2', 206, null, null),
('ds160_data.personal.us_tax_id', 'Número de Identificación Fiscal de EE.UU. (US Taxpayer ID). Si nunca ha tenido, escriba "Does Not Apply".', 'US Taxpayer ID', 'text', 'personal_2', 207, null, null);

-- SECCIÓN 3: DIRECCIÓN Y TELÉFONO
INSERT INTO ai_interview_flow (field_key, question_es, question_en, input_type, section, order_index, options, required_logic) VALUES
('ds160_data.contact.home_address', 'Dirección Particular Completa (Calle, Número, Ciudad, Estado, CP, País):', 'Home Address', 'textarea', 'contact', 301, null, null),
('ds160_data.contact.mailing_same', '¿Es su dirección de correo (Mailing Address) la misma que su dirección particular?', 'Is Mailing Address same as Home?', 'boolean', 'contact', 302, null, null),
('ds160_data.contact.mailing_address', 'Proporcione la dirección completa de correo donde puede recibir correspondencia física.', 'Mailing Address', 'textarea', 'contact', 303, null, '{"field": "ds160_data.contact.mailing_same", "operator": "eq", "value": false}'),
('ds160_data.contact.phone_primary', 'Número de Teléfono Principal:', 'Primary Phone Number', 'text', 'contact', 304, null, null),
('ds160_data.contact.phone_secondary', 'Número de Teléfono Secundario (Opcional):', 'Secondary Phone Number', 'text', 'contact', 305, null, null),
('ds160_data.contact.phone_work', 'Número de Teléfono del Trabajo (Opcional):', 'Work Phone Number', 'text', 'contact', 306, null, null),
('ds160_data.contact.email_address', 'Dirección de Correo Electrónico (Email Address):', 'Email Address', 'email', 'contact', 308, null, null);

-- SECCIÓN 4: INFORMACIÓN DEL PASAPORTE
INSERT INTO ai_interview_flow (field_key, question_es, question_en, input_type, section, order_index, options, required_logic) VALUES
('ds160_data.passport.passport_type', 'Tipo de Documento de Viaje:', 'Passport Type', 'select', 'passport', 401, '[{"label": "Regular", "value": "R"}, {"label": "Oficial", "value": "O"}, {"label": "Diplomático", "value": "D"}]', null),
('ds160_data.passport.passport_number', 'Número de Pasaporte:', 'Passport Number', 'text', 'passport', 402, null, null),
('ds160_data.passport.passport_book_num', 'Número de Libreta de Pasaporte (Passport Book Number). Si no aplica, escriba "Does Not Apply".', 'Passport Book Number', 'text', 'passport', 403, null, null),
('ds160_data.passport.passport_issuer', 'País/Autoridad que emitió el pasaporte:', 'Country/Authority of Issuance', 'text', 'passport', 404, null, null),
('ds160_data.passport.passport_issue_city', 'Ciudad donde se emitió:', 'City of Issuance', 'text', 'passport', 405, null, null),
('ds160_data.passport.issue_date', 'Fecha de Emisión:', 'Date of Issuance', 'date', 'passport', 406, null, null),
('ds160_data.passport.expiration_date', 'Fecha de Vencimiento:', 'Expiration Date', 'date', 'passport', 407, null, null),
('ds160_data.passport.lost_passport', '¿Alguna vez ha perdido o le han robado un pasaporte?', 'Have you ever lost a passport?', 'boolean', 'passport', 408, null, null);

-- SECCIÓN 5: INFORMACIÓN DEL VIAJE
INSERT INTO ai_interview_flow (field_key, question_es, question_en, input_type, section, order_index, options, required_logic) VALUES
('ds160_data.travel.purpose_code', 'Propósito Principal del Viaje (Ej: Turismo (B2), Negocios (B1), Estudiante (F1)):', 'Purpose of Trip to US', 'text', 'travel', 501, null, null),
('ds160_data.travel.has_plans', '¿Ha hecho planes de viaje específicos (vuelos comprados, etc.)?', 'Have you made specific travel plans?', 'boolean', 'travel', 502, null, null),
('ds160_data.travel.travel_plans_details', 'Proporcione detalles de su itinerario (Vuelo, fecha Llegada/Salida).', 'Provide itinerary details', 'textarea', 'travel', 503, null, '{"field": "ds160_data.travel.has_plans", "operator": "eq", "value": true}'),
('ds160_data.travel.arrival_date_est', 'Fecha estimada de llegada:', 'Estimated Date of Arrival', 'date', 'travel', 504, null, '{"field": "ds160_data.travel.has_plans", "operator": "eq", "value": false}'),
('ds160_data.travel.stay_length_est', 'Tiempo estimado de estancia (Ej: 2 semanas):', 'Estimated Length of Stay', 'text', 'travel', 505, null, '{"field": "ds160_data.travel.has_plans", "operator": "eq", "value": false}'),
('ds160_data.travel.us_stay_address', 'Dirección donde se hospedará en EE.UU. (Calle, Ciudad, Estado, CP):', 'Address where you will stay in US', 'textarea', 'travel', 506, null, null),
('ds160_data.travel.trip_payer', 'Entidad o Persona que Paga el Viaje (Self, Other Person, Company):', 'Person/Entity paying for trip', 'text', 'travel', 507, null, null);

-- SECCIÓN 6: COMPAÑEROS DE VIAJE
INSERT INTO ai_interview_flow (field_key, question_es, question_en, input_type, section, order_index, options, required_logic) VALUES
('ds160_data.travel.has_companions', '¿Hay otras personas viajando con usted?', 'Are there other persons traveling with you?', 'boolean', 'travel_companions', 601, null, null),
('ds160_data.travel.companions_list', 'Indique nombres completos y relación con usted de sus acompañantes.', 'List names and relationships of companions', 'textarea', 'travel_companions', 602, null, '{"field": "ds160_data.travel.has_companions", "operator": "eq", "value": true}');

-- SECCIÓN 7: INFORMACIÓN DE VIAJES PREVIOS A EE.UU.
INSERT INTO ai_interview_flow (field_key, question_es, question_en, input_type, section, order_index, options, required_logic) VALUES
('ds160_data.travel.previous_us_travel', '¿Ha estado alguna vez en EE.UU.?', 'Have you ever been in the US?', 'boolean', 'previous_travel', 701, null, null),
('ds160_data.travel.previous_us_travel_details', 'Proporcione fechas y duración de sus ultimos 5 viajes a EE.UU.', 'Provide details of previous US visits', 'textarea', 'previous_travel', 702, null, '{"field": "ds160_data.travel.previous_us_travel", "operator": "eq", "value": true}'),
('ds160_data.travel.us_driver_license', '¿Alguna vez tuvo una licencia de conducir de EE.UU.? Si sí, número y estado.', 'Did you ever hold a US Driver License?', 'text', 'previous_travel', 703, null, null),
('ds160_data.travel.previous_visa', '¿Ha tenido alguna vez una visa de EE.UU.?', 'Have you ever been issued a US Visa?', 'boolean', 'previous_travel', 704, null, null),
('ds160_data.travel.visa_cancelled', '¿Alguna vez su visa de EE.UU. ha sido cancelada o revocada?', 'Has your US Visa ever been cancelled/revoked?', 'boolean', 'previous_travel', 705, null, null),
('ds160_data.travel.visa_refusals', '¿Alguna vez le han negado una visa, la entrada a EE.UU. o ha retirado su solicitud?', 'Have you ever been refused a US Visa?', 'boolean', 'previous_travel', 706, null, null),
('ds160_data.travel.visa_refusal_explanation', 'Explique detalladamente los motivos y fechas de la negación.', 'Explain the refusal', 'textarea', 'previous_travel', 707, null, '{"field": "ds160_data.travel.visa_refusals", "operator": "eq", "value": true}'),
('ds160_data.travel.immigrant_petition', '¿Alguna vez alguien ha presentado una petición de inmigrante (Residencia) en su nombre?', 'Has anyone ever filed an immigrant petition for you?', 'boolean', 'previous_travel', 708, null, null);

-- SECCIÓN 8: PUNTO DE CONTACTO EN EE.UU.
INSERT INTO ai_interview_flow (field_key, question_es, question_en, input_type, section, order_index, options, required_logic) VALUES
('ds160_data.us_contact.contact_person', 'Punto de Contacto en EE.UU. Nombre de la Persona (Si no conoce a nadie, escriba "Do Not Know").', 'US Contact Person Name', 'text', 'us_contact', 801, null, null),
('ds160_data.us_contact.organization_name', 'Nombre de la Organización de Contacto (Si aplica):', 'Organization Name', 'text', 'us_contact', 802, null, null),
('ds160_data.us_contact.relationship', 'Relación con usted (Relative, Friend, Business Associate, Employer, School Official):', 'Relationship to you', 'text', 'us_contact', 803, null, null),
('ds160_data.us_contact.address', 'Dirección del Punto de Contacto:', 'Address of US Contact', 'textarea', 'us_contact', 804, null, null),
('ds160_data.us_contact.phone', 'Teléfono del Punto de Contacto:', 'Phone Number of US Contact', 'text', 'us_contact', 805, null, null),
('ds160_data.us_contact.email', 'Email del Punto de Contacto:', 'Email of US Contact', 'text', 'us_contact', 806, null, null);

-- SECCIÓN 9: INFORMACIÓN FAMILIAR (PARIENTES)
INSERT INTO ai_interview_flow (field_key, question_es, question_en, input_type, section, order_index, options, required_logic) VALUES
('ds160_data.family.father_surnames', 'Apellidos del Padre:', 'Father''s Surnames', 'text', 'family', 901, null, null),
('ds160_data.family.father_given_names', 'Nombres del Padre:', 'Father''s Given Names', 'text', 'family', 902, null, null),
('ds160_data.family.father_dob', 'Fecha de Nacimiento del Padre:', 'Father''s DOB', 'date', 'family', 903, null, null),
('ds160_data.family.father_in_us', '¿Está su padre en EE.UU.?', 'Is your father in the US?', 'boolean', 'family', 904, null, null),
('ds160_data.family.mother_surnames', 'Apellidos de la Madre:', 'Mother''s Surnames', 'text', 'family', 905, null, null),
('ds160_data.family.mother_given_names', 'Nombres de la Madre:', 'Mother''s Given Names', 'text', 'family', 906, null, null),
('ds160_data.family.mother_dob', 'Fecha de Nacimiento de la Madre:', 'Mother''s DOB', 'date', 'family', 907, null, null),
('ds160_data.family.mother_in_us', '¿Está su madre en EE.UU.?', 'Is your mother in the US?', 'boolean', 'family', 908, null, null),
('ds160_data.family.immediate_relatives', '¿Tiene algún familiar inmediato (Hijo, Hermano, Prometido) en EE.UU. aparte de padres?', 'Do you have immediate relatives in US?', 'boolean', 'family', 909, null, null),
('ds160_data.family.other_relatives', '¿Tiene algún otro familiar en EE.UU. (Tíos, primos)?', 'Do you have any other relatives in US?', 'boolean', 'family', 910, null, null);

-- SECCIÓN 10: INFORMACIÓN FAMILIAR (CÓNYUGE) - ATOMIC QUESTIONS
INSERT INTO ai_interview_flow (field_key, question_es, question_en, input_type, section, order_index, options, required_logic) VALUES
('ds160_data.personal.spouse.surnames', '¿Cuáles son los apellidos de tu pareja?', 'Spouse''s Surnames', 'text', 'family', 1001, null, '{"field": "ds160_data.personal.marital_status", "operator": "eq", "value": "M"}'),
('ds160_data.personal.spouse.given_names', '¿Cuáles son los nombres de tu pareja?', 'Spouse''s Given Names', 'text', 'family', 1002, null, '{"field": "ds160_data.personal.marital_status", "operator": "eq", "value": "M"}'),
('ds160_data.personal.spouse.dob', '¿Cuál es la fecha de nacimiento de tu pareja?', 'Spouse''s Date of Birth', 'date', 'family', 1003, null, '{"field": "ds160_data.personal.marital_status", "operator": "eq", "value": "M"}'),
('ds160_data.personal.spouse.nationality', 'Nacionalidad de tu pareja:', 'Spouse''s Nationality', 'text', 'family', 1004, null, '{"field": "ds160_data.personal.marital_status", "operator": "eq", "value": "M"}'),
('ds160_data.personal.spouse.pob', 'Ciudad/Lugar de Nacimiento de tu pareja:', 'Spouse''s Birth City', 'text', 'family', 1005, null, '{"field": "ds160_data.personal.marital_status", "operator": "eq", "value": "M"}');

-- SECCIÓN 10.5: CHILDREN (New)
INSERT INTO ai_interview_flow (field_key, question_es, question_en, input_type, section, order_index, options, required_logic) VALUES
('ds160_data.family.has_children', '¿Tiene hijos (biológicos, adoptados o hijastros)?', 'Do you have children?', 'boolean', 'family', 1050, null, null),
('ds160_data.family.children_details', 'Proporcione nombre completo y fecha de nacimiento de cada hijo.', 'List children details', 'textarea', 'family', 1051, null, '{"field": "ds160_data.family.has_children", "operator": "eq", "value": true}');

-- SECCIÓN 11: TRABAJO / EDUCACIÓN / CAPACITACIÓN (ACTUAL)
INSERT INTO ai_interview_flow (field_key, question_es, question_en, input_type, section, order_index, options, required_logic) VALUES
('ds160_data.work_history.current_job.employer_name', 'Nombre del Empleador Actual o Escuela:', 'Attual Employer/School Name', 'text', 'work_education', 1101, null, null),
('ds160_data.work_history.current_job.address', 'Dirección del Empleador/Escuela:', 'Employer Address', 'textarea', 'work_education', 1102, null, null),
('ds160_data.work_history.current_job.phone', 'Teléfono del Empleador/Escuela:', 'Employer Phone', 'text', 'work_education', 1103, null, null),
('ds160_data.work_history.current_job.start_date', 'Fecha de Inicio:', 'Start Date', 'date', 'work_education', 1104, null, null),
('ds160_data.work_history.current_job.duties', 'Describa brevemente sus funciones:', 'Briefly describe your duties', 'textarea', 'work_education', 1105, null, null); 

-- SECCIÓN 12: TRABAJO / EDUCACIÓN / CAPACITACIÓN (PREVIO)
INSERT INTO ai_interview_flow (field_key, question_es, question_en, input_type, section, order_index, options, required_logic) VALUES
('ds160_data.work_history.previous_employment_check', '¿Ha estado empleado previamente en los últimos 5 años?', 'Were you previously employed?', 'boolean', 'work_education', 1201, null, null),
('ds160_data.work_history.previous_jobs', 'Liste sus empleos anteriores (Nombre, Fecha Inicio, Fecha Fin, Título, Supervisor).', 'List previous jobs', 'textarea', 'work_education', 1202, null, '{"field": "ds160_data.work_history.previous_employment_check", "operator": "eq", "value": true}'),
('ds160_data.education.attended_secondary', '¿Ha asistido a alguna institución educativa de nivel secundario o superior?', 'Have you attended any educational institutions?', 'boolean', 'work_education', 1203, null, null),
('ds160_data.education.institutions', 'Liste las instituciones a las que asistió (Nombre, Dirección, Curso, Fechas).', 'List institutions', 'textarea', 'work_education', 1204, null, '{"field": "ds160_data.education.attended_secondary", "operator": "eq", "value": true}');

-- SECCIÓN 13: INFORMACIÓN ADICIONAL (SEGURIDAD/VARIOS)
INSERT INTO ai_interview_flow (field_key, question_es, question_en, input_type, section, order_index, options, required_logic) VALUES
('ds160_data.security_questions.languages', 'Idiomas que habla:', 'Languages Spoken', 'text', 'security_misc', 1301, null, null),
('ds160_data.security_questions.countries_visited', 'Países visitados en los últimos 5 años:', 'Countries Visited', 'text', 'security_misc', 1302, null, null),
('ds160_data.security_questions.charitable_orgs', '¿Pertenece a alguna organización caritativa o profesional?', 'Belong to any organizations?', 'boolean', 'security_misc', 1303, null, null),
('ds160_data.security_questions.specialized_skills', '¿Tiene habilidades especializadas (armas, explosivos, nuclear, biológico)?', 'Specialized Skills?', 'boolean', 'security_misc', 1304, null, null),
('ds160_data.security_questions.military_service', '¿Ha servido en el ejército?', 'Military Service?', 'boolean', 'security_misc', 1305, null, null),
('ds160_data.security_questions.insurgent_group', '¿Ha sido miembro de algún grupo insurgente o de guerrilla?', 'Insurgent Group Member?', 'boolean', 'security_misc', 1306, null, null);

-- SECCIÓN 14: SEGURIDAD Y ANTECEDENTES (GRANULAR)
-- Part 1: Health
INSERT INTO ai_interview_flow (field_key, question_es, question_en, input_type, section, order_index, options, required_logic) VALUES
('ds160_data.security_questions.communicable_disease', '¿Tiene alguna enfermedad contagiosa de importancia para la salud pública (Tuberculosis)?', 'Communicable Disease?', 'boolean', 'security', 1401, null, null),
('ds160_data.security_questions.mental_disorder', '¿Tiene un trastorno mental o físico que represente una amenaza para la seguridad de usted o de otros?', 'Mental Disorder?', 'boolean', 'security', 1402, null, null),
('ds160_data.security_questions.drug_addict', '¿Es o ha sido adicto a las drogas o abusado de ellas?', 'Drug Addict?', 'boolean', 'security', 1403, null, null);

-- Part 2: Criminal
INSERT INTO ai_interview_flow (field_key, question_es, question_en, input_type, section, order_index, options, required_logic) VALUES
('ds160_data.security_questions.arrested', '¿Alguna vez ha sido arrestado o condenado por algún delito o crimen?', 'Arrested or Convicted?', 'boolean', 'security', 1404, null, null),
('ds160_data.security_questions.controlled_substances', '¿Alguna vez ha violado alguna ley relacionada con sustancias controladas?', 'Controlled Substances Violation?', 'boolean', 'security', 1405, null, null),
('ds160_data.security_questions.prostitution', '¿Viene a los EE.UU. para ejercer la prostitución o la ha ejercido en los últimos 10 años?', 'Prostitution?', 'boolean', 'security', 1406, null, null),
('ds160_data.security_questions.money_laundering', '¿Ha estado involucrado en o busca participar en lavado de dinero?', 'Money Laundering?', 'boolean', 'security', 1407, null, null),
('ds160_data.security_questions.human_trafficking', '¿Ha cometido o conspirado para cometer delitos de trata de personas?', 'Human Trafficking?', 'boolean', 'security', 1408, null, null),
('ds160_data.security_questions.human_trafficking_assist', '¿Ha ayudado, instigado o coludido con un traficante de personas severo?', 'Assisted Human Trafficking?', 'boolean', 'security', 1409, null, null),
('ds160_data.security_questions.human_trafficking_benefit', '¿Es usted cónyuge o hijo de alguien que ha cometido trata de personas y se ha beneficiado de ello?', 'Benefited from Trafficking?', 'boolean', 'security', 1410, null, null);

-- Part 3: Security
INSERT INTO ai_interview_flow (field_key, question_es, question_en, input_type, section, order_index, options, required_logic) VALUES
('ds160_data.security_questions.espionage', '¿Busca participar en espionaje, sabotaje o violaciones de control de exportaciones?', 'Espionage/Sabotage?', 'boolean', 'security', 1411, null, null),
('ds160_data.security_questions.terrorist_activity', '¿Busca participar en actividades terroristas o ha participado en ellas?', 'Terrorist Activity?', 'boolean', 'security', 1412, null, null),
('ds160_data.security_questions.terrorist_support', '¿Ha proporcionado apoyo financiero o material a terroristas?', 'Terrorist Support?', 'boolean', 'security', 1413, null, null),
('ds160_data.security_questions.genocide', '¿Ha ordenado, incitado o participado en genocidio?', 'Genocide?', 'boolean', 'security', 1414, null, null),
('ds160_data.security_questions.torture', '¿Ha cometido tortura?', 'Torture?', 'boolean', 'security', 1415, null, null),
('ds160_data.security_questions.political_killings', '¿Ha cometido ejecuciones extrajudiciales o asesinatos políticos?', 'Political Killings?', 'boolean', 'security', 1416, null, null),
('ds160_data.security_questions.child_soldiers', '¿Ha reclutado o utilizado niños soldados?', 'Child Soldiers?', 'boolean', 'security', 1417, null, null),
('ds160_data.security_questions.religious_freedom', '¿Ha sido responsable de violaciones severas de la libertad religiosa?', 'Religious Freedom Violation?', 'boolean', 'security', 1418, null, null);

-- Part 4: Immigration Rules
INSERT INTO ai_interview_flow (field_key, question_es, question_en, input_type, section, order_index, options, required_logic) VALUES
('ds160_data.security_questions.immigration_fraud', '¿Alguna vez ha buscado obtener una visa o entrada a EE.UU. mediante fraude?', 'Immigration Fraud?', 'boolean', 'security', 1419, null, null),
('ds160_data.security_questions.deported', '¿Alguna vez ha sido expulsado o deportado de algún país?', 'Deported?', 'boolean', 'security', 1420, null, null);

-- Part 5: Other
INSERT INTO ai_interview_flow (field_key, question_es, question_en, input_type, section, order_index, options, required_logic) VALUES
('ds160_data.security_questions.child_custody', '¿Ha retenido la custodia de un niño ciudadano de EE.UU. fuera de EE.UU. ilegalmente?', 'Child Custody?', 'boolean', 'security', 1421, null, null),
('ds160_data.security_questions.voting', '¿Ha votado en los Estados Unidos en violación de alguna ley?', 'Illegal Voting?', 'boolean', 'security', 1422, null, null),
('ds160_data.security_questions.renounce_citizenship', '¿Alguna vez ha renunciado a la ciudadanía estadounidense para evitar impuestos?', 'Renounced Citizenship?', 'boolean', 'security', 1423, null, null);
