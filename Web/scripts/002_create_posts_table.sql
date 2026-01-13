-- Create posts table for flower sharing
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
create policy "Public posts are viewable by everyone"
  on public.posts for select
  using (
    (is_public = true and status = 'approved')
    or author_id = auth.uid()
  );

create policy "Users can insert their own posts"
  on public.posts for insert
  with check (auth.uid() = author_id);

create policy "Users can update their own posts"
  on public.posts for update
  using (auth.uid() = author_id);

create policy "Users can delete their own posts"
  on public.posts for delete
  using (auth.uid() = author_id);

-- Indexes for performance
create index posts_author_id_idx on public.posts(author_id);
create index posts_status_idx on public.posts(status);
create index posts_created_at_idx on public.posts(created_at desc);

-- Updated at trigger
create trigger posts_updated_at
  before update on public.posts
  for each row
  execute function public.handle_updated_at();
