-- Migration: Fix Missing Translations
-- Description: Ensures critical questions have Spanish versions.

UPDATE ai_interview_flow
SET question_es = 'Número de Identificación Fiscal de EE.UU. (US Taxpayer ID). Si nunca ha tenido, escriba "Does Not Apply".'
WHERE field_key = 'ds160_data.personal.us_tax_id';

-- Ensure all other sensitive questions have explicit Spanish
UPDATE ai_interview_flow
SET question_es = '¿Es usted ciudadano o nacional de algún otro país?'
WHERE field_key = 'ds160_data.personal.other_nationality' AND question_es IS NULL;
