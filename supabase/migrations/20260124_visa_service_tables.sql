-- Migration: 20260124_visa_service_tables.sql
-- Description: Creates tables for Visa Service features (Categories, Restrictions, Fees, Inadmissibility, Social Audit)

-- 1. VISA CATEGORIES
CREATE TYPE visa_type_enum AS ENUM ('immigrant', 'non_immigrant');
CREATE TYPE form_engine_enum AS ENUM ('DS-160', 'DS-260');

CREATE TABLE public.visa_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE, -- e.g. B1/B2, F1
  name TEXT NOT NULL,
  description TEXT,
  visa_type visa_type_enum NOT NULL,
  form_engine form_engine_enum NOT NULL,
  base_fee_usd INTEGER NOT NULL,
  requires_sevis BOOLEAN NOT NULL DEFAULT false,
  requires_petition BOOLEAN NOT NULL DEFAULT false,
  is_fiance_visa BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS: Public Read, Admin Write
ALTER TABLE public.visa_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public Read Categories" ON public.visa_categories FOR SELECT USING (true);
-- (Admin write policies omitted for simplicity, can be added later)

-- 2. COUNTRY RESTRICTIONS
CREATE TYPE restriction_level_enum AS ENUM ('none', 'total_ban', 'partial_restriction', 'immigrant_pause');

CREATE TABLE public.country_restrictions (
  country_code TEXT PRIMARY KEY, -- ISO Code
  country_name TEXT NOT NULL,
  restriction_level restriction_level_enum NOT NULL DEFAULT 'none',
  restricted_categories TEXT[], -- Array of visa codes e.g. ['B1/B2']
  effective_date DATE,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS: Public Read
ALTER TABLE public.country_restrictions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public Read Restrictions" ON public.country_restrictions FOR SELECT USING (true);

-- 3. VISA FEES
CREATE TYPE fee_type_enum AS ENUM ('mrv_base', 'integrity_fee', 'sevis_i901', 'i94_land', 'reciprocity');

CREATE TABLE public.visa_fees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fee_type fee_type_enum NOT NULL,
  amount_usd INTEGER NOT NULL,
  visa_category_code TEXT REFERENCES public.visa_categories(code), -- Nullable implies general fee
  country_code TEXT REFERENCES public.country_restrictions(country_code), -- Nullable
  description TEXT,
  is_refundable BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS: Public Read
ALTER TABLE public.visa_fees ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public Read Fees" ON public.visa_fees FOR SELECT USING (true);

-- 4. INADMISSIBILITY FLAGS
CREATE TYPE inadmissibility_type_enum AS ENUM ('unlawful_presence', 'visa_overstay', 'criminal_record', 'immigration_fraud', 'public_charge', 'health_grounds', 'returning_resident');
CREATE TYPE severity_enum AS ENUM ('critical', 'high', 'medium', 'low');

CREATE TABLE public.inadmissibility_flags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id UUID NOT NULL REFERENCES public.applications(id) ON DELETE CASCADE,
  flag_type inadmissibility_type_enum NOT NULL,
  severity severity_enum NOT NULL,
  detected_from_field TEXT,
  detected_value TEXT,
  suggested_waiver TEXT,
  waiver_notes TEXT,
  user_acknowledged BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS: Owner Access
ALTER TABLE public.inadmissibility_flags ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Owner Access Flags" ON public.inadmissibility_flags
  FOR ALL USING (auth.uid() IN (
    SELECT user_id FROM public.applications WHERE id = inadmissibility_flags.application_id
  ));

-- 5. SOCIAL MEDIA PROFILES
CREATE TYPE social_platform_enum AS ENUM ('linkedin', 'facebook', 'instagram', 'twitter', 'tiktok', 'other');
CREATE TYPE audit_status_enum AS ENUM ('pending', 'matched', 'discrepancy', 'alert');

CREATE TABLE public.social_media_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id UUID NOT NULL REFERENCES public.applications(id) ON DELETE CASCADE,
  platform social_platform_enum NOT NULL,
  profile_url TEXT NOT NULL,
  username TEXT,
  audit_status audit_status_enum NOT NULL DEFAULT 'pending',
  discrepancy_details JSONB, -- Stores the diff report
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS: Owner Access
ALTER TABLE public.social_media_profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Owner Access Social Profiles" ON public.social_media_profiles
  FOR ALL USING (auth.uid() IN (
    SELECT user_id FROM public.applications WHERE id = social_media_profiles.application_id
  ));

-- 6. PREREQUISITES TABLES
CREATE TYPE prerequisite_status_enum AS ENUM ('pending', 'fulfilled', 'failed');

CREATE TABLE public.prerequisites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  visa_category_code TEXT NOT NULL REFERENCES public.visa_categories(code),
  document_type TEXT NOT NULL, -- e.g. 'I-20', 'DS-2019'
  description TEXT,
  is_mandatory BOOLEAN NOT NULL DEFAULT true,
  validation_regex TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS: Public Read
ALTER TABLE public.prerequisites ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public Read Prerequisites" ON public.prerequisites FOR SELECT USING (true);
