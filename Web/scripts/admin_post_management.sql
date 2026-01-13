-- ============================================
-- ADMIN POST MANAGEMENT - NO PENDING FLOW
-- ============================================

-- 1. Remove pending status requirement
ALTER TABLE public.posts ALTER COLUMN status SET DEFAULT 'approved';
UPDATE public.posts SET status = 'approved' WHERE status = 'pending';

-- 2. Update RLS policies for Admins to manage any post
-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Admins can view any post" ON public.posts;
DROP POLICY IF EXISTS "Admins can delete any post" ON public.posts;
DROP POLICY IF EXISTS "Admins can update any post" ON public.posts;

-- Create admin policies (Confirmed column 'id' is used in your database)
CREATE POLICY "Admins can view any post"
ON public.posts
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.admin_users
    WHERE admin_users.id = auth.uid()
  )
);

CREATE POLICY "Admins can delete any post"
ON public.posts
FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.admin_users
    WHERE admin_users.id = auth.uid()
  )
);

CREATE POLICY "Admins can update any post"
ON public.posts
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM public.admin_users
    WHERE admin_users.id = auth.uid()
  )
);

-- 3. Success message
DO $$
BEGIN
  RAISE NOTICE 'Admin Post Management policies applied and pending status removed.';
END $$;
