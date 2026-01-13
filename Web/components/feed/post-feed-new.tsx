'use client';

import { useEffect, useState, useCallback } from 'react';
import { PostCard } from './post-card';
import { Button } from '@/components/ui/button';
import { Loader2 } from 'lucide-react';
import { posts as postsApi, auth } from '@/lib/supabase/api';
import type { Post } from '@/lib/supabase/api';
import { toast } from 'sonner';

interface PostFeedProps {
    initialPosts?: Post[];
    filter?: 'latest' | 'trending' | 'following';
}

export function PostFeed({ initialPosts = [], filter = 'latest' }: PostFeedProps) {
    const [posts, setPosts] = useState<Post[]>(initialPosts);
    const [page, setPage] = useState(0);
    const [loading, setLoading] = useState(false);
    const [hasMore, setHasMore] = useState(true);
    const [currentUserId, setCurrentUserId] = useState<string | undefined>();
    const [cache, setCache] = useState<Partial<Record<'latest' | 'trending' | 'following', { posts: Post[]; page: number; hasMore: boolean }>>>({})

    useEffect(() => {
        loadCurrentUser();

        const cached = cache[filter]
        if (cached) {
            setPosts(cached.posts)
            setPage(cached.page)
            setHasMore(cached.hasMore)
        } else {
            setPosts([])
            setPage(0)
            setHasMore(true)
            loadPosts(0, filter)
        }
    // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [filter]);

    const loadCurrentUser = async () => {
        const user = await auth.getCurrentUser();
        if (user) setCurrentUserId(user.id);
    };

    const loadPosts = useCallback(async (pageNum: number, targetFilter: 'latest' | 'trending' | 'following' = filter) => {
        if (loading) return;

        setLoading(true);
        try {
            let newPosts: Post[] = [];

            switch (targetFilter) {
                case 'trending':
                    // Trending: Posts sorted by engagement (likes + comments) in last 7 days
                    if (pageNum === 0) {
                        newPosts = await postsApi.getTrending(7, 20);
                    } else {
                        // For trending, we don't support pagination well, so just load more regular posts
                        newPosts = await postsApi.getAll(pageNum, 20);
                    }
                    break;
                case 'following':
                    // Following: Only posts from users you follow
                    newPosts = await postsApi.getFollowingFeed(pageNum, 20);
                    break;
                default:
                    // Latest: All posts sorted by creation date
                    newPosts = await postsApi.getAll(pageNum, 20);
            }

            setHasMore(newPosts.length >= 20);

            if (pageNum === 0) {
                setPosts(newPosts);
            } else {
                setPosts(prev => [...prev, ...newPosts]);
            }

            // cache results for this filter to avoid flashing/spinner when switching tabs
            setCache(prev => ({
                ...prev,
                [targetFilter]: {
                    posts: pageNum === 0 ? newPosts : [...(prev[targetFilter]?.posts || []), ...newPosts],
                    page: pageNum,
                    hasMore: newPosts.length >= 20
                }
            }))
        } catch (error: any) {
            console.error('Error loading posts:', {
                message: error?.message,
                details: error?.details,
                hint: error?.hint,
                code: error?.code,
                error: error
            });
            toast.error('Failed to load posts');
            // Fallback to regular feed on error
            if (pageNum === 0) {
                try {
                    const fallbackPosts = await postsApi.getAll(0, 20);
                    setPosts(fallbackPosts);
                } catch (fallbackError: any) {
                    console.error('Fallback also failed:', {
                        message: fallbackError?.message,
                        details: fallbackError?.details,
                        hint: fallbackError?.hint,
                        code: fallbackError?.code,
                        error: fallbackError
                    });
                }
            }
        } finally {
            setLoading(false);
        }
    }, [filter, loading]);

    const loadMore = () => {
        const nextPage = page + 1;
        setPage(nextPage);
        loadPosts(nextPage, filter);
    };

    const handleLikeChange = (postId: string, isLiked: boolean) => {
        setPosts(prev => prev.map(post =>
            post.id === postId
                ? { ...post, is_liked_by_current_user: isLiked, likes_count: post.likes_count + (isLiked ? 1 : -1) }
                : post
        ));
    };

    const handleDeletePost = async (postId: string) => {
        if (!window.confirm("Are you sure you want to delete this post?")) return;

        try {
            await postsApi.delete(postId);
            setPosts(prev => prev.filter(p => p.id !== postId));
            toast.success("Post deleted");
        } catch (error) {
            console.error("Error deleting post:", error);
            toast.error("Failed to delete post");
        }
    };

    if (posts.length === 0 && !loading) {
        return (
            <div className="flex flex-col items-center justify-center py-12 text-center bg-white rounded-xl border border-green-100 shadow-sm">
                <div className="text-6xl mb-4">🌸</div>
                <h3 className="text-lg font-semibold mb-2">No posts yet</h3>
                <p className="text-muted-foreground mb-4 max-w-xs">
                    Be the first to share a beautiful flower in our community!
                </p>
                <Button className="bg-green-600 hover:bg-green-700" onClick={() => loadPosts(0)}>
                    Refresh Feed
                </Button>
            </div>
        );
    }

    return (
        <div className="space-y-6 pb-20">
            {posts.map((post) => (
                <PostCard
                    key={post.id}
                    post={post}
                    currentUserId={currentUserId}
                    onLikeChange={handleLikeChange}
                    onDelete={handleDeletePost}
                />
            ))}

            {loading && posts.length === 0 && (
                <div className="flex justify-center py-8">
                    <Loader2 className="h-8 w-8 animate-spin text-green-500" />
                </div>
            )}

            {!loading && hasMore && posts.length > 0 && (
                <div className="flex justify-center py-4">
                    <Button
                        onClick={loadMore}
                        variant="outline"
                        size="lg"
                        className="border-green-200 text-green-700 hover:bg-green-50"
                    >
                        Load More
                    </Button>
                </div>
            )}

            {!hasMore && posts.length > 0 && (
                <p className="text-center text-sm text-slate-400 py-8 italic">
                    You've reached the end! 🌺
                </p>
            )}
        </div>
    );
}
