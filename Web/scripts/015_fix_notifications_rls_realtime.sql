-- Fix missing RLS policy for updating notifications
-- This was likely missing in definitive_db_fix.sql (Nuclear Cleanup V8)

-- 1. Create the update policy
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'notifications' 
    AND policyname = 'p_notifications_update'
  ) THEN
    CREATE POLICY "p_notifications_update" 
      ON public.notifications 
      FOR UPDATE 
      USING (auth.uid() = recipient_id);
  END IF;
END $$;

-- 2. Ensure real-time is enabled for notifications table
DO $$
BEGIN
  -- This adds the table to the supabase_realtime publication
  -- Note: This requires superuser or being the owner of the publication
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    IF NOT EXISTS (
      SELECT 1 FROM pg_publication_tables 
      WHERE pubname = 'supabase_realtime' 
      AND tablename = 'notifications'
    ) THEN
      ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
    END IF;
  END IF;
END $$;

-- 3. Also fix the mark_all_notifications_read RPC to make it more robust
CREATE OR REPLACE FUNCTION public.mark_all_notifications_read(target_user_id uuid)
RETURNS void AS $$
BEGIN
  UPDATE public.notifications 
  SET is_read = true 
  WHERE recipient_id = target_user_id 
    AND is_read = false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; -- Use SECURITY DEFINER to ensure it can always update its own rows

-- Notify PostgREST to refresh schema
NOTIFY pgrst, 'reload schema';
