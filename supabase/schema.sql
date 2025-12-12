-- BLUEPRINT SCHEMA IMPLEMENTATION

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- TABLA 1: PERFILES DE USUARIO (Datos fijos)
-- TABLA 1: PERFILES DE USUARIO (Data Sync with Auth)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE, -- 1:1 Link with Supabase Auth
    email TEXT, -- Copied from auth.users for easy access
    role TEXT DEFAULT 'client', -- 'client', 'admin', 'agent', 'client_fresh'
    first_name TEXT,
    last_name TEXT,
    phone TEXT,
    visa_score_status TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Profiles Policies
CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles" ON public.profiles
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- TABLA 2: APLICACIONES (El corazón del sistema)
CREATE TABLE IF NOT EXISTS applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id), -- Linking to Supabase Auth Users
    
    -- ESTADO DEL FLUJO (Crucial para el Dashboard)
    status TEXT NOT NULL DEFAULT 'draft', 
    -- Estados posibles: 
    -- 'draft' (llenando), 
    -- 'paid_pending_review' (listo para operador), 
    -- 'in_review_human' (operador trabajando), 
    -- 'submitted_ceac' (enviado oficial), 
    -- 'completed_delivered' (PDF entregado), 
    -- 'on_hold_client_action' (esperando dato del cliente).
    
    -- EL JSON GIGANTE
    ds160_payload JSONB DEFAULT '{}',
    
    -- DATOS OPERATIVOS FINALES
    ceac_confirmation_number TEXT, -- El código de barras AA00...
    ceac_security_question TEXT,
    ceac_security_answer TEXT,
    final_pdf_url TEXT, -- Link al PDF oficial guardado en Storage
    
    -- FLAGS DE SERVICIO
    service_tier TEXT, -- 'strategy_only' ($39) o 'full_service' ($99)
    has_insurance_addon BOOLEAN DEFAULT FALSE,
    
    -- METADATA
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- TABLA 3: COLA DE TRABAJO PARA OPERADORES
CREATE TABLE IF NOT EXISTS admin_task_queue (
    id SERIAL PRIMARY KEY,
    application_id UUID REFERENCES applications(id),
    assigned_to_admin_id UUID REFERENCES auth.users(id), -- Qué empleado lo tomó
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    notes TEXT -- Notas internas del operador
);

-- RLS POLICIES (Basic Security)
ALTER TABLE applications ENABLE ROW LEVEL SECURITY;

-- Users can view/edit their own applications
CREATE POLICY "Users can view own applications" ON applications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own applications" ON applications
    FOR UPDATE USING (auth.uid() = user_id);

-- Admins (Service Role or specific claim) can view all
-- For now, allowing read for authenticated users to simplify dev, 
-- IN PRODUCTION: Restrict to admin role.
CREATE POLICY "Admins can view all applications" ON applications
    FOR ALL USING (auth.role() = 'service_role');

-- TABLA 4: ANALYTICS & INTELLIGENCE
CREATE TABLE IF NOT EXISTS analytics_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id),
    session_id TEXT, -- Stripe Session or Cookie ID
    event_type TEXT NOT NULL, -- 'login', 'page_view', 'checkout_start', 'purchase'
    
    -- GEOLOCATION & DEVICE FINGERPRINT
    ip_address TEXT,
    country TEXT,
    city TEXT,
    user_agent TEXT,
    device_type TEXT, -- 'mobile', 'desktop'
    
    metadata JSONB DEFAULT '{}', -- Extra data (UTMs, etc)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add Metadata column to Applications if not exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'applications' AND column_name = 'client_metadata') THEN
        ALTER TABLE applications ADD COLUMN client_metadata JSONB DEFAULT '{}';
    END IF;
END $$;

-- RLS for Analytics
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can view analytics" ON analytics_events
    FOR SELECT USING (auth.role() = 'service_role');

CREATE POLICY "Server can insert analytics" ON analytics_events
    FOR INSERT WITH CHECK (true); -- Allow inserts from server (authenticated or anon)
