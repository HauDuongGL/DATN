-- Function to update group member count
create or replace function update_group_member_count()
returns trigger as $$
begin
  if TG_OP = 'INSERT' then
    update groups
    set member_count = member_count + 1
    where id = NEW.group_id;
    return NEW;
  elsif TG_OP = 'DELETE' then
    update groups
    set member_count = member_count - 1
    where id = OLD.group_id;
    return OLD;
  end if;
  return null;
end;
$$ language plpgsql;

-- Trigger for group member count
drop trigger if exists group_member_count_trigger on group_members;
create trigger group_member_count_trigger
after insert or delete on group_members
for each row execute function update_group_member_count();

-- Function to update group post count
create or replace function update_group_post_count()
returns trigger as $$
begin
  if TG_OP = 'INSERT' then
    update groups
    set post_count = post_count + 1
    where id = NEW.group_id;
    return NEW;
  elsif TG_OP = 'DELETE' then
    update groups
    set post_count = post_count - 1
    where id = OLD.group_id;
    return OLD;
  end if;
  return null;
end;
$$ language plpgsql;

-- Trigger for group post count
drop trigger if exists group_post_count_trigger on group_posts;
create trigger group_post_count_trigger
after insert or delete on group_posts
for each row execute function update_group_post_count();

-- Function to auto-add creator as admin when group is created
create or replace function add_group_creator_as_admin()
returns trigger as $$
begin
  insert into group_members (group_id, user_id, role)
  values (NEW.id, NEW.created_by, 'admin');
  return NEW;
end;
$$ language plpgsql;

-- Trigger to add creator as admin
drop trigger if exists add_group_creator_trigger on groups;
create trigger add_group_creator_trigger
after insert on groups
for each row execute function add_group_creator_as_admin();
