-- ============================================
-- FIX POST_MEDIA RLS POLICY FOR INSERT
-- ============================================
-- This script fixes the Row Level Security policy for post_media table
-- to allow users to insert media for their own posts

-- Drop ALL existing policies to avoid conflicts
DROP POLICY IF EXISTS "Users can insert media for their posts" ON public.post_media;
DROP POLICY IF EXISTS "Users can insert media for their own posts" ON public.post_media;
DROP POLICY IF EXISTS "Allow users to insert their post_media" ON public.post_media;
DROP POLICY IF EXISTS "Post media is viewable through posts" ON public.post_media;
DROP POLICY IF EXISTS "Post media is viewable with post" ON public.post_media;
DROP POLICY IF EXISTS "Allow public read on post_media" ON public.post_media;
DROP POLICY IF EXISTS "Users can delete media from their posts" ON public.post_media;
DROP POLICY IF EXISTS "Users can delete their own post media" ON public.post_media;
DROP POLICY IF EXISTS "Admins can view any post media" ON public.post_media;

-- Create a new INSERT policy that allows users to insert media for posts they own
-- This policy checks that the user is authenticated and the post exists with the user as author
CREATE POLICY "Users can insert media for their own posts"
  ON public.post_media
  FOR INSERT
  WITH CHECK (
    auth.uid() IS NOT NULL
    AND EXISTS (
      SELECT 1 
      FROM public.posts
      WHERE posts.id = post_media.post_id
      AND posts.author_id = auth.uid()
    )
  );

-- Also ensure SELECT policy allows users to see their own media
CREATE POLICY "Post media is viewable through posts"
  ON public.post_media
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 
      FROM public.posts
      WHERE posts.id = post_media.post_id
      AND (
        (posts.is_public = true AND posts.status = 'approved')
        OR posts.author_id = auth.uid()
      )
    )
  );

-- Ensure DELETE policy exists
DROP POLICY IF EXISTS "Users can delete media from their posts" ON public.post_media;
DROP POLICY IF EXISTS "Users can delete their own post media" ON public.post_media;

CREATE POLICY "Users can delete their own post media"
  ON public.post_media
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 
      FROM public.posts
      WHERE posts.id = post_media.post_id
      AND posts.author_id = auth.uid()
    )
  );

-- Add admin policy if admin_users table exists
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'admin_users') THEN
    CREATE POLICY "Admins can view any post media" ON public.post_media
    FOR SELECT
    USING (
      EXISTS (SELECT 1 FROM public.admin_users WHERE id = auth.uid())
    );
    RAISE NOTICE 'Admin policy for post_media has been added';
  END IF;
END $$;

-- Reload PostgREST schema cache
NOTIFY pgrst, 'reload schema';

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Post media RLS policies have been fixed!';
END $$;
