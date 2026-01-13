"use client"

import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card"
import { CommentItem } from "@/components/post/comment-item"
import { CommentForm } from "@/components/post/comment-form"
import { useState, useEffect, useCallback } from "react"
import { comments as commentsApi } from "@/lib/supabase/api"
import type { Comment } from "@/lib/supabase/api"
import { Loader2 } from "lucide-react"

interface CommentSectionProps {
  postId: string
  currentUserId?: string
}

export function CommentSection({ postId, currentUserId }: CommentSectionProps) {
  const [comments, setComments] = useState<Comment[]>([])
  const [loading, setLoading] = useState(true)

  const loadComments = useCallback(async () => {
    try {
      const data = await commentsApi.getPostComments(postId)
      setComments(data)
    } catch (error: any) {
      console.error("Error loading comments:", error.message || error)
      if (error.details) console.error("Error details:", error.details)
    } finally {
      setLoading(false)
    }
  }, [postId])

  useEffect(() => {
    loadComments()
  }, [loadComments])

  return (
    <Card className="border-green-100 bg-white shadow-sm overflow-hidden">
      <CardHeader className="bg-green-50/50 border-b border-green-100 py-4">
        <CardTitle className="text-lg font-bold flex items-center gap-2">
          Comments
          <span className="text-sm font-normal text-muted-foreground">
            ({comments.length})
          </span>
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-6 pt-6">
        <CommentForm
          postId={postId}
          authorId={currentUserId}
          onCommentAdded={loadComments}
        />

        <div className="space-y-6">
          {loading ? (
            <div className="flex justify-center py-8">
              <Loader2 className="h-6 w-6 animate-spin text-green-500" />
            </div>
          ) : comments.length === 0 ? (
            <p className="py-12 text-center text-sm text-slate-500 italic">
              No comments yet. Be the first to share your thoughts!
            </p>
          ) : (
            <div className="space-y-6">
              {comments.map((comment) => (
                <CommentItem
                  key={comment.id}
                  comment={comment}
                  currentUserId={currentUserId}
                  postId={postId}
                  onCommentDeleted={loadComments}
                />
              ))}
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  )
}
