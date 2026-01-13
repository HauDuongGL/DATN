import { Shield, Flower2 } from "lucide-react"
import Link from "next/link"
import { UserMenu } from "@/components/auth/user-menu"

interface AdminHeaderProps {
  user: {
    id: string
    email: string
    username: string
    full_name?: string | null
    avatar_url?: string | null
  }
}

export function AdminHeader({ user }: AdminHeaderProps) {
  return (
    <header className="sticky top-0 z-50 border-b border-red-200 bg-red-50/95 backdrop-blur supports-[backdrop-filter]:bg-red-50/80">
      <div className="container mx-auto flex items-center justify-between px-4 py-3">
        <div className="flex items-center gap-6">
          <Link href="/feed" className="flex items-center gap-2">
            <Flower2 className="h-6 w-6 text-emerald-600" />
            <span className="text-lg font-bold text-emerald-900">FlowerShare</span>
          </Link>
          <div className="flex items-center gap-2 rounded-lg bg-red-100 px-3 py-1">
            <Shield className="h-4 w-4 text-red-600" />
            <span className="text-sm font-semibold text-red-700">Admin Panel</span>
          </div>
        </div>

        <UserMenu user={user} isAdmin />
      </div>
    </header>
  )
}
