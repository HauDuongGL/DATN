-- Create groups table for communities
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

-- Create group_members table for membership
create table if not exists group_members (
  id uuid primary key default gen_random_uuid(),
  group_id uuid references groups(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  role text not null default 'member' check (role in ('admin', 'moderator', 'member')),
  joined_at timestamp with time zone default now(),
  unique(group_id, user_id)
);

-- Create group_posts table to link posts to groups
create table if not exists group_posts (
  id uuid primary key default gen_random_uuid(),
  group_id uuid references groups(id) on delete cascade not null,
  post_id uuid references posts(id) on delete cascade not null,
  created_at timestamp with time zone default now(),
  unique(group_id, post_id)
);

-- Create group_join_requests table for private groups
create table if not exists group_join_requests (
  id uuid primary key default gen_random_uuid(),
  group_id uuid references groups(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now(),
  unique(group_id, user_id)
);

-- Indexes
create index if not exists idx_groups_created_by on groups(created_by);
create index if not exists idx_group_members_group on group_members(group_id);
create index if not exists idx_group_members_user on group_members(user_id);
create index if not exists idx_group_posts_group on group_posts(group_id);
create index if not exists idx_group_posts_post on group_posts(post_id);
create index if not exists idx_group_join_requests_group on group_join_requests(group_id);
create index if not exists idx_group_join_requests_user on group_join_requests(user_id);

-- RLS Policies
alter table groups enable row level security;
alter table group_members enable row level security;
alter table group_posts enable row level security;
alter table group_join_requests enable row level security;

-- Groups: Everyone can view public groups
create policy "Public groups are viewable by everyone"
  on groups for select
  using (is_private = false or exists (
    select 1 from group_members
    where group_members.group_id = groups.id
    and group_members.user_id = auth.uid()
  ));

-- Groups: Authenticated users can create groups
create policy "Authenticated users can create groups"
  on groups for insert
  with check (auth.uid() = created_by);

-- Groups: Admins can update their groups
create policy "Group admins can update groups"
  on groups for update
  using (exists (
    select 1 from group_members
    where group_members.group_id = groups.id
    and group_members.user_id = auth.uid()
    and group_members.role = 'admin'
  ));

-- Group Members: Users can view members of groups they're in
create policy "Users can view group members"
  on group_members for select
  using (exists (
    select 1 from groups
    where groups.id = group_members.group_id
    and (groups.is_private = false or exists (
      select 1 from group_members gm
      where gm.group_id = groups.id
      and gm.user_id = auth.uid()
    ))
  ));

-- Group Members: Admins can add members
create policy "Group admins can add members"
  on group_members for insert
  with check (exists (
    select 1 from group_members gm
    where gm.group_id = group_members.group_id
    and gm.user_id = auth.uid()
    and gm.role = 'admin'
  ));

-- Group Members: Users can leave groups
create policy "Users can leave groups"
  on group_members for delete
  using (user_id = auth.uid() or exists (
    select 1 from group_members gm
    where gm.group_id = group_members.group_id
    and gm.user_id = auth.uid()
    and gm.role = 'admin'
  ));

-- Group Posts: Members can view group posts
create policy "Group members can view posts"
  on group_posts for select
  using (exists (
    select 1 from group_members
    where group_members.group_id = group_posts.group_id
    and group_members.user_id = auth.uid()
  ));

-- Group Posts: Members can create posts in groups
create policy "Group members can create posts"
  on group_posts for insert
  with check (exists (
    select 1 from group_members
    where group_members.group_id = group_posts.group_id
    and group_members.user_id = auth.uid()
  ));

-- Group Join Requests: Users can view their own requests
create policy "Users can view their join requests"
  on group_join_requests for select
  using (user_id = auth.uid() or exists (
    select 1 from group_members
    where group_members.group_id = group_join_requests.group_id
    and group_members.user_id = auth.uid()
    and group_members.role in ('admin', 'moderator')
  ));

-- Group Join Requests: Users can create requests
create policy "Users can create join requests"
  on group_join_requests for insert
  with check (auth.uid() = user_id);

-- Group Join Requests: Admins can update requests
create policy "Admins can update join requests"
  on group_join_requests for update
  using (exists (
    select 1 from group_members
    where group_members.group_id = group_join_requests.group_id
    and group_members.user_id = auth.uid()
    and group_members.role in ('admin', 'moderator')
  ));
