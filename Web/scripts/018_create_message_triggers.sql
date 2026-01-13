-- Function to update conversation updated_at when new message is sent
create or replace function update_conversation_timestamp()
returns trigger as $$
begin
  update conversations
  set updated_at = now()
  where id = NEW.conversation_id;
  return NEW;
end;
$$ language plpgsql;

-- Trigger to update conversation timestamp
drop trigger if exists update_conversation_timestamp_trigger on messages;
create trigger update_conversation_timestamp_trigger
after insert on messages
for each row execute function update_conversation_timestamp();
