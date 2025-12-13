-- Add passport_image_url column to applications table
ALTER TABLE applications ADD COLUMN IF NOT EXISTS passport_image_url TEXT;

-- Create storage bucket for passports
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('passports', 'passports', false, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

-- Enable RLS on storage.objects (usually enabled by default but good to verify)
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to upload their own passport
CREATE POLICY "Authenticated users can upload passport"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'passports' AND auth.uid() = owner);

-- Allow users to read their own passport
CREATE POLICY "Users can view own passport"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'passports' AND auth.uid() = owner);

-- Allow service role (admin/server) full access
CREATE POLICY "Service role full access"
ON storage.objects FOR ALL
TO service_role
USING (bucket_id = 'passports')
WITH CHECK (bucket_id = 'passports');
