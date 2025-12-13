-- Migration: Update DS-160 Master Flow (FINAL V3)
-- Description: Adds the final missing granular questions identified in the User's Master Reference.
-- ADDS: Social Media, Clan/Tribe, Group Travel, Deep Previous Visa Details.

-- 1. Insert Social Media (Section 3 - Contact)
-- We insert it after Email (Order 308), so let's use 309.
INSERT INTO ai_interview_flow (field_key, question_es, question_en, input_type, section, order_index, options, required_logic) VALUES
('ds160_data.contact.social_media_check', '¿Tiene presencia en redes sociales (Facebook, Instagram, LinkedIn, etc.) usada en los últimos 5 años?', 'Do you have social media presence?', 'boolean', 'contact', 309, null, null),
('ds160_data.contact.social_media_list', 'Liste la plataforma y su usuario (Handle) para cada una.', 'List Platform and Handle', 'textarea', 'contact', 310, null, '{"field": "ds160_data.contact.social_media_check", "operator": "eq", "value": true}');

-- 2. Insert Group Travel (Section 6 - Travel Companions)
-- Insert after companions check.
INSERT INTO ai_interview_flow (field_key, question_es, question_en, input_type, section, order_index, options, required_logic) VALUES
('ds160_data.travel.is_group_travel', '¿Viaja como parte de un grupo u organización organizado? (Ej. orquesta, tour deportivo)', 'Traveling as part of a group/org?', 'boolean', 'travel_companions', 603, null, null);

-- 3. Insert Deep Previous Visa Details (Section 7 - Previous Travel)
-- Only asked if they had a previous visa (previous_visa = true)
INSERT INTO ai_interview_flow (field_key, question_es, question_en, input_type, section, order_index, options, required_logic) VALUES
('ds160_data.travel.previous_visa_same_type', '¿Está aplicando al mismo tipo de visa que la anterior?', 'Applying for same visa type?', 'boolean', 'previous_travel', 710, null, '{"field": "ds160_data.travel.previous_visa", "operator": "eq", "value": true}'),
('ds160_data.travel.previous_visa_same_country', '¿Está aplicando en el mismo país donde obtuvo la visa anterior?', 'Applying in same country?', 'boolean', 'previous_travel', 711, null, '{"field": "ds160_data.travel.previous_visa", "operator": "eq", "value": true}'),
('ds160_data.travel.previous_visa_fingerprinted', '¿Le han tomado huellas dactilares (10 huellas) anteriormente?', 'Ten-printed?', 'boolean', 'previous_travel', 712, null, '{"field": "ds160_data.travel.previous_visa", "operator": "eq", "value": true}'),
('ds160_data.travel.previous_visa_lost', '¿Su visa ha sido perdida o robada alguna vez?', 'Visa lost or stolen?', 'boolean', 'previous_travel', 713, null, '{"field": "ds160_data.travel.previous_visa", "operator": "eq", "value": true}');

-- 4. Insert Clan/Tribe (Section 13 - Security Misc)
INSERT INTO ai_interview_flow (field_key, question_es, question_en, input_type, section, order_index, options, required_logic) VALUES
('ds160_data.security_questions.clan_tribe', '¿Pertenece a algún clan o tribu?', 'Belong to a clan or tribe?', 'boolean', 'security_misc', 1300, null, null);
