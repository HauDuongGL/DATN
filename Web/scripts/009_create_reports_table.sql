-- Create reports table for content moderation
create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  post_id uuid references public.posts(id) on delete cascade,
  comment_id uuid references public.comments(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  reason text not null,
  description text,
  status text default 'pending' check (status in ('pending', 'reviewed', 'resolved', 'dismissed')),
  reviewed_by uuid references public.admin_users(id),
  reviewed_at timestamp with time zone,
  resolution_notes text,
  created_at timestamp with time zone default now(),
  constraint report_target_check check (
    (post_id is not null and comment_id is null and user_id is null) or
    (post_id is null and comment_id is not null and user_id is null) or
    (post_id is null and comment_id is null and user_id is not null)
  )
);

-- Enable RLS
alter table public.reports enable row level security;

-- RLS Policies for reports
create policy "Users can view their own reports"
  on public.reports for select
  using (auth.uid() = reporter_id);

create policy "Admins can view all reports"
  on public.reports for select
  using (
    exists (
      select 1 from public.admin_users
      where admin_users.id = auth.uid()
    )
  );

create policy "Users can submit reports"
  on public.reports for insert
  with check (auth.uid() = reporter_id);

create policy "Admins can update reports"
  on public.reports for update
  using (
    exists (
      select 1 from public.admin_users
      where admin_users.id = auth.uid()
    )
  );

-- Indexes
create index reports_status_idx on public.reports(status);
create index reports_post_id_idx on public.reports(post_id);
create index reports_reporter_id_idx on public.reports(reporter_id);
