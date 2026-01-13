-- 1. Create function to add creator as admin
create or replace function public.handle_new_group()
returns trigger
language plpgsql
security definer
as $$
begin
  insert into public.group_members (group_id, user_id, role)
  values (new.id, new.created_by, 'admin');
  return new;
end;
$$;

-- 2. Create trigger
drop trigger if exists on_group_created on public.groups;
create trigger on_group_created
  after insert on public.groups
  for each row
  execute function public.handle_new_group();

-- 3. Backfill: Add existing group creators as admins if not already members
insert into public.group_members (group_id, user_id, role)
select id, created_by, 'admin'
from public.groups
where not exists (
  select 1 from public.group_members
  where group_members.group_id = groups.id
  and group_members.user_id = groups.created_by
);
