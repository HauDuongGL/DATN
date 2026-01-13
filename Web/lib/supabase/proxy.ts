import { createServerClient } from "@supabase/ssr"
import { NextResponse, type NextRequest } from "next/server"

export async function updateSession(request: NextRequest) {
  let supabaseResponse = NextResponse.next({
    request,
  })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value))
          supabaseResponse = NextResponse.next({
            request,
          })
          cookiesToSet.forEach(({ name, value, options }) => supabaseResponse.cookies.set(name, value, options))
        },
      },
    },
  )

  const {
    data: { user },
  } = await supabase.auth.getUser()

  // Users can manually navigate to /onboarding if needed
  // Once database is set up, uncomment the code below:

  /*
  if (user && !request.nextUrl.pathname.startsWith("/onboarding") && !request.nextUrl.pathname.startsWith("/auth")) {
    try {
      const { data: profile, error } = await supabase
        .from("profiles")
        .select("onboarding_completed")
        .eq("id", user.id)
        .single()

      if (!error && profile && profile.onboarding_completed === false) {
        const url = request.nextUrl.clone()
        url.pathname = "/onboarding"
        return NextResponse.redirect(url)
      }
    } catch (error) {
    }
  }
  */

  // Protect /feed, /profile, /upload, /settings, /groups, /messages routes
  if (
    (request.nextUrl.pathname.startsWith("/feed") ||
      request.nextUrl.pathname.startsWith("/profile") ||
      request.nextUrl.pathname.startsWith("/upload") ||
      request.nextUrl.pathname.startsWith("/settings") ||
      request.nextUrl.pathname.startsWith("/groups") ||
      request.nextUrl.pathname.startsWith("/messages")) &&
    !user
  ) {
    const url = request.nextUrl.clone()
    url.pathname = "/auth/login"
    return NextResponse.redirect(url)
  }

  // Redirect authenticated users away from auth pages
  if (
    (request.nextUrl.pathname.startsWith("/auth/login") || request.nextUrl.pathname.startsWith("/auth/sign-up")) &&
    user
  ) {
    const url = request.nextUrl.clone()
    url.pathname = "/feed"
    return NextResponse.redirect(url)
  }

  // Protect /admin routes (but allow /admin-debug for diagnostics)
  if (
    request.nextUrl.pathname.startsWith("/admin") &&
    !request.nextUrl.pathname.startsWith("/admin-debug") &&
    user
  ) {
    // Sequential check for maximum resilience
    const { data: adminById } = await supabase.from("admin_users").select("role").eq("id", user.id).maybeSingle()

    let isAdmin = !!adminById

    if (!isAdmin) {
      const { data: adminByUserId } = await supabase.from("admin_users").select("role").eq("user_id", user.id).maybeSingle()
      isAdmin = !!adminByUserId
    }

    if (!isAdmin) {
      const url = request.nextUrl.clone()
      url.pathname = "/feed"
      return NextResponse.redirect(url)
    }
  }

  return supabaseResponse
}
