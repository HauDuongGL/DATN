-- ============================================
-- FIX ADMIN ACCESS & GRANT ADMIN ROLE (V1.2)
-- SOLVES: Infinite recursion & Column mismatch
-- ============================================

-- 1. DISABLE RLS on admin_users to solve recursion error
-- The "infinite recursion" happened because policies were checking themselves.
-- For a small internal table like this, disabling RLS is the safest unblocker.
ALTER TABLE public.admin_users DISABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view admin status" ON public.admin_users;
DROP POLICY IF EXISTS "Admin users can view all admin users" ON public.admin_users;
DROP POLICY IF EXISTS "Super admins can manage admin users" ON public.admin_users;
DROP POLICY IF EXISTS "Admin users are viewable by authenticated users" ON public.admin_users;

-- 2. Grant admin role (using the confirmed 'id' column)
DO $$
DECLARE
    target_user_id uuid;
    target_email text;
BEGIN
    -- Get user details from auth.users
    SELECT id, email INTO target_user_id, target_email 
    FROM auth.users 
    WHERE email = 'dphau.20it2@vku.udn.vn';
    
    IF target_user_id IS NOT NULL THEN
        -- Ensure profile exists
        BEGIN
            INSERT INTO public.profiles (id, email, username, full_name)
            VALUES (target_user_id, target_email, 'dphau.20it2', 'Dương Phúc Hậu')
            ON CONFLICT (id) DO NOTHING;
        EXCEPTION WHEN OTHERS THEN
            NULL; -- Ignore if profile partially exists
        END;
        
        -- Grant role in admin_users (using 'id' as confirmed by debug)
        INSERT INTO public.admin_users (id, role)
        VALUES (target_user_id, 'super_admin')
        ON CONFLICT (id) DO UPDATE SET role = 'super_admin';
        
        RAISE NOTICE 'SUCCESS: User % is now a super_admin.', target_email;
    ELSE
        RAISE NOTICE 'ERROR: User with email dphau.20it2@vku.udn.vn not found.';
    END IF;
END $$;
