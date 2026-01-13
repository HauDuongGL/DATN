-- Fix follow notification trigger to use correct column names
-- This script ensures the trigger uses actor_id instead of user_id or sender_id

-- Drop ALL existing triggers that might conflict
DROP TRIGGER IF EXISTS follows_create_notification ON public.follows CASCADE;
DROP TRIGGER IF EXISTS notify_on_follow ON public.follows CASCADE;

-- Drop existing function if it exists (try all possible names)
DROP FUNCTION IF EXISTS public.notify_on_follow() CASCADE;
DROP FUNCTION IF EXISTS notify_on_follow() CASCADE;

-- Ensure notifications table has actor_id column (rename from sender_id if needed)
DO $$
BEGIN
  -- Check if sender_id exists and rename to actor_id
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'notifications' 
    AND column_name = 'sender_id'
  ) THEN
    ALTER TABLE public.notifications RENAME COLUMN sender_id TO actor_id;
  END IF;
  
  -- Ensure actor_id column exists
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'notifications' 
    AND column_name = 'actor_id'
  ) THEN
    ALTER TABLE public.notifications ADD COLUMN actor_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE;
  END IF;
END $$;

-- Create fixed follow notification function
CREATE OR REPLACE FUNCTION public.notify_on_follow()
RETURNS trigger AS $$
BEGIN
  -- Only create notification if not following yourself
  IF NEW.following_id != NEW.follower_id THEN
    INSERT INTO public.notifications (recipient_id, actor_id, type, message)
    VALUES (NEW.following_id, NEW.follower_id, 'follow', 'đã theo dõi bạn')
    ON CONFLICT DO NOTHING; -- Prevent duplicate notifications
  END IF;
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log error but don't fail the follow operation
    RAISE WARNING 'Error creating follow notification: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recreate trigger
CREATE TRIGGER follows_create_notification
  AFTER INSERT ON public.follows
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_on_follow();

-- Notify PostgREST to reload schema
NOTIFY pgrst, 'reload schema';
