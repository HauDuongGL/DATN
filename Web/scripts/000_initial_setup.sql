-- ============================================
-- INITIAL SETUP - BASE TABLES
-- Run this script FIRST in Supabase SQL Editor
-- ============================================
-- This script consolidates all base table creation scripts (001-013)
-- to ensure the database schema is properly set up.

-- 1. Create profiles table
-- ============================================
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  full_name text,
  avatar_url text,
  bio text,
  followers_count integer default 0,
  following_count integer default 0,
  posts_count integer default 0,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Enable RLS
alter table public.profiles enable row level security;

-- RLS Policies for profiles
drop policy if exists "Profiles are viewable by everyone" on public.profiles;
create policy "Profiles are viewable by everyone"
  on public.profiles for select
  using (true);

drop policy if exists "Users can update their own profile" on public.profiles;
create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Indexes
create index if not exists profiles_username_idx on public.profiles(username);


-- 2. Create posts table for flower sharing
-- ============================================
create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  caption text,
  flower_name text,
  flower_species text,
  location text,
  tags text[],
  ai_confidence numeric(5,2),
  is_public boolean default true,
  status text default 'pending' check (status in ('pending', 'approved', 'rejected')),
  likes_count integer default 0,
  comments_count integer default 0,
  shares_count integer default 0,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Enable RLS
alter table public.posts enable row level security;

-- RLS Policies for posts
drop policy if exists "Public posts are viewable by everyone" on public.posts;
create policy "Public posts are viewable by everyone"
  on public.posts for select
  using (
    (is_public = true and status = 'approved')
    or author_id = auth.uid()
  );

drop policy if exists "Users can insert their own posts" on public.posts;
create policy "Users can insert their own posts"
  on public.posts for insert
  with check (auth.uid() = author_id);

drop policy if exists "Users can update their own posts" on public.posts;
create policy "Users can update their own posts"
  on public.posts for update
  using (auth.uid() = author_id);

drop policy if exists "Users can delete their own posts" on public.posts;
create policy "Users can delete their own posts"
  on public.posts for delete
  using (auth.uid() = author_id);

-- Indexes for performance
create index if not exists posts_author_id_idx on public.posts(author_id);
create index if not exists posts_status_idx on public.posts(status);
create index if not exists posts_created_at_idx on public.posts(created_at desc);


-- 3. Create post_media table
-- ============================================
create table if not exists public.post_media (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  media_url text not null,
  media_type text not null check (media_type in ('image', 'video')),
  display_order integer default 0,
  created_at timestamp with time zone default now()
);

-- Enable RLS
alter table public.post_media enable row level security;

-- RLS Policies for post_media
drop policy if exists "Post media is viewable through posts" on public.post_media;
create policy "Post media is viewable through posts"
  on public.post_media for select
  using (
    exists (
      select 1 from public.posts
      where posts.id = post_media.post_id
      and ((posts.is_public = true and posts.status = 'approved') or posts.author_id = auth.uid())
    )
  );

drop policy if exists "Users can insert media for their posts" on public.post_media;
create policy "Users can insert media for their posts"
  on public.post_media for insert
  with check (
    exists (
      select 1 from public.posts
      where posts.id = post_media.post_id
      and posts.author_id = auth.uid()
    )
  );

drop policy if exists "Users can delete media from their posts" on public.post_media;
create policy "Users can delete media from their posts"
  on public.post_media for delete
  using (
    exists (
      select 1 from public.posts
      where posts.id = post_media.post_id
      and posts.author_id = auth.uid()
    )
  );

-- Indexes
create index if not exists post_media_post_id_idx on public.post_media(post_id);


-- 4. Create comments table
-- ============================================
create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete cascade,
  content text not null,
  likes_count integer default 0,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Enable RLS
alter table public.comments enable row level security;

-- RLS Policies for comments
drop policy if exists "Comments are viewable through posts" on public.comments;
create policy "Comments are viewable through posts"
  on public.comments for select
  using (
    exists (
      select 1 from public.posts
      where posts.id = comments.post_id
      and ((posts.is_public = true and posts.status = 'approved') or posts.author_id = auth.uid())
    )
  );

drop policy if exists "Authenticated users can create comments" on public.comments;
create policy "Authenticated users can create comments"
  on public.comments for insert
  with check (auth.uid() = author_id);

drop policy if exists "Users can update their own comments" on public.comments;
create policy "Users can update their own comments"
  on public.comments for update
  using (auth.uid() = author_id);

drop policy if exists "Users can delete their own comments" on public.comments;
create policy "Users can delete their own comments"
  on public.comments for delete
  using (auth.uid() = author_id);

-- Indexes
create index if not exists comments_post_id_idx on public.comments(post_id);
create index if not exists comments_author_id_idx on public.comments(author_id);
create index if not exists comments_created_at_idx on public.comments(created_at desc);


-- 5. Create likes table
-- ============================================
create table if not exists public.likes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  post_id uuid references public.posts(id) on delete cascade,
  comment_id uuid references public.comments(id) on delete cascade,
  created_at timestamp with time zone default now(),
  constraint likes_target_check check (
    (post_id is not null and comment_id is null) or
    (post_id is null and comment_id is not null)
  ),
  unique(user_id, post_id),
  unique(user_id, comment_id)
);

-- Enable RLS
alter table public.likes enable row level security;

-- RLS Policies for likes
drop policy if exists "Likes are viewable by everyone" on public.likes;
create policy "Likes are viewable by everyone"
  on public.likes for select
  using (true);

drop policy if exists "Authenticated users can like" on public.likes;
create policy "Authenticated users can like"
  on public.likes for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users can remove their likes" on public.likes;
create policy "Users can remove their likes"
  on public.likes for delete
  using (auth.uid() = user_id);

-- Indexes
create index if not exists likes_user_id_idx on public.likes(user_id);
create index if not exists likes_post_id_idx on public.likes(post_id);
create index if not exists likes_comment_id_idx on public.likes(comment_id);


-- 6. Create follows table
-- ============================================
create table if not exists public.follows (
  id uuid primary key default gen_random_uuid(),
  follower_id uuid not null references public.profiles(id) on delete cascade,
  following_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamp with time zone default now(),
  unique(follower_id, following_id),
  constraint follows_self_check check (follower_id != following_id)
);

-- Enable RLS
alter table public.follows enable row level security;

-- RLS Policies for follows
drop policy if exists "Follows are viewable by everyone" on public.follows;
create policy "Follows are viewable by everyone"
  on public.follows for select
  using (true);

drop policy if exists "Authenticated users can follow" on public.follows;
create policy "Authenticated users can follow"
  on public.follows for insert
  with check (auth.uid() = follower_id);

drop policy if exists "Users can unfollow" on public.follows;
create policy "Users can unfollow"
  on public.follows for delete
  using (auth.uid() = follower_id);

-- Indexes
create index if not exists follows_follower_id_idx on public.follows(follower_id);
create index if not exists follows_following_id_idx on public.follows(following_id);


-- 7. Create notifications table
-- ============================================
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_id uuid not null references public.profiles(id) on delete cascade,
  actor_id uuid references public.profiles(id) on delete cascade,
  type text not null check (type in ('like', 'comment', 'follow', 'mention')),
  post_id uuid references public.posts(id) on delete cascade,
  comment_id uuid references public.comments(id) on delete cascade,
  is_read boolean default false,
  created_at timestamp with time zone default now()
);

-- Enable RLS
alter table public.notifications enable row level security;

-- RLS Policies for notifications
drop policy if exists "Users can view their own notifications" on public.notifications;
create policy "Users can view their own notifications"
  on public.notifications for select
  using (auth.uid() = recipient_id);

drop policy if exists "System can create notifications" on public.notifications;
create policy "System can create notifications"
  on public.notifications for insert
  with check (true);

drop policy if exists "Users can update their own notifications" on public.notifications;
create policy "Users can update their own notifications"
  on public.notifications for update
  using (auth.uid() = recipient_id);

drop policy if exists "Users can delete their own notifications" on public.notifications;
create policy "Users can delete their own notifications"
  on public.notifications for delete
  using (auth.uid() = recipient_id);

-- Indexes
create index if not exists notifications_recipient_id_idx on public.notifications(recipient_id);
create index if not exists notifications_created_at_idx on public.notifications(created_at desc);
create index if not exists notifications_is_read_idx on public.notifications(is_read);


-- 8. Create admin_users table
-- ============================================
create table if not exists public.admin_users (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade unique,
  role text not null default 'moderator' check (role in ('admin', 'moderator')),
  created_at timestamp with time zone default now()
);

-- Enable RLS
alter table public.admin_users enable row level security;

-- RLS Policies for admin_users
drop policy if exists "Admin users are viewable by authenticated users" on public.admin_users;
create policy "Admin users are viewable by authenticated users"
  on public.admin_users for select
  using (auth.role() = 'authenticated');

-- Indexes
create index if not exists admin_users_user_id_idx on public.admin_users(user_id);


-- 9. Create reports table
-- ============================================
create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  reported_user_id uuid references public.profiles(id) on delete cascade,
  reported_post_id uuid references public.posts(id) on delete cascade,
  reported_comment_id uuid references public.comments(id) on delete cascade,
  reason text not null,
  description text,
  status text default 'pending' check (status in ('pending', 'reviewing', 'resolved', 'dismissed')),
  resolved_by uuid references public.admin_users(user_id),
  resolved_at timestamp with time zone,
  created_at timestamp with time zone default now(),
  constraint reports_target_check check (
    (reported_user_id is not null) or
    (reported_post_id is not null) or
    (reported_comment_id is not null)
  )
);

-- Enable RLS
alter table public.reports enable row level security;

-- RLS Policies for reports
drop policy if exists "Users can view their own reports" on public.reports;
create policy "Users can view their own reports"
  on public.reports for select
  using (
    auth.uid() = reporter_id or
    exists (
      select 1 from public.admin_users
      where admin_users.user_id = auth.uid()
    )
  );

drop policy if exists "Authenticated users can create reports" on public.reports;
create policy "Authenticated users can create reports"
  on public.reports for insert
  with check (auth.uid() = reporter_id);

drop policy if exists "Admins can update reports" on public.reports;
create policy "Admins can update reports"
  on public.reports for update
  using (
    exists (
      select 1 from public.admin_users
      where admin_users.user_id = auth.uid()
    )
  );

-- Indexes
create index if not exists reports_reporter_id_idx on public.reports(reporter_id);
create index if not exists reports_status_idx on public.reports(status);
create index if not exists reports_created_at_idx on public.reports(created_at desc);


-- 10. Create helper functions and triggers
-- ============================================

-- Function to handle updated_at timestamp
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Updated at triggers
drop trigger if exists profiles_updated_at on public.profiles;
create trigger profiles_updated_at
  before update on public.profiles
  for each row
  execute function public.handle_updated_at();

drop trigger if exists posts_updated_at on public.posts;
create trigger posts_updated_at
  before update on public.posts
  for each row
  execute function public.handle_updated_at();

drop trigger if exists comments_updated_at on public.comments;
create trigger comments_updated_at
  before update on public.comments
  for each row
  execute function public.handle_updated_at();


-- Function to handle new user profile creation
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username, full_name, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'username', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    coalesce(new.raw_user_meta_data->>'avatar_url', '')
  );
  return new;
end;
$$ language plpgsql security definer;

-- Trigger to create profile on user signup
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();


-- 11. Counter functions for posts, comments, likes
-- ============================================

-- Increment post likes
create or replace function increment_post_likes()
returns trigger as $$
begin
  update public.posts
  set likes_count = likes_count + 1
  where id = new.post_id;
  return new;
end;
$$ language plpgsql;

-- Decrement post likes
create or replace function decrement_post_likes()
returns trigger as $$
begin
  update public.posts
  set likes_count = likes_count - 1
  where id = old.post_id;
  return old;
end;
$$ language plpgsql;

-- Increment comment likes
create or replace function increment_comment_likes()
returns trigger as $$
begin
  update public.comments
  set likes_count = likes_count + 1
  where id = new.comment_id;
  return new;
end;
$$ language plpgsql;

-- Decrement comment likes
create or replace function decrement_comment_likes()
returns trigger as $$
begin
  update public.comments
  set likes_count = likes_count - 1
  where id = old.comment_id;
  return old;
end;
$$ language plpgsql;

-- Increment post comments
create or replace function increment_post_comments()
returns trigger as $$
begin
  update public.posts
  set comments_count = comments_count + 1
  where id = new.post_id;
  return new;
end;
$$ language plpgsql;

-- Decrement post comments
create or replace function decrement_post_comments()
returns trigger as $$
begin
  update public.posts
  set comments_count = comments_count - 1
  where id = old.post_id;
  return old;
end;
$$ language plpgsql;

-- Increment author posts count
create or replace function increment_author_posts()
returns trigger as $$
begin
  update public.profiles
  set posts_count = posts_count + 1
  where id = new.author_id;
  return new;
end;
$$ language plpgsql;

-- Decrement author posts count
create or replace function decrement_author_posts()
returns trigger as $$
begin
  update public.profiles
  set posts_count = posts_count - 1
  where id = old.author_id;
  return old;
end;
$$ language plpgsql;

-- Increment followers/following counts
create or replace function increment_follow_counts()
returns trigger as $$
begin
  update public.profiles
  set following_count = following_count + 1
  where id = new.follower_id;
  
  update public.profiles
  set followers_count = followers_count + 1
  where id = new.following_id;
  
  return new;
end;
$$ language plpgsql;

-- Decrement followers/following counts
create or replace function decrement_follow_counts()
returns trigger as $$
begin
  update public.profiles
  set following_count = following_count - 1
  where id = old.follower_id;
  
  update public.profiles
  set followers_count = followers_count - 1
  where id = old.following_id;
  
  return old;
end;
$$ language plpgsql;


-- 12. Create triggers for counters
-- ============================================

-- Likes on posts
drop trigger if exists on_post_like_added on public.likes;
create trigger on_post_like_added
  after insert on public.likes
  for each row
  when (new.post_id is not null)
  execute function increment_post_likes();

drop trigger if exists on_post_like_removed on public.likes;
create trigger on_post_like_removed
  after delete on public.likes
  for each row
  when (old.post_id is not null)
  execute function decrement_post_likes();

-- Likes on comments
drop trigger if exists on_comment_like_added on public.likes;
create trigger on_comment_like_added
  after insert on public.likes
  for each row
  when (new.comment_id is not null)
  execute function increment_comment_likes();

drop trigger if exists on_comment_like_removed on public.likes;
create trigger on_comment_like_removed
  after delete on public.likes
  for each row
  when (old.comment_id is not null)
  execute function decrement_comment_likes();

-- Comments on posts
drop trigger if exists on_comment_added on public.comments;
create trigger on_comment_added
  after insert on public.comments
  for each row
  execute function increment_post_comments();

drop trigger if exists on_comment_removed on public.comments;
create trigger on_comment_removed
  after delete on public.comments
  for each row
  execute function decrement_post_comments();

-- Posts by author
drop trigger if exists on_post_created on public.posts;
create trigger on_post_created
  after insert on public.posts
  for each row
  execute function increment_author_posts();

drop trigger if exists on_post_deleted on public.posts;
create trigger on_post_deleted
  after delete on public.posts
  for each row
  execute function decrement_author_posts();

-- Follows
drop trigger if exists on_follow_added on public.follows;
create trigger on_follow_added
  after insert on public.follows
  for each row
  execute function increment_follow_counts();

drop trigger if exists on_follow_removed on public.follows;
create trigger on_follow_removed
  after delete on public.follows
  for each row
  execute function decrement_follow_counts();


-- 13. Create storage buckets and policies
-- ============================================

-- Create storage buckets
insert into storage.buckets (id, name, public)
values 
  ('avatars', 'avatars', true),
  ('post-images', 'post-images', true)
on conflict (id) do nothing;

-- RLS for avatars bucket
drop policy if exists "Avatar images are publicly accessible" on storage.objects;
create policy "Avatar images are publicly accessible"
  on storage.objects for select
  using (bucket_id = 'avatars');

drop policy if exists "Authenticated users can upload avatars" on storage.objects;
create policy "Authenticated users can upload avatars"
  on storage.objects for insert
  with check (
    bucket_id = 'avatars'
    and auth.role() = 'authenticated'
  );

drop policy if exists "Users can update their own avatars" on storage.objects;
create policy "Users can update their own avatars"
  on storage.objects for update
  using (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists "Users can delete their own avatars" on storage.objects;
create policy "Users can delete their own avatars"
  on storage.objects for delete
  using (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

-- RLS for post-images bucket
drop policy if exists "Post images are publicly accessible" on storage.objects;
create policy "Post images are publicly accessible"
  on storage.objects for select
  using (bucket_id = 'post-images');

drop policy if exists "Authenticated users can upload post images" on storage.objects;
create policy "Authenticated users can upload post images"
  on storage.objects for insert
  with check (
    bucket_id = 'post-images'
    and auth.role() = 'authenticated'
  );

drop policy if exists "Users can update their own post images" on storage.objects;
create policy "Users can update their own post images"
  on storage.objects for update
  using (
    bucket_id = 'post-images'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists "Users can delete their own post images" on storage.objects;
create policy "Users can delete their own post images"
  on storage.objects for delete
  using (
    bucket_id = 'post-images'
    and auth.uid()::text = (storage.foldername(name))[1]
  );


-- ============================================
-- SUCCESS MESSAGE
-- ============================================
do $$
begin
  raise notice 'Initial setup completed successfully!';
  raise notice 'All base tables created with RLS policies and triggers.';
  raise notice 'Next step: Run 100_consolidated_new_features.sql for Groups, Messages, and Onboarding features.';
end $$;
