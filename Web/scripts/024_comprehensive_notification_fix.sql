-- ============================================
-- COMPREHENSIVE NOTIFICATION SYSTEM FIX (V1.0)
-- Standardizes schema and fixes all triggers/functions
-- ============================================

-- 1. Standardize Notifications Schema
DO $$ 
BEGIN
  -- table notifications: user_id -> recipient_id
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='notifications' AND column_name='user_id') THEN
    ALTER TABLE public.notifications RENAME COLUMN user_id TO recipient_id;
    RAISE NOTICE 'Renamed notifications.user_id to recipient_id';
  END IF;

  -- table notifications: sender_id -> actor_id
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='notifications' AND column_name='sender_id') THEN
    ALTER TABLE public.notifications RENAME COLUMN sender_id TO actor_id;
    RAISE NOTICE 'Renamed notifications.sender_id to actor_id';
  END IF;

  -- Ensure actor_id exists if it was neither sender_id nor actor_id
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='notifications' AND column_name='actor_id') THEN
    ALTER TABLE public.notifications ADD COLUMN actor_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE;
    RAISE NOTICE 'Added actor_id to notifications';
  END IF;

  -- Standardize other tables that might have variations
  -- table likes: ensure user_id is the column (matches api.ts)
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='likes' AND column_name='author_id') THEN
    ALTER TABLE public.likes RENAME COLUMN author_id TO user_id;
    RAISE NOTICE 'Renamed likes.author_id to user_id';
  END IF;
  
  -- table comments: ensure author_id is the column (matches api.ts)
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='comments' AND column_name='user_id') THEN
    ALTER TABLE public.comments RENAME COLUMN user_id TO author_id;
    RAISE NOTICE 'Renamed comments.user_id to author_id';
  END IF;
END $$;

-- 2. Drop all old triggers and functions to start clean
DROP TRIGGER IF EXISTS tr_comment_notification ON public.comments CASCADE;
DROP TRIGGER IF EXISTS likes_create_notification ON public.likes CASCADE;
DROP TRIGGER IF EXISTS comments_create_notification ON public.comments CASCADE;
DROP TRIGGER IF EXISTS follows_create_notification ON public.follows CASCADE;
DROP TRIGGER IF EXISTS notify_on_post_shared ON public.posts CASCADE;

DROP FUNCTION IF EXISTS public.handle_comment_notification() CASCADE;
DROP FUNCTION IF EXISTS public.notify_on_like() CASCADE;
DROP FUNCTION IF EXISTS public.notify_on_comment() CASCADE;
DROP FUNCTION IF EXISTS public.notify_on_follow() CASCADE;
DROP FUNCTION IF EXISTS public.notify_on_post_share() CASCADE;

-- 3. Create Fixed Functions

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
  RAISE WARNING 'Error in notify_on_like: %', SQLERRM;
  RETURN NEW;
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
  RAISE WARNING 'Error in notify_on_comment: %', SQLERRM;
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
  RAISE WARNING 'Error in notify_on_follow: %', SQLERRM;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Recreate Triggers
CREATE TRIGGER tr_like_notification AFTER INSERT ON public.likes FOR EACH ROW EXECUTE FUNCTION public.notify_on_like();
CREATE TRIGGER tr_comment_notification AFTER INSERT ON public.comments FOR EACH ROW EXECUTE FUNCTION public.notify_on_comment();
CREATE TRIGGER tr_follow_notification AFTER INSERT ON public.follows FOR EACH ROW EXECUTE FUNCTION public.notify_on_follow();

-- 5. Fix RLS Polices for Notifications
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "p_notifications_select" ON public.notifications;
CREATE POLICY "p_notifications_select" ON public.notifications FOR SELECT USING (auth.uid() = recipient_id);

DROP POLICY IF EXISTS "p_notifications_insert" ON public.notifications;
CREATE POLICY "p_notifications_insert" ON public.notifications FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "p_notifications_update" ON public.notifications;
CREATE POLICY "p_notifications_update" ON public.notifications FOR UPDATE USING (auth.uid() = recipient_id);

-- 6. Reload Schema
NOTIFY pgrst, 'reload schema';

DO $$
BEGIN
  RAISE NOTICE 'COMPREHENSIVE NOTIFICATION SYSTEM FIX COMPLETED!';
END $$;
