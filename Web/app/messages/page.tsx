import { createServerClient } from "@/lib/supabase/server"
import { redirect } from "next/navigation"
import MessagesView from "@/components/messages/messages-view"

export default async function MessagesPage() {
  const supabase = await createServerClient()

  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    redirect("/auth/login")
  }

  return (
    <div className="min-h-screen bg-neutral-50">
      <MessagesView userId={user.id} />
    </div>
  )
}
