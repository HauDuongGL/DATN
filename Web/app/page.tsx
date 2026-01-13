import { Button } from "@/components/ui/button"
import { Flower2, Camera, Users, Sparkles } from "lucide-react"
import Link from "next/link"
import { getCurrentUser } from "@/lib/auth/get-user"
import { redirect } from "next/navigation"

export default async function HomePage() {
  const user = await getCurrentUser()

  if (user) {
    redirect("/feed")
  }

  return (
    <div className="flex min-h-screen flex-col bg-gradient-to-br from-emerald-50 via-teal-50 to-cyan-50">
      {/* Header */}
      <header className="border-b border-emerald-100 bg-white/80 backdrop-blur-sm">
        <div className="container mx-auto flex items-center justify-between px-4 py-4">
          <div className="flex items-center gap-2">
            <Flower2 className="h-8 w-8 text-emerald-600" />
            <span className="text-2xl font-bold text-emerald-900">FlowerShare</span>
          </div>
          <div className="flex items-center gap-3">
            <Button asChild variant="ghost" className="text-emerald-700">
              <Link href="/auth/login">Sign in</Link>
            </Button>
            <Button asChild className="bg-emerald-600 hover:bg-emerald-700">
              <Link href="/auth/sign-up">Get started</Link>
            </Button>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <main className="flex-1">
        <div className="container mx-auto px-4 py-20">
          <div className="mx-auto max-w-4xl text-center">
            <h1 className="mb-6 text-balance text-5xl font-bold leading-tight text-emerald-900 md:text-6xl">
              Discover, Share, and Identify Beautiful Flowers
            </h1>
            <p className="mb-8 text-pretty text-xl text-slate-600">
              Join a vibrant community of flower enthusiasts. Share your botanical discoveries, get AI-powered flower
              identification, and connect with nature lovers worldwide.
            </p>
            <div className="flex flex-col items-center justify-center gap-4 sm:flex-row">
              <Button asChild size="lg" className="bg-emerald-600 hover:bg-emerald-700">
                <Link href="/auth/sign-up">Start sharing flowers</Link>
              </Button>
              <Button
                asChild
                size="lg"
                variant="outline"
                className="border-emerald-600 text-emerald-700 hover:bg-emerald-50 bg-transparent"
              >
                <Link href="/auth/login">Explore feed</Link>
              </Button>
            </div>
          </div>

          {/* Features */}
          <div className="mt-24 grid gap-8 md:grid-cols-3">
            <div className="rounded-2xl bg-white p-8 shadow-lg">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-emerald-100">
                <Camera className="h-6 w-6 text-emerald-600" />
              </div>
              <h3 className="mb-2 text-xl font-semibold text-emerald-900">Share Your Flowers</h3>
              <p className="text-slate-600">
                Capture and share stunning flower photos with our community. Tell your botanical stories.
              </p>
            </div>

            <div className="rounded-2xl bg-white p-8 shadow-lg">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-teal-100">
                <Sparkles className="h-6 w-6 text-teal-600" />
              </div>
              <h3 className="mb-2 text-xl font-semibold text-emerald-900">AI Identification</h3>
              <p className="text-slate-600">
                Get instant flower species identification powered by advanced AI technology.
              </p>
            </div>

            <div className="rounded-2xl bg-white p-8 shadow-lg">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-xl bg-cyan-100">
                <Users className="h-6 w-6 text-cyan-600" />
              </div>
              <h3 className="mb-2 text-xl font-semibold text-emerald-900">Connect & Learn</h3>
              <p className="text-slate-600">
                Follow fellow enthusiasts, share knowledge, and grow your botanical expertise together.
              </p>
            </div>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="border-t border-emerald-100 bg-white/80 py-8">
        <div className="container mx-auto px-4 text-center text-sm text-slate-600">
          <p>&copy; 2025 FlowerShare. Built with love for nature.</p>
        </div>
      </footer>
    </div>
  )
}
