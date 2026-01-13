-- Add FCM token column to profiles for mobile push notifications

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS fcm_token text;

