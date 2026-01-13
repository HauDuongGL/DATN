-- Enable Group Admins to Manage Posts

-- 1. Allow Group Admins to UPDATE posts (Approve/Reject)
-- This allows updating the status of a post if it belongs to a group where the user is an admin
create policy "Group admins can update group posts"
  on public.posts for update
  using (
    exists (
      select 1 from public.group_posts gp
      join public.group_members gm on gp.group_id = gm.group_id
      where gp.post_id = posts.id
      and gm.user_id = auth.uid()
      and gm.role in ('admin', 'moderator')
    )
  );

-- 2. Allow Group Admins to DELETE group_posts association
-- This removes the post from the group (doesn't necessarily delete the post itself, unless cascade)
create policy "Group admins can remove posts from group"
  on public.group_posts for delete
  using (
    exists (
      select 1 from public.group_members gm
      where gm.group_id = group_posts.group_id
      and gm.user_id = auth.uid()
      and gm.role in ('admin', 'moderator')
    )
  );

-- 3. Allow Group Admins to DELETE the actual post (Optional, strict moderation)
create policy "Group admins can delete group posts"
  on public.posts for delete
  using (
    exists (
      select 1 from public.group_posts gp
      join public.group_members gm on gp.group_id = gm.group_id
      where gp.post_id = posts.id
      and gm.user_id = auth.uid()
      and gm.role = 'admin'
    )
  );

-- 4. Create index to speed up these lookups
create index if not exists idx_group_members_role on public.group_members(role);
