ALTER TABLE applications ADD COLUMN IF NOT EXISTS simulator_history JSONB DEFAULT '[]'::jsonb;
