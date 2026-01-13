-- ============================================
-- DEFINITIVE DATABASE FIX V8 - THE "NUCLEAR CLEANUP"
-- ============================================

-- 1. DYNAMICALLY DROP ALL TRIGGERS ON KEY TABLES
DO $$
DECLARE
    tr RECORD;
BEGIN
    FOR tr IN (
        SELECT tgname, relname 
        FROM pg_trigger 
        JOIN pg_class ON tgrelid = pg_class.oid 
        WHERE relname IN ('comments', 'likes', 'posts', 'notifications')
        AND tgisinternal = false
    ) LOOP
        EXECUTE 'DROP TRIGGER IF EXISTS ' || quote_ident(tr.tgname) || ' ON public.' || quote_ident(tr.relname) || ' CASCADE';
        RAISE NOTICE 'Dropped trigger % on table %', tr.tgname, tr.relname;
    END LOOP;
END $$;

-- 2. DYNAMICALLY DROP ALL POLICIES ON KEY TABLES
DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN (
        SELECT policyname, tablename 
        FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename IN ('comments', 'likes', 'posts', 'notifications', 'profiles')
    ) LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(pol.policyname) || ' ON public.' || quote_ident(pol.tablename);
        RAISE NOTICE 'Dropped policy % on table %', pol.policyname, pol.tablename;
    END LOOP;
END $$;

-- 3. ENSURE COLUMN NAMES ARE CORRECT (author_id / recipient_id)
DO $$ 
BEGIN
  -- table comments
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='comments' AND column_name='user_id') THEN
    ALTER TABLE public.comments RENAME COLUMN user_id TO author_id;
  END IF;

  -- table notifications
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='notifications' AND column_name='user_id') THEN
    ALTER TABLE public.notifications RENAME COLUMN user_id TO recipient_id;
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='notifications' AND column_name='sender_id') THEN
    ALTER TABLE public.notifications RENAME COLUMN sender_id TO actor_id;
  END IF;

  -- table likes
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='likes' AND column_name='author_id') THEN
    ALTER TABLE public.likes RENAME COLUMN author_id TO user_id;
  END IF;
END $$;

-- 4. RE-RE-ESTABLISH FOREIGN KEYS
ALTER TABLE public.posts DROP CONSTRAINT IF EXISTS posts_author_id_fkey;
ALTER TABLE public.posts ADD CONSTRAINT posts_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.comments DROP CONSTRAINT IF EXISTS comments_author_id_fkey;
ALTER TABLE public.comments ADD CONSTRAINT comments_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.likes DROP CONSTRAINT IF EXISTS likes_user_id_fkey;
ALTER TABLE public.likes ADD CONSTRAINT likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.notifications DROP CONSTRAINT IF EXISTS notifications_recipient_id_fkey;
ALTER TABLE public.notifications ADD CONSTRAINT notifications_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- 5. RECREATE ALL NECESSARY FUNCTIONS & TRIGGERS
CREATE OR REPLACE FUNCTION public.sync_comments_count()
RETURNS trigger AS $$
BEGIN
  UPDATE public.posts 
  SET comments_count = (SELECT count(*) FROM public.comments WHERE post_id = COALESCE(NEW.post_id, OLD.post_id))
  WHERE id = COALESCE(NEW.post_id, OLD.post_id);
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.handle_comment_notification()
RETURNS trigger AS $$
DECLARE v_post_author_id uuid;
BEGIN
  SELECT author_id INTO v_post_author_id FROM public.posts WHERE id = NEW.post_id;
  IF v_post_author_id != NEW.author_id THEN
    INSERT INTO public.notifications (recipient_id, actor_id, type, post_id, comment_id)
    VALUES (v_post_author_id, NEW.author_id, 'comment', NEW.post_id, NEW.id);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_sync_comments_count AFTER INSERT OR DELETE ON public.comments FOR EACH ROW EXECUTE FUNCTION public.sync_comments_count();
CREATE TRIGGER tr_comment_notification AFTER INSERT ON public.comments FOR EACH ROW EXECUTE FUNCTION public.handle_comment_notification();

-- 6. RE-ENABLE RLS AND CREATE FRESH POLICIES
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "p_posts_select" ON public.posts FOR SELECT USING (true);
CREATE POLICY "p_posts_all" ON public.posts FOR ALL USING (auth.uid() = author_id);

ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "p_comments_select" ON public.comments FOR SELECT USING (true);
CREATE POLICY "p_comments_insert" ON public.comments FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "p_comments_update_delete" ON public.comments FOR ALL USING (auth.uid() = author_id);

ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "p_likes_select" ON public.likes FOR SELECT USING (true);
CREATE POLICY "p_likes_insert" ON public.likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "p_likes_delete" ON public.likes FOR DELETE USING (auth.uid() = user_id);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "p_notifications_select" ON public.notifications FOR SELECT USING (auth.uid() = recipient_id);
CREATE POLICY "p_notifications_insert" ON public.notifications FOR INSERT WITH CHECK (true);

-- 7. RECREATE RPCs
CREATE OR REPLACE FUNCTION public.mark_all_notifications_read(target_user_id uuid)
RETURNS void AS $$
BEGIN
  UPDATE public.notifications SET is_read = true WHERE recipient_id = target_user_id;
END;
$$ LANGUAGE plpgsql;

-- 8. FINAL FORCE RELOAD
NOTIFY pgrst, 'reload schema';

DO $$
BEGIN
  RAISE NOTICE 'DATABASE DEFINITIVE FIX V8 (NUCLEAR CLEANUP) COMPLETED!';
END $$;
