import { createServerClient } from "@/lib/supabase/server"
import { redirect, notFound } from "next/navigation"
import GroupDetail from "@/components/groups/group-detail"

export default async function GroupDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const supabase = await createServerClient()

  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    redirect("/auth/login")
  }

  // Fetch group details
  const { data: group, error } = await supabase.from("groups").select("*").eq("id", id).single()

  if (error || !group) {
    notFound()
  }

  // Check if user is a member
  const { data: membership } = await supabase
    .from("group_members")
    .select("role")
    .eq("group_id", id)
    .eq("user_id", user.id)
    .single()

  if (group.is_private && !membership) {
    return (
      <div className="min-h-screen bg-neutral-50 flex items-center justify-center">
        <div className="text-center">
          <h1 className="text-2xl font-bold mb-4">Private Group</h1>
          <p className="text-neutral-600">You need to be a member to view this group.</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-neutral-50">
      <GroupDetail groupId={id} userId={user.id} userRole={membership?.role} />
    </div>
  )
}
