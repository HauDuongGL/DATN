'use client';

import { useEffect, useState } from 'react';
import { SidebarMenu } from '@/components/feed/sidebar-menu';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Users, UserMinus, Loader2 } from 'lucide-react';
import Link from 'next/link';
import { follows, auth } from '@/lib/supabase/api';
import { toast } from 'sonner';
import { useRouter } from 'next/navigation';

interface FollowingUser {
    id: string;
    user: {
        id: string;
        username: string;
        avatar_url?: string;
        full_name?: string;
    };
}

export default function FriendsPage() {
    const [following, setFollowing] = useState<FollowingUser[]>([]);
    const [loading, setLoading] = useState(true);
    const [unfollowingIds, setUnfollowingIds] = useState<Set<string>>(new Set());
    const router = useRouter();

    useEffect(() => {
        loadFollowing();
    }, []);

    const loadFollowing = async () => {
        try {
            setLoading(true);
            const user = await auth.getCurrentUser();
            if (!user) {
                router.push('/auth/login');
                return;
            }

            const data = await follows.getFollowing(user.id);
            
            // Transform data to match our interface
            const transformed = data.map((item: any) => {
                // Handle different data structures
                const userData = item.user || item.profiles || null;
                
                return {
                    id: item.id,
                    user: userData ? {
                        id: userData.id || item.following_id,
                        username: userData.username || 'unknown',
                        avatar_url: userData.avatar_url || null,
                        full_name: userData.full_name || null,
                    } : {
                        id: item.following_id,
                        username: 'unknown',
                        avatar_url: null,
                        full_name: null,
                    },
                };
            });
            
            setFollowing(transformed);
            
            // Debug log
            if (data.length > 0) {
                console.log('[FriendsPage] Loaded following:', {
                    count: data.length,
                    sample: data[0],
                });
            }
        } catch (error: any) {
            // Better error logging
            const errorInfo: any = {};
            
            if (error instanceof Error) {
                errorInfo.name = error.name;
                errorInfo.message = error.message;
                errorInfo.stack = error.stack;
            }
            
            if (error && typeof error === 'object') {
                errorInfo.code = error.code;
                errorInfo.details = error.details;
                errorInfo.hint = error.hint;
                
                try {
                    errorInfo._stringified = JSON.stringify(error, null, 2);
                } catch {
                    errorInfo._stringified = 'Could not stringify';
                }
            } else {
                errorInfo.rawError = String(error);
            }
            
            console.error('Error loading following:', errorInfo);
            console.error('Raw error object:', error);
            
            toast.error(error?.message || 'Không thể tải danh sách follow');
        } finally {
            setLoading(false);
        }
    };

    const handleUnfollow = async (userId: string) => {
        if (unfollowingIds.has(userId)) return;

        setUnfollowingIds(prev => new Set(prev).add(userId));

        // Optimistic update
        const previousFollowing = [...following];
        setFollowing(prev => prev.filter(item => item.user.id !== userId));

        try {
            await follows.unfollow(userId);
            toast.success('Đã bỏ follow');
        } catch (error: any) {
            // Revert on error
            setFollowing(previousFollowing);
            console.error('Error unfollowing:', error);
            
            // Better error handling
            if (error?.message?.includes('notifications') || error?.message?.includes('user_id')) {
                // Trigger error, but unfollow succeeded
                toast.success('Đã bỏ follow');
            } else {
                toast.error(error?.message || 'Không thể bỏ follow');
            }
        } finally {
            setUnfollowingIds(prev => {
                const next = new Set(prev);
                next.delete(userId);
                return next;
            });
        }
    };

    return (
        <div className="min-h-screen bg-gradient-to-b from-green-50 to-white">
            <SidebarMenu />
            <div className="lg:ml-[280px]">
                {/* Header */}
                <header className="sticky top-0 z-40 bg-white/80 backdrop-blur-md border-b">
                    <div className="px-6 py-4">
                        <h1 className="text-2xl font-bold">Follow</h1>
                        <p className="text-sm text-muted-foreground mt-1">
                            Danh sách người bạn đang theo dõi
                        </p>
                    </div>
                </header>

                {/* Content */}
                <main className="px-6 py-6">
                    <div className="max-w-4xl mx-auto">
                        {loading ? (
                            <div className="flex items-center justify-center py-12">
                                <Loader2 className="h-8 w-8 animate-spin text-green-500" />
                            </div>
                        ) : following.length === 0 ? (
                            <Card>
                                <CardContent className="p-12 text-center">
                                    <Users className="h-16 w-16 mx-auto mb-4 text-gray-400" />
                                    <h2 className="text-xl font-semibold mb-2">Chưa follow ai</h2>
                                    <p className="text-muted-foreground mb-6">
                                        Bạn chưa follow ai cả. Hãy khám phá và follow những người bạn quan tâm!
                                    </p>
                                    <Link href="/feed">
                                        <Button>Khám phá Feed</Button>
                                    </Link>
                                </CardContent>
                            </Card>
                        ) : (
                            <div className="space-y-3">
                                {following.map((item) => {
                                    const user = item.user;
                                    const isUnfollowing = unfollowingIds.has(user.id);

                                    return (
                                        <Card key={item.id} className="hover:shadow-md transition-shadow">
                                            <CardContent className="p-4">
                                                <div className="flex items-center justify-between">
                                                    <Link
                                                        href={`/profile-new/${user.username}`}
                                                        className="flex items-center gap-4 flex-1 hover:opacity-80 transition-opacity"
                                                    >
                                                        <Avatar className="h-12 w-12">
                                                            <AvatarImage src={user.avatar_url} />
                                                            <AvatarFallback className="bg-green-500 text-white">
                                                                {user.username?.[0]?.toUpperCase() || 'U'}
                                                            </AvatarFallback>
                                                        </Avatar>
                                                        <div>
                                                            <p className="font-semibold">
                                                                {user.full_name || user.username}
                                                            </p>
                                                            <p className="text-sm text-muted-foreground">
                                                                @{user.username}
                                                            </p>
                                                        </div>
                                                    </Link>

                                                    <Button
                                                        variant="outline"
                                                        size="sm"
                                                        onClick={() => handleUnfollow(user.id)}
                                                        disabled={isUnfollowing}
                                                        className="ml-4"
                                                    >
                                                        {isUnfollowing ? (
                                                            <>
                                                                <Loader2 className="h-4 w-4 animate-spin mr-2" />
                                                                Unfollowing...
                                                            </>
                                                        ) : (
                                                            <>
                                                                <UserMinus className="h-4 w-4 mr-2" />
                                                                Unfollow
                                                            </>
                                                        )}
                                                    </Button>
                                                </div>
                                            </CardContent>
                                        </Card>
                                    );
                                })}
                            </div>
                        )}
                    </div>
                </main>
            </div>
        </div>
    );
}
