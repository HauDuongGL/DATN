"use client"

import { useState } from "react"
import { Card, CardContent } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { MessageSquare, Plus, Search } from "lucide-react"
import ConversationsList from "./conversations-list"
import ChatWindow from "./chat-window"
import NewConversationDialog from "./new-conversation-dialog"
import { Input } from "@/components/ui/input"

interface MessagesViewProps {
  userId: string
}

export default function MessagesView({ userId }: MessagesViewProps) {
  const [selectedConversationId, setSelectedConversationId] = useState<string | null>(null)
  const [showNewConversation, setShowNewConversation] = useState(false)
  const [searchQuery, setSearchQuery] = useState("")

  return (
    <div className="h-screen flex flex-col">
      {/* Header */}
      <div className="bg-white border-b">
        <div className="container max-w-7xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-emerald-100 rounded-full flex items-center justify-center">
                <MessageSquare className="w-5 h-5 text-emerald-600" />
              </div>
              <h1 className="text-2xl font-bold text-neutral-900">Messages</h1>
            </div>
            <Button onClick={() => setShowNewConversation(true)} className="bg-emerald-600 hover:bg-emerald-700">
              <Plus className="w-4 h-4 mr-2" />
              New Message
            </Button>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 overflow-hidden">
        <div className="container max-w-7xl mx-auto px-4 h-full py-4">
          <div className="grid grid-cols-12 gap-4 h-full">
            {/* Conversations List */}
            <div className="col-span-4 flex flex-col h-full">
              <Card className="flex-1 flex flex-col overflow-hidden">
                <div className="p-4 border-b">
                  <div className="relative">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-neutral-400" />
                    <Input
                      placeholder="Search conversations..."
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      className="pl-9 border-emerald-200 focus-visible:ring-emerald-500"
                    />
                  </div>
                </div>
                <div className="flex-1 overflow-y-auto">
                  <ConversationsList
                    userId={userId}
                    selectedId={selectedConversationId}
                    onSelect={setSelectedConversationId}
                    searchQuery={searchQuery}
                  />
                </div>
              </Card>
            </div>

            {/* Chat Window */}
            <div className="col-span-8 h-full">
              {selectedConversationId ? (
                <ChatWindow userId={userId} conversationId={selectedConversationId} />
              ) : (
                <Card className="h-full flex items-center justify-center">
                  <CardContent className="text-center">
                    <MessageSquare className="w-16 h-16 text-neutral-400 mx-auto mb-4" />
                    <h3 className="text-lg font-medium text-neutral-900 mb-2">No conversation selected</h3>
                    <p className="text-neutral-600 mb-4">Choose a conversation or start a new one</p>
                    <Button
                      onClick={() => setShowNewConversation(true)}
                      className="bg-emerald-600 hover:bg-emerald-700"
                    >
                      <Plus className="w-4 h-4 mr-2" />
                      New Message
                    </Button>
                  </CardContent>
                </Card>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* New Conversation Dialog */}
      {showNewConversation && (
        <NewConversationDialog
          userId={userId}
          onClose={() => setShowNewConversation(false)}
          onCreated={(conversationId) => {
            setSelectedConversationId(conversationId)
            setShowNewConversation(false)
          }}
        />
      )}
    </div>
  )
}
