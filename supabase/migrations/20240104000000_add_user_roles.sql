-- Create the user_role type
CREATE TYPE user_role AS ENUM ('client', 'agent', 'admin');

-- Add the role column to the profiles table, defaulting to 'client'
ALTER TABLE public.profiles 
ADD COLUMN role user_role NOT NULL DEFAULT 'client';

-- Update RLS policies to handle roles (optional but good practice)
-- Ideally, we'd have policies like:
-- Agents can view all profiles/applications they are assigned to (or all if open system)
-- Admins can view everything.
-- For now, we rely on application logic for routing, but DB level security is safer.

-- Example: Allow admins and agents to read all profiles (adjust as per existing policies)
CREATE POLICY "Admins and Agents can view all profiles"
  ON public.profiles
  FOR SELECT
  USING (
    auth.uid() IN (
      SELECT id FROM public.profiles WHERE role IN ('admin', 'agent')
    )
  );
