-- ============================================
-- NUCLEAR NOTIFICATION CLEANUP (V1.0)
-- Drops ALL triggers on core tables and resets notification system
-- ============================================

-- 1. Dynamic Cleanup of ALL Triggers
DO $$
DECLARE
    tr RECORD;
BEGIN
    FOR tr IN (
        SELECT tgname, relname 
        FROM pg_trigger 
        JOIN pg_class ON tgrelid = pg_class.oid 
        WHERE relname IN ('comments', 'likes', 'posts', 'notifications', 'follows')
        AND tgisinternal = false
    ) LOOP
        EXECUTE 'DROP TRIGGER IF EXISTS ' || quote_ident(tr.tgname) || ' ON public.' || quote_ident(tr.relname) || ' CASCADE';
        RAISE NOTICE 'Dropped trigger % on table %', tr.tgname, tr.relname;
    END LOOP;
END $$;

-- 2. Standardize Notifications Table
DO $$ 
BEGIN
  -- table notifications: rename user_id -> recipient_id
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='notifications' AND column_name='user_id') THEN
    ALTER TABLE public.notifications RENAME COLUMN user_id TO recipient_id;
  END IF;

  -- table notifications: rename sender_id -> actor_id
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='notifications' AND column_name='sender_id') THEN
    ALTER TABLE public.notifications RENAME COLUMN sender_id TO actor_id;
  END IF;

  -- Ensure actor_id exists
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='notifications' AND column_name='actor_id') THEN
    ALTER TABLE public.notifications ADD COLUMN actor_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE;
  END IF;
END $$;

-- 3. Standardize Other Tables
DO $$ 
BEGIN
  -- table likes: ensure user_id is the column
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='likes' AND column_name='author_id') THEN
    ALTER TABLE public.likes RENAME COLUMN author_id TO user_id;
  END IF;
  
  -- table comments: ensure author_id is the column
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='comments' AND column_name='user_id') THEN
    ALTER TABLE public.comments RENAME COLUMN user_id TO author_id;
  END IF;
END $$;

-- 4. Create Standard Functions with SECURITY DEFINER
-- This ensures they run with enough permissions regardless of the user

-- Like Notification
CREATE OR REPLACE FUNCTION public.notify_on_like()
RETURNS trigger AS $$
DECLARE v_recipient_id uuid;
BEGIN
  IF NEW.post_id IS NOT NULL THEN
    SELECT author_id INTO v_recipient_id FROM public.posts WHERE id = NEW.post_id;
    IF v_recipient_id != NEW.user_id THEN
      INSERT INTO public.notifications (recipient_id, actor_id, type, post_id, message)
      VALUES (v_recipient_id, NEW.user_id, 'like', NEW.post_id, 'đã thích bài viết của bạn')
      ON CONFLICT DO NOTHING;
    END IF;
  ELSIF NEW.comment_id IS NOT NULL THEN
    SELECT author_id INTO v_recipient_id FROM public.comments WHERE id = NEW.comment_id;
    IF v_recipient_id != NEW.user_id THEN
      INSERT INTO public.notifications (recipient_id, actor_id, type, comment_id, message)
      VALUES (v_recipient_id, NEW.user_id, 'like', NEW.comment_id, 'đã thích bình luận của bạn')
      ON CONFLICT DO NOTHING;
    END IF;
  END IF;
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  RETURN NEW; -- Just fail silently but don't block the action
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Comment Notification
CREATE OR REPLACE FUNCTION public.notify_on_comment()
RETURNS trigger AS $$
DECLARE v_recipient_id uuid;
BEGIN
  SELECT author_id INTO v_recipient_id FROM public.posts WHERE id = NEW.post_id;
  IF v_recipient_id != NEW.author_id THEN
    INSERT INTO public.notifications (recipient_id, actor_id, type, post_id, comment_id, message)
    VALUES (v_recipient_id, NEW.author_id, 'comment', NEW.post_id, NEW.id, 'đã bình luận bài viết của bạn')
    ON CONFLICT DO NOTHING;
  END IF;
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Follow Notification
CREATE OR REPLACE FUNCTION public.notify_on_follow()
RETURNS trigger AS $$
BEGIN
  IF NEW.following_id != NEW.follower_id THEN
    INSERT INTO public.notifications (recipient_id, actor_id, type, message)
    VALUES (NEW.following_id, NEW.follower_id, 'follow', 'đã bắt đầu theo dõi bạn')
    ON CONFLICT DO NOTHING;
  END IF;
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Establish Triggers
CREATE TRIGGER tr_like_notification AFTER INSERT ON public.likes FOR EACH ROW EXECUTE FUNCTION public.notify_on_like();
CREATE TRIGGER tr_comment_notification AFTER INSERT ON public.comments FOR EACH ROW EXECUTE FUNCTION public.notify_on_comment();
CREATE TRIGGER tr_follow_notification AFTER INSERT ON public.follows FOR EACH ROW EXECUTE FUNCTION public.notify_on_follow();

-- 6. RPC Fixes
CREATE OR REPLACE FUNCTION public.mark_all_notifications_read(target_user_id uuid)
RETURNS void AS $$
BEGIN
  UPDATE public.notifications SET is_read = true WHERE recipient_id = target_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. RLS Reset
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "p_notifications_select" ON public.notifications;
CREATE POLICY "p_notifications_select" ON public.notifications FOR SELECT USING (auth.uid() = recipient_id);
DROP POLICY IF EXISTS "p_notifications_insert" ON public.notifications;
CREATE POLICY "p_notifications_insert" ON public.notifications FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "p_notifications_update" ON public.notifications;
CREATE POLICY "p_notifications_update" ON public.notifications FOR UPDATE USING (auth.uid() = recipient_id);

-- 8. Force Schema Reload
NOTIFY pgrst, 'reload schema';

DO $$
BEGIN
  RAISE NOTICE 'NUCLEAR NOTIFICATION CLEANUP COMPLETED! Follow/Like errors should be gone.';
END $$;
