'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { 
    Users, 
    Bell, 
    UserCircle, 
    Settings as SettingsIcon, 
    Film, 
    ChevronDown,
    Sparkles,
    LogOut
} from 'lucide-react';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { cn } from '@/lib/utils';
import { auth, users as usersApi } from '@/lib/supabase/api';
import type { UserProfile } from '@/lib/supabase/api';
import { createClient } from '@/lib/supabase/client';

interface MenuItem {
    id: string;
    label: string;
    icon: React.ComponentType<{ className?: string }>;
    href?: string;
}

const menuItems: MenuItem[] = [
    // Bạn bè => Follow
    { id: 'follow', label: 'Follow', icon: Users, href: '/friends' },
    // Kỷ niệm => Notifications
    { id: 'notifications', label: 'Notifications', icon: Bell, href: '/notifications' },
    // Đã lưu => Profile (href handled dynamically because it needs current user id)
    { id: 'profile', label: 'Profile', icon: UserCircle },
    // Nhóm => Settings
    { id: 'settings', label: 'Settings', icon: SettingsIcon, href: '/settings' },
    // Thước phim => Group
    { id: 'groups', label: 'Groups', icon: Users, href: '/groups' },
    // Marketplace => Logout (handled as action)
    { id: 'logout', label: 'Logout', icon: LogOut },
];

export function SidebarMenu() {
    const pathname = usePathname();
    const router = useRouter();
    const supabase = createClient();

    const [currentUser, setCurrentUser] = useState<UserProfile | null>(null);
    const [loading, setLoading] = useState(true);
    const [loggingOut, setLoggingOut] = useState(false);

    useEffect(() => {
        loadCurrentUser();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    const loadCurrentUser = async () => {
        try {
            const user = await auth.getCurrentUser();
            if (user) {
                const profile = await usersApi.getProfile(user.id);
                setCurrentUser(profile);
            }
        } catch (error) {
            console.error('Error loading user:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleLogout = async () => {
        if (loggingOut) return;
        try {
            setLoggingOut(true);
            await supabase.auth.signOut();
            router.push('/auth/login');
            router.refresh();
        } catch (error) {
            console.error('Error during logout:', error);
        } finally {
            setLoggingOut(false);
        }
    };

    const isActive = (href: string) => {
        if (href === '/feed' || href === '/') {
            return pathname === '/feed' || pathname === '/';
        }
        return pathname === href || pathname.startsWith(href + '/');
    };

    return (
        <aside className="fixed left-0 top-0 h-screen w-[280px] border-r bg-white overflow-y-auto z-30 hidden lg:block">
            <div className="flex flex-col h-full">
                {/* Profile Section */}
                <div className="p-4 border-b">
                    {loading ? (
                        <div className="flex items-center gap-3 p-2 rounded-lg">
                            <div className="h-10 w-10 rounded-full bg-gray-200 animate-pulse" />
                            <div className="h-4 w-24 bg-gray-200 rounded animate-pulse" />
                        </div>
                    ) : currentUser ? (
                        <Link
                            href={`/profile-new/${currentUser.username}`}
                            className={cn(
                                "flex items-center gap-3 p-2 rounded-lg transition-colors",
                                "hover:bg-gray-100",
                                isActive(`/profile-new/${currentUser.username}`) && "bg-green-50"
                            )}
                        >
                            <Avatar className="h-10 w-10">
                                <AvatarImage src={currentUser.avatar_url} />
                                <AvatarFallback className="bg-green-500 text-white">
                                    {currentUser.username?.[0]?.toUpperCase() || 'U'}
                                </AvatarFallback>
                            </Avatar>
                            <span className="font-semibold text-gray-900">
                                {currentUser.full_name || currentUser.username}
                            </span>
                        </Link>
                    ) : (
                        <div className="flex items-center gap-3 p-2 rounded-lg">
                            <Avatar className="h-10 w-10">
                                <AvatarFallback className="bg-gray-200" />
                            </Avatar>
                            <span className="font-semibold text-gray-400">Guest</span>
                        </div>
                    )}
                </div>

                {/* Menu Items */}
                <nav className="flex-1 p-2">
                    {/* Meta AI - Special item with gradient */}
                    <Link
                        href="/ai"
                        className={cn(
                            "flex items-center gap-3 px-3 py-2.5 rounded-lg mb-1 transition-colors",
                            "hover:bg-gray-100",
                            isActive('/ai') && "bg-gradient-to-r from-blue-50 to-purple-50"
                        )}
                    >
                        <div className={cn(
                            "h-9 w-9 rounded-full flex items-center justify-center",
                            "bg-gradient-to-br from-blue-500 via-purple-500 to-pink-500"
                        )}>
                            <Sparkles className="h-5 w-5 text-white" />
                        </div>
                        <span className="font-medium text-gray-900">Meta AI</span>
                    </Link>

                    {/* Regular Menu Items */}
                    {menuItems.map((item) => {
                        const Icon = item.icon;
                        let href = item.href;

                        // Dynamic href cho Profile (dựa trên current user)
                        if (item.id === 'profile') {
                            href = currentUser ? `/profile/${currentUser.id}` : '/auth/login';
                        }

                        const active = href ? isActive(href) : false;
                        
                        // Logout là action, dùng button thay vì Link
                        if (item.id === 'logout') {
                            return (
                                <button
                                    key={item.id}
                                    onClick={handleLogout}
                                    className={cn(
                                        "flex items-center gap-3 px-3 py-2.5 rounded-lg mb-1 w-full transition-colors",
                                        "hover:bg-red-50 text-left"
                                    )}
                                >
                                    <div className="h-9 w-9 rounded-full flex items-center justify-center bg-red-100">
                                        <Icon className="h-5 w-5 text-red-600" />
                                    </div>
                                    <span className="font-medium text-red-600">
                                        {loggingOut ? 'Logging out...' : item.label}
                                    </span>
                                </button>
                            );
                        }

                        if (!href) return null;

                        return (
                            <Link
                                key={item.id}
                                href={href}
                                className={cn(
                                    "flex items-center gap-3 px-3 py-2.5 rounded-lg mb-1 transition-colors",
                                    "hover:bg-gray-100",
                                    active && "bg-green-50"
                                )}
                            >
                                <div className={cn(
                                    "h-9 w-9 rounded-full flex items-center justify-center",
                                    active ? "bg-green-500" : "bg-gray-100"
                                )}>
                                    <Icon className={cn(
                                        "h-5 w-5",
                                        active ? "text-white" : "text-gray-600"
                                    )} />
                                </div>
                                <span className={cn(
                                    "font-medium",
                                    active ? "text-green-700" : "text-gray-900"
                                )}>
                                    {item.label}
                                </span>
                            </Link>
                        );
                    })}

                    {/* See More */}
                    <button
                        className={cn(
                            "flex items-center gap-3 px-3 py-2.5 rounded-lg mb-1 w-full transition-colors",
                            "hover:bg-gray-100 text-left"
                        )}
                    >
                        <div className="h-9 w-9 rounded-full flex items-center justify-center bg-gray-100">
                            <ChevronDown className="h-5 w-5 text-gray-600" />
                        </div>
                        <span className="font-medium text-gray-900">Xem thêm</span>
                    </button>
                </nav>
            </div>
        </aside>
    );
}
