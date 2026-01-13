-- Fix: Ensure onboarding_completed column exists in profiles table
-- This handles cases where script 014 might not have run yet

-- Add columns if they don't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' 
    AND column_name = 'onboarding_completed'
  ) THEN
    ALTER TABLE profiles ADD COLUMN onboarding_completed boolean DEFAULT false;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' 
    AND column_name = 'interests'
  ) THEN
    ALTER TABLE profiles ADD COLUMN interests text[] DEFAULT '{}';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' 
    AND column_name = 'favorite_flowers'
  ) THEN
    ALTER TABLE profiles ADD COLUMN favorite_flowers text[] DEFAULT '{}';
  END IF;
END $$;

-- Add index for querying if it doesn't exist
CREATE INDEX IF NOT EXISTS idx_profiles_onboarding on profiles(onboarding_completed);

-- Add comments
COMMENT ON COLUMN profiles.onboarding_completed IS 'Whether user has completed onboarding flow';
COMMENT ON COLUMN profiles.interests IS 'User interests (gardening, photography, botany, etc.)';
COMMENT ON COLUMN profiles.favorite_flowers IS 'User favorite flower types';
