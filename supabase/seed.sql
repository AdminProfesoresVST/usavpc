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
