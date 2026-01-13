/**
 * Feed Page
 * Main social feed with filters and infinite scroll
 */

'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { PostFeed } from '@/components/feed/post-feed-new';
import { FeedFilters } from '@/components/feed/feed-filters';
import { SidebarMenu } from '@/components/feed/sidebar-menu';
import { CreatePostButton } from '@/components/feed/create-post-button';
import { Button } from '@/components/ui/button';
import { Search, Users, Flower2 } from 'lucide-react';
import Link from 'next/link';
import { NotificationDrawer } from '@/components/notifications/notification-drawer';
import { auth } from '@/lib/supabase/api';

export default function FeedPage() {
    const [filter, setFilter] = useState<'latest' | 'trending' | 'following'>('latest');
    const [isLoading, setIsLoading] = useState(true);
    const router = useRouter();

    useEffect(() => {
        checkAuth();
    }, []);

    const checkAuth = async () => {
        try {
            const user = await auth.getCurrentUser();
            if (!user) {
                router.push('/auth/login');
            } else {
                setIsLoading(false);
            }
        } catch (error) {
            router.push('/auth/login');
        }
    };

    if (isLoading) {
        return (
            <div className="flex min-h-screen items-center justify-center">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-green-500"></div>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-gradient-to-b from-green-50 to-white">
            {/* Sidebar Menu */}
            <SidebarMenu />

            {/* Main Layout */}
            <div className="lg:ml-[280px]">
                {/* Header */}
                <header className="sticky top-0 z-40 bg-white/80 backdrop-blur-md border-b">
                    <div className="px-6 py-4">
                        <div className="flex items-center justify-between max-w-4xl mx-auto">
                            {/* Logo and Search */}
                            <div className="flex items-center gap-4 flex-1">
                                <Link href="/feed" className="flex items-center gap-2">
                                    <div className="h-10 w-10 rounded-full bg-gradient-to-br from-green-500 to-pink-500 flex items-center justify-center">
                                        <Flower2 className="h-6 w-6 text-white" />
                                    </div>
                                    <h1 className="text-xl font-bold bg-gradient-to-r from-green-600 to-pink-600 bg-clip-text text-transparent hidden sm:block">
                                        FlowerSocial
                                    </h1>
                                </Link>
                                
                                {/* Search Bar */}
                                <div className="hidden md:flex items-center gap-2 bg-gray-100 rounded-full px-4 py-2 flex-1 max-w-md">
                                    <Search className="h-4 w-4 text-gray-500" />
                                    <input
                                        type="text"
                                        placeholder="Tìm kiếm trên FlowerSocial"
                                        className="bg-transparent border-none outline-none flex-1 text-sm placeholder:text-gray-500"
                                        onClick={() => router.push('/search')}
                                    />
                                </div>
                            </div>

                            {/* Right Actions */}
                            <div className="flex items-center gap-2">
                                <Link href="/groups">
                                    <Button variant="ghost" size="icon" title="Groups">
                                        <Users className="h-5 w-5" />
                                    </Button>
                                </Link>
                                <Link href="/search" className="md:hidden">
                                    <Button variant="ghost" size="icon" title="Search">
                                        <Search className="h-5 w-5" />
                                    </Button>
                                </Link>
                                <NotificationDrawer />
                            </div>
                        </div>
                    </div>
                </header>

                {/* Main Content */}
                <main className="px-6 py-6">
                    <div className="max-w-2xl mx-auto">
                        {/* Filters */}
                        <div className="mb-6">
                            <FeedFilters value={filter} onChange={setFilter} />
                        </div>

                        {/* Feed */}
                        <PostFeed filter={filter} />
                    </div>
                </main>
            </div>

            {/* Create Post FAB */}
            <CreatePostButton />
        </div>
    );
}
