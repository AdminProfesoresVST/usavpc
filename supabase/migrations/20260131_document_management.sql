-- Document Management System Migration
-- Created: 2026-01-31
-- Purpose: Add document catalog and per-user document tracking with OCR status

-- ============================================================
-- TABLA 1: CATÁLOGO DE TIPOS DE DOCUMENTOS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.document_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code TEXT UNIQUE NOT NULL,                           -- 'PASSPORT', 'PHOTO', 'BIRTH_CERT', etc.
    name_en TEXT NOT NULL,                               -- 'Passport'
    name_es TEXT NOT NULL,                               -- 'Pasaporte'
    description_en TEXT,                                  -- 'Valid passport with 6+ months validity'
    description_es TEXT,
    category TEXT NOT NULL DEFAULT 'identity',           -- 'identity', 'civil', 'financial', 'supporting'
    required_for TEXT[] DEFAULT ARRAY['DS160'],          -- Which forms require this: 'DS160', 'DS260', 'BOTH'
    accepted_mime_types TEXT[] DEFAULT ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf'],
    max_file_size_mb INTEGER DEFAULT 10,
    ocr_extractable BOOLEAN DEFAULT true,                -- Can OCR extract data from this?
    display_order INTEGER DEFAULT 0,
    is_required BOOLEAN DEFAULT true,                    -- Is this mandatory?
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.document_types ENABLE ROW LEVEL SECURITY;

-- Public read access (catalog is public)
CREATE POLICY "Anyone can view document types" 
ON public.document_types FOR SELECT 
USING (is_active = true);

-- ============================================================
-- TABLA 2: DOCUMENTOS POR USUARIO
-- ============================================================
CREATE TABLE IF NOT EXISTS public.user_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    application_id UUID REFERENCES public.applications(id) ON DELETE SET NULL,
    document_type_id UUID NOT NULL REFERENCES public.document_types(id),
    
    -- File Storage
    storage_path TEXT NOT NULL,                          -- Path in Supabase Storage
    original_filename TEXT,
    file_size_bytes INTEGER,
    mime_type TEXT,
    
    -- OCR Processing Status
    ocr_status TEXT NOT NULL DEFAULT 'pending',          -- 'pending', 'processing', 'complete', 'failed', 'not_applicable'
    ocr_result JSONB DEFAULT '{}',                       -- Extracted data from OCR
    ocr_confidence DECIMAL(5,2),                         -- 0.00 to 100.00
    ocr_processed_at TIMESTAMPTZ,
    ocr_error TEXT,
    
    -- Verification (by admin/agent)
    is_verified BOOLEAN DEFAULT false,
    verified_by UUID REFERENCES auth.users(id),
    verified_at TIMESTAMPTZ,
    verification_notes TEXT,
    
    -- Metadata
    uploaded_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Prevent duplicate uploads of same document type per user
    UNIQUE(user_id, document_type_id)
);

-- Enable RLS
ALTER TABLE public.user_documents ENABLE ROW LEVEL SECURITY;

-- Users can view their own documents
CREATE POLICY "Users can view own documents" 
ON public.user_documents FOR SELECT 
TO authenticated
USING (auth.uid() = user_id);

-- Users can insert their own documents
CREATE POLICY "Users can upload own documents" 
ON public.user_documents FOR INSERT 
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Users can update their own documents
CREATE POLICY "Users can update own documents" 
ON public.user_documents FOR UPDATE 
TO authenticated
USING (auth.uid() = user_id);

-- Users can delete their own documents
CREATE POLICY "Users can delete own documents" 
ON public.user_documents FOR DELETE 
TO authenticated
USING (auth.uid() = user_id);

-- Service role has full access (for OCR processing)
CREATE POLICY "Service role full access" 
ON public.user_documents FOR ALL 
TO service_role
USING (true)
WITH CHECK (true);

-- ============================================================
-- STORAGE BUCKET: DOCUMENTS
-- ============================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'documents', 
    'documents', 
    false, 
    10485760,  -- 10MB
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf']
)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for documents bucket
CREATE POLICY "Authenticated users can upload documents"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'documents' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can view own documents"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'documents' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete own documents"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'documents' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Service role documents access"
ON storage.objects FOR ALL
TO service_role
USING (bucket_id = 'documents')
WITH CHECK (bucket_id = 'documents');

-- ============================================================
-- SEED DATA: DOCUMENT TYPES CATALOG
-- ============================================================
INSERT INTO public.document_types (code, name_en, name_es, description_en, description_es, category, required_for, ocr_extractable, is_required, display_order) VALUES

-- Identity Documents
('PASSPORT', 'Passport', 'Pasaporte', 
 'Valid passport with at least 6 months validity beyond intended stay', 
 'Pasaporte válido con al menos 6 meses de vigencia después de la estancia prevista',
 'identity', ARRAY['DS160', 'DS260'], true, true, 1),

('PHOTO', 'Passport Photo', 'Foto de Pasaporte',
 'Recent 2x2 inch photo meeting US visa requirements',
 'Foto reciente de 2x2 pulgadas que cumpla con requisitos de visa de EE.UU.',
 'identity', ARRAY['DS160', 'DS260'], false, true, 2),

('NATIONAL_ID', 'National ID Card', 'Cédula de Identidad',
 'Government-issued national identification card',
 'Cédula de identidad emitida por el gobierno',
 'identity', ARRAY['DS160', 'DS260'], true, false, 3),

-- Civil Documents
('BIRTH_CERT', 'Birth Certificate', 'Acta de Nacimiento',
 'Original or certified copy of birth certificate',
 'Original o copia certificada del acta de nacimiento',
 'civil', ARRAY['DS260'], true, true, 10),

('MARRIAGE_CERT', 'Marriage Certificate', 'Acta de Matrimonio',
 'If married, original or certified copy',
 'Si está casado, original o copia certificada',
 'civil', ARRAY['DS260'], true, false, 11),

('DIVORCE_CERT', 'Divorce Certificate', 'Acta de Divorcio',
 'If previously divorced, decree or certificate',
 'Si estuvo divorciado anteriormente, decreto o certificado',
 'civil', ARRAY['DS260'], false, false, 12),

('DEATH_CERT', 'Death Certificate (Spouse)', 'Acta de Defunción (Cónyuge)',
 'If widowed, death certificate of deceased spouse',
 'Si enviudó, acta de defunción del cónyuge fallecido',
 'civil', ARRAY['DS260'], false, false, 13),

-- Financial Documents
('BANK_STATEMENT', 'Bank Statement', 'Estado de Cuenta Bancario',
 'Recent bank statements (last 3-6 months)',
 'Estados de cuenta bancarios recientes (últimos 3-6 meses)',
 'financial', ARRAY['DS160', 'DS260'], true, false, 20),

('EMPLOYMENT_LETTER', 'Employment Letter', 'Carta de Empleo',
 'Letter from employer confirming position, salary, and dates',
 'Carta del empleador confirmando puesto, salario y fechas',
 'financial', ARRAY['DS160', 'DS260'], true, false, 21),

('TAX_RETURNS', 'Tax Returns', 'Declaraciones de Impuestos',
 'Tax returns for the last 2-3 years',
 'Declaraciones de impuestos de los últimos 2-3 años',
 'financial', ARRAY['DS260'], true, false, 22),

-- Supporting Documents
('I-20', 'Form I-20', 'Formulario I-20',
 'For F-1 student visa applicants',
 'Para solicitantes de visa de estudiante F-1',
 'supporting', ARRAY['DS160'], false, false, 30),

('DS2019', 'Form DS-2019', 'Formulario DS-2019',
 'For J-1 exchange visitor visa applicants',
 'Para solicitantes de visa de visitante de intercambio J-1',
 'supporting', ARRAY['DS160'], false, false, 31),

('I-797', 'Form I-797 (Approval Notice)', 'Formulario I-797 (Aviso de Aprobación)',
 'USCIS approval notice for petition-based visas',
 'Aviso de aprobación de USCIS para visas basadas en petición',
 'supporting', ARRAY['DS160', 'DS260'], true, false, 32),

('POLICE_CERT', 'Police Certificate', 'Certificado de Policía',
 'Police clearance certificate from countries of residence',
 'Certificado de antecedentes policiales de países de residencia',
 'supporting', ARRAY['DS260'], false, true, 33),

('MEDICAL_EXAM', 'Medical Examination', 'Examen Médico',
 'DS-260 required medical examination by approved physician',
 'Examen médico requerido DS-260 por médico aprobado',
 'supporting', ARRAY['DS260'], false, true, 34),

('SPONSOR_I864', 'Affidavit of Support (I-864)', 'Declaración Jurada de Manutención (I-864)',
 'Financial sponsor documentation',
 'Documentación del patrocinador financiero',
 'financial', ARRAY['DS260'], true, true, 35)

ON CONFLICT (code) DO UPDATE SET
    name_en = EXCLUDED.name_en,
    name_es = EXCLUDED.name_es,
    description_en = EXCLUDED.description_en,
    description_es = EXCLUDED.description_es,
    category = EXCLUDED.category,
    required_for = EXCLUDED.required_for,
    ocr_extractable = EXCLUDED.ocr_extractable,
    is_required = EXCLUDED.is_required,
    display_order = EXCLUDED.display_order;

-- ============================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_user_documents_user_id ON public.user_documents(user_id);
CREATE INDEX IF NOT EXISTS idx_user_documents_application_id ON public.user_documents(application_id);
CREATE INDEX IF NOT EXISTS idx_user_documents_ocr_status ON public.user_documents(ocr_status);
CREATE INDEX IF NOT EXISTS idx_document_types_category ON public.document_types(category);
CREATE INDEX IF NOT EXISTS idx_document_types_required_for ON public.document_types USING GIN(required_for);

-- ============================================================
-- FUNCTION: Calculate document progress for a user
-- ============================================================
CREATE OR REPLACE FUNCTION public.get_document_progress(p_user_id UUID, p_form_type TEXT DEFAULT 'DS160')
RETURNS TABLE (
    total_required INTEGER,
    total_uploaded INTEGER,
    total_ocr_complete INTEGER,
    total_verified INTEGER,
    progress_percentage DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(dt.id)::INTEGER AS total_required,
        COUNT(ud.id)::INTEGER AS total_uploaded,
        COUNT(CASE WHEN ud.ocr_status = 'complete' THEN 1 END)::INTEGER AS total_ocr_complete,
        COUNT(CASE WHEN ud.is_verified = true THEN 1 END)::INTEGER AS total_verified,
        CASE 
            WHEN COUNT(dt.id) = 0 THEN 0
            ELSE ROUND((COUNT(ud.id)::DECIMAL / COUNT(dt.id)::DECIMAL) * 100, 2)
        END AS progress_percentage
    FROM public.document_types dt
    LEFT JOIN public.user_documents ud 
        ON ud.document_type_id = dt.id AND ud.user_id = p_user_id
    WHERE dt.is_active = true 
        AND dt.is_required = true
        AND p_form_type = ANY(dt.required_for);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
