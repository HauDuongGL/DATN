"use client"

import { useEffect, useState } from "react"
import { createBrowserClient } from "@/lib/supabase/client"
import { formatDistanceToNow } from "date-fns"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"

interface Conversation {
  id: string
  updated_at: string
  other_user: {
    id: string
    display_name: string
    avatar_url: string | null
  }
  last_message: {
    content: string
    created_at: string
  } | null
  unread_count: number
}

interface ConversationsListProps {
  userId: string
  selectedId: string | null
  onSelect: (id: string) => void
  searchQuery: string
}

export default function ConversationsList({ userId, selectedId, onSelect, searchQuery }: ConversationsListProps) {
  const supabase = createBrowserClient()
  const [conversations, setConversations] = useState<Conversation[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchConversations()

    // Subscribe to new messages
    const channel = supabase
      .channel("conversations")
      .on("postgres_changes", { event: "*", schema: "public", table: "messages" }, () => {
        fetchConversations()
      })
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [])

  const fetchConversations = async () => {
    try {
      // Get user's conversations
      const { data: participations, error: participationsError } = await supabase
        .from("conversation_participants")
        .select("conversation_id, last_read_at")
        .eq("user_id", userId)

      if (participationsError) throw participationsError

      if (!participations || participations.length === 0) {
        setConversations([])
        setLoading(false)
        return
      }

      const conversationIds = participations.map((p) => p.conversation_id)

      // Get conversations with details
      const { data: conversationsData, error: conversationsError } = await supabase
        .from("conversations")
        .select("id, updated_at")
        .in("id", conversationIds)
        .order("updated_at", { ascending: false })

      if (conversationsError) throw conversationsError

      // For each conversation, get the other participant and last message
      const conversationsWithDetails = await Promise.all(
        (conversationsData || []).map(async (conv) => {
          // Get other participant
          const { data: otherParticipant } = await supabase
            .from("conversation_participants")
            .select("user_id, profiles(id, display_name, avatar_url)")
            .eq("conversation_id", conv.id)
            .neq("user_id", userId)
            .single()

          // Get last message
          const { data: lastMessage } = await supabase
            .from("messages")
            .select("content, created_at")
            .eq("conversation_id", conv.id)
            .order("created_at", { ascending: false })
            .limit(1)
            .single()

          // Get unread count
          const participation = participations.find((p) => p.conversation_id === conv.id)
          const { count: unreadCount } = await supabase
            .from("messages")
            .select("*", { count: "exact", head: true })
            .eq("conversation_id", conv.id)
            .neq("sender_id", userId)
            .gt("created_at", participation?.last_read_at || new Date(0).toISOString())

          return {
            id: conv.id,
            updated_at: conv.updated_at,
            other_user: {
              id: otherParticipant?.user_id || "",
              display_name: (otherParticipant?.profiles as any)?.display_name || "Unknown User",
              avatar_url: (otherParticipant?.profiles as any)?.avatar_url || null,
            },
            last_message: lastMessage,
            unread_count: unreadCount || 0,
          }
        }),
      )

      setConversations(conversationsWithDetails)
    } catch (error) {
      console.error("Error fetching conversations:", error)
    } finally {
      setLoading(false)
    }
  }

  const filteredConversations = conversations.filter((conv) =>
    conv.other_user.display_name.toLowerCase().includes(searchQuery.toLowerCase()),
  )

  if (loading) {
    return <div className="p-4 text-center text-neutral-600">Loading conversations...</div>
  }

  if (filteredConversations.length === 0) {
    return (
      <div className="p-4 text-center text-neutral-600">
        {searchQuery ? "No conversations found" : "No conversations yet"}
      </div>
    )
  }

  return (
    <div>
      {filteredConversations.map((conversation) => (
        <button
          key={conversation.id}
          onClick={() => onSelect(conversation.id)}
          className={`w-full p-4 flex items-start gap-3 hover:bg-neutral-50 transition-colors border-b ${
            selectedId === conversation.id ? "bg-emerald-50" : ""
          }`}
        >
          <Avatar>
            <AvatarImage src={conversation.other_user.avatar_url || "/placeholder.svg"} />
            <AvatarFallback className="bg-emerald-100 text-emerald-700">
              {conversation.other_user.display_name.charAt(0).toUpperCase()}
            </AvatarFallback>
          </Avatar>
          <div className="flex-1 text-left min-w-0">
            <div className="flex items-center justify-between mb-1">
              <h3 className="font-medium text-neutral-900 truncate">{conversation.other_user.display_name}</h3>
              {conversation.last_message && (
                <span className="text-xs text-neutral-500">
                  {formatDistanceToNow(new Date(conversation.last_message.created_at), { addSuffix: true })}
                </span>
              )}
            </div>
            <p className="text-sm text-neutral-600 truncate">
              {conversation.last_message?.content || "No messages yet"}
            </p>
          </div>
          {conversation.unread_count > 0 && (
            <div className="w-5 h-5 bg-emerald-600 text-white text-xs rounded-full flex items-center justify-center">
              {conversation.unread_count}
            </div>
          )}
        </button>
      ))}
    </div>
  )
}
