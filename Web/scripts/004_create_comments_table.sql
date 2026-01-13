-- Create comments table
create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete cascade,
  parent_comment_id uuid references public.comments(id) on delete cascade,
  content text not null,
  likes_count integer default 0,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Enable RLS
alter table public.comments enable row level security;

-- RLS Policies for comments
create policy "Comments are viewable with post"
  on public.comments for select
  using (
    exists (
      select 1 from public.posts
      where posts.id = comments.post_id
      and (
        (posts.is_public = true and posts.status = 'approved')
        or posts.author_id = auth.uid()
      )
    )
  );

create policy "Users can insert comments on visible posts"
  on public.comments for insert
  with check (
    auth.uid() = author_id
    and exists (
      select 1 from public.posts
      where posts.id = comments.post_id
      and (posts.is_public = true and posts.status = 'approved')
    )
  );

create policy "Users can update their own comments"
  on public.comments for update
  using (auth.uid() = author_id);

create policy "Users can delete their own comments"
  on public.comments for delete
  using (auth.uid() = author_id);

-- Indexes
create index comments_post_id_idx on public.comments(post_id);
create index comments_author_id_idx on public.comments(author_id);
create index comments_parent_comment_id_idx on public.comments(parent_comment_id);

-- Updated at trigger
create trigger comments_updated_at
  before update on public.comments
  for each row
  execute function public.handle_updated_at();
