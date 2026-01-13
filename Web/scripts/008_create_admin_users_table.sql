-- Create admin_users table for admin management
create table if not exists public.admin_users (
  id uuid primary key references public.profiles(id) on delete cascade,
  role text not null check (role in ('super_admin', 'moderator', 'content_reviewer')),
  permissions jsonb default '[]'::jsonb,
  created_at timestamp with time zone default now(),
  created_by uuid references public.profiles(id)
);

-- Enable RLS (Temporarily disabled for debugging)
-- alter table public.admin_users enable row level security;
alter table public.admin_users disable row level security;

-- RLS Policies for admin_users
drop policy if exists "Admin users can view all admin users" on public.admin_users;
create policy "Anyone can view admin status"
  on public.admin_users for select
  using (true);

drop policy if exists "Super admins can manage admin users" on public.admin_users;
create policy "Super admins can manage admin users"
  on public.admin_users for all
  using (
    exists (
      select 1 from public.admin_users
      where admin_users.id = auth.uid()
      and admin_users.role = 'super_admin'
    )
  );
