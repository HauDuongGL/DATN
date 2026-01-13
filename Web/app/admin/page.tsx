import { createClient } from "@/lib/supabase/server"
import { getCurrentUser, getIsAdmin } from "@/lib/auth/get-user"
import { redirect } from "next/navigation"
import { AdminHeader } from "@/components/admin/admin-header"
import { AdminStats } from "@/components/admin/admin-stats"
import { AdminTabs } from "@/components/admin/admin-tabs"

export default async function AdminPage() {
  const user = await getCurrentUser()
  const isAdmin = await getIsAdmin()

  if (!user || !isAdmin) {
    redirect("/feed")
  }

  const supabase = await createClient()

  // Get stats
  const { count: totalUsers } = await supabase.from("profiles").select("*", { count: "exact", head: true })

  const { count: totalPosts } = await supabase.from("posts").select("*", { count: "exact", head: true })

  const { count: pendingReports } = await supabase
    .from("reports")
    .select("*", { count: "exact", head: true })
    .eq("status", "pending")

  // Get all posts for management
  const { data: posts } = await supabase
    .from("posts")
    .select(
      `
      *,
      author:profiles!author_id(*),
      post_media!post_id(*)
    `,
    )
    .order("created_at", { ascending: false })
    .limit(50)

  // Get reports
  const { data: reports } = await supabase
    .from("reports")
    .select(
      `
      *,
      reporter:profiles!reporter_id(username, full_name),
      post:posts!reported_post_id(id, caption),
      reported_user:profiles!reported_user_id(username, full_name)
    `,
    )
    .eq("status", "pending")
    .order("created_at", { ascending: false })

  return (
    <div className="min-h-screen bg-slate-50">
      <AdminHeader user={user} />

      <main className="container mx-auto max-w-7xl px-4 py-6">
        <h1 className="mb-6 text-3xl font-bold text-slate-900">Admin Dashboard</h1>

        <AdminStats
          totalUsers={totalUsers || 0}
          totalPosts={totalPosts || 0}
          pendingReports={pendingReports || 0}
        />

        <AdminTabs posts={posts || []} reports={reports || []} adminId={user.id} />
      </main>
    </div>
  )
}
