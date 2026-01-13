"use client"

import { Card, CardContent } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Trash2, ExternalLink } from "lucide-react"
import { formatDistanceToNow } from "date-fns"
import { useState } from "react"
import { createClient } from "@/lib/supabase/client"
import { useRouter } from "next/navigation"
import { toast } from "sonner"
import Link from "next/link"

interface AdminPostListProps {
    posts: Array<{
        id: string
        caption: string | null
        flower_name: string | null
        created_at: string
        author: {
            id: string
            full_name: string | null
            username: string
        }
        post_media: Array<{
            media_url: string
        }>
    }>
    adminId: string
}

export function AdminPostList({ posts, adminId }: AdminPostListProps) {
    const [processing, setProcessing] = useState<string | null>(null)
    const router = useRouter()
    const supabase = createClient()

    const handleDelete = async (postId: string) => {
        if (!confirm("Are you sure you want to delete this post? This action cannot be undone.")) return

        setProcessing(postId)
        try {
            const { error } = await supabase.from("posts").delete().eq("id", postId)

            if (error) throw error

            toast.success("Post deleted successfully")
            router.refresh()
        } catch (error: any) {
            console.error("Error deleting post:", error)
            toast.error("Failed to delete post: " + error.message)
        } finally {
            setProcessing(null)
        }
    }

    if (posts.length === 0) {
        return (
            <Card className="border-slate-200">
                <CardContent className="py-12 text-center text-slate-600">No posts found</CardContent>
            </Card>
        )
    }

    return (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            {posts.map((post) => (
                <Card key={post.id} className="overflow-hidden border-slate-200">
                    <div className="relative aspect-square w-full overflow-hidden bg-slate-100">
                        {post.post_media && post.post_media.length > 0 ? (
                            <img
                                src={post.post_media[0].media_url || "/placeholder.svg"}
                                alt={post.flower_name || "Flower"}
                                className="h-full w-full object-cover"
                            />
                        ) : (
                            <div className="flex h-full w-full items-center justify-center text-slate-400">
                                No image
                            </div>
                        )}
                        <div className="absolute right-2 top-2">
                            <Link href={`/post/${post.id}`} target="_blank">
                                <Button size="icon" variant="secondary" className="h-8 w-8 rounded-full opacity-80 hover:opacity-100">
                                    <ExternalLink className="h-4 w-4" />
                                </Button>
                            </Link>
                        </div>
                    </div>

                    <CardContent className="space-y-3 p-4">
                        <div className="flex items-start justify-between gap-2">
                            <div>
                                <p className="font-semibold text-slate-900">
                                    {post.author.full_name || post.author.username}
                                </p>
                                <p className="text-xs text-slate-500">
                                    {formatDistanceToNow(new Date(post.created_at), { addSuffix: true })}
                                </p>
                            </div>
                        </div>

                        {post.flower_name && (
                            <div className="rounded-lg bg-emerald-50 p-2">
                                <p className="text-sm font-medium text-emerald-900">{post.flower_name}</p>
                            </div>
                        )}

                        {post.caption && <p className="line-clamp-2 text-sm text-slate-700">{post.caption}</p>}

                        <div className="pt-2">
                            <Button
                                onClick={() => handleDelete(post.id)}
                                disabled={processing === post.id}
                                variant="destructive"
                                className="w-full"
                            >
                                <Trash2 className="mr-2 h-4 w-4" />
                                Delete Post
                            </Button>
                        </div>
                    </CardContent>
                </Card>
            ))}
        </div>
    )
}
