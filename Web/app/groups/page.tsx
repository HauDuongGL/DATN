import { createServerClient } from "@/lib/supabase/server"
import { redirect } from "next/navigation"
import GroupsList from "@/components/groups/groups-list"
import GroupsHeader from "@/components/groups/groups-header"

export default async function GroupsPage() {
  const supabase = await createServerClient()

  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    redirect("/auth/login")
  }

  return (
    <div className="min-h-screen bg-neutral-50">
      <GroupsHeader />
      <div className="container max-w-6xl mx-auto px-4 py-8">
        <GroupsList userId={user.id} />
      </div>
    </div>
  )
}
