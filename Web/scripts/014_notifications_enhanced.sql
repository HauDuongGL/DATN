-- Enhanced notifications for post create & share, plus unified actor_id usage
-- Safe to run repeatedly (drops and recreates triggers/functions)

-- Drop old triggers if they exist (guard shares table)
DROP TRIGGER IF EXISTS likes_create_notification ON public.likes;
DROP TRIGGER IF EXISTS comments_create_notification ON public.comments;
DROP TRIGGER IF EXISTS follows_create_notification ON public.follows;
DROP TRIGGER IF EXISTS posts_create_notification ON public.posts;
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='shares') THEN
    EXECUTE 'DROP TRIGGER IF EXISTS shares_create_notification ON public.shares';
  END IF;
END $$;

-- Ensure notifications table uses actor_id and supports new types
ALTER TABLE public.notifications
  DROP CONSTRAINT IF EXISTS notifications_type_check;

ALTER TABLE public.notifications
  ADD CONSTRAINT notifications_type_check
  CHECK (type IN ('like','comment','follow','mention','post_created','share'));

-- Ensure column names are aligned
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='notifications' AND column_name='sender_id') THEN
    ALTER TABLE public.notifications RENAME COLUMN sender_id TO actor_id;
  END IF;
END $$;

-- Like notification
CREATE OR REPLACE FUNCTION public.notify_on_like()
RETURNS trigger AS $$
DECLARE
  v_post_author_id uuid;
  v_comment_author_id uuid;
BEGIN
  IF NEW.post_id IS NOT NULL THEN
    SELECT author_id INTO v_post_author_id FROM public.posts WHERE id = NEW.post_id;
    IF v_post_author_id IS NOT NULL AND v_post_author_id != NEW.user_id THEN
      INSERT INTO public.notifications (recipient_id, actor_id, type, post_id, message)
      VALUES (v_post_author_id, NEW.user_id, 'like', NEW.post_id, 'đã thích bài viết của bạn');
    END IF;
  ELSIF NEW.comment_id IS NOT NULL THEN
    SELECT author_id INTO v_comment_author_id FROM public.comments WHERE id = NEW.comment_id;
    IF v_comment_author_id IS NOT NULL AND v_comment_author_id != NEW.user_id THEN
      INSERT INTO public.notifications (recipient_id, actor_id, type, comment_id, message)
      VALUES (v_comment_author_id, NEW.user_id, 'like', NEW.comment_id, 'đã thích bình luận của bạn');
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER likes_create_notification
  AFTER INSERT ON public.likes
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_on_like();

-- Comment notification
CREATE OR REPLACE FUNCTION public.notify_on_comment()
RETURNS trigger AS $$
DECLARE
  v_post_author_id uuid;
BEGIN
  SELECT author_id INTO v_post_author_id FROM public.posts WHERE id = NEW.post_id;
  IF v_post_author_id IS NOT NULL AND v_post_author_id != NEW.author_id THEN
    INSERT INTO public.notifications (recipient_id, actor_id, type, post_id, comment_id, message)
    VALUES (v_post_author_id, NEW.author_id, 'comment', NEW.post_id, NEW.id, 'đã bình luận về bài viết của bạn');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER comments_create_notification
  AFTER INSERT ON public.comments
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_on_comment();

-- Follow notification
CREATE OR REPLACE FUNCTION public.notify_on_follow()
RETURNS trigger AS $$
BEGIN
  IF NEW.following_id != NEW.follower_id THEN
    INSERT INTO public.notifications (recipient_id, actor_id, type, message)
    VALUES (NEW.following_id, NEW.follower_id, 'follow', 'đã theo dõi bạn');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER follows_create_notification
  AFTER INSERT ON public.follows
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_on_follow();

-- Post created notification to followers
CREATE OR REPLACE FUNCTION public.notify_on_post_create()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.notifications (recipient_id, actor_id, type, post_id, message)
  SELECT follower_id, NEW.author_id, 'post_created', NEW.id, 'đã đăng một bài viết mới'
  FROM public.follows
  WHERE following_id = NEW.author_id
    AND follower_id != NEW.author_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER posts_create_notification
  AFTER INSERT ON public.posts
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_on_post_create();

-- Optional share table support (if table exists)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='shares') THEN
    EXECUTE $share$
    CREATE OR REPLACE FUNCTION public.notify_on_share()
    RETURNS trigger AS $fn$
    DECLARE
      v_post_author_id uuid;
    BEGIN
      SELECT author_id INTO v_post_author_id FROM public.posts WHERE id = NEW.post_id;
      IF v_post_author_id IS NOT NULL AND v_post_author_id != NEW.user_id THEN
        INSERT INTO public.notifications (recipient_id, actor_id, type, post_id, message)
        VALUES (v_post_author_id, NEW.user_id, 'share', NEW.post_id, 'đã chia sẻ bài viết của bạn');
      END IF;
      RETURN NEW;
    END;
    $fn$ LANGUAGE plpgsql;
    $share$;

    EXECUTE $share$
    CREATE TRIGGER shares_create_notification
      AFTER INSERT ON public.shares
      FOR EACH ROW
      EXECUTE FUNCTION public.notify_on_share();
    $share$;
  END IF;
END $$;

-- Re-notify PostgREST to refresh
NOTIFY pgrst, 'reload schema';
