"use client"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Heart, MessageCircle, Trash2 } from "lucide-react"
import { formatDistanceToNow } from "date-fns"
import { useState } from "react"
import { comments as commentsApi } from "@/lib/supabase/api"
import { CommentForm } from "@/components/post/comment-form"
import { toast } from "sonner"
import type { Comment } from "@/lib/supabase/api"
import { Button } from "@/components/ui/button"

interface CommentItemProps {
  comment: Comment
  currentUserId?: string
  postId: string
  isReply?: boolean
  onCommentDeleted?: () => void
}

export function CommentItem({
  comment,
  currentUserId,
  postId,
  isReply = false,
  onCommentDeleted
}: CommentItemProps) {
  const [likesCount, setLikesCount] = useState(0) // Logic for comment likes can be added later
  const [showReplyForm, setShowReplyForm] = useState(false)
  const [isDeleting, setIsDeleting] = useState(false)

  const isAuthor = currentUserId === comment.author_id

  const getInitials = (name?: string) => {
    if (!name) return "U"
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase()
      .slice(0, 2)
  }

  const handleDelete = async () => {
    if (!window.confirm("Are you sure you want to delete this comment?")) return

    setIsDeleting(true)
    try {
      await commentsApi.delete(comment.id)
      toast.success("Comment deleted")
      onCommentDeleted?.()
    } catch (error) {
      console.error("Error deleting comment:", error)
      toast.error("Failed to delete comment")
    } finally {
      setIsDeleting(false)
    }
  }

  return (
    <div className={`space-y-3 ${isReply ? "ml-12" : ""}`}>
      <div className="flex gap-3">
        <Avatar className="h-8 w-8 shrink-0 border border-green-100">
          <AvatarImage src={comment.user?.avatar_url} alt={comment.user?.username} />
          <AvatarFallback className="bg-green-100 text-xs text-green-700">
            {getInitials(comment.user?.full_name || comment.user?.username)}
          </AvatarFallback>
        </Avatar>

        <div className="flex-1 space-y-2">
          <div className="rounded-lg bg-green-50/50 p-3 border border-green-100">
            <div className="flex justify-between items-start">
              <p className="text-sm font-semibold text-slate-900">
                {comment.user?.full_name || comment.user?.username}
              </p>
              {isAuthor && (
                <Button
                  variant="ghost"
                  size="icon"
                  className="h-6 w-6 text-muted-foreground hover:text-red-500"
                  onClick={handleDelete}
                  disabled={isDeleting}
                >
                  <Trash2 className="h-3 w-3" />
                </Button>
              )}
            </div>
            <p className="mt-1 text-sm leading-relaxed text-slate-700">{comment.content}</p>
          </div>

          <div className="flex items-center gap-4 text-xs text-slate-500">
            <span>{formatDistanceToNow(new Date(comment.created_at), { addSuffix: true })}</span>
            {!isReply && (
              <button
                onClick={() => setShowReplyForm(!showReplyForm)}
                className="hover:text-green-600 flex items-center gap-1"
              >
                <MessageCircle className="h-3 w-3" />
                Reply
              </button>
            )}
          </div>

          {showReplyForm && (
            <div className="mt-3">
              <CommentForm
                postId={postId}
                parentCommentId={comment.id}
                onCommentAdded={() => {
                  setShowReplyForm(false)
                  // We should ideally refresh just the comments or the parent
                  window.location.reload()
                }}
                placeholder={`Reply to ${comment.user?.username}...`}
              />
            </div>
          )}
        </div>
      </div>

      {/* Render replies */}
      {comment.replies && comment.replies.length > 0 && (
        <div className="space-y-3">
          {comment.replies.map((reply) => (
            <CommentItem
              key={reply.id}
              comment={reply}
              currentUserId={currentUserId}
              postId={postId}
              isReply
              onCommentDeleted={onCommentDeleted}
            />
          ))}
        </div>
      )}
    </div>
  )
}
