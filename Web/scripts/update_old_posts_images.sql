-- ============================================
-- Sửa dữ liệu bài viết cũ - Cập nhật image_url
-- ============================================

-- Script này sẽ lấy ảnh đầu tiên từ bảng post_media
-- và cập nhật vào cột image_url của bảng posts.
-- Điều này giúp hiển thị ảnh cho các bài viết đã đăng trước đó.

UPDATE public.posts
SET image_url = (
  SELECT media_url 
  FROM public.post_media 
  WHERE post_media.post_id = posts.id 
  ORDER BY display_order ASC 
  LIMIT 1
)
WHERE image_url IS NULL;

-- Nếu vẫn chưa có ảnh (do chưa từng lưu vào post_media), 
-- người dùng nên đăng bài mới để kiểm tra luồng hoàn chỉnh.

-- Reload schema cache lần nữa cho chắc chắn
NOTIFY pgrst, 'reload schema';

DO $$
BEGIN
  RAISE NOTICE 'Đã cập nhật image_url cho các bài viết cũ từ post_media!';
END $$;
