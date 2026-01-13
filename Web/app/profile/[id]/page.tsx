import { createClient } from "@/lib/supabase/server"
import { getCurrentUser } from "@/lib/auth/get-user"
import { redirect, notFound } from "next/navigation"
import { FeedHeader } from "@/components/feed/feed-header"
import { ProfileHeader } from "@/components/profile/profile-header"
import { ProfileTabs } from "@/components/profile/profile-tabs"
import { PostCard } from "@/components/feed/post-card"

export default async function ProfilePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const currentUser = await getCurrentUser()

  if (!currentUser) {
    redirect("/auth/login")
  }

  const supabase = await createClient()

  // Get profile
  const { data: profile } = await supabase.from("profiles").select("*").eq("id", id).single()

  if (!profile) {
    notFound()
  }

  // Get follower/following counts
  const { count: followersCount } = await supabase
    .from("follows")
    .select("*", { count: "exact", head: true })
    .eq("following_id", id)

  const { count: followingCount } = await supabase
    .from("follows")
    .select("*", { count: "exact", head: true })
    .eq("follower_id", id)

  // Check if current user follows this profile
  const { data: followData } = await supabase
    .from("follows")
    .select("id")
    .eq("follower_id", currentUser.id)
    .eq("following_id", id)
    .single()

  const isFollowing = !!followData

  // Get user posts
  const { data: posts } = await supabase
    .from("posts")
    .select(
      `
      *,
      author:profiles!author_id(*),
      post_media(*),
      likes(user_id)
    `,
    )
    .eq("author_id", id)
    .eq("status", "approved")
    .order("created_at", { ascending: false })

  // Get posts count
  const { count: postsCount } = await supabase
    .from("posts")
    .select("*", { count: "exact", head: true })
    .eq("author_id", id)
    .eq("status", "approved")

  return (
    <div className="min-h-screen bg-slate-50">
      <FeedHeader user={currentUser} />

      <main className="container mx-auto max-w-4xl px-4 py-6">
        <ProfileHeader
          profile={profile}
          currentUserId={currentUser.id}
          isFollowing={isFollowing}
          followersCount={followersCount || 0}
          followingCount={followingCount || 0}
          postsCount={postsCount || 0}
        />

        <ProfileTabs>
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {posts?.map((post) => (
              <PostCard
                key={post.id}
                post={post}
                currentUserId={currentUser.id}
                isLiked={post.likes?.some((like: { user_id: string }) => like.user_id === currentUser.id) || false}
              />
            ))}

            {(!posts || posts.length === 0) && (
              <div className="col-span-full rounded-lg bg-white p-12 text-center shadow">
                <p className="text-slate-600">No posts yet</p>
              </div>
            )}
          </div>
        </ProfileTabs>
      </main>
    </div>
  )
}
