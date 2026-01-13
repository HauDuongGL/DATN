-- ============================================
-- Fix posts table - Add missing image columns
-- ============================================

-- Add image_url and image_thumbnail_url to posts table
-- These are needed for quick display in feed and detail pages
ALTER TABLE public.posts ADD COLUMN IF NOT EXISTS image_url text;
ALTER TABLE public.posts ADD COLUMN IF NOT EXISTS image_thumbnail_url text;

-- Also add flower_description and planting_guide if missing (seen in detail page)
ALTER TABLE public.posts ADD COLUMN IF NOT EXISTS flower_description text;
ALTER TABLE public.posts ADD COLUMN IF NOT EXISTS planting_guide text;
ALTER TABLE public.posts ADD COLUMN IF NOT EXISTS location_name text;
ALTER TABLE public.posts ADD COLUMN IF NOT EXISTS latitude numeric;
ALTER TABLE public.posts ADD COLUMN IF NOT EXISTS longitude numeric;

-- Reload schema cache
NOTIFY pgrst, 'reload schema';

DO $$
BEGIN
  RAISE NOTICE 'Đã thêm các cột còn thiếu vào bảng posts!';
END $$;
