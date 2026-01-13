-- ============================================
-- CONSOLIDATED MIGRATION FOR NEW FEATURES
-- Run this script in Supabase SQL Editor
-- ============================================

-- 1. Add onboarding fields to profiles table
-- ============================================
alter table profiles
add column if not exists onboarding_completed boolean default false,
add column if not exists interests text[] default '{}',
add column if not exists favorite_flowers text[] default '{}';

create index if not exists idx_profiles_onboarding on profiles(onboarding_completed);

comment on column profiles.onboarding_completed is 'Whether user has completed onboarding flow';
comment on column profiles.interests is 'User interests (gardening, photography, botany, etc.)';
comment on column profiles.favorite_flowers is 'User favorite flower types';


-- 2. Create groups and related tables
-- ============================================
create table if not exists groups (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  cover_image_url text,
  created_by uuid references profiles(id) on delete cascade not null,
  is_private boolean default false,
  member_count integer default 0,
  post_count integer default 0,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

create table if not exists group_members (
  id uuid primary key default gen_random_uuid(),
  group_id uuid references groups(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  role text not null default 'member' check (role in ('admin', 'moderator', 'member')),
  joined_at timestamp with time zone default now(),
  unique(group_id, user_id)
);

create table if not exists group_posts (
  id uuid primary key default gen_random_uuid(),
  group_id uuid references groups(id) on delete cascade not null,
  post_id uuid references posts(id) on delete cascade not null,
  created_at timestamp with time zone default now(),
  unique(group_id, post_id)
);

create table if not exists group_join_requests (
  id uuid primary key default gen_random_uuid(),
  group_id uuid references groups(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now(),
  unique(group_id, user_id)
);

-- Indexes for groups
create index if not exists idx_groups_created_by on groups(created_by);
create index if not exists idx_group_members_group on group_members(group_id);
create index if not exists idx_group_members_user on group_members(user_id);
create index if not exists idx_group_posts_group on group_posts(group_id);
create index if not exists idx_group_posts_post on group_posts(post_id);
create index if not exists idx_group_join_requests_group on group_join_requests(group_id);
create index if not exists idx_group_join_requests_user on group_join_requests(user_id);


-- 3. Create messages and conversations tables
-- ============================================
create table if not exists conversations (
  id uuid primary key default gen_random_uuid(),
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

create table if not exists conversation_participants (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid references conversations(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  last_read_at timestamp with time zone default now(),
  joined_at timestamp with time zone default now(),
  unique(conversation_id, user_id)
);

create table if not exists messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid references conversations(id) on delete cascade not null,
  sender_id uuid references profiles(id) on delete cascade not null,
  content text not null,
  is_read boolean default false,
  created_at timestamp with time zone default now()
);

-- Indexes for messages
create index if not exists idx_conversation_participants_conversation on conversation_participants(conversation_id);
create index if not exists idx_conversation_participants_user on conversation_participants(user_id);
create index if not exists idx_messages_conversation on messages(conversation_id);
create index if not exists idx_messages_sender on messages(sender_id);
create index if not exists idx_messages_created_at on messages(created_at desc);


-- 4. Enable RLS on all new tables
-- ============================================
alter table groups enable row level security;
alter table group_members enable row level security;
alter table group_posts enable row level security;
alter table group_join_requests enable row level security;
alter table conversations enable row level security;
alter table conversation_participants enable row level security;
alter table messages enable row level security;


-- 5. RLS Policies for Groups
-- ============================================
drop policy if exists "Public groups are viewable by everyone" on groups;
drop policy if exists "Groups are viewable by everyone" on groups;
create policy "Groups are viewable by everyone"
  on groups for select
  using (true);

drop policy if exists "Authenticated users can create groups" on groups;
create policy "Authenticated users can create groups"
  on groups for insert
  with check (auth.uid() = created_by);

drop policy if exists "Group admins can update groups" on groups;
create policy "Group admins can update groups"
  on groups for update
  using (exists (
    select 1 from group_members
    where group_members.group_id = groups.id
    and group_members.user_id = auth.uid()
    and group_members.role = 'admin'
  ));

drop policy if exists "Authenticated users can view group memberships" on group_members;
create policy "Authenticated users can view group memberships"
  on group_members for select
  using (auth.role() = 'authenticated');

drop policy if exists "Users can join public groups" on group_members;
create policy "Users can join public groups"
  on group_members for insert
  with check (
    auth.uid() = user_id 
    and exists (
      select 1 from groups
      where groups.id = group_id
      and groups.is_private = false
    )
  );

drop policy if exists "Group admins can add members" on group_members;
create policy "Group admins can add members"
  on group_members for insert
  with check (exists (
    select 1 from group_members gm
    where gm.group_id = group_members.group_id
    and gm.user_id = auth.uid()
    and gm.role = 'admin'
  ));

drop policy if exists "Users can leave groups" on group_members;
create policy "Users can leave groups"
  on group_members for delete
  using (user_id = auth.uid() or exists (
    select 1 from group_members gm
    where gm.group_id = group_members.group_id
    and gm.user_id = auth.uid()
    and gm.role = 'admin'
  ));

drop policy if exists "Group members can view posts" on group_posts;
create policy "Group members can view posts"
  on group_posts for select
  using (exists (
    select 1 from group_members
    where group_members.group_id = group_posts.group_id
    and group_members.user_id = auth.uid()
  ));

drop policy if exists "Group members can create posts" on group_posts;
create policy "Group members can create posts"
  on group_posts for insert
  with check (exists (
    select 1 from group_members
    where group_members.group_id = group_posts.group_id
    and group_members.user_id = auth.uid()
  ));

drop policy if exists "Users can view their join requests" on group_join_requests;
create policy "Users can view their join requests"
  on group_join_requests for select
  using (user_id = auth.uid() or exists (
    select 1 from group_members
    where group_members.group_id = group_join_requests.group_id
    and group_members.user_id = auth.uid()
    and group_members.role in ('admin', 'moderator')
  ));

drop policy if exists "Users can create join requests" on group_join_requests;
create policy "Users can create join requests"
  on group_join_requests for insert
  with check (auth.uid() = user_id);

drop policy if exists "Admins can update join requests" on group_join_requests;
create policy "Admins can update join requests"
  on group_join_requests for update
  using (exists (
    select 1 from group_members
    where group_members.group_id = group_join_requests.group_id
    and group_members.user_id = auth.uid()
    and group_members.role in ('admin', 'moderator')
  ));


-- 6. RLS Policies for Messages
-- ============================================
drop policy if exists "Users can view their conversations" on conversations;
create policy "Users can view their conversations"
  on conversations for select
  using (exists (
    select 1 from conversation_participants
    where conversation_participants.conversation_id = conversations.id
    and conversation_participants.user_id = auth.uid()
  ));

drop policy if exists "Authenticated users can create conversations" on conversations;
create policy "Authenticated users can create conversations"
  on conversations for insert
  with check (auth.role() = 'authenticated');

drop policy if exists "Users can view conversation participants" on conversation_participants;
create policy "Users can view conversation participants"
  on conversation_participants for select
  using (exists (
    select 1 from conversation_participants cp
    where cp.conversation_id = conversation_participants.conversation_id
    and cp.user_id = auth.uid()
  ));

drop policy if exists "Users can add conversation participants" on conversation_participants;
create policy "Users can add conversation participants"
  on conversation_participants for insert
  with check (exists (
    select 1 from conversation_participants cp
    where cp.conversation_id = conversation_participants.conversation_id
    and cp.user_id = auth.uid()
  ) or not exists (
    select 1 from conversation_participants cp
    where cp.conversation_id = conversation_participants.conversation_id
  ));

drop policy if exists "Users can update their participation" on conversation_participants;
create policy "Users can update their participation"
  on conversation_participants for update
  using (user_id = auth.uid());

drop policy if exists "Users can view conversation messages" on messages;
create policy "Users can view conversation messages"
  on messages for select
  using (exists (
    select 1 from conversation_participants
    where conversation_participants.conversation_id = messages.conversation_id
    and conversation_participants.user_id = auth.uid()
  ));

drop policy if exists "Users can send messages" on messages;
create policy "Users can send messages"
  on messages for insert
  with check (
    sender_id = auth.uid()
    and exists (
      select 1 from conversation_participants
      where conversation_participants.conversation_id = messages.conversation_id
      and conversation_participants.user_id = auth.uid()
    )
  );

drop policy if exists "Users can update their messages" on messages;
create policy "Users can update their messages"
  on messages for update
  using (sender_id = auth.uid());


-- 7. Create triggers for group counters
-- ============================================
create or replace function increment_group_member_count()
returns trigger as $$
begin
  update groups
  set member_count = member_count + 1
  where id = new.group_id;
  return new;
end;
$$ language plpgsql;

create or replace function decrement_group_member_count()
returns trigger as $$
begin
  update groups
  set member_count = member_count - 1
  where id = old.group_id;
  return old;
end;
$$ language plpgsql;

drop trigger if exists on_group_member_added on group_members;
create trigger on_group_member_added
  after insert on group_members
  for each row execute function increment_group_member_count();

drop trigger if exists on_group_member_removed on group_members;
create trigger on_group_member_removed
  after delete on group_members
  for each row execute function decrement_group_member_count();


-- 8. Success message
-- ============================================
do $$
begin
  raise notice 'Migration completed successfully! All tables created with RLS policies.';
end $$;
