/**
 * Notifications Page
 * Display user notifications with real-time updates
 */

'use client';

import { useCallback, useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { ArrowLeft, Heart, MessageCircle, UserPlus, Check, Loader2, Bell } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { notifications as notificationsApi } from '@/lib/supabase/api';
import type { Notification } from '@/lib/supabase/api';
import { toast } from 'sonner';

export default function NotificationsPage() {
    const router = useRouter();
    const [notifications, setNotifications] = useState<Notification[]>([]);
    const [loading, setLoading] = useState(true);
    const [filter, setFilter] = useState<'all' | 'unread'>('all');

    const loadNotifications = useCallback(async () => {
        try {
            const data = await notificationsApi.getAll();
            setNotifications(data);
        } catch (error) {
            console.error('Error loading notifications:', error);
            toast.error('Failed to load notifications');
        } finally {
            setLoading(false);
        }
    }, []);

    useEffect(() => {
        loadNotifications();
        const subscription = notificationsApi.subscribeToNotifications(() => {
            loadNotifications();
        });
        return () => {
            subscription?.unsubscribe?.();
        };
    }, [loadNotifications]);

    const handleMarkAsRead = async (notificationId: string) => {
        try {
            await notificationsApi.markAsRead(notificationId);
            setNotifications(prev =>
                prev.map(n => n.id === notificationId ? { ...n, is_read: true } : n)
            );
            // Refresh global unread count badge
            if (typeof window !== 'undefined') {
                window.dispatchEvent(new Event('notifications:refresh-count'));
            }
        } catch (error) {
            console.error('Error marking notification as read:', error);
            toast.error('Failed to mark as read');
        }
    };

    const handleMarkAllAsRead = async () => {
        try {
            await notificationsApi.markAllAsRead();
            setNotifications(prev => prev.map(n => ({ ...n, is_read: true })));
            toast.success('All notifications marked as read');
            // Refresh global unread count badge
            if (typeof window !== 'undefined') {
                window.dispatchEvent(new Event('notifications:refresh-count'));
            }
        } catch (error) {
            console.error('Error marking all as read:', error);
            toast.error('Failed to mark all as read');
        }
    };

    const filteredNotifications = filter === 'unread'
        ? notifications.filter(n => !n.is_read)
        : notifications;

    const unreadCount = notifications.filter(n => !n.is_read).length;

    const getNotificationIcon = (type: string) => {
        switch (type) {
            case 'like':
                return <Heart className="h-5 w-5 text-red-500" />;
            case 'comment':
                return <MessageCircle className="h-5 w-5 text-blue-500" />;
            case 'follow':
                return <UserPlus className="h-5 w-5 text-green-500" />;
            case 'post_created':
                return <Bell className="h-5 w-5 text-amber-500" />;
            case 'share':
                return <Bell className="h-5 w-5 text-purple-500" />;
            default:
                return null;
        }
    };

    const getNotificationLink = (notification: Notification) => {
        if (notification.post_id) {
            return `/post-new/${notification.post_id}`;
        }
        if (notification.actor?.username) {
            return `/profile-new/${notification.actor.username}`;
        }
        return '#';
    };

    return (
        <div className="min-h-screen bg-gradient-to-b from-green-50 to-white">
            {/* Header */}
            <header className="sticky top-0 z-40 bg-white/80 backdrop-blur-md border-b">
                <div className="container mx-auto max-w-2xl px-4 py-4">
                    <div className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                            <Button
                                variant="ghost"
                                size="icon"
                                onClick={() => router.back()}
                            >
                                <ArrowLeft className="h-5 w-5" />
                            </Button>
                            <h1 className="text-xl font-bold">Notifications</h1>
                            {unreadCount > 0 && (
                                <span className="bg-red-500 text-white text-xs font-bold px-2 py-1 rounded-full">
                                    {unreadCount}
                                </span>
                            )}
                        </div>

                        {unreadCount > 0 && (
                            <Button
                                variant="ghost"
                                size="sm"
                                onClick={handleMarkAllAsRead}
                                className="gap-2"
                            >
                                <Check className="h-4 w-4" />
                                Mark all read
                            </Button>
                        )}
                    </div>
                </div>
            </header>

            <main className="container mx-auto max-w-2xl px-4 py-6">
                {/* Filters */}
                <Tabs value={filter} onValueChange={(v) => setFilter(v as any)} className="mb-6">
                    <TabsList className="grid w-full grid-cols-2">
                        <TabsTrigger value="all">
                            All ({notifications.length})
                        </TabsTrigger>
                        <TabsTrigger value="unread">
                            Unread ({unreadCount})
                        </TabsTrigger>
                    </TabsList>
                </Tabs>

                {/* Notifications List */}
                {loading ? (
                    <div className="flex justify-center py-12">
                        <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
                    </div>
                ) : filteredNotifications.length === 0 ? (
                    <Card>
                        <CardContent className="p-12 text-center">
                            <div className="text-6xl mb-4">🔔</div>
                            <h3 className="text-lg font-semibold mb-2">No notifications</h3>
                            <p className="text-muted-foreground">
                                {filter === 'unread'
                                    ? "You're all caught up!"
                                    : "You'll see notifications here when people interact with your posts"}
                            </p>
                        </CardContent>
                    </Card>
                ) : (
                    <div className="space-y-2">
                        {filteredNotifications.map((notification) => (
                            <Card
                                key={notification.id}
                                className={`hover:shadow-md transition-shadow ${!notification.is_read ? 'bg-green-50/50 border-green-200' : ''
                                    }`}
                            >
                                <CardContent className="p-4">
                                    <Link
                                        href={getNotificationLink(notification)}
                                        onClick={() => !notification.is_read && handleMarkAsRead(notification.id)}
                                    >
                                        <div className="flex gap-3">
                                            {/* Icon */}
                                            <div className="flex-shrink-0 mt-1">
                                                {getNotificationIcon(notification.type)}
                                            </div>

                                            {/* Actor Avatar */}
                                            <Avatar className="h-10 w-10">
                                                <AvatarImage src={notification.actor?.avatar_url} />
                                                <AvatarFallback>
                                                    {notification.actor?.username?.[0]?.toUpperCase()}
                                                </AvatarFallback>
                                            </Avatar>

                                            {/* Content */}
                                            <div className="flex-1 min-w-0">
                                                <p className="text-sm">
                                                    <span className="font-semibold">
                                                        {notification.actor?.full_name || notification.actor?.username}
                                                    </span>{' '}
                                                    <span className="text-muted-foreground">
                                                        {notification.message}
                                                    </span>
                                                </p>
                                                <p className="text-xs text-muted-foreground mt-1">
                                                    {new Date(notification.created_at).toLocaleDateString('vi-VN', {
                                                        day: 'numeric',
                                                        month: 'short',
                                                        hour: '2-digit',
                                                        minute: '2-digit'
                                                    })}
                                                </p>
                                            </div>

                                            {/* Unread Indicator */}
                                            {!notification.is_read && (
                                                <div className="flex-shrink-0">
                                                    <div className="h-2 w-2 bg-green-500 rounded-full"></div>
                                                </div>
                                            )}
                                        </div>
                                    </Link>
                                </CardContent>
                            </Card>
                        ))}
                    </div>
                )}
            </main>
        </div>
    );
}
