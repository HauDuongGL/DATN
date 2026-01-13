"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import { User, Bell, Shield, Palette, HelpCircle, ArrowLeft } from "lucide-react"
import { Button } from "@/components/ui/button"
import { cn } from "@/lib/utils"

const sidebarItems = [
    {
        title: "Profile",
        href: "/settings/profile",
        icon: User,
    },
    {
        title: "Notifications",
        href: "/settings/notifications",
        icon: Bell,
    },
    {
        title: "Security",
        href: "/settings/security",
        icon: Shield,
    },
    {
        title: "Appearance",
        href: "/settings/appearance",
        icon: Palette,
    },
    {
        title: "Help & Support",
        href: "/settings/help",
        icon: HelpCircle,
    },
]

export default function SettingsLayout({
    children,
}: {
    children: React.ReactNode
}) {
    const pathname = usePathname()

    return (
        <div className="min-h-screen bg-slate-50">
            <header className="sticky top-0 z-40 bg-white border-b">
                <div className="container mx-auto max-w-6xl px-4 py-4 flex items-center gap-4">
                    <Link href="/feed">
                        <Button variant="ghost" size="icon">
                            <ArrowLeft className="h-5 w-5" />
                        </Button>
                    </Link>
                    <h1 className="text-xl font-bold">Settings</h1>
                </div>
            </header>

            <main className="container mx-auto max-w-6xl px-4 py-8">
                <div className="flex flex-col md:flex-row gap-8">
                    <aside className="w-full md:w-64 space-y-1">
                        {sidebarItems.map((item) => (
                            <Link key={item.href} href={item.href}>
                                <span
                                    className={cn(
                                        "flex items-center gap-3 px-4 py-3 rounded-lg text-sm font-medium transition-colors",
                                        pathname === item.href
                                            ? "bg-green-100 text-green-700 shadow-sm"
                                            : "text-slate-600 hover:bg-slate-200"
                                    )}
                                >
                                    <item.icon className="h-5 w-5" />
                                    {item.title}
                                </span>
                            </Link>
                        ))}
                    </aside>

                    <div className="flex-1 max-w-3xl">
                        {children}
                    </div>
                </div>
            </main>
        </div>
    )
}
