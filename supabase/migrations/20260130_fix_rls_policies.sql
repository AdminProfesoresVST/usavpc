-- Fix RLS Policies for Critical Tables
-- Date: 2026-01-30

-- 1. APPLICATIONS TABLE
ALTER TABLE IF EXISTS applications ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to ensure clean slate (or use IF NOT EXISTS if supported, but DROP is safer for idempotency in dev)
DROP POLICY IF EXISTS "Users can view own application" ON applications;
DROP POLICY IF EXISTS "Users can insert own application" ON applications;
DROP POLICY IF EXISTS "Users can update own application" ON applications;

CREATE POLICY "Users can view own application" ON applications
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own application" ON applications
FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own application" ON applications
FOR UPDATE USING (auth.uid() = user_id);

-- 2. DS-160 QUESTIONS (Ensure Public Read)
ALTER TABLE IF EXISTS ds160_questions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read ds160" ON ds160_questions;
CREATE POLICY "Public read ds160" ON ds160_questions
FOR SELECT USING (true);


-- 3. DS-260 QUESTIONS (Ensure Public Read)
ALTER TABLE IF EXISTS ds260_questions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read ds260" ON ds260_questions;
CREATE POLICY "Public read ds260" ON ds260_questions
FOR SELECT USING (true);
