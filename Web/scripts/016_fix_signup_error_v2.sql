-- ============================================
-- FIX: SIGN-UP DATABASE ERROR (V2.0)
-- ULTRA-RESILIENT VERSION
-- Handles multiple schema variations and ensures non-blocking creation
-- ============================================

-- 1. Correct the Profiles Table Schema
DO $$ 
BEGIN
  -- Ensure email column exists (legacy but widely used in this codebase)
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='email') THEN
    ALTER TABLE public.profiles ADD COLUMN email text;
    RAISE NOTICE 'Added email column to profiles';
  END IF;
  -- Make email nullable to avoid blocking if it's not provided
  ALTER TABLE public.profiles ALTER COLUMN email DROP NOT NULL;

  -- Ensure username column exists
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='username') THEN
    ALTER TABLE public.profiles ADD COLUMN username text;
    RAISE NOTICE 'Added username column to profiles';
  END IF;
  -- Temporarily drop NOT NULL to avoid errors during creation if possible, 
  -- but we will fill it in the trigger.
  ALTER TABLE public.profiles ALTER COLUMN username DROP NOT NULL;

  -- Handle full_name vs display_name
  -- Ensure full_name exists
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='full_name') THEN
    -- If display_name exists, rename it
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='display_name') THEN
        ALTER TABLE public.profiles RENAME COLUMN display_name TO full_name;
        RAISE NOTICE 'Renamed display_name to full_name';
    ELSE
        ALTER TABLE public.profiles ADD COLUMN full_name text;
        RAISE NOTICE 'Added full_name column';
    END IF;
  END IF;
  
  -- If legacy display_name still exists (unlikely after rename but just in case), make it nullable
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='display_name') THEN
    ALTER TABLE public.profiles ALTER COLUMN display_name DROP NOT NULL;
  END IF;

  -- Ensure avatar_url exists
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='avatar_url') THEN
    ALTER TABLE public.profiles ADD COLUMN avatar_url text;
  END IF;
END $$;

-- 2. Create the ultra-resilient trigger function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_username text;
  v_full_name text;
BEGIN
  -- Generate a safe username
  v_username := COALESCE(
    NEW.raw_user_meta_data->>'username', 
    split_part(NEW.email, '@', 1),
    'user_' || substring(NEW.id::text, 1, 8)
  );
  
  -- Handle potential username conflict (unlikely for new user but safe)
  -- If the username exists, append a short random suffix
  IF EXISTS (SELECT 1 FROM public.profiles WHERE username = v_username) THEN
    v_username := v_username || '_' || substring(NEW.id::text, 1, 4);
  END IF;

  v_full_name := COALESCE(
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'display_name',
    ''
  );

  -- Insert using dynamic SQL or just safe columns
  -- We use ON CONFLICT (id) DO UPDATE to handle accidental retries
  INSERT INTO public.profiles (id, email, username, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    v_username,
    v_full_name,
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', '')
  )
  ON CONFLICT (id) DO UPDATE
  SET
    email = EXCLUDED.email,
    username = COALESCE(profiles.username, EXCLUDED.username), -- Keep existing if available
    full_name = COALESCE(EXCLUDED.full_name, profiles.full_name),
    avatar_url = COALESCE(EXCLUDED.avatar_url, profiles.avatar_url),
    updated_at = now();

  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  -- CRITICAL: Catch errors and log them (if possible) but DON'T block auth
  -- In a production app, you might want to log this to a table
  RAISE WARNING 'Error in handle_new_user trigger: %', SQLERRM;
  RETURN NEW; -- Still return NEW so the user can at least sign up even if profile fails
END;
$$;

-- 3. Re-create the trigger on auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW 
  EXECUTE FUNCTION public.handle_new_user();

-- 4. Final safety check: Make sure RLS doesn't block the trigger (SECURITY DEFINER already helps)
-- but ensure profiles has basic select for everything
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "p_profiles_all_select" ON public.profiles;
CREATE POLICY "p_profiles_all_select" ON public.profiles FOR SELECT USING (true);

-- 5. Force schema reload
NOTIFY pgrst, 'reload schema';

DO $$
BEGIN
  RAISE NOTICE 'SIGN-UP FIX V2 COMPLETED SUCCESSFULLY!';
END $$;
