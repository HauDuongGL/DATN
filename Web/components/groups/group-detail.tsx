"use client"

import { useEffect, useState, useRef } from "react"
import { createBrowserClient } from "@/lib/supabase/client"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Users, Settings, ArrowLeft, Plus, Shield, User, MapPin, Sparkles, Camera } from "lucide-react"
import Link from "next/link"
import { useRouter } from "next/navigation"

import { PostCard } from "@/components/feed/post-card"
import { GroupMembersTab } from "@/components/groups/group-members-tab"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"

interface GroupDetailProps {
  groupId: string
  userId: string
  userRole?: string
}

interface Group {
  id: string
  name: string
  description: string
  cover_image_url: string | null
  is_private: boolean
  member_count: number
  post_count: number
  created_by: string
}

export default function GroupDetail({ groupId, userId, userRole }: GroupDetailProps) {
  const router = useRouter()
  const supabase = createBrowserClient()
  const [group, setGroup] = useState<Group | null>(null)
  const [posts, setPosts] = useState<any[]>([]) // Using any for brevity, ideally reuse Post type
  const [loading, setLoading] = useState(true)

  const fileInputRef = useRef<HTMLInputElement>(null)
  const [isUploadingCover, setIsUploadingCover] = useState(false)

  useEffect(() => {
    fetchGroupDetails()
  }, [])

  const handleCoverUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (!file) return

    setIsUploadingCover(true)
    try {
      // 1. Upload image to Supabase Storage
      const fileExt = file.name.split(".").pop()
      const fileName = `${groupId}/cover_${Date.now()}.${fileExt}`
      const { error: uploadError, data } = await supabase.storage
        .from("post-images") // Reusing post-images bucket
        .upload(fileName, file)

      if (uploadError) throw uploadError

      // 2. Get Public URL
      const { data: { publicUrl } } = supabase.storage
        .from("post-images")
        .getPublicUrl(fileName)

      // 3. Update Group record
      const { error: updateError } = await supabase
        .from("groups")
        .update({ cover_image_url: publicUrl })
        .eq("id", groupId)

      if (updateError) throw updateError

      // 4. Update local state
      setGroup((prev) => (prev ? { ...prev, cover_image_url: publicUrl } : null))
      router.refresh()
    } catch (error) {
      console.error("Error updating cover image:", error)
      alert("Failed to update cover image")
    } finally {
      setIsUploadingCover(false)
    }
  }

  const fetchGroupDetails = async () => {
    try {
      // Fetch group info
      const { data: groupData, error: groupError } = await supabase
        .from("groups")
        .select("*")
        .eq("id", groupId)
        .single()

      if (groupError) throw groupError
      setGroup(groupData)

      // Fetch group posts
      const { data: postsData, error: postsError } = await supabase
        .from("group_posts")
        .select(`
          post:posts (
            *,
            author:profiles!author_id (*),
            post_media (*),
            likes (user_id)
          )
        `)
        .eq("group_id", groupId)
        .order("created_at", { ascending: false })

      if (postsError) throw postsError

      // Transform data to match PostCard requirements
      const formattedPosts = postsData?.map((item: any) => item.post).filter(Boolean) || []
      setPosts(formattedPosts)

    } catch (error) {
      console.error("Error fetching group details:", error)
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return <div className="text-center py-12">Loading group...</div>
  }

  if (!group) {
    return <div className="text-center py-12">Group not found</div>
  }

  const isAdmin = userRole === "admin"

  const handleApprovePost = async (postId: string) => {
    try {
      const { error } = await supabase.from("posts").update({ status: "approved" }).eq("id", postId)
      if (error) throw error
      setPosts((prev) => prev.map((p) => (p.id === postId ? { ...p, status: "approved" } : p)))
      router.refresh()
    } catch (error) {
      console.error("Error approving post:", error)
    }
  }

  const handleRejectPost = async (postId: string) => {
    try {
      const { error } = await supabase.from("posts").update({ status: "rejected" }).eq("id", postId)
      if (error) throw error
      setPosts((prev) => prev.filter((p) => p.id !== postId)) // Remove from view
      router.refresh()
    } catch (error) {
      console.error("Error rejecting post:", error)
    }
  }

  const handleDeletePost = async (postId: string) => {
    if (!confirm("Are you sure you want to delete this post?")) return
    try {
      // Delete linkage first (cascade should handle it usually but being safe)
      const { error } = await supabase.from("group_posts").delete().eq("post_id", postId).eq("group_id", groupId)
      if (error) throw error
      setPosts((prev) => prev.filter((p) => p.id !== postId))
      router.refresh()
    } catch (error) {
      console.error("Error deleting post:", error)
    }
  }

  return (
    <div className="bg-neutral-100 min-h-screen">
      {/* Facebook-style Group Header */}
      <div className="bg-white shadow-sm mb-4">
        <div className="container max-w-6xl mx-auto px-0 md:px-4">
          {/* Cover Image */}
          <div className="relative h-48 md:h-[350px] w-full rounded-b-lg overflow-hidden bg-gradient-to-r from-emerald-400 to-cyan-500 group">
            {group.cover_image_url ? (
              <img src={group.cover_image_url} alt="Cover" className="w-full h-full object-cover" />
            ) : (
              <div className="w-full h-full flex items-center justify-center text-white text-lg font-medium bg-neutral-300">
                No Cover Image
              </div>
            )}

            {/* Edit Cover Button (Admin Only) */}
            {isAdmin && (
              <>
                <input
                  type="file"
                  ref={fileInputRef}
                  className="hidden"
                  accept="image/*"
                  onChange={handleCoverUpload}
                />
                <Button
                  variant="secondary"
                  className="absolute bottom-4 right-4 bg-white/80 hover:bg-white text-neutral-800 shadow-sm opacity-0 group-hover:opacity-100 transition-opacity"
                  onClick={() => fileInputRef.current?.click()}
                  disabled={isUploadingCover}
                >
                  <Camera className="w-4 h-4 mr-2" />
                  {isUploadingCover ? "Uploading..." : "Edit Cover Photo"}
                </Button>
              </>
            )}
          </div>

          {/* Group Info Section */}
          <div className="px-4 py-4 md:py-6 pb-0">
            <div className="flex flex-col md:flex-row gap-4 items-start md:items-end -mt-12 md:mt-0 relative z-10">
              {/* Group Name & Details */}
              <div className="flex-1 mt-4 md:mt-0">
                <h1 className="text-3xl font-bold text-neutral-900 leading-tight">{group.name}</h1>
                <div className="flex items-center gap-2 text-neutral-500 text-sm mt-1">
                  {group.is_private ? <Shield className="w-4 h-4" /> : <Users className="w-4 h-4" />}
                  <span>{group.is_private ? 'Private' : 'Public'} Group</span>
                  <span>•</span>
                  <span className="font-semibold text-neutral-700">{group.member_count} members</span>
                </div>
              </div>

              {/* Group Actions */}
              <div className="flex gap-2 w-full md:w-auto mt-4 md:mt-0">
                {isAdmin && (
                  <Button variant="secondary" className="gap-2 bg-neutral-200 text-neutral-800 hover:bg-neutral-300">
                    <Settings className="w-4 h-4" /> Manage
                  </Button>
                )}
                <Button className="gap-2 bg-emerald-600 hover:bg-emerald-700 text-white font-semibold">
                  <Plus className="w-4 h-4" /> Invite
                </Button>
              </div>
            </div>

            <div className="mt-6 border-t border-neutral-200">
              <Tabs defaultValue="discussion" className="w-full">
                <TabsList className="h-12 bg-transparent p-0 w-full justify-start space-x-2">
                  <TabsTrigger
                    value="discussion"
                    className="h-full rounded-none border-b-2 border-transparent data-[state=active]:border-emerald-600 data-[state=active]:text-emerald-600 data-[state=active]:shadow-none bg-transparent px-4 font-semibold text-neutral-600"
                  >
                    Discussion
                  </TabsTrigger>
                  <TabsTrigger
                    value="members"
                    className="h-full rounded-none border-b-2 border-transparent data-[state=active]:border-emerald-600 data-[state=active]:text-emerald-600 data-[state=active]:shadow-none bg-transparent px-4 font-semibold text-neutral-600"
                  >
                    People
                  </TabsTrigger>
                </TabsList>

                {/* Tab Content Wrappers (To be rendered below in main area) */}
                {/* Note: TabsContent usually goes inside Tabs. We will structure the layout to keep TabsContent inside Tabs but use grid layout within the contents if needed, OR wrap the grid inside the content. */}

                <div className="container max-w-6xl mx-auto py-6">
                  <TabsContent value="discussion" className="mt-0">
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                      {/* Left/Main Column: Feed */}
                      <div className="md:col-span-2 space-y-6">

                        {/* "What's on your mind?" Input Trigger */}
                        <Card className="shadow-sm border-neutral-200 p-4">
                          <div className="flex gap-3">
                            <Avatar>
                              <AvatarImage src="" />
                              <AvatarFallback><User className="w-6 h-6" /></AvatarFallback>
                            </Avatar>
                            <div
                              className="flex-1 bg-neutral-100 hover:bg-neutral-200 rounded-full px-4 py-2 flex items-center text-neutral-500 cursor-pointer transition-colors"
                              onClick={() => router.push(`/upload?groupId=${groupId}`)}
                            >
                              Write something...
                            </div>
                          </div>
                          <div className="flex items-center justify-between mt-4 pt-3 border-t border-neutral-100">
                            <Button variant="ghost" className="flex-1 text-neutral-600 hover:bg-neutral-50 gap-2" onClick={() => router.push(`/upload?groupId=${groupId}`)}>
                              <span className="text-green-500"><Sparkles className="w-5 h-5" /></span>
                              Photo/Video
                            </Button>
                            <Button variant="ghost" className="flex-1 text-neutral-600 hover:bg-neutral-50 gap-2">
                              <span className="text-yellow-500"><MapPin className="w-5 h-5" /></span>
                              Feeling/Activity
                            </Button>
                          </div>
                        </Card>

                        {/* Feed Content */}
                        <div className="space-y-4">
                          {posts.length > 0 ? (
                            posts.map((post) => (
                              <PostCard
                                key={post.id}
                                post={post}
                                currentUserId={userId}
                                isLiked={post.likes?.some((like: { user_id: string }) => like.user_id === userId) || false}
                                isAdmin={isAdmin}
                                onApprove={() => handleApprovePost(post.id)}
                                onReject={() => handleRejectPost(post.id)}
                                onDelete={() => handleDeletePost(post.id)}
                              />
                            ))
                          ) : (
                            <Card>
                              <CardContent className="text-center py-12">
                                <p className="text-neutral-600">No posts yet. Be the first to share!</p>
                              </CardContent>
                            </Card>
                          )}
                        </div>
                      </div>

                      {/* Right Column: Sidebar info */}
                      <div className="hidden md:block space-y-6">
                        <Card className="shadow-sm border-neutral-200">
                          <CardContent className="p-4 space-y-4">
                            <h3 className="font-bold text-lg">About</h3>
                            <p className="text-sm text-neutral-600">{group.description || "No description provided."}</p>

                            <div className="space-y-3 pt-2">
                              <div className="flex items-center gap-3 text-neutral-700">
                                <Users className="w-5 h-5 text-neutral-500" />
                                <div>
                                  <div className="font-semibold text-sm">{group.is_private ? 'Private' : 'Public'}</div>
                                  <div className="text-xs text-neutral-500">
                                    {group.is_private ? 'Only members can see who\'s in the group and what they post.' : 'Anyone can see who\'s in the group and what they post.'}
                                  </div>
                                </div>
                              </div>
                              <div className="flex items-center gap-3 text-neutral-700">
                                <MapPin className="w-5 h-5 text-neutral-500" />
                                <div>
                                  <div className="font-semibold text-sm">History</div>
                                  <div className="text-xs text-neutral-500">
                                    Group created on {new Date().toLocaleDateString()}
                                  </div>
                                </div>
                              </div>
                            </div>
                          </CardContent>
                        </Card>
                      </div>
                    </div>
                  </TabsContent>

                  <TabsContent value="members" className="mt-6">
                    <GroupMembersTab groupId={groupId} isAdmin={isAdmin} currentUserId={userId} />
                  </TabsContent>
                </div>
              </Tabs>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
