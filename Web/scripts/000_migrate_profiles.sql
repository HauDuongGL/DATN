-- ============================================
-- MIGRATION: Update Profiles Table Schema
-- Chạy script này nếu bạn gặp lỗi "column username does not exist"
-- ============================================
-- Script này sẽ cập nhật bảng profiles hiện có để phù hợp với schema mới

-- Kiểm tra và thêm cột username nếu chưa có
do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' 
    and table_name = 'profiles' 
    and column_name = 'username'
  ) then
    -- Thêm cột username
    alter table public.profiles add column username text;
    
    -- Điền dữ liệu cho username từ email hoặc display_name
    update public.profiles
    set username = coalesce(
      split_part(email, '@', 1),
      lower(replace(display_name, ' ', '_')),
      'user_' || substring(id::text, 1, 8)
    )
    where username is null;
    
    -- Đặt constraint unique và not null
    alter table public.profiles 
      alter column username set not null,
      add constraint profiles_username_unique unique (username);
    
    raise notice 'Đã thêm cột username vào bảng profiles';
  else
    raise notice 'Cột username đã tồn tại trong bảng profiles';
  end if;
end $$;

-- Kiểm tra và đổi tên cột display_name thành full_name nếu cần
do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' 
    and table_name = 'profiles' 
    and column_name = 'display_name'
  ) and not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' 
    and table_name = 'profiles' 
    and column_name = 'full_name'
  ) then
    -- Đổi tên cột display_name thành full_name
    alter table public.profiles rename column display_name to full_name;
    raise notice 'Đã đổi tên cột display_name thành full_name';
  else
    raise notice 'Cột full_name đã tồn tại hoặc display_name không tồn tại';
  end if;
end $$;

-- Thêm các cột đếm nếu chưa có
do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' 
    and table_name = 'profiles' 
    and column_name = 'followers_count'
  ) then
    alter table public.profiles add column followers_count integer default 0;
    raise notice 'Đã thêm cột followers_count';
  end if;
  
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' 
    and table_name = 'profiles' 
    and column_name = 'following_count'
  ) then
    alter table public.profiles add column following_count integer default 0;
    raise notice 'Đã thêm cột following_count';
  end if;
  
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' 
    and table_name = 'profiles' 
    and column_name = 'posts_count'
  ) then
    alter table public.profiles add column posts_count integer default 0;
    raise notice 'Đã thêm cột posts_count';
  end if;
end $$;

-- Xóa cột email nếu không cần thiết (tùy chọn - comment out nếu bạn muốn giữ)
-- do $$
-- begin
--   if exists (
--     select 1 from information_schema.columns
--     where table_schema = 'public' 
--     and table_name = 'profiles' 
--     and column_name = 'email'
--   ) then
--     alter table public.profiles drop column email;
--     raise notice 'Đã xóa cột email';
--   end if;
-- end $$;

-- Xóa các cột không cần thiết khác (tùy chọn)
do $$
begin
  -- Xóa location nếu có (vì schema mới không dùng)
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' 
    and table_name = 'profiles' 
    and column_name = 'location'
  ) then
    alter table public.profiles drop column location;
    raise notice 'Đã xóa cột location';
  end if;
  
  -- Xóa website nếu có
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' 
    and table_name = 'profiles' 
    and column_name = 'website'
  ) then
    alter table public.profiles drop column website;
    raise notice 'Đã xóa cột website';
  end if;
  
  -- Xóa phone nếu có
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' 
    and table_name = 'profiles' 
    and column_name = 'phone'
  ) then
    alter table public.profiles drop column phone;
    raise notice 'Đã xóa cột phone';
  end if;
  
  -- Xóa is_private nếu có
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' 
    and table_name = 'profiles' 
    and column_name = 'is_private'
  ) then
    alter table public.profiles drop column is_private;
    raise notice 'Đã xóa cột is_private';
  end if;
end $$;

-- Tạo index cho username nếu chưa có
create index if not exists profiles_username_idx on public.profiles(username);

-- Cập nhật hoặc tạo function handle_new_user
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username, full_name, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'username', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    coalesce(new.raw_user_meta_data->>'avatar_url', '')
  )
  on conflict (id) do update
  set
    username = coalesce(excluded.username, profiles.username),
    full_name = coalesce(excluded.full_name, profiles.full_name),
    avatar_url = coalesce(excluded.avatar_url, profiles.avatar_url);
  return new;
end;
$$ language plpgsql security definer;

-- Đảm bảo trigger tồn tại
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Thông báo hoàn thành
do $$
begin
  raise notice '==============================================';
  raise notice 'Migration hoàn thành!';
  raise notice 'Bảng profiles đã được cập nhật với schema mới.';
  raise notice 'Bây giờ bạn có thể chạy lại script 000_initial_setup.sql';
  raise notice 'hoặc tiếp tục với các bước tiếp theo.';
  raise notice '==============================================';
end $$;
