-- Function to create notification on like
create or replace function public.notify_on_like()
returns trigger as $$
declare
  v_post_author_id uuid;
  v_comment_author_id uuid;
begin
  if new.post_id is not null then
    select author_id into v_post_author_id
    from public.posts
    where id = new.post_id;
    
    if v_post_author_id != new.user_id then
      insert into public.notifications (recipient_id, sender_id, type, post_id)
      values (v_post_author_id, new.user_id, 'like', new.post_id);
    end if;
  elsif new.comment_id is not null then
    select author_id into v_comment_author_id
    from public.comments
    where id = new.comment_id;
    
    if v_comment_author_id != new.user_id then
      insert into public.notifications (recipient_id, sender_id, type, comment_id)
      values (v_comment_author_id, new.user_id, 'like', new.comment_id);
    end if;
  end if;
  
  return new;
end;
$$ language plpgsql;

create trigger likes_create_notification
  after insert on public.likes
  for each row
  execute function public.notify_on_like();

-- Function to create notification on comment
create or replace function public.notify_on_comment()
returns trigger as $$
declare
  v_post_author_id uuid;
begin
  select author_id into v_post_author_id
  from public.posts
  where id = new.post_id;
  
  if v_post_author_id != new.author_id then
    insert into public.notifications (recipient_id, sender_id, type, post_id, comment_id)
    values (v_post_author_id, new.author_id, 'comment', new.post_id, new.id);
  end if;
  
  return new;
end;
$$ language plpgsql;

create trigger comments_create_notification
  after insert on public.comments
  for each row
  execute function public.notify_on_comment();

-- Function to create notification on follow
create or replace function public.notify_on_follow()
returns trigger as $$
begin
  insert into public.notifications (recipient_id, sender_id, type)
  values (new.following_id, new.follower_id, 'follow');
  
  return new;
end;
$$ language plpgsql;

create trigger follows_create_notification
  after insert on public.follows
  for each row
  execute function public.notify_on_follow();
