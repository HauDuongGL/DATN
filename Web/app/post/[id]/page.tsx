import { createClient } from "@/lib/supabase/server"
import { getCurrentUser } from "@/lib/auth/get-user"
import { redirect, notFound } from "next/navigation"
import { FeedHeader } from "@/components/feed/feed-header"
import { PostCard } from "@/components/feed/post-card"
import { CommentSection } from "@/components/post/comment-section"

export default async function PostDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const user = await getCurrentUser()

  if (!user) {
    redirect("/auth/login")
  }

  const supabase = await createClient()

  // Get post with all details
  const { data: post } = await supabase
    .from("posts")
    .select(
      `
      *,
      author:profiles!author_id(*),
      post_media(*),
      likes(user_id)
    `,
    )
    .eq("id", id)
    .single()

  if (!post) {
    notFound()
  }

  // Get comments with nested replies
  const { data: comments } = await supabase
    .from("comments")
    .select(
      `
      *,
      author:profiles!author_id(*),
      likes(user_id)
    `,
    )
    .eq("post_id", id)
    .is("parent_comment_id", null)
    .order("created_at", { ascending: false })

  // Get replies for each comment
  const commentsWithReplies = await Promise.all(
    (comments || []).map(async (comment) => {
      const { data: replies } = await supabase
        .from("comments")
        .select(
          `
          *,
          author:profiles!author_id(*),
          likes(user_id)
        `,
        )
        .eq("parent_comment_id", comment.id)
        .order("created_at", { ascending: true })

      return { ...comment, replies: replies || [] }
    }),
  )

  return (
    <div className="min-h-screen bg-slate-50">
      <FeedHeader user={user} />

      <main className="container mx-auto max-w-2xl px-4 py-6">
        <div className="space-y-6">
          <PostCard
            post={post}
            currentUserId={user.id}
            isLiked={post.likes?.some((like: { user_id: string }) => like.user_id === user.id) || false}
            showFullContent
          />

          <CommentSection postId={id} comments={commentsWithReplies} currentUserId={user.id} />
        </div>
      </main>
    </div>
  )
}
