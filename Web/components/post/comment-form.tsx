"use client"

import type React from "react"

import { useState } from "react"
import { comments as commentsApi } from "@/lib/supabase/api"
import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import { Loader2 } from "lucide-react"
import { toast } from "sonner"

interface CommentFormProps {
  postId: string
  authorId?: string
  parentCommentId?: string
  onCommentAdded: () => void
  placeholder?: string
}

export function CommentForm({
  postId,
  authorId,
  parentCommentId,
  onCommentAdded,
  placeholder = "Add a comment...",
}: CommentFormProps) {
  const [content, setContent] = useState("")
  const [isSubmitting, setIsSubmitting] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!content.trim()) return
    if (!authorId) {
      toast.error("You must be logged in to comment")
      return
    }

    setIsSubmitting(true)

    try {
      await commentsApi.create(postId, content.trim(), authorId, parentCommentId)
      setContent("")
      onCommentAdded()
      toast.success("Comment posted!")
    } catch (error: any) {
      console.error("Error posting comment:", error.message || error)
      if (error.details) console.error("Error details:", error.details)
      toast.error("Failed to post comment")
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-3">
      <Textarea
        value={content}
        onChange={(e) => setContent(e.target.value)}
        placeholder={placeholder}
        rows={3}
        className="resize-none border-slate-200 focus:border-green-500"
      />
      <div className="flex justify-end">
        <Button
          type="submit"
          disabled={isSubmitting || !content.trim()}
          className="bg-green-600 hover:bg-green-700 text-white"
        >
          {isSubmitting ? (
            <>
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              Posting...
            </>
          ) : (
            "Post Comment"
          )}
        </Button>
      </div>
    </form>
  )
}
