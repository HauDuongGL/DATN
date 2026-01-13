"use client"

import { useState, useEffect } from "react"
import { notifications as notificationsApi } from "@/lib/supabase/api"
import { Bell } from "lucide-react"

export function NotificationBadge() {
    const [unreadCount, setUnreadCount] = useState(0)

    useEffect(() => {
        // Initial fetch
        loadUnreadCount()

        // Subscribe to real-time changes
        const subscription = notificationsApi.subscribeToNotifications(() => {
            loadUnreadCount()
        })

        // Listen for manual refresh events (e.g., mark all as read)
        const handler = () => loadUnreadCount()
        window.addEventListener("notifications:refresh-count", handler)

        return () => {
            subscription.unsubscribe()
            window.removeEventListener("notifications:refresh-count", handler)
        }
    }, [])

    const loadUnreadCount = async () => {
        try {
            const count = await notificationsApi.getUnreadCount()
            setUnreadCount(count)
        } catch (error) {
            console.error("Error loading unread count:", error)
        }
    }

    return (
        <div className="relative">
            <Bell className="h-5 w-5" />
            {unreadCount > 0 && (
                <span className="absolute -top-1 -right-1 flex h-4 w-4 items-center justify-center rounded-full bg-red-500 text-[10px] font-bold text-white shadow-sm ring-2 ring-white animate-in zoom-in duration-300">
                    {unreadCount > 9 ? "9+" : unreadCount}
                </span>
            )}
        </div>
    )
}
