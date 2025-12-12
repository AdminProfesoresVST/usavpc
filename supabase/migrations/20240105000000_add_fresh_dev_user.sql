-- Migration: Add Fresh Dev User
-- Description: Adds a new dev user (dev_fresh@example.com) with no existing application to allow testing the 'New Application' flow.

-- 1. Create User in auth.users
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
VALUES 
  ('00000000-0000-0000-0000-000000000004', 'dev_fresh@example.com', crypt('password', gen_salt('bf')), now(), '{"provider":"email","providers":["email"]}', '{"name":"Dev Fresh"}', now(), now())
ON CONFLICT (id) DO NOTHING;

-- 2. Create Profile in public.profiles
INSERT INTO public.profiles (id, email, role, first_name, last_name)
VALUES 
  ('00000000-0000-0000-0000-000000000004', 'dev_fresh@example.com', 'client', 'Dev', 'Fresh')
ON CONFLICT (id) DO NOTHING;
