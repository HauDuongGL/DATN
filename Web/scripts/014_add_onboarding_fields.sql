-- Add onboarding_completed field to profiles table
alter table profiles
add column if not exists onboarding_completed boolean default false,
add column if not exists interests text[] default '{}',
add column if not exists favorite_flowers text[] default '{}';

-- Add index for querying
create index if not exists idx_profiles_onboarding on profiles(onboarding_completed);

comment on column profiles.onboarding_completed is 'Whether user has completed onboarding flow';
comment on column profiles.interests is 'User interests (gardening, photography, botany, etc.)';
comment on column profiles.favorite_flowers is 'User favorite flower types';
