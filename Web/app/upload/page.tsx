import { getCurrentUser } from "@/lib/auth/get-user"
import { redirect } from "next/navigation"
import { UploadForm } from "@/components/upload/upload-form"
import { ArrowLeft, Flower2 } from "lucide-react"
import Link from "next/link"

export default async function UploadPage({
  searchParams,
}: {
  searchParams: Promise<{ 
    groupId?: string
    flowerName?: string
    flowerSpecies?: string
    description?: string
    care?: string
    caption?: string
    imageUrl?: string
  }>
}) {
  const user = await getCurrentUser()
  const params = await searchParams
  const { groupId } = params

  if (!user) {
    redirect("/auth/login")
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-teal-50 to-cyan-50">
      <header className="border-b border-emerald-100 bg-white/95 backdrop-blur">
        <div className="container mx-auto flex items-center gap-4 px-4 py-3">
          <Link href={groupId ? `/groups/${groupId}` : "/feed"}>
            <ArrowLeft className="h-6 w-6 text-slate-600 hover:text-emerald-600" />
          </Link>
          <div className="flex items-center gap-2">
            <Flower2 className="h-6 w-6 text-emerald-600" />
            <span className="text-lg font-semibold text-emerald-900">Share a Flower</span>
          </div>
        </div>
      </header>

      <main className="container mx-auto max-w-2xl px-4 py-8">
        <UploadForm userId={user.id} groupId={groupId} />
      </main>
    </div>
  )
}
