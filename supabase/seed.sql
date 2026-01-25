-- Create Dev Users (Password: password)

-- 1. Dev Applicant
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
VALUES 
  ('00000000-0000-0000-0000-000000000001', 'dev_applicant@example.com', crypt('password', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"name":"Dev Applicant"}', now(), now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.profiles (id, email, role, first_name, last_name)
VALUES 
  ('00000000-0000-0000-0000-000000000001', 'dev_applicant@example.com', 'client', 'Dev', 'Applicant')
ON CONFLICT (id) DO NOTHING;

-- Create Application for Dev Applicant
INSERT INTO public.applications (user_id, ais_account_email, status, service_tier, payment_status, created_at, updated_at)
VALUES 
  ('00000000-0000-0000-0000-000000000001', 'dev_applicant@example.com', 'received', 'diy', 'pending', now(), now())
ON CONFLICT (user_id) DO NOTHING;


-- 2. Dev Admin
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
VALUES 
  ('00000000-0000-0000-0000-000000000002', 'dev_admin@example.com', crypt('password', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"name":"Dev Admin"}', now(), now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.profiles (id, email, role, first_name, last_name)
VALUES 
  ('00000000-0000-0000-0000-000000000002', 'dev_admin@example.com', 'admin', 'Dev', 'Admin')
ON CONFLICT (id) DO NOTHING;


-- 3. Dev Agent
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
VALUES 
  ('00000000-0000-0000-0000-000000000003', 'dev_agent@example.com', crypt('password', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"name":"Dev Agent"}', now(), now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.profiles (id, email, role, first_name, last_name)
VALUES 
  ('00000000-0000-0000-0000-000000000003', 'dev_agent@example.com', 'agent', 'Dev', 'Agent')
ON CONFLICT (id) DO NOTHING;


-- 4. Clean Dev Applicant (No Application)
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
VALUES 
  ('00000000-0000-0000-0000-000000000004', 'dev_fresh@example.com', crypt('password', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"name":"Dev Fresh"}', now(), now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.profiles (id, email, role, first_name, last_name)
VALUES 
  ('00000000-0000-0000-0000-000000000004', 'dev_fresh@example.com', 'client', 'Dev', 'Fresh')
ON CONFLICT (id) DO NOTHING;

-- ==========================================
-- VISA SERVICE DATA (Added 2026-01-24)
-- ==========================================

-- 1. Visa Categories
INSERT INTO public.visa_categories (code, name, description, visa_type, form_engine, base_fee_usd, requires_sevis, requires_petition, is_fiance_visa)
VALUES
  ('B1/B2', 'Visitor Business/Tourism', 'For temporary business or tourism purposes', 'non_immigrant', 'DS-160', 185, false, false, false),
  ('F1', 'Student (Academic)', 'For academic studies in US institutions', 'non_immigrant', 'DS-160', 185, true, false, false),
  ('M1', 'Student (Vocational)', 'For vocational or non-academic studies', 'non_immigrant', 'DS-160', 185, true, false, false),
  ('J1', 'Exchange Visitor', 'For work-and-travel, au pair, or research exchange', 'non_immigrant', 'DS-160', 185, true, false, false),
  ('H1B', 'Specialty Occupation', 'For professionals in specialty occupations', 'non_immigrant', 'DS-160', 205, false, true, false),
  ('L1', 'Intracompany Transferee', 'For transfer of employees within multinational companies', 'non_immigrant', 'DS-160', 205, false, true, false),
  ('O1', 'Extraordinary Ability', 'For individuals with extraordinary ability or achievement', 'non_immigrant', 'DS-160', 205, false, true, false),
  ('P1', 'Athlete/Entertainer', 'For athletes, entertainers, and artists', 'non_immigrant', 'DS-160', 205, false, true, false),
  ('K1', 'Fiancé(e)', 'For fiancé(e) of US citizen', 'non_immigrant', 'DS-160', 265, false, true, true),
  ('E1/E2', 'Treaty Trader/Investor', 'For investors from treaty countries', 'non_immigrant', 'DS-160', 315, false, false, false),
  ('IR1', 'Spouse of US Citizen', 'Immediate relative spouse visa', 'immigrant', 'DS-260', 325, false, true, false),
  ('CR1', 'Spouse (Conditional)', 'Conditional resident spouse visa', 'immigrant', 'DS-260', 325, false, true, false);

-- 2. Country Restrictions (Sample 2026 Data)
INSERT INTO public.country_restrictions (country_code, country_name, restriction_level, restricted_categories, notes)
VALUES
  ('CU', 'Cuba', 'total_ban', NULL, 'State Sponsor of Terrorism designation. Full suspension.'),
  ('IR', 'Iran', 'partial_restriction', ARRAY['F1', 'M1', 'J1'], 'Student visa restrictions for specific technology fields.'),
  ('RU', 'Russia', 'immigrant_pause', NULL, 'Immigrant visa processing paused. Non-immigrant requires interview in 3rd country.'),
  ('VE', 'Venezuela', 'partial_restriction', ARRAY['B1/B2'], 'Reciprocity fee increase and B1/B2 limitations.');

-- 3. Visa Fees
INSERT INTO public.visa_fees (fee_type, amount_usd, visa_category_code, description, is_refundable)
VALUES
  ('integrity_fee', 250, NULL, 'USCIS Asylum Program Fee (Petition based)', false),
  ('sevis_i901', 350, 'F1', 'SEVIS I-901 Fee for Academic Students', false),
  ('sevis_i901', 350, 'M1', 'SEVIS I-901 Fee for Vocational Students', false),
  ('sevis_i901', 220, 'J1', 'SEVIS I-901 Fee for Exchange Visitors', false),
  ('i94_land', 24, NULL, 'I-94 Land Border Crossing Fee', false);

-- 4. Prerequisites
INSERT INTO public.prerequisites (visa_category_code, document_type, description, is_mandatory, validation_regex)
VALUES
  ('F1', 'I-20', 'Certificate of Eligibility for Nonimmigrant Student Status', true, '^N[0-9]{10}$'),
  ('M1', 'I-20', 'Certificate of Eligibility for Nonimmigrant Student Status', true, '^N[0-9]{10}$'),
  ('J1', 'DS-2019', 'Certificate of Eligibility for Exchange Visitor Status', true, '^N[0-9]{10}$'),
  ('H1B', 'I-797', 'Notice of Action (Approval Notice)', true, '^WAC[0-9]{10}$'),
  ('L1', 'I-129S', 'Nonimmigrant Petition Based on Blanket L Petition', true, NULL);
