import { createClient } from "@/lib/supabase/server"
import { cache } from "react"

export const getCurrentUser = cache(async () => {
  const supabase = await createClient()

  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) return null

  const { data: profile } = await supabase.from("profiles").select("*").eq("id", user.id).single()

  return profile
})

export const getIsAdmin = cache(async () => {
  const supabase = await createClient()

  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) return false

  // Check with id first (Standard schema)
  const { data: adminById } = await supabase
    .from("admin_users")
    .select("role")
    .eq("id", user.id)
    .maybeSingle()

  if (adminById) {
    return adminById.role === 'admin' || adminById.role === 'super_admin'
  }

  // Fallback to user_id (Alternative schema)
  const { data: adminByUserId } = await supabase
    .from("admin_users")
    .select("role")
    .eq("user_id", user.id)
    .maybeSingle()

  return !!adminByUserId && (adminByUserId.role === 'admin' || adminByUserId.role === 'super_admin')
})
