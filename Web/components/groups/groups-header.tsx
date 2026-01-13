import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Plus, Users } from "lucide-react"

export default function GroupsHeader() {
  return (
    <div className="bg-white border-b">
      <div className="container max-w-6xl mx-auto px-4 py-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-emerald-100 rounded-full flex items-center justify-center">
              <Users className="w-5 h-5 text-emerald-600" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-neutral-900">Groups</h1>
              <p className="text-sm text-neutral-600">Join communities and share your passion</p>
            </div>
          </div>
          <Link href="/groups/create">
            <Button className="bg-emerald-600 hover:bg-emerald-700">
              <Plus className="w-4 h-4 mr-2" />
              Create Group
            </Button>
          </Link>
        </div>
      </div>
    </div>
  )
}
