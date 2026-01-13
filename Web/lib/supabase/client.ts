import { createBrowserClient as createSupabaseBrowserClient } from "@supabase/ssr"

export function createBrowserClient() {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
  const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

  if (!supabaseUrl || !supabaseAnonKey) {
    throw new Error(
      "Missing Supabase environment variables. Make sure NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY are set.",
    )
  }

  return createSupabaseBrowserClient(supabaseUrl, supabaseAnonKey, {
    cookies: {
      get(name: string) {
        if (typeof document === "undefined") return undefined
        const cookies = document.cookie.split("; ")
        const cookie = cookies.find((c) => c.startsWith(`${name}=`))
        return cookie?.split("=")[1]
      },
      set(name: string, value: string, options: any) {
        if (typeof document === "undefined") return
        let cookie = `${name}=${value}`
        if (options?.maxAge) cookie += `; max-age=${options.maxAge}`
        const path = options?.path || "/"
        cookie += `; path=${path}`
        // Ensure cookies work over HTTPS tunnels
        cookie += "; SameSite=Lax; Secure"
        document.cookie = cookie
      },
      remove(name: string, options: any) {
        if (typeof document === "undefined") return
        document.cookie = `${name}=; max-age=0; path=${options?.path || "/"}; SameSite=Lax; Secure`
      },
    },
  })
}

export const createClient = createBrowserClient
