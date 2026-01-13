-- ============================================
-- FIX: FOLLOW COUNTERS (V1.0)
-- Re-establishes triggers and recalculates counts
-- ============================================

-- 1. Create/Update the counter functions
CREATE OR REPLACE FUNCTION public.increment_follow_counts()
RETURNS trigger AS $$
BEGIN
  UPDATE public.profiles
  SET following_count = following_count + 1
  WHERE id = NEW.follower_id;
  
  UPDATE public.profiles
  SET followers_count = followers_count + 1
  WHERE id = NEW.following_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.decrement_follow_counts()
RETURNS trigger AS $$
BEGIN
  UPDATE public.profiles
  SET following_count = GREATEST(0, following_count - 1)
  WHERE id = OLD.follower_id;
  
  UPDATE public.profiles
  SET followers_count = GREATEST(0, followers_count - 1)
  WHERE id = OLD.following_id;
  
  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Re-establish triggers on the follows table
DROP TRIGGER IF EXISTS on_follow_added ON public.follows;
CREATE TRIGGER on_follow_added
  AFTER INSERT ON public.follows
  FOR EACH ROW
  EXECUTE FUNCTION public.increment_follow_counts();

DROP TRIGGER IF EXISTS on_follow_removed ON public.follows;
CREATE TRIGGER on_follow_removed
  AFTER DELETE ON public.follows
  FOR EACH ROW
  EXECUTE FUNCTION public.decrement_follow_counts();

-- 3. Recalculate all counts to sync with reality
DO $$
BEGIN
  -- Reset all counts to 0 first to ensure clean calculation
  UPDATE public.profiles SET followers_count = 0, following_count = 0;
  
  -- Update following_count
  UPDATE public.profiles p
  SET following_count = (
    SELECT count(*) 
    FROM public.follows f 
    WHERE f.follower_id = p.id
  );
  
  -- Update followers_count
  UPDATE public.profiles p
  SET followers_count = (
    SELECT count(*) 
    FROM public.follows f 
    WHERE f.following_id = p.id
  );
END $$;

-- 4. Force Reload
NOTIFY pgrst, 'reload schema';

DO $$
BEGIN
  RAISE NOTICE 'FOLLOW COUNTERS RE-ESTABLISHED AND SYNCED SUCCESSFULLY!';
END $$;
