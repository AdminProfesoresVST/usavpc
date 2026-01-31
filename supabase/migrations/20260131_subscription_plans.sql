-- ============================================
-- SUBSCRIPTION PLANS TABLE
-- Run this in Supabase SQL Editor
-- ============================================

-- Create table
CREATE TABLE IF NOT EXISTS subscription_plans (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  price_formatted TEXT NOT NULL,
  billing_period TEXT NOT NULL, -- 'monthly' or 'yearly'
  description TEXT,
  features TEXT[] NOT NULL DEFAULT '{}',
  savings_text TEXT, -- e.g. 'Ahorra 50%'
  is_popular BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed initial plans
INSERT INTO subscription_plans (id, title, price, price_formatted, billing_period, description, features, savings_text, is_popular, display_order)
VALUES
  ('monthly', 'Plan Mensual', 9.99, '$9.99/mes', 'monthly', 'Acceso básico al simulador', ARRAY['Simulador IA', 'Tips básicos', 'Acceso estándar'], NULL, FALSE, 1),
  ('yearly', 'Plan Anual', 59.99, '$59.99/año', 'yearly', 'Acceso completo con ahorro', ARRAY['Simulador IA ilimitado', 'Soporte prioritario', 'Sin anuncios'], 'Ahorra 50%', TRUE, 2)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  price = EXCLUDED.price,
  price_formatted = EXCLUDED.price_formatted,
  features = EXCLUDED.features,
  savings_text = EXCLUDED.savings_text,
  is_popular = EXCLUDED.is_popular,
  updated_at = NOW();

-- Enable RLS with public read
ALTER TABLE subscription_plans ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read" ON subscription_plans;
CREATE POLICY "Allow public read" ON subscription_plans FOR SELECT USING (true);
