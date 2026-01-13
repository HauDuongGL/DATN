/**
 * User Profile Page
 * Display user information, stats, and posts
 */

'use client';

import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Image from 'next/image';
import Link from 'next/link';
import { ArrowLeft, Settings, UserPlus, UserMinus, MessageCircle, MoreHorizontal } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { users, posts as postsApi, follows, auth } from '@/lib/supabase/api';
import type { UserProfile, Post } from '@/lib/supabase/api';
import { toast } from 'sonner';
import { Loader2 } from 'lucide-react';

export default function UserProfilePage() {
    const params = useParams();
    const router = useRouter();
    const username = params.username as string;

    const [profile, setProfile] = useState<UserProfile | null>(null);
    const [userPosts, setUserPosts] = useState<Post[]>([]);
    const [loading, setLoading] = useState(true);
    const [isFollowing, setIsFollowing] = useState(false);
    const [isOwnProfile, setIsOwnProfile] = useState(false);
    const [followLoading, setFollowLoading] = useState(false);

    useEffect(() => {
        loadProfile();
    }, [username]);

    // Reload profile when page becomes visible (user comes back from another tab)
    useEffect(() => {
        let lastVisibilityChange = Date.now();
        
        const handleVisibilityChange = () => {
            if (document.visibilityState === 'visible') {
                const now = Date.now();
                // Only reload if page was hidden for more than 2 seconds
                if (now - lastVisibilityChange > 2000 && !loading) {
                    loadProfile();
                }
                lastVisibilityChange = now;
            } else {
                lastVisibilityChange = Date.now();
            }
        };

        document.addEventListener('visibilitychange', handleVisibilityChange);
        return () => {
            document.removeEventListener('visibilitychange', handleVisibilityChange);
        };
    }, [username, loading]);

    const loadProfile = async () => {
        try {
            // Lookup profile by username
            const data = await users.getProfileByUsername(username);
            if (!data) {
                setProfile(null);
                setUserPosts([]);
                setIsFollowing(false);
                toast.error('User not found');
                return;
            }

            setProfile(data);

            // Determine if this is the current user's own profile
            const currentUser = await auth.getCurrentUser();
            setIsOwnProfile(currentUser?.id === data.id);

            // Check follow status separately (more reliable)
            if (currentUser && currentUser.id !== data.id) {
                try {
                    const isFollowingStatus = await follows.isFollowing(data.id);
                    setIsFollowing(isFollowingStatus);
                } catch (followError: any) {
                    console.warn('Error checking follow status:', followError);
                    // Default to false if check fails
                    setIsFollowing(false);
                }
            } else {
                setIsFollowing(false); // Can't follow yourself
            }

            // Load user's posts using their id
            const posts = await postsApi.getUserPosts(data.id);
            setUserPosts(posts);
        } catch (error: any) {
            console.error('Error loading profile:', {
                message: error?.message,
                details: error?.details,
                hint: error?.hint,
                code: error?.code,
                error,
            });
            toast.error('Failed to load profile');
        } finally {
            setLoading(false);
        }
    };

    const handleFollow = async () => {
        if (followLoading || !profile) return;

        setFollowLoading(true);
        const newIsFollowing = !isFollowing;

        // Optimistic update
        setIsFollowing(newIsFollowing);
        setProfile(prev => prev ? {
            ...prev,
            followers_count: (prev.followers_count || 0) + (newIsFollowing ? 1 : -1)
        } : null);

        try {
            if (newIsFollowing) {
                await follows.follow(profile.id);
            } else {
                await follows.unfollow(profile.id);
            }
            
            // Wait a bit for database to sync, then verify follow status
            await new Promise(resolve => setTimeout(resolve, 300));
            
            // Verify follow status after action
            try {
                const verifiedStatus = await follows.isFollowing(profile.id);
                console.log('[handleFollow] Verified status:', verifiedStatus, 'Expected:', newIsFollowing);
                
                if (verifiedStatus !== newIsFollowing) {
                    console.warn('[handleFollow] Status mismatch! Expected:', newIsFollowing, 'Got:', verifiedStatus);
                    // Retry verification once more
                    await new Promise(resolve => setTimeout(resolve, 500));
                    const retryStatus = await follows.isFollowing(profile.id);
                    setIsFollowing(retryStatus);
                    console.log('[handleFollow] Retry verified status:', retryStatus);
                } else {
                    setIsFollowing(verifiedStatus);
                }
            } catch (verifyError) {
                console.warn('Could not verify follow status:', verifyError);
                // Keep optimistic update if verification fails
            }
            
            toast.success(newIsFollowing ? 'Đã follow!' : 'Đã bỏ follow');
            
            // Reload profile to ensure all data is fresh
            setTimeout(() => {
                loadProfile();
            }, 1000);
        } catch (error: any) {
            // Revert on error
            setIsFollowing(!newIsFollowing);
            setProfile(prev => prev ? {
                ...prev,
                followers_count: (prev.followers_count || 0) + (newIsFollowing ? -1 : 1)
            } : null);
            
            // Better error handling
            let errorMessage = 'Failed to update follow status';
            
            if (error?.code === '23505') {
                // Duplicate key error - already following
                errorMessage = 'You are already following this user';
                setIsFollowing(true);
            } else if (error?.code === 'PGRST116') {
                // Not found error - already unfollowed
                errorMessage = 'You are not following this user';
                setIsFollowing(false);
            } else if (error?.message) {
                errorMessage = error.message;
            }
            
            // Better error logging - handle all error types
            let errorInfo: any = {};
            
            try {
                // If error is an Error instance
                if (error instanceof Error) {
                    errorInfo = {
                        name: error.name,
                        message: error.message,
                        stack: error.stack,
                    };
                    
                    // Try to get additional properties
                    const errorKeys = Object.getOwnPropertyNames(error);
                    errorKeys.forEach(key => {
                        if (!['name', 'message', 'stack'].includes(key)) {
                            try {
                                errorInfo[key] = (error as any)[key];
                            } catch {
                                // Skip if can't access
                            }
                        }
                    });
                } 
                // If error is a plain object
                else if (error && typeof error === 'object') {
                    errorInfo = { ...error };
                    
                    // Try to stringify
                    try {
                        errorInfo._stringified = JSON.stringify(error, null, 2);
                    } catch {
                        errorInfo._stringified = 'Could not stringify';
                    }
                } 
                // If error is a primitive
                else {
                    errorInfo = {
                        type: typeof error,
                        value: String(error)
                    };
                }
                
                // Always log the raw error first
                console.error('Raw error:', error);
                console.error('Error updating follow status (parsed):', errorInfo);
                
            } catch (logError) {
                // If even logging fails, just log what we can
                console.error('Error updating follow status (logging failed):', {
                    originalError: String(error),
                    logError: String(logError)
                });
            }
            
            toast.error(errorMessage);
        } finally {
            setFollowLoading(false);
        }
    };

    if (loading) {
        return (
            <div className="min-h-screen flex items-center justify-center">
                <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
            </div>
        );
    }

    if (!profile) {
        return (
            <div className="min-h-screen flex flex-col items-center justify-center">
                <h2 className="text-2xl font-bold mb-2">User not found</h2>
                <Button onClick={() => router.push('/feed')}>Back to Feed</Button>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-gradient-to-b from-green-50 to-white">
            {/* Header */}
            <header className="sticky top-0 z-40 bg-white/80 backdrop-blur-md border-b">
                <div className="container mx-auto max-w-4xl px-4 py-4">
                    <div className="flex items-center justify-between">
                        <Button
                            variant="ghost"
                            onClick={() => router.back()}
                            className="gap-2"
                        >
                            <ArrowLeft className="h-4 w-4" />
                            Back
                        </Button>

                        {isOwnProfile && (
                            <Link href="/settings/profile">
                                <Button variant="ghost" size="icon">
                                    <Settings className="h-5 w-5" />
                                </Button>
                            </Link>
                        )}
                    </div>
                </div>
            </header>

            <main className="container mx-auto max-w-4xl px-4 py-6">
                {/* Profile Header */}
                <Card className="mb-6">
                    <CardContent className="p-6">
                        <div className="flex flex-col md:flex-row gap-6">
                            {/* Avatar */}
                            <Avatar className="h-32 w-32 border-4 border-white shadow-lg">
                                <AvatarImage src={profile.avatar_url} />
                                <AvatarFallback className="text-3xl">
                                    {profile.username?.[0]?.toUpperCase()}
                                </AvatarFallback>
                            </Avatar>

                            {/* Info */}
                            <div className="flex-1 space-y-4">
                                <div>
                                    <h1 className="text-2xl font-bold">{profile.full_name || profile.username}</h1>
                                    <p className="text-muted-foreground">@{profile.username}</p>
                                </div>

                                {profile.bio && (
                                    <p className="text-sm">{profile.bio}</p>
                                )}

                                {/* Stats */}
                                <div className="flex gap-6">
                                    <div className="text-center">
                                        <p className="font-bold text-xl">{profile.posts_count || 0}</p>
                                        <p className="text-sm text-muted-foreground">Posts</p>
                                    </div>
                                    <div className="text-center">
                                        <p className="font-bold text-xl">{profile.followers_count || 0}</p>
                                        <p className="text-sm text-muted-foreground">Followers</p>
                                    </div>
                                    <div className="text-center">
                                        <p className="font-bold text-xl">{profile.following_count || 0}</p>
                                        <p className="text-sm text-muted-foreground">Following</p>
                                    </div>
                                </div>

                                {/* Actions */}
                                <div className="flex gap-2">
                                    {isOwnProfile ? (
                                        <Link href="/settings/profile" className="flex-1">
                                            <Button variant="outline" className="w-full">
                                                Edit Profile
                                            </Button>
                                        </Link>
                                    ) : (
                                        <>
                                            <Button
                                                onClick={handleFollow}
                                                disabled={followLoading}
                                                className="flex-1"
                                                variant={isFollowing ? 'outline' : 'default'}
                                            >
                                                {followLoading ? (
                                                    <Loader2 className="h-4 w-4 animate-spin mr-2" />
                                                ) : isFollowing ? (
                                                    <UserMinus className="h-4 w-4 mr-2" />
                                                ) : (
                                                    <UserPlus className="h-4 w-4 mr-2" />
                                                )}
                                                {isFollowing ? 'Unfollow' : 'Follow'}
                                            </Button>
                                            <Button variant="outline">
                                                <MessageCircle className="h-4 w-4 mr-2" />
                                                Message
                                            </Button>
                                            <Button variant="ghost" size="icon">
                                                <MoreHorizontal className="h-4 w-4" />
                                            </Button>
                                        </>
                                    )}
                                </div>
                            </div>
                        </div>
                    </CardContent>
                </Card>

                {/* Posts Tabs */}
                <Tabs defaultValue="posts" className="w-full">
                    <TabsList className="grid w-full grid-cols-3">
                        <TabsTrigger value="posts">Posts</TabsTrigger>
                        <TabsTrigger value="liked">Liked</TabsTrigger>
                        <TabsTrigger value="saved">Saved</TabsTrigger>
                    </TabsList>

                    <TabsContent value="posts" className="mt-6">
                        {userPosts.length === 0 ? (
                            <Card>
                                <CardContent className="p-12 text-center">
                                    <p className="text-muted-foreground">No posts yet</p>
                                </CardContent>
                            </Card>
                        ) : (
                            <div className="grid grid-cols-3 gap-1 md:gap-2">
                                {userPosts.map((post) => (
                                    <Link key={post.id} href={`/post-new/${post.id}`}>
                                        <div className="relative aspect-square overflow-hidden rounded-lg bg-muted hover:opacity-90 transition-opacity">
                                            <Image
                                                src={post.image_url}
                                                alt={post.flower_name}
                                                fill
                                                className="object-cover"
                                            />
                                        </div>
                                    </Link>
                                ))}
                            </div>
                        )}
                    </TabsContent>

                    <TabsContent value="liked" className="mt-6">
                        <Card>
                            <CardContent className="p-12 text-center">
                                <p className="text-muted-foreground">Liked posts coming soon...</p>
                            </CardContent>
                        </Card>
                    </TabsContent>

                    <TabsContent value="saved" className="mt-6">
                        <Card>
                            <CardContent className="p-12 text-center">
                                <p className="text-muted-foreground">Saved posts coming soon...</p>
                            </CardContent>
                        </Card>
                    </TabsContent>
                </Tabs>
            </main>
        </div>
    );
}
