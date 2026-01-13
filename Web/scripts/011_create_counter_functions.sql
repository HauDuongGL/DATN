-- Function to update likes count on posts
create or replace function public.update_post_likes_count()
returns trigger as $$
begin
  if TG_OP = 'INSERT' and new.post_id is not null then
    update public.posts
    set likes_count = likes_count + 1
    where id = new.post_id;
  elsif TG_OP = 'DELETE' and old.post_id is not null then
    update public.posts
    set likes_count = greatest(0, likes_count - 1)
    where id = old.post_id;
  end if;
  return coalesce(new, old);
end;
$$ language plpgsql;

create trigger likes_update_post_count
  after insert or delete on public.likes
  for each row
  execute function public.update_post_likes_count();

-- Function to update comments count on posts
create or replace function public.update_post_comments_count()
returns trigger as $$
begin
  if TG_OP = 'INSERT' then
    update public.posts
    set comments_count = comments_count + 1
    where id = new.post_id;
  elsif TG_OP = 'DELETE' then
    update public.posts
    set comments_count = greatest(0, comments_count - 1)
    where id = old.post_id;
  end if;
  return coalesce(new, old);
end;
$$ language plpgsql;

create trigger comments_update_post_count
  after insert or delete on public.comments
  for each row
  execute function public.update_post_comments_count();

-- Function to update likes count on comments
create or replace function public.update_comment_likes_count()
returns trigger as $$
begin
  if TG_OP = 'INSERT' and new.comment_id is not null then
    update public.comments
    set likes_count = likes_count + 1
    where id = new.comment_id;
  elsif TG_OP = 'DELETE' and old.comment_id is not null then
    update public.comments
    set likes_count = greatest(0, likes_count - 1)
    where id = old.comment_id;
  end if;
  return coalesce(new, old);
end;
$$ language plpgsql;

create trigger likes_update_comment_count
  after insert or delete on public.likes
  for each row
  execute function public.update_comment_likes_count();
