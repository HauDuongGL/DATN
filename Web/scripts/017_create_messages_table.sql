-- Create conversations table for chat threads
create table if not exists conversations (
  id uuid primary key default gen_random_uuid(),
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Create conversation_participants table
create table if not exists conversation_participants (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid references conversations(id) on delete cascade not null,
  user_id uuid references profiles(id) on delete cascade not null,
  last_read_at timestamp with time zone default now(),
  joined_at timestamp with time zone default now(),
  unique(conversation_id, user_id)
);

-- Create messages table
create table if not exists messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid references conversations(id) on delete cascade not null,
  sender_id uuid references profiles(id) on delete cascade not null,
  content text not null,
  is_read boolean default false,
  created_at timestamp with time zone default now()
);

-- Indexes
create index if not exists idx_conversation_participants_conversation on conversation_participants(conversation_id);
create index if not exists idx_conversation_participants_user on conversation_participants(user_id);
create index if not exists idx_messages_conversation on messages(conversation_id);
create index if not exists idx_messages_sender on messages(sender_id);
create index if not exists idx_messages_created_at on messages(created_at desc);

-- RLS Policies
alter table conversations enable row level security;
alter table conversation_participants enable row level security;
alter table messages enable row level security;

-- Conversations: Users can only view conversations they're part of
create policy "Users can view their conversations"
  on conversations for select
  using (exists (
    select 1 from conversation_participants
    where conversation_participants.conversation_id = conversations.id
    and conversation_participants.user_id = auth.uid()
  ));

-- Conversations: Authenticated users can create conversations
create policy "Authenticated users can create conversations"
  on conversations for insert
  with check (auth.role() = 'authenticated');

-- Conversation Participants: Users can view participants in their conversations
create policy "Users can view conversation participants"
  on conversation_participants for select
  using (exists (
    select 1 from conversation_participants cp
    where cp.conversation_id = conversation_participants.conversation_id
    and cp.user_id = auth.uid()
  ));

-- Conversation Participants: Users can add participants when creating conversation
create policy "Users can add conversation participants"
  on conversation_participants for insert
  with check (exists (
    select 1 from conversation_participants cp
    where cp.conversation_id = conversation_participants.conversation_id
    and cp.user_id = auth.uid()
  ) or not exists (
    select 1 from conversation_participants cp
    where cp.conversation_id = conversation_participants.conversation_id
  ));

-- Conversation Participants: Users can update their own participation
create policy "Users can update their participation"
  on conversation_participants for update
  using (user_id = auth.uid());

-- Messages: Users can view messages in their conversations
create policy "Users can view conversation messages"
  on messages for select
  using (exists (
    select 1 from conversation_participants
    where conversation_participants.conversation_id = messages.conversation_id
    and conversation_participants.user_id = auth.uid()
  ));

-- Messages: Users can send messages in their conversations
create policy "Users can send messages"
  on messages for insert
  with check (
    sender_id = auth.uid()
    and exists (
      select 1 from conversation_participants
      where conversation_participants.conversation_id = messages.conversation_id
      and conversation_participants.user_id = auth.uid()
    )
  );

-- Messages: Users can update their own messages
create policy "Users can update their messages"
  on messages for update
  using (sender_id = auth.uid());
