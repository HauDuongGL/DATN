'use client';

import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Image from 'next/image';
import Link from 'next/link';
import { ArrowLeft, Heart, MessageCircle, Share2, Bookmark, MapPin, Sparkles } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader } from '@/components/ui/card';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import { Separator } from '@/components/ui/separator';
import { posts as postsApi, likes, auth } from '@/lib/supabase/api';
import type { Post } from '@/lib/supabase/api';
import { toast } from 'sonner';
import { Loader2 } from 'lucide-react';
import { CommentSection } from '@/components/post/comment-section';

export default function PostDetailPage() {
    const params = useParams();
    const router = useRouter();
    const postId = params.id as string;

    const [post, setPost] = useState<Post | null>(null);
    const [loading, setLoading] = useState(true);
    const [isLiked, setIsLiked] = useState(false);
    const [likesCount, setLikesCount] = useState(0);
    const [isLiking, setIsLiking] = useState(false);
    const [currentUserId, setCurrentUserId] = useState<string | undefined>();

    useEffect(() => {
        loadPost();
        checkIfLiked();
        loadCurrentUser();
    }, [postId]);

    const loadCurrentUser = async () => {
        const user = await auth.getCurrentUser();
        if (user) setCurrentUserId(user.id);
    };

    const loadPost = async () => {
        try {
            const data = await postsApi.getById(postId);
            setPost(data);
            setLikesCount(data.likes_count);
        } catch (error) {
            console.error('Error loading post:', error);
            toast.error('Failed to load post');
        } finally {
            setLoading(false);
        }
    };

    const checkIfLiked = async () => {
        try {
            const liked = await likes.isLiked(postId);
            setIsLiked(liked);
        } catch (error) {
            console.error('Error checking like status:', error);
        }
    };

    const handleLike = async () => {
        if (isLiking) return;

        setIsLiking(true);
        const newIsLiked = !isLiked;

        // Optimistic update
        setIsLiked(newIsLiked);
        setLikesCount(prev => newIsLiked ? prev + 1 : prev - 1);

        try {
            if (newIsLiked) {
                if (!currentUserId) {
                    toast.error('You must be logged in to like');
                    throw new Error('Not logged in');
                }
                await likes.like(postId, currentUserId);
            } else {
                if (!currentUserId) throw new Error('Not logged in');
                await likes.unlike(postId, currentUserId);
            }
        } catch (error) {
            // Revert on error
            setIsLiked(!newIsLiked);
            setLikesCount(prev => newIsLiked ? prev - 1 : prev + 1);
            toast.error('Failed to update like');
        } finally {
            setIsLiking(false);
        }
    };

    const getConfidenceColor = (confidence: number) => {
        if (confidence >= 90) return 'bg-green-500';
        if (confidence >= 70) return 'bg-yellow-500';
        return 'bg-orange-500';
    };

    const handleShare = async () => {
        if (!post) return;
        if (!currentUserId) {
            toast.error('You must be logged in to share');
            return;
        }

        try {
            // Debug: Kiểm tra dữ liệu post
            console.log('Sharing post:', {
                id: post.id,
                flower_description: post.flower_description,
                planting_guide: post.planting_guide,
                caption: post.caption
            });

            // Lấy description và planting_guide (Care) để đưa vào caption
            const params = new URLSearchParams();
            if (post.image_url) params.set('imageUrl', post.image_url);

            // Kiểm tra và thêm description (giới hạn độ dài để tránh URL quá dài)
            if (post.flower_description && post.flower_description.trim()) {
                const description = post.flower_description.trim();
                // Giới hạn 5000 ký tự để tránh URL quá dài (URL max ~2000 chars)
                params.set('description', description.length > 5000 ? description.substring(0, 5000) : description);
            }

            // Kiểm tra và thêm care (planting_guide) (giới hạn độ dài)
            if (post.planting_guide && post.planting_guide.trim()) {
                const care = post.planting_guide.trim();
                params.set('care', care.length > 5000 ? care.substring(0, 5000) : care);
            }

            if (post.flower_name) params.set('flowerName', post.flower_name);
            if (post.flower_species) params.set('flowerSpecies', post.flower_species);

            console.log('Share params:', params.toString());

            // Redirect đến upload page (dùng /upload thay vì /upload-new)
            const url = `/upload?${params.toString()}`;
            console.log('Redirecting to:', url);

            try {
                router.push(url);
            } catch (pushError) {
                console.error('Router push failed, trying window.location:', pushError);
                // Fallback: dùng window.location nếu router.push fail
                window.location.href = url;
            }
        } catch (error) {
            console.error('Error sharing post:', error);
            toast.error('Failed to share post');
        }
    };

    if (loading) {
        return (
            <div className="min-h-screen flex items-center justify-center">
                <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
            </div>
        );
    }

    if (!post) {
        return (
            <div className="min-h-screen flex flex-col items-center justify-center">
                <h2 className="text-2xl font-bold mb-2">Post not found</h2>
                <Button onClick={() => router.push('/feed')}>Back to Feed</Button>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-gradient-to-b from-green-50 to-white">
            {/* Header */}
            <header className="sticky top-0 z-40 bg-white/80 backdrop-blur-md border-b">
                <div className="container mx-auto max-w-4xl px-4 py-4">
                    <Button
                        variant="ghost"
                        onClick={() => router.back()}
                        className="gap-2"
                    >
                        <ArrowLeft className="h-4 w-4" />
                        Back
                    </Button>
                </div>
            </header>

            <main className="container mx-auto max-w-4xl px-4 py-6">
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    {/* Left Column - Image */}
                    <div className="space-y-4">
                        <Card className="overflow-hidden">
                            <div className="relative aspect-square w-full bg-slate-100 flex items-center justify-center">
                                {post.image_url ? (
                                    <Image
                                        src={post.image_url}
                                        alt={post.flower_name || 'Flower'}
                                        fill
                                        className="object-cover"
                                        priority
                                    />
                                ) : (
                                    <div className="flex flex-col items-center gap-2 text-slate-400">
                                        <Sparkles className="h-12 w-12" />
                                        <span className="text-sm">No image available</span>
                                    </div>
                                )}
                            </div>
                        </Card>

                        {/* Actions */}
                        <Card>
                            <CardContent className="p-4">
                                <div className="flex items-center justify-between">
                                    <div className="flex items-center gap-4">
                                        <Button
                                            variant="ghost"
                                            size="lg"
                                            className={`gap-2 ${isLiked ? 'text-red-500' : ''}`}
                                            onClick={handleLike}
                                            disabled={isLiking}
                                        >
                                            <Heart className={`h-6 w-6 ${isLiked ? 'fill-current' : ''}`} />
                                            <span className="font-semibold">{likesCount}</span>
                                        </Button>

                                        <Button variant="ghost" size="lg" className="gap-2">
                                            <MessageCircle className="h-6 w-6" />
                                            <span className="font-semibold">{post.comments_count}</span>
                                        </Button>

                                        <Button variant="ghost" size="lg" onClick={handleShare}>
                                            <Share2 className="h-6 w-6" />
                                        </Button>
                                    </div>

                                    <Button variant="ghost" size="lg">
                                        <Bookmark className="h-6 w-6" />
                                    </Button>
                                </div>
                            </CardContent>
                        </Card>
                    </div>

                    {/* Right Column - Info & Comments */}
                    <div className="space-y-6">
                        {/* Author Info */}
                        <Card>
                            <CardHeader>
                                <Link
                                    href={`/profile-new/${post.user?.username}`}
                                    className="flex items-center gap-3 hover:opacity-80 transition-opacity"
                                >
                                    <Avatar className="h-12 w-12">
                                        <AvatarImage src={post.user?.avatar_url} />
                                        <AvatarFallback>
                                            {post.user?.username?.[0]?.toUpperCase()}
                                        </AvatarFallback>
                                    </Avatar>
                                    <div>
                                        <p className="font-semibold">{post.user?.full_name || post.user?.username}</p>
                                        <p className="text-sm text-muted-foreground">
                                            {new Date(post.created_at).toLocaleDateString('vi-VN', {
                                                day: 'numeric',
                                                month: 'long',
                                                year: 'numeric'
                                            })}
                                        </p>
                                    </div>
                                </Link>
                            </CardHeader>
                        </Card>

                        {/* Flower Information */}
                        <Card className="border-green-100 shadow-sm overflow-hidden">
                            <div className="bg-gradient-to-r from-green-600 to-emerald-600 px-6 py-4 flex items-center justify-between">
                                <div className="flex items-center gap-2">
                                    <Sparkles className="h-5 w-5 text-white animate-pulse" />
                                    <h2 className="text-xl font-bold text-white">AI Identification</h2>
                                </div>
                                <div className="bg-white/20 backdrop-blur-md rounded-full px-3 py-1 border border-white/30">
                                    <span className="text-xs font-bold text-white uppercase tracking-wider">Verified {post.ai_confidence}%</span>
                                </div>
                            </div>
                            <CardContent className="space-y-6 pt-6">
                                <div>
                                    <h2 className="text-3xl font-bold text-slate-900 mb-1">{post.flower_name}</h2>
                                    <p className="text-sm font-medium text-green-700">Scientific Identification Complete</p>
                                </div>
                                {post.location_name && (
                                    <div className="flex items-center gap-2 text-sm text-emerald-600 mb-4 bg-emerald-50 w-fit px-3 py-1.5 rounded-full">
                                        <MapPin className="h-4 w-4" />
                                        <span>{post.location_name}</span>
                                    </div>
                                )}

                                {post.caption && (
                                    <div>
                                        <h3 className="font-semibold mb-2">Caption</h3>
                                        <p className="text-sm">{post.caption}</p>
                                    </div>
                                )}

                                {post.flower_description && (
                                    <div>
                                        <h3 className="font-semibold mb-2">Description</h3>
                                        <p className="text-sm text-muted-foreground">
                                            {post.flower_description}
                                        </p>
                                    </div>
                                )}

                                {post.planting_guide && (
                                    <div>
                                        <h3 className="font-semibold mb-2">🌱 Planting Guide</h3>
                                        <p className="text-sm text-muted-foreground whitespace-pre-line">
                                            {post.planting_guide}
                                        </p>
                                    </div>
                                )}


                            </CardContent>
                        </Card>

                        <Separator />

                        {/* Comments Section */}
                        <CommentSection postId={postId} currentUserId={currentUserId} />
                    </div>
                </div>
            </main>
        </div>
    );
}
