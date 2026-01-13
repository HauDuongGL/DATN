-- ============================================
-- ADMIN DASHBOARD RELATIONSHIP FIX (V1.2)
-- Atomic fix for relationships and orphan data
-- ============================================

DO $$ 
BEGIN
    -- 1. Standardize reports table columns
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='reports' AND column_name='post_id') THEN
        ALTER TABLE public.reports RENAME COLUMN post_id TO reported_post_id;
        RAISE NOTICE 'Renamed post_id to reported_post_id';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='reports' AND column_name='reported_post_id') THEN
        ALTER TABLE public.reports ADD COLUMN reported_post_id uuid;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='reports' AND column_name='reported_user_id') THEN
        ALTER TABLE public.reports ADD COLUMN reported_user_id uuid;
    END IF;

    -- 2. CLEANUP ORPHANS (Inside DO block to avoid parse errors)
    -- Delete media that refers to non-existent posts
    DELETE FROM public.post_media WHERE post_id NOT IN (SELECT id FROM public.posts);
    
    -- Delete reports that refer to non-existent targets
    -- Use dynamic SQL to avoid "column does not exist" during parsing
    EXECUTE 'DELETE FROM public.reports WHERE reported_post_id NOT IN (SELECT id FROM public.posts) AND reported_post_id IS NOT NULL';
    EXECUTE 'DELETE FROM public.reports WHERE reported_user_id NOT IN (SELECT id FROM public.profiles) AND reported_user_id IS NOT NULL';
    DELETE FROM public.reports WHERE reporter_id NOT IN (SELECT id FROM public.profiles);

    -- 3. Re-establish foreign keys
    -- Post Media
    ALTER TABLE IF EXISTS public.post_media DROP CONSTRAINT IF EXISTS post_media_post_id_fkey;
    ALTER TABLE public.post_media ADD CONSTRAINT post_media_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;

    -- Reports
    ALTER TABLE IF EXISTS public.reports DROP CONSTRAINT IF EXISTS reports_reported_post_id_fkey;
    ALTER TABLE public.reports ADD CONSTRAINT reports_reported_post_id_fkey FOREIGN KEY (reported_post_id) REFERENCES public.posts(id) ON DELETE CASCADE;

    ALTER TABLE IF EXISTS public.reports DROP CONSTRAINT IF EXISTS reports_reporter_id_fkey;
    ALTER TABLE public.reports ADD CONSTRAINT reports_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

    ALTER TABLE IF EXISTS public.reports DROP CONSTRAINT IF EXISTS reports_reported_user_id_fkey;
    ALTER TABLE public.reports ADD CONSTRAINT reports_reported_user_id_fkey FOREIGN KEY (reported_user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

    RAISE NOTICE 'Relationships and orphan cleanup completed.';
END $$;

-- 4. Ensure RLS allows Admins to see this data
DROP POLICY IF EXISTS "Admins can view any post media" ON public.post_media;
CREATE POLICY "Admins can view any post media" ON public.post_media FOR SELECT
USING (
  EXISTS (SELECT 1 FROM public.admin_users WHERE id = auth.uid())
);

DROP POLICY IF EXISTS "Admins can view all reports" ON public.reports;
CREATE POLICY "Admins can view all reports" ON public.reports FOR SELECT
USING (
  EXISTS (SELECT 1 FROM public.admin_users WHERE id = auth.uid())
);

-- 5. Reload PostgREST schema cache
NOTIFY pgrst, 'reload schema';

-- DONE!
SELECT 'Admin Dashboard relationships have been re-established and orphans purged!' as status;
