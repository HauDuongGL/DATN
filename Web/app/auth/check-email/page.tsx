import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import Link from "next/link"
import { Mail, Flower2 } from "lucide-react"

export default function CheckEmailPage() {
  return (
    <div className="flex min-h-screen w-full items-center justify-center bg-gradient-to-br from-emerald-50 via-teal-50 to-cyan-50 p-6">
      <div className="w-full max-w-md">
        <div className="mb-8 flex flex-col items-center gap-2">
          <div className="flex items-center gap-2">
            <Flower2 className="h-10 w-10 text-emerald-600" />
            <h1 className="text-3xl font-bold text-emerald-900">FlowerShare</h1>
          </div>
        </div>

        <Card className="border-emerald-100 shadow-xl">
          <CardHeader className="text-center">
            <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-emerald-100">
              <Mail className="h-8 w-8 text-emerald-600" />
            </div>
            <CardTitle className="text-2xl text-emerald-900">Check your email</CardTitle>
            <CardDescription className="text-base">
              We&apos;ve sent you a confirmation link. Please check your email and click the link to activate your
              account.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="rounded-lg bg-emerald-50 p-4 text-sm text-emerald-800">
              <p className="font-medium">What&apos;s next?</p>
              <ul className="mt-2 list-inside list-disc space-y-1">
                <li>Check your inbox for the confirmation email</li>
                <li>Click the confirmation link in the email</li>
                <li>You&apos;ll be redirected to your feed</li>
              </ul>
            </div>
            <Button asChild className="w-full bg-emerald-600 hover:bg-emerald-700">
              <Link href="/auth/login">Back to login</Link>
            </Button>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
