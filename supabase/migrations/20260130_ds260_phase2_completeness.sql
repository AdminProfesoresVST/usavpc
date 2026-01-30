-- Migration: DS-260 Phase 2 Completeness
-- Purpose: Add missing sections (Mailing Address, Petitioner) and questions to match CEAC spec.
-- Date: 2026-01-30

-- =====================================================
-- SECCIÓN 4: Mailing Address (Dirección de Envío)
-- =====================================================
INSERT INTO ds260_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, input_type, required) VALUES
('is_mailing_same', 'address_mailing', 1,
 'Is your Mailing Address the same as your Present Address?',
 '¿Su dirección de correo postal es la misma que la dirección donde vive actualmente?',
 '¿Mismo correo que vivienda?',
 'Si responde NO, deberá darnos una dirección en EE. UU. (generalmente) o donde recibe correspondencia.',
 ARRAY['Si vives fuera de EE. UU., generalmente es NO (para recibir la Green Card)', 'Esta es la dirección donde llegará tu tarjeta'],
 'boolean', true);

INSERT INTO ds260_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, input_type, required, depends_on, depends_on_value) VALUES
('mailing_address_details', 'address_mailing', 2,
 'Dirección de envío en EE. UU. (Nombre persona, Calle, Ciudad, Estado, Zip Code).',
 '¿A dónde quieres que te llegue la correspondencia (Green Card)? Danos la dirección completa.',
 'Dirección de envío.',
 'Debe ser una dirección válida en Estados Unidos.',
 ARRAY['Nombre del residente', 'Calle y Número', 'Ciudad, Estado, Zip'],
 'textarea', true, 'is_mailing_same', 'false');

-- =====================================================
-- SECCIÓN 8: Petitioner (Peticionario)
-- =====================================================
INSERT INTO ds260_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, input_type, required) VALUES
('petitioner_relation', 'petitioner', 1,
 'Relación del Peticionario con usted.',
 '¿Quién te pidió? (¿Quién es tu peticionario?)',
 'Relación con Peticionario.',
 'Ejemplo: Esposo, Padre, Hermano, Empleador.',
 ARRAY['Padre/Madre', 'Cónyuge', 'Hijo/a', 'Empleador'],
 'text', true),

('petitioner_name', 'petitioner', 2,
 'Nombre completo del Peticionario.',
 '¿Cómo se llama tu peticionario?',
 'Nombre Peticionario.',
 'Tal como aparece en la I-130 o I-140.',
 ARRAY['Nombre legal completo'],
 'text', true),

('petitioner_address', 'petitioner', 3,
 'Dirección del Peticionario.',
 '¿Dónde vive tu peticionario?',
 'Dirección Peticionario.',
 'Dirección actual.',
 ARRAY['Calle, Ciudad, Estado, Zip'],
 'textarea', true),

('petitioner_contact', 'petitioner', 4,
 'Teléfono y Correo Electrónico del Peticionario.',
 'Danos el teléfono y email de tu peticionario.',
 'Contacto Peticionario.',
 'Para contactarlo en caso de emergencia o dudas.',
 ARRAY['Teléfono y Email'],
 'textarea', true);

-- =====================================================
-- SECCIÓN 9: Security (Missing Item)
-- =====================================================
INSERT INTO ds260_questions (field_key, section, section_order, question_formal, question_friendly, question_simple, question_context, tips, input_type, required) VALUES
('child_abduction', 'security_misc', 5,
 '¿Alguna vez ha estado involucrado en el secuestro internacional de niños (custodia)?',
 '¿Has tenido problemas custodia internacional o secuestro de niños?',
 '¿Secuestro niños?',
 'Violación de custodia a través de fronteras.',
 ARRAY['Convenio de la Haya'],
 'boolean', true);
