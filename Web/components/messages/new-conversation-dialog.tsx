"use client"

import { useState, useEffect } from "react"
import { createBrowserClient } from "@/lib/supabase/client"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { X, Search } from "lucide-react"

interface User {
  id: string
  display_name: string
  avatar_url: string | null
}

interface NewConversationDialogProps {
  userId: string
  onClose: () => void
  onCreated: (conversationId: string) => void
}

export default function NewConversationDialog({ userId, onClose, onCreated }: NewConversationDialogProps) {
  const supabase = createBrowserClient()
  const [users, setUsers] = useState<User[]>([])
  const [searchQuery, setSearchQuery] = useState("")
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    searchUsers()
  }, [searchQuery])

  const searchUsers = async () => {
    try {
      let query = supabase.from("profiles").select("id, display_name, avatar_url").neq("id", userId).limit(10)

      if (searchQuery) {
        query = query.ilike("display_name", `%${searchQuery}%`)
      }

      const { data, error } = await query

      if (error) throw error
      setUsers(data || [])
    } catch (error) {
      console.error("Error searching users:", error)
    }
  }

  const createConversation = async (otherUserId: string) => {
    setLoading(true)
    try {
      // Check if conversation already exists
      const { data: existingParticipations } = await supabase
        .from("conversation_participants")
        .select("conversation_id")
        .eq("user_id", userId)

      if (existingParticipations) {
        for (const participation of existingParticipations) {
          const { data: otherParticipation } = await supabase
            .from("conversation_participants")
            .select("conversation_id")
            .eq("conversation_id", participation.conversation_id)
            .eq("user_id", otherUserId)
            .single()

          if (otherParticipation) {
            onCreated(participation.conversation_id)
            return
          }
        }
      }

      // Create new conversation
      const { data: conversation, error: conversationError } = await supabase
        .from("conversations")
        .insert({})
        .select()
        .single()

      if (conversationError) throw conversationError

      // Add participants
      const { error: participantsError } = await supabase.from("conversation_participants").insert([
        { conversation_id: conversation.id, user_id: userId },
        { conversation_id: conversation.id, user_id: otherUserId },
      ])

      if (participantsError) throw participantsError

      onCreated(conversation.id)
    } catch (error) {
      console.error("Error creating conversation:", error)
      alert("Failed to create conversation. Please try again.")
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <Card className="w-full max-w-md">
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>New Message</CardTitle>
              <CardDescription>Search for users to start a conversation</CardDescription>
            </div>
            <Button variant="ghost" size="icon" onClick={onClose}>
              <X className="w-4 h-4" />
            </Button>
          </div>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-neutral-400" />
              <Input
                placeholder="Search users..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-9 border-emerald-200 focus-visible:ring-emerald-500"
              />
            </div>

            <div className="max-h-[300px] overflow-y-auto space-y-2">
              {users.length === 0 ? (
                <p className="text-center text-neutral-600 py-8">
                  {searchQuery ? "No users found" : "Start typing to search users"}
                </p>
              ) : (
                users.map((user) => (
                  <button
                    key={user.id}
                    onClick={() => createConversation(user.id)}
                    disabled={loading}
                    className="w-full p-3 flex items-center gap-3 hover:bg-neutral-50 rounded-lg transition-colors"
                  >
                    <Avatar>
                      <AvatarImage src={user.avatar_url || "/placeholder.svg"} />
                      <AvatarFallback className="bg-emerald-100 text-emerald-700">
                        {user.display_name.charAt(0).toUpperCase()}
                      </AvatarFallback>
                    </Avatar>
                    <span className="font-medium text-neutral-900">{user.display_name}</span>
                  </button>
                ))
              )}
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
