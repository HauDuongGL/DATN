"use client"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { Card } from "@/components/ui/card"
import { MapPin, LinkIcon, Calendar, Settings, Upload, Loader2 } from "lucide-react"
import { formatDistanceToNow } from "date-fns"
import { useState } from "react"
import { createClient } from "@/lib/supabase/client"
import { useRouter } from "next/navigation"
import Link from "next/link"
import { toast } from "sonner"

interface ProfileHeaderProps {
  profile: {
    id: string
    display_name?: string | null
    username?: string | null
    full_name?: string | null
    email: string
    avatar_url: string | null
    bio: string | null
    location: string | null
    website: string | null
    created_at: string
  }
  currentUserId: string
  isFollowing: boolean
  followersCount: number
  followingCount: number
  postsCount: number
}

export function ProfileHeader({
  profile,
  currentUserId,
  isFollowing: initialIsFollowing,
  followersCount: initialFollowersCount,
  followingCount,
  postsCount,
}: ProfileHeaderProps) {
  const [isFollowing, setIsFollowing] = useState(initialIsFollowing)
  const [followersCount, setFollowersCount] = useState(initialFollowersCount)
  const [isLoading, setIsLoading] = useState(false)
  const [isUploadingAvatar, setIsUploadingAvatar] = useState(false)
  const [avatarUrl, setAvatarUrl] = useState(profile.avatar_url)
  const router = useRouter()
  const supabase = createClient()
  const isOwnProfile = profile.id === currentUserId

  const getInitials = (name?: string | null) => {
    if (!name) return "U"
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase()
      .slice(0, 2)
  }

  const handleFollowToggle = async () => {
    if (isLoading) return
    setIsLoading(true)

    const wasFollowing = isFollowing
    const oldCount = followersCount

    // Optimistic update
    setIsFollowing(!isFollowing)
    setFollowersCount((prev) => wasFollowing ? Math.max(0, prev - 1) : prev + 1)

    try {
      if (wasFollowing) {
        const { error } = await supabase
          .from("follows")
          .delete()
          .eq("follower_id", currentUserId)
          .eq("following_id", profile.id)
        
        if (error) {
          // If not found, already unfollowed - ignore
          if (error.code !== 'PGRST116') {
            throw error
          }
        }
      } else {
        // Check if already following first
        const { data: existing } = await supabase
          .from("follows")
          .select("id")
          .eq("follower_id", currentUserId)
          .eq("following_id", profile.id)
          .maybeSingle()

        if (!existing) {
          const { error } = await supabase.from("follows").insert({
            follower_id: currentUserId,
            following_id: profile.id,
          })
          
          if (error) {
            // If duplicate key error, already following - ignore
            if (error.code !== '23505') {
              throw error
            }
          }
        }
      }
      router.refresh()
      toast.success(wasFollowing ? 'Unfollowed' : 'Followed!')
    } catch (error: any) {
      // Revert on error
      setIsFollowing(wasFollowing)
      setFollowersCount(oldCount)
      
      console.error("[v0] Error toggling follow:", {
        message: error?.message,
        code: error?.code,
        error: error?.toString ? error.toString() : String(error),
      })
      
      toast.error(error?.message || 'Failed to update follow status')
    } finally {
      setIsLoading(false)
    }
  }

  const handleAvatarUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return

    // Validate file size (max 5MB)
    if (file.size > 5 * 1024 * 1024) {
      toast.error("File size must be less than 5MB")
      return
    }

    // Validate file type
    if (!file.type.startsWith("image/")) {
      toast.error("Please upload an image file")
      return
    }

    setIsUploadingAvatar(true)

    try {
      const fileExt = file.name.split(".").pop()
      const fileName = `${profile.id}/avatar.${fileExt}`

      // Delete old avatar if exists
      if (avatarUrl) {
        const oldPath = avatarUrl.split("/").pop()
        if (oldPath) {
          await supabase.storage.from("avatars").remove([`${profile.id}/${oldPath}`])
        }
      }

      // Upload new avatar
      const { error: uploadError } = await supabase.storage.from("avatars").upload(fileName, file, {
        upsert: true,
      })

      if (uploadError) throw uploadError

      // Get public URL
      const {
        data: { publicUrl },
      } = supabase.storage.from("avatars").getPublicUrl(fileName)

      setAvatarUrl(publicUrl)

      // Update profile
      const { error: updateError } = await supabase
        .from("profiles")
        .update({ avatar_url: publicUrl })
        .eq("id", profile.id)

      if (updateError) throw updateError

      toast.success("Avatar updated successfully!")
      router.refresh()
    } catch (error) {
      console.error("Avatar upload error:", error)
      toast.error(error instanceof Error ? error.message : "Failed to upload avatar")
    } finally {
      setIsUploadingAvatar(false)
      // Reset input
      e.target.value = ""
    }
  }

  return (
    <Card className="mb-6 overflow-hidden border-slate-200 bg-white shadow-sm">
      <div className="h-32 bg-gradient-to-r from-emerald-400 via-teal-400 to-cyan-400" />

      <div className="relative px-6 pb-6">
        <div className="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
          <div className="flex flex-col gap-4 sm:flex-row sm:items-end">
            <div className="relative group">
              <Avatar className="-mt-16 h-32 w-32 border-4 border-white shadow-lg">
                <AvatarImage 
                  src={avatarUrl || undefined} 
                  alt={profile.display_name || profile.full_name || profile.username || "User"} 
                />
                <AvatarFallback className="bg-emerald-100 text-3xl text-emerald-700">
                  {getInitials(profile.display_name || profile.full_name || profile.username)}
                </AvatarFallback>
              </Avatar>
              {isOwnProfile && (
                <>
                  <label
                    htmlFor="avatar-upload"
                    className="absolute -bottom-2 -right-2 flex h-10 w-10 cursor-pointer items-center justify-center rounded-full bg-emerald-600 text-white shadow-lg transition-all hover:bg-emerald-700 hover:scale-110"
                    title="Upload avatar"
                  >
                    {isUploadingAvatar ? (
                      <Loader2 className="h-5 w-5 animate-spin" />
                    ) : (
                      <Upload className="h-5 w-5" />
                    )}
                  </label>
                  <input
                    id="avatar-upload"
                    type="file"
                    accept="image/*"
                    onChange={handleAvatarUpload}
                    disabled={isUploadingAvatar}
                    className="hidden"
                  />
                </>
              )}
            </div>

            <div className="space-y-1">
              <h1 className="text-2xl font-bold text-slate-900">
                {profile.display_name || profile.full_name || profile.username || "User"}
              </h1>
              <p className="text-sm text-slate-500">{profile.email}</p>
            </div>
          </div>

          <div className="flex gap-2">
            {isOwnProfile ? (
              <Button
                asChild
                variant="outline"
                className="border-emerald-600 text-emerald-700 hover:bg-emerald-50 bg-transparent"
              >
                <Link href="/settings">
                  <Settings className="mr-2 h-4 w-4" />
                  Edit Profile
                </Link>
              </Button>
            ) : (
              <Button
                onClick={handleFollowToggle}
                disabled={isLoading}
                className={
                  isFollowing
                    ? "border-emerald-600 bg-white text-emerald-700 hover:bg-emerald-50"
                    : "bg-emerald-600 hover:bg-emerald-700"
                }
                variant={isFollowing ? "outline" : "default"}
              >
                {isFollowing ? "Following" : "Follow"}
              </Button>
            )}
          </div>
        </div>

        {/* Stats */}
        <div className="mt-6 flex gap-6 border-t border-slate-100 pt-4">
          <div className="text-center">
            <p className="text-2xl font-bold text-slate-900">{postsCount}</p>
            <p className="text-sm text-slate-500">Posts</p>
          </div>
          <div className="text-center">
            <p className="text-2xl font-bold text-slate-900">{followersCount}</p>
            <p className="text-sm text-slate-500">Followers</p>
          </div>
          <div className="text-center">
            <p className="text-2xl font-bold text-slate-900">{followingCount}</p>
            <p className="text-sm text-slate-500">Following</p>
          </div>
        </div>

        {/* Bio and Info */}
        <div className="mt-6 space-y-3">
          {profile.bio && <p className="text-slate-700">{profile.bio}</p>}

          <div className="flex flex-wrap gap-4 text-sm text-slate-500">
            {profile.location && (
              <div className="flex items-center gap-1">
                <MapPin className="h-4 w-4" />
                <span>{profile.location}</span>
              </div>
            )}
            {profile.website && (
              <div className="flex items-center gap-1">
                <LinkIcon className="h-4 w-4" />
                <a
                  href={profile.website}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-emerald-600 hover:underline"
                >
                  {profile.website}
                </a>
              </div>
            )}
            <div className="flex items-center gap-1">
              <Calendar className="h-4 w-4" />
              <span>Joined {formatDistanceToNow(new Date(profile.created_at), { addSuffix: true })}</span>
            </div>
          </div>
        </div>
      </div>
    </Card>
  )
}
