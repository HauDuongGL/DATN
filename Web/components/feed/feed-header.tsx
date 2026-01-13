import { Flower2, Home, Users, MessageSquare } from "lucide-react"
import Link from "next/link"
import { UserMenu } from "@/components/auth/user-menu"
import { Button } from "@/components/ui/button"

interface FeedHeaderProps {
  user: {
    id: string
    email: string
    username?: string
    full_name?: string
    avatar_url?: string | null
  }
}

export function FeedHeader({ user }: FeedHeaderProps) {
  return (
    <header className="sticky top-0 z-50 border-b border-emerald-100 bg-white/95 backdrop-blur supports-[backdrop-filter]:bg-white/80">
      <div className="container mx-auto flex items-center justify-between px-4 py-3">
        <Link href="/feed" className="flex items-center gap-2">
          <Flower2 className="h-8 w-8 text-emerald-600" />
          <span className="text-xl font-bold text-emerald-900">FlowerShare</span>
        </Link>

        <nav className="flex items-center gap-2">
          <Button
            asChild
            variant="ghost"
            size="sm"
            className="text-neutral-700 hover:text-emerald-700 hover:bg-emerald-50"
          >
            <Link href="/feed">
              <Home className="w-4 h-4 mr-2" />
              Feed
            </Link>
          </Button>
          <Button
            asChild
            variant="ghost"
            size="sm"
            className="text-neutral-700 hover:text-emerald-700 hover:bg-emerald-50"
          >
            <Link href="/groups">
              <Users className="w-4 h-4 mr-2" />
              Groups
            </Link>
          </Button>
          <Button
            asChild
            variant="ghost"
            size="sm"
            className="text-neutral-700 hover:text-emerald-700 hover:bg-emerald-50"
          >
            <Link href="/messages">
              <MessageSquare className="w-4 h-4 mr-2" />
              Messages
            </Link>
          </Button>
        </nav>

        <UserMenu user={user} />
      </div>
    </header>
  )
}
