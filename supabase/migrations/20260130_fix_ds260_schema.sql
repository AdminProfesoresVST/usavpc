-- FIX DS-260 SCHEMA AND LOGIC
-- Author: Antigravity
-- Date: 2026-01-30

-- 1. ADD MISSING COLUMN 'form_type' TO applications
-- This fixes the PGRST204 error when saving.
ALTER TABLE applications ADD COLUMN IF NOT EXISTS form_type TEXT DEFAULT 'DS-160';

-- 2. UPDATE DS-260 QUESTIONS TO SKIP OCR FIELDS
-- This fixes the "Duplicate Question" issue (asking for Surnames again).
UPDATE ds260_questions 
SET skip_if_ocr = true 
WHERE field_key IN ('surnames', 'given_names', 'dob', 'nationality', 'city_of_birth', 'state_of_birth', 'country_of_birth');

-- 3. FORCE SCHEMA CACHE RELOAD
NOTIFY pgrst, 'reload config';
