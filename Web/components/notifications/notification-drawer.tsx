"use client"

import { useEffect, useMemo, useState } from "react"
import Link from "next/link"
import { Bell, Check, Loader2, X } from "lucide-react"
import { notifications as notificationsApi, type Notification } from "@/lib/supabase/api"
import { Drawer, DrawerClose, DrawerContent, DrawerHeader, DrawerTitle, DrawerTrigger } from "@/components/ui/drawer"
import { Button } from "@/components/ui/button"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { NotificationBadge } from "./notification-badge"

export function NotificationDrawer() {
    const [open, setOpen] = useState(false)
    const [items, setItems] = useState<Notification[]>([])
    const [loading, setLoading] = useState(false)

    const unreadCount = useMemo(() => items.filter((n) => !n.is_read).length, [items])

    const loadNotifications = async () => {
        setLoading(true)
        try {
            const data = await notificationsApi.getAll()
            setItems(data || [])
        } catch (error: any) {
            // Log detailed error information
            console.error("Failed to load notifications", {
                message: error?.message,
                details: error?.details,
                hint: error?.hint,
                code: error?.code,
                error
            })
            // Set empty array on error to prevent UI issues
            setItems([])
        } finally {
            setLoading(false)
        }
    }

    useEffect(() => {
        if (!open) return
        loadNotifications()

        let subscription: ReturnType<typeof notificationsApi.subscribeToNotifications> | null = null
        try {
            subscription = notificationsApi.subscribeToNotifications(() => {
                loadNotifications()
            })
        } catch (error) {
            console.error("Failed to subscribe to notifications", error)
        }

        return () => {
            if (subscription) {
                try {
                    subscription.unsubscribe?.()
                } catch (error) {
                    console.error("Error unsubscribing from notifications", error)
                }
            }
        }
    }, [open])

    const handleMarkAll = async () => {
        try {
            await notificationsApi.markAllAsRead()
            setItems((prev) => prev.map((n) => ({ ...n, is_read: true })))
            // Refresh global unread count badge
            if (typeof window !== "undefined") {
                window.dispatchEvent(new Event("notifications:refresh-count"))
            }
        } catch (error) {
            console.error("Failed to mark all as read", error)
        }
    }

    const getMessage = (notification: Notification) => {
        if (notification.message) return notification.message
        switch (notification.type) {
            case "like":
                return "đã thích bài viết của bạn"
            case "comment":
                return "đã bình luận về bài viết của bạn"
            case "follow":
                return "đã theo dõi bạn"
            case "post_created":
                return "đã đăng một bài viết mới"
            case "share":
                return "đã chia sẻ bài viết của bạn"
            default:
                return "đã tương tác"
        }
    }

    const getLink = (notification: Notification) => {
        if (notification.post_id) return `/post-new/${notification.post_id}`
        if (notification.actor?.username) return `/profile-new/${notification.actor.username}`
        return "#"
    }

    const getInitial = (text?: string) => text?.[0]?.toUpperCase() || "U"

    return (
        <Drawer direction="right" open={open} onOpenChange={setOpen}>
            <DrawerTrigger asChild>
                <Button variant="ghost" size="icon" aria-label="Notifications">
                    <NotificationBadge />
                </Button>
            </DrawerTrigger>

            <DrawerContent className="sm:max-w-sm">
                <DrawerHeader className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                        <Bell className="h-5 w-5" />
                        <DrawerTitle>Thông báo</DrawerTitle>
                        {unreadCount > 0 && (
                            <span className="bg-red-500 text-white text-xs font-bold px-2 py-1 rounded-full">
                                {unreadCount}
                            </span>
                        )}
                    </div>
                    <DrawerClose asChild>
                        <Button variant="ghost" size="icon">
                            <X className="h-4 w-4" />
                        </Button>
                    </DrawerClose>
                </DrawerHeader>

                <div className="flex items-center justify-between px-4 pb-2">
                    <span className="text-sm text-muted-foreground">Nhận thông báo khi có tương tác mới</span>
                    {unreadCount > 0 && (
                        <Button variant="ghost" size="sm" className="gap-2" onClick={handleMarkAll}>
                            <Check className="h-4 w-4" />
                            Đánh dấu đã đọc
                        </Button>
                    )}
                </div>

                <div className="px-4 pb-4 max-h-[70vh] overflow-y-auto space-y-2">
                    {loading ? (
                        <div className="flex justify-center py-12">
                            <Loader2 className="h-6 w-6 animate-spin text-muted-foreground" />
                        </div>
                    ) : items.length === 0 ? (
                        <div className="text-center text-sm text-muted-foreground py-10">
                            Chưa có thông báo nào
                        </div>
                    ) : (
                        items.map((notification) => (
                            <Link
                                key={notification.id}
                                href={getLink(notification)}
                                className={`flex items-center gap-3 rounded-lg border px-3 py-2 hover:border-green-200 transition ${notification.is_read ? "bg-white" : "bg-green-50/60 border-green-200"
                                    }`}
                                onClick={async () => {
                                    if (!notification.is_read) {
                                        try {
                                            await notificationsApi.markAsRead(notification.id)
                                            setItems((prev) =>
                                                prev.map((n) => n.id === notification.id ? { ...n, is_read: true } : n)
                                            )
                                            // Refresh global unread count badge
                                            if (typeof window !== "undefined") {
                                                window.dispatchEvent(new Event("notifications:refresh-count"))
                                            }
                                        } catch (error) {
                                            console.error("Failed to mark notification as read", error)
                                        }
                                    }
                                }}
                            >
                                <Avatar className="h-10 w-10">
                                    <AvatarImage src={notification.actor?.avatar_url} />
                                    <AvatarFallback>{getInitial(notification.actor?.username)}</AvatarFallback>
                                </Avatar>
                                <div className="flex-1 min-w-0">
                                    <div className="text-sm">
                                        <span className="font-semibold">
                                            {notification.actor?.full_name || notification.actor?.username || "Người dùng"}
                                        </span>{" "}
                                        <span className="text-muted-foreground">
                                            {getMessage(notification)}
                                        </span>
                                    </div>
                                    <div className="text-xs text-muted-foreground">
                                        {new Date(notification.created_at).toLocaleString("vi-VN", {
                                            day: "numeric",
                                            month: "short",
                                            hour: "2-digit",
                                            minute: "2-digit",
                                        })}
                                    </div>
                                </div>
                                {!notification.is_read && <div className="h-2 w-2 bg-green-500 rounded-full" />}
                            </Link>
                        ))
                    )}
                </div>
            </DrawerContent>
        </Drawer>
    )
}
