-- Temporarily disable follow notification trigger
-- Use this if you need to disable the trigger while fixing it

-- Drop the trigger (keeps the function)
DROP TRIGGER IF EXISTS follows_create_notification ON public.follows CASCADE;

-- To re-enable later, run:
-- CREATE TRIGGER follows_create_notification
--   AFTER INSERT ON public.follows
--   FOR EACH ROW
--   EXECUTE FUNCTION public.notify_on_follow();
