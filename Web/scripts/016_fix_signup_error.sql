-- ============================================
-- FIX: SIGN-UP DATABASE ERROR (V1.0)
-- REASON: Trigger function mismatch with profiles table schema
-- ============================================

-- 1. Ensure Profiles Table has the correct schema
DO $$ 
BEGIN
  -- Add username if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='username') THEN
    ALTER TABLE public.profiles ADD COLUMN username text;
    -- Populate username for existing users
    UPDATE public.profiles SET username = split_part(email, '@', 1) WHERE username IS NULL;
    ALTER TABLE public.profiles ALTER COLUMN username SET NOT NULL;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'profiles_username_unique') THEN
        ALTER TABLE public.profiles ADD CONSTRAINT profiles_username_unique UNIQUE (username);
    END IF;
  END IF;

  -- Add full_name if it doesn't exist (handle display_name rename if needed)
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='display_name') 
     AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='full_name') THEN
    ALTER TABLE public.profiles RENAME COLUMN display_name TO full_name;
  ELSIF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='full_name') THEN
    ALTER TABLE public.profiles ADD COLUMN full_name text;
  END IF;

  -- Ensure avatar_url exists
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='avatar_url') THEN
    ALTER TABLE public.profiles ADD COLUMN avatar_url text;
  END IF;
END $$;

-- 2. Fix handle_new_user function to match the frontend expectations
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, username, full_name, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', '')
  )
  ON CONFLICT (id) DO UPDATE
  SET
    username = COALESCE(EXCLUDED.username, profiles.username),
    full_name = COALESCE(EXCLUDED.full_name, profiles.full_name),
    avatar_url = COALESCE(EXCLUDED.avatar_url, profiles.avatar_url);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Re-create the trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 4. Re-establish basic RLS policies for profiles (in case they were dropped)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "p_profiles_select" ON public.profiles;
CREATE POLICY "p_profiles_select" ON public.profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "p_profiles_update" ON public.profiles;
CREATE POLICY "p_profiles_update" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- 5. Force schema reload
NOTIFY pgrst, 'reload schema';

DO $$
BEGIN
  RAISE NOTICE 'SIGN-UP FIX COMPLETED SUCCESSFULLY!';
END $$;
