-- FIX SIMULATOR PERSISTENCE
-- Run this in Supabase SQL Editor

-- 1. History Persistence (The "Amnesia" Fix)
ALTER TABLE applications ADD COLUMN IF NOT EXISTS simulator_history JSONB DEFAULT '[]'::jsonb;

-- 2. Scoring System
ALTER TABLE applications ADD COLUMN IF NOT EXISTS simulator_score INTEGER DEFAULT 50;
ALTER TABLE applications ADD COLUMN IF NOT EXISTS simulator_turns INTEGER DEFAULT 0;

-- 3. Verify
SELECT id, simulator_score FROM applications LIMIT 5;
