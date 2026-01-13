"use client"

import { Button } from "@/components/ui/button"
import { Plus } from "lucide-react"
import { useRouter } from "next/navigation"

export function CreatePostButton() {
  const router = useRouter()

  return (
    <Button
      onClick={() => router.push("/upload")}
      size="lg"
      className="fixed bottom-6 right-6 h-14 w-14 rounded-full bg-emerald-600 shadow-lg hover:bg-emerald-700"
    >
      <Plus className="h-6 w-6" />
    </Button>
  )
}
