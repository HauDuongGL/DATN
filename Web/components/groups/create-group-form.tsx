"use client"

import type React from "react"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { createBrowserClient } from "@/lib/supabase/client"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Switch } from "@/components/ui/switch"
import { ArrowLeft, Users } from "lucide-react"
import Link from "next/link"

interface CreateGroupFormProps {
  userId: string
}

export default function CreateGroupForm({ userId }: CreateGroupFormProps) {
  const router = useRouter()
  const supabase = createBrowserClient()
  const [loading, setLoading] = useState(false)
  const [formData, setFormData] = useState({
    name: "",
    description: "",
    isPrivate: false,
  })

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)

    try {
      const { data, error } = await supabase
        .from("groups")
        .insert({
          name: formData.name,
          description: formData.description,
          is_private: formData.isPrivate,
          created_by: userId,
        })
        .select()
        .single()

      if (error) throw error

      router.push(`/groups/${data.id}`)
      router.refresh()
    } catch (error) {
      console.error("Error creating group:", error)
      alert("Failed to create group. Please try again.")
    } finally {
      setLoading(false)
    }
  }

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center gap-3 mb-2">
          <Link href="/groups">
            <Button variant="ghost" size="icon">
              <ArrowLeft className="w-4 h-4" />
            </Button>
          </Link>
          <div className="w-10 h-10 bg-emerald-100 rounded-full flex items-center justify-center">
            <Users className="w-5 h-5 text-emerald-600" />
          </div>
        </div>
        <CardTitle>Create a New Group</CardTitle>
        <CardDescription>Build a community around your favorite flowers</CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="space-y-2">
            <Label htmlFor="name">Group Name</Label>
            <Input
              id="name"
              placeholder="e.g., Rose Enthusiasts"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              required
              className="border-emerald-200 focus-visible:ring-emerald-500"
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="description">Description</Label>
            <Textarea
              id="description"
              placeholder="Tell people what this group is about..."
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              rows={4}
              className="border-emerald-200 focus-visible:ring-emerald-500 resize-none"
            />
          </div>

          <div className="flex items-center justify-between p-4 border border-emerald-200 rounded-lg">
            <div className="space-y-0.5">
              <Label htmlFor="private">Private Group</Label>
              <p className="text-sm text-neutral-600">Require approval to join this group</p>
            </div>
            <Switch
              id="private"
              checked={formData.isPrivate}
              onCheckedChange={(checked) => setFormData({ ...formData, isPrivate: checked })}
            />
          </div>

          <div className="flex gap-3">
            <Link href="/groups" className="flex-1">
              <Button type="button" variant="outline" className="w-full bg-transparent">
                Cancel
              </Button>
            </Link>
            <Button
              type="submit"
              disabled={loading || !formData.name}
              className="flex-1 bg-emerald-600 hover:bg-emerald-700"
            >
              {loading ? "Creating..." : "Create Group"}
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  )
}
