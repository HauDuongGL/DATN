-- Create notifications table
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_id uuid not null references public.profiles(id) on delete cascade,
  sender_id uuid references public.profiles(id) on delete cascade,
  type text not null check (type in ('like', 'comment', 'follow', 'mention', 'post_approved', 'post_rejected')),
  post_id uuid references public.posts(id) on delete cascade,
  comment_id uuid references public.comments(id) on delete cascade,
  message text,
  is_read boolean default false,
  created_at timestamp with time zone default now()
);

-- Enable RLS
alter table public.notifications enable row level security;

-- RLS Policies for notifications
create policy "Users can view their own notifications"
  on public.notifications for select
  using (auth.uid() = recipient_id);

create policy "System can insert notifications"
  on public.notifications for insert
  with check (true);

create policy "Users can update their own notifications"
  on public.notifications for update
  using (auth.uid() = recipient_id);

create policy "Users can delete their own notifications"
  on public.notifications for delete
  using (auth.uid() = recipient_id);

-- Index
create index notifications_recipient_id_idx on public.notifications(recipient_id);
create index notifications_is_read_idx on public.notifications(is_read);
