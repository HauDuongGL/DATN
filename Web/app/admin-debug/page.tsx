import { createClient } from "@/lib/supabase/server"
import { getCurrentUser, getIsAdmin } from "@/lib/auth/get-user"

export default async function AdminDebugPage() {
    const supabase = await createClient()

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    const profile = await getCurrentUser()

    // Test admin_users query directly
    const { data: adminById, error: errorId } = await supabase
        .from("admin_users")
        .select("*")
        .eq("id", user?.id || "")
        .maybeSingle()

    const { data: adminByUserId, error: errorUserId } = await supabase
        .from("admin_users")
        .select("*")
        .eq("user_id", user?.id || "")
        .maybeSingle()

    // Test THE EXACT QUERY from the admin page
    const { data: posts, error: postsError } = await supabase
        .from("posts")
        .select(`
      *,
      author:profiles!author_id(*),
      post_media!post_id(*)
    `)
        .order("created_at", { ascending: false })
        .limit(50)

    // Test THE EXACT REPORTS QUERY
    const { data: reports, error: reportsError } = await supabase
        .from("reports")
        .select(`
      *,
      reporter:profiles!reporter_id(username, full_name),
      post:posts!reported_post_id(id, caption),
      reported_user:profiles!reported_user_id(username, full_name)
    `)
        .eq("status", "pending")
        .order("created_at", { ascending: false })

    const isAdmin = await getIsAdmin()

    return (
        <div className="p-8 font-mono text-sm space-y-6">
            <h1 className="text-2xl font-bold">Admin Debug Info</h1>

            <section>
                <h2 className="font-bold border-b mb-2">Supabase Auth User</h2>
                <pre className="bg-slate-100 p-4 rounded">{JSON.stringify({ user, authError }, null, 2)}</pre>
            </section>

            <section>
                <h2 className="font-bold border-b mb-2">Posts Query Result ({posts?.length || 0} items)</h2>
                <pre className="bg-slate-100 p-4 rounded text-red-600 font-bold">{JSON.stringify(postsError, null, 2)}</pre>
                <p className="text-xs text-slate-500 mt-1">Data Sample: {JSON.stringify(posts?.[0], null, 2)}</p>
            </section>

            <section>
                <h2 className="font-bold border-b mb-2">Reports Query Result ({reports?.length || 0} items)</h2>
                <pre className="bg-slate-100 p-4 rounded text-red-600 font-bold">{JSON.stringify(reportsError, null, 2)}</pre>
            </section>

            <section>
                <h2 className="font-bold border-b mb-2">Table: admin_users (check by "id")</h2>
                <pre className="bg-slate-100 p-4 rounded">{JSON.stringify({ data: adminById, error: errorId }, null, 2)}</pre>
            </section>

            <section>
                <h2 className="font-bold border-b mb-2">getIsAdmin() Result</h2>
                <div className="text-xl font-bold bg-yellow-100 p-4">
                    Result: {isAdmin ? "TRUE ✅" : "FALSE ❌"}
                </div>
            </section>

            <div className="mt-8">
                <a href="/admin" className="text-blue-600 underline">Refresh and try Admin Dashboard again</a>
            </div>
        </div>
    )
}
