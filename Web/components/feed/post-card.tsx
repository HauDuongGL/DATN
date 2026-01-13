"use client"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { Card } from "@/components/ui/card"
import { Heart, MessageCircle, Share2, MapPin, Sparkles, MoreHorizontal, Trash2 } from "lucide-react"
import Link from "next/link"
import { formatDistanceToNow } from "date-fns"
import { useState, useEffect } from "react"
import { likes as likesApi, posts as postsApi, notifications as notificationsApi } from "@/lib/supabase/api"
import type { Post } from "@/lib/supabase/api"
import { useRouter } from "next/navigation"
import { toast } from "sonner"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"

interface PostCardProps {
  post: Post
  currentUserId?: string
  onLikeChange?: (postId: string, isLiked: boolean) => void
  onDelete?: (postId: string) => void
}

export function PostCard({
  post,
  currentUserId,
  onLikeChange,
  onDelete,
}: PostCardProps) {
  const [isLiked, setIsLiked] = useState(post.is_liked_by_current_user || false)
  const [likesCount, setLikesCount] = useState(post.likes_count)
  const [isLiking, setIsLiking] = useState(false)
  const [isCaptionExpanded, setIsCaptionExpanded] = useState(false)
  const router = useRouter()

  // Reset caption expanded state when post changes
  useEffect(() => {
    setIsCaptionExpanded(false)
  }, [post.id])

  const getInitials = (name?: string) => {
    if (!name) return "U"
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase()
      .slice(0, 2)
  }

  const handleLike = async (e: React.MouseEvent) => {
    e.preventDefault()
    e.stopPropagation()

    if (isLiking) return
    setIsLiking(true)

    const newIsLiked = !isLiked
    setIsLiked(newIsLiked)
    setLikesCount((prev) => (newIsLiked ? prev + 1 : Math.max(0, prev - 1)))
    onLikeChange?.(post.id, newIsLiked)

    try {
      if (newIsLiked) {
        if (!currentUserId) {
          toast.error("You must be logged in to like")
          throw new Error("Not logged in")
        }
        await likesApi.like(post.id, currentUserId)
      } else {
        if (!currentUserId) throw new Error("Not logged in")
        await likesApi.unlike(post.id, currentUserId)
      }
    } catch (error) {
      // Revert on error
      setIsLiked(!newIsLiked)
      setLikesCount((prev) => (newIsLiked ? Math.max(0, prev - 1) : prev + 1))
      onLikeChange?.(post.id, !newIsLiked)
      toast.error("Failed to update like")
    } finally {
      setIsLiking(false)
    }
  }

  const handleCommentClick = (e: React.MouseEvent) => {
    e.preventDefault()
    e.stopPropagation()
    router.push(`/post-new/${post.id}`)
  }

  const handleShare = async (e: React.MouseEvent) => {
    e.preventDefault()
    e.stopPropagation()
    
    if (!currentUserId) {
      toast.error("You must be logged in to share")
      return
    }

    try {
      // Fetch lại post với đầy đủ fields để đảm bảo có description và planting_guide
      const fullPost = await postsApi.getById(post.id)
      
      // Gửi notification cho tác giả nếu người khác chia sẻ
      if (post.author_id && currentUserId && currentUserId !== post.author_id) {
        notificationsApi.create({
          recipientId: post.author_id,
          type: "share",
          postId: post.id,
          message: "đã chia sẻ bài viết của bạn",
        }).catch((err) => console.warn("Create share notification failed", err))
      }

      // Debug: Kiểm tra dữ liệu post
      console.log("Sharing post:", {
        id: fullPost.id,
        flower_description: fullPost.flower_description,
        planting_guide: fullPost.planting_guide,
        caption: fullPost.caption
      })

      // Lấy description và planting_guide (Care) để đưa vào caption
      const params = new URLSearchParams()
      if (fullPost.image_url) params.set("imageUrl", fullPost.image_url)
      
      // Kiểm tra và thêm description (giới hạn độ dài để tránh URL quá dài)
      if (fullPost.flower_description && fullPost.flower_description.trim()) {
        const description = fullPost.flower_description.trim()
        // Giới hạn 5000 ký tự để tránh URL quá dài (URL max ~2000 chars)
        params.set("description", description.length > 5000 ? description.substring(0, 5000) : description)
      }
      
      // Kiểm tra và thêm care (planting_guide) (giới hạn độ dài)
      if (fullPost.planting_guide && fullPost.planting_guide.trim()) {
        const care = fullPost.planting_guide.trim()
        params.set("care", care.length > 5000 ? care.substring(0, 5000) : care)
      }
      
      if (fullPost.flower_name) params.set("flowerName", fullPost.flower_name)
      if (fullPost.flower_species) params.set("flowerSpecies", fullPost.flower_species)

      console.log("Share params:", params.toString())

      // Redirect đến upload page (dùng /upload thay vì /upload-new)
      const url = `/upload?${params.toString()}`
      console.log("Redirecting to:", url)
      
      try {
        router.push(url)
      } catch (pushError) {
        console.error("Router push failed, trying window.location:", pushError)
        // Fallback: dùng window.location nếu router.push fail
        window.location.href = url
      }
    } catch (error) {
      console.error("Error sharing post:", error)
      toast.error("Failed to share post")
    }
  }

  return (
    <Card className="overflow-hidden border-green-100 bg-white shadow-sm hover:shadow-md transition-shadow">
      {/* Author Header */}
      <div className="flex items-center gap-3 p-4">
        <Link href={`/profile-new/${post.user?.username}`} className="flex items-center gap-3 flex-1 group">
          <Avatar className="h-10 w-10 border-2 border-green-100 group-hover:border-green-300 transition-colors">
            <AvatarImage src={post.user?.avatar_url} alt={post.user?.username} />
            <AvatarFallback className="bg-green-100 text-green-700">
              {getInitials(post.user?.full_name || post.user?.username)}
            </AvatarFallback>
          </Avatar>
          <div className="flex-1">
            <p className="font-semibold text-slate-900 group-hover:text-green-600 transition-colors">
              {post.user?.full_name || post.user?.username}
            </p>
            <p className="text-xs text-slate-500">
              {formatDistanceToNow(new Date(post.created_at), { addSuffix: true })}
            </p>
          </div>
        </Link>

        {currentUserId === post.author_id && (
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" size="icon" className="h-8 w-8 text-slate-400">
                <MoreHorizontal className="h-4 w-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem
                onClick={() => onDelete?.(post.id)}
                className="text-red-600 cursor-pointer"
              >
                <Trash2 className="mr-2 h-4 w-4" />
                Delete Post
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        )}
      </div>

      {/* Caption - Moved before image */}
      {post.caption && (() => {
        // Estimate if caption will be truncated (roughly 2 lines = ~100-120 chars)
        // Using a lower threshold to make it more visible for testing
        const estimatedCharsPerLine = 50
        const maxCharsForTwoLines = estimatedCharsPerLine * 2
        const usernameLength = (post.user?.username?.length || 0) + 2 // +2 for spacing
        const captionNeedsTruncation = (post.caption.length + usernameLength) > maxCharsForTwoLines

        return (
          <div className="px-4 pb-3">
            <p className={`text-sm leading-relaxed text-slate-700 ${!isCaptionExpanded && captionNeedsTruncation ? 'line-clamp-2' : ''}`}>
              <span className="font-semibold text-slate-900 mr-2">
                {post.user?.username}
              </span>
              {post.caption}
            </p>
            {captionNeedsTruncation && (
              <button
                onClick={(e) => {
                  e.preventDefault()
                  e.stopPropagation()
                  setIsCaptionExpanded(!isCaptionExpanded)
                }}
                className="text-sm text-slate-500 hover:text-slate-700 mt-1 font-medium transition-colors cursor-pointer"
              >
                {isCaptionExpanded ? 'See less' : 'See more'}
              </button>
            )}
          </div>
        )
      })()}

      <Link href={`/post-new/${post.id}`}>
        <div className="relative aspect-square w-full overflow-hidden bg-slate-50">
          {post.image_url ? (
            <img
              src={post.image_url}
              alt={post.flower_name}
              className="h-full w-full object-cover transition-transform duration-500 hover:scale-105"
            />
          ) : (
            <div className="h-full w-full flex items-center justify-center bg-gradient-to-br from-green-50 to-emerald-50">
              <Sparkles className="h-16 w-16 text-green-300" />
            </div>
          )}
        </div>
      </Link>

      {/* Actions */}
      <div className="flex items-center gap-4 px-4 py-3">
        <Button
          variant="ghost"
          size="sm"
          onClick={handleLike}
          disabled={isLiking}
          className={`gap-2 hover:bg-red-50 hover:text-red-600 ${isLiked ? "text-red-600 bg-red-50" : "text-slate-600"}`}
        >
          <Heart className={`h-5 w-5 ${isLiked ? "fill-current" : ""}`} />
          <span className="text-sm font-medium">{likesCount}</span>
        </Button>
        <Button
          variant="ghost"
          size="sm"
          onClick={handleCommentClick}
          className="gap-2 text-slate-600 hover:bg-green-50 hover:text-green-600"
        >
          <MessageCircle className="h-5 w-5" />
          <span className="text-sm font-medium">{post.comments_count}</span>
        </Button>
        <Button 
          variant="ghost" 
          size="sm" 
          className="ml-auto text-slate-400 hover:text-green-600"
          onClick={handleShare}
        >
          <Share2 className="h-5 w-5" />
        </Button>
      </div>

      {/* Content */}
      <div className="space-y-3 px-4 pb-4">
        {/* Flower Info - Only show enhanced badge if AI data exists */}
        {post.ai_confidence > 0 ? (
          <div className="flex items-center justify-between gap-2 rounded-xl bg-gradient-to-r from-green-50 to-emerald-50 p-3 border border-green-100 shadow-sm">
            <div className="flex items-center gap-2">
              <div className="p-1.5 bg-white rounded-lg shadow-sm">
                <Sparkles className="h-4 w-4 text-green-600" />
              </div>
              <div>
                <p className="text-sm font-bold text-slate-900 leading-tight">{post.flower_name}</p>
                <p className="text-[11px] text-green-700 font-medium">AI Identification</p>
              </div>
            </div>
            <div className="flex flex-col items-end">
              <div className="shimmer-fast flex items-center gap-1 px-2 py-0.5 bg-green-600 rounded-full text-[10px] font-bold text-white uppercase tracking-wider">
                Verified
              </div>
              <p className="text-[10px] text-slate-400 mt-1">{post.ai_confidence}% score</p>
            </div>
          </div>
        ) : (
          <div className="flex items-center gap-2 rounded-lg bg-slate-50 p-2.5 border border-slate-100">
            <div className="p-1 bg-white rounded shadow-xs">
              <Sparkles className="h-3.5 w-3.5 text-slate-400" />
            </div>
            <p className="text-sm font-bold text-slate-900">{post.flower_name}</p>
          </div>
        )}

        {/* Location */}
        {post.location_name && (
          <div className="flex items-center gap-1 text-[11px] text-slate-400">
            <MapPin className="h-3 w-3" />
            <span>{post.location_name}</span>
          </div>
        )}
      </div>
    </Card>
  )
}
