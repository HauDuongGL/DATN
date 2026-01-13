"use client"

import { Card, CardContent } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Check, X } from "lucide-react"
import { formatDistanceToNow } from "date-fns"
import { useState } from "react"
import { createClient } from "@/lib/supabase/client"
import { useRouter } from "next/navigation"

interface PendingPostsListProps {
  posts: Array<{
    id: string
    caption: string | null
    flower_name: string | null
    created_at: string
    author: {
      id: string
      display_name: string
    }
    post_media: Array<{
      media_url: string
    }>
  }>
  adminId: string
}

export function PendingPostsList({ posts, adminId }: PendingPostsListProps) {
  const [processing, setProcessing] = useState<string | null>(null)
  const router = useRouter()
  const supabase = createClient()

  const handleApprove = async (postId: string, authorId: string) => {
    setProcessing(postId)
    try {
      await supabase.from("posts").update({ status: "approved" }).eq("id", postId)

      // Create notification
      await supabase.from("notifications").insert({
        recipient_id: authorId,
        type: "post_approved",
        post_id: postId,
        message: "Your post has been approved and is now visible to everyone!",
      })

      router.refresh()
    } catch (error) {
      console.error("[v0] Error approving post:", error)
    } finally {
      setProcessing(null)
    }
  }

  const handleReject = async (postId: string, authorId: string) => {
    setProcessing(postId)
    try {
      await supabase.from("posts").update({ status: "rejected" }).eq("id", postId)

      // Create notification
      await supabase.from("notifications").insert({
        recipient_id: authorId,
        type: "post_rejected",
        post_id: postId,
        message: "Your post was rejected. Please review our community guidelines.",
      })

      router.refresh()
    } catch (error) {
      console.error("[v0] Error rejecting post:", error)
    } finally {
      setProcessing(null)
    }
  }

  if (posts.length === 0) {
    return (
      <Card className="border-slate-200">
        <CardContent className="py-12 text-center text-slate-600">No pending posts</CardContent>
      </Card>
    )
  }

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
      {posts.map((post) => (
        <Card key={post.id} className="overflow-hidden border-slate-200">
          {post.post_media && post.post_media.length > 0 && (
            <div className="aspect-square w-full overflow-hidden bg-slate-100">
              <img
                src={post.post_media[0].media_url || "/placeholder.svg"}
                alt={post.flower_name || "Flower"}
                className="h-full w-full object-cover"
              />
            </div>
          )}

          <CardContent className="space-y-3 p-4">
            <div>
              <p className="font-semibold text-slate-900">{post.author.display_name}</p>
              <p className="text-xs text-slate-500">
                {formatDistanceToNow(new Date(post.created_at), { addSuffix: true })}
              </p>
            </div>

            {post.flower_name && (
              <div className="rounded-lg bg-emerald-50 p-2">
                <p className="text-sm font-medium text-emerald-900">{post.flower_name}</p>
              </div>
            )}

            {post.caption && <p className="line-clamp-2 text-sm text-slate-700">{post.caption}</p>}

            <div className="flex gap-2">
              <Button
                onClick={() => handleApprove(post.id, post.author.id)}
                disabled={processing === post.id}
                size="sm"
                className="flex-1 bg-emerald-600 hover:bg-emerald-700"
              >
                <Check className="mr-1 h-4 w-4" />
                Approve
              </Button>
              <Button
                onClick={() => handleReject(post.id, post.author.id)}
                disabled={processing === post.id}
                size="sm"
                variant="destructive"
                className="flex-1"
              >
                <X className="mr-1 h-4 w-4" />
                Reject
              </Button>
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  )
}
