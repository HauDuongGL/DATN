import { createServerClient } from "@/lib/supabase/server"
import { redirect } from "next/navigation"
import CreateGroupForm from "@/components/groups/create-group-form"

export default async function CreateGroupPage() {
  const supabase = await createServerClient()

  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    redirect("/auth/login")
  }

  return (
    <div className="min-h-screen bg-neutral-50 py-8">
      <div className="container max-w-2xl mx-auto px-4">
        <CreateGroupForm userId={user.id} />
      </div>
    </div>
  )
}
