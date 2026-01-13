import { redirect } from "next/navigation"
import { createServerClient } from "@/lib/supabase/server"
import OnboardingFlow from "@/components/onboarding/onboarding-flow"

export default async function OnboardingPage() {
  const supabase = await createServerClient()

  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    redirect("/auth/login")
  }

  // Check if already completed onboarding
  const { data: profile } = await supabase.from("profiles").select("onboarding_completed").eq("id", user.id).single()

  if (profile?.onboarding_completed) {
    redirect("/feed")
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-teal-50 to-cyan-50">
      <OnboardingFlow userId={user.id} />
    </div>
  )
}
