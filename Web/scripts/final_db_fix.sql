-- ============================================
-- FINAL FIX - ENSURE ALL TABLES AND COLUMNS
-- ============================================

-- 1. Đảm bảo bảng posts có đầy đủ các cột cần thiết
ALTER TABLE public.posts ADD COLUMN IF NOT EXISTS image_url text;
ALTER TABLE public.posts ADD COLUMN IF NOT EXISTS image_thumbnail_url text;
ALTER TABLE public.posts ADD COLUMN IF NOT EXISTS flower_description text;
ALTER TABLE public.posts ADD COLUMN IF NOT EXISTS planting_guide text;
ALTER TABLE public.posts ADD COLUMN IF NOT EXISTS location_name text;
ALTER TABLE public.posts ADD COLUMN IF NOT EXISTS latitude numeric;
ALTER TABLE public.posts ADD COLUMN IF NOT EXISTS longitude numeric;

-- 2. Đảm bảo bảng post_media tồn tại
CREATE TABLE IF NOT EXISTS public.post_media (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  media_url text NOT NULL,
  media_type text NOT NULL DEFAULT 'image',
  display_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now()
);

-- 3. Đảm bảo RLS cho post_media (Cho phép đọc công khai)
ALTER TABLE public.post_media ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read on post_media" ON public.post_media;
CREATE POLICY "Allow public read on post_media" ON public.post_media FOR SELECT USING (true);
DROP POLICY IF EXISTS "Allow users to insert their post_media" ON public.post_media;
CREATE POLICY "Allow users to insert their post_media" ON public.post_media FOR INSERT WITH CHECK (true);

-- 4. Cập nhật bài viết luôn là APPROVED và PUBLIC
ALTER TABLE public.posts ALTER COLUMN status SET DEFAULT 'approved';
ALTER TABLE public.posts ALTER COLUMN is_public SET DEFAULT true;

-- Cập nhật tất cả bài cũ
UPDATE public.posts SET status = 'approved', is_public = true WHERE status != 'approved' OR is_public != true;

-- 5. Cập nhật image_url từ post_media vào posts (nếu bài cũ có ảnh trong media nhưng chưa có image_url)
UPDATE public.posts
SET image_url = (
  SELECT media_url 
  FROM public.post_media 
  WHERE post_media.post_id = posts.id 
  ORDER BY display_order ASC 
  LIMIT 1
)
WHERE image_url IS NULL OR image_url = '';

-- 6. Buộc Supabase nạp lại schema cache
NOTIFY pgrst, 'reload schema';

DO $$
BEGIN
  RAISE NOTICE 'Đã sửa lỗi schema, nạp ảnh cũ và thiết lập TỰ ĐỘNG DUYỆT bài viết!';
END $$;
