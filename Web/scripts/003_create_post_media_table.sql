-- Create post_media table for storing multiple images per post
create table if not exists public.post_media (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  media_url text not null,
  media_type text not null check (media_type in ('image', 'video')),
  thumbnail_url text,
  width integer,
  height integer,
  file_size integer,
  display_order integer default 0,
  created_at timestamp with time zone default now()
);

-- Enable RLS
alter table public.post_media enable row level security;

-- RLS Policies for post_media
create policy "Post media is viewable with post"
  on public.post_media for select
  using (
    exists (
      select 1 from public.posts
      where posts.id = post_media.post_id
      and (
        (posts.is_public = true and posts.status = 'approved')
        or posts.author_id = auth.uid()
      )
    )
  );

create policy "Users can insert media for their own posts"
  on public.post_media for insert
  with check (
    exists (
      select 1 from public.posts
      where posts.id = post_media.post_id
      and posts.author_id = auth.uid()
    )
  );

create policy "Users can delete their own post media"
  on public.post_media for delete
  using (
    exists (
      select 1 from public.posts
      where posts.id = post_media.post_id
      and posts.author_id = auth.uid()
    )
  );

-- Index for performance
create index post_media_post_id_idx on public.post_media(post_id);
