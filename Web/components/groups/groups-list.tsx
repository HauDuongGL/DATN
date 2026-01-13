"use client"

import { useEffect, useState } from "react"
import { createBrowserClient } from "@/lib/supabase/client"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Users, Lock, Globe, TrendingUp } from "lucide-react"
import Link from "next/link"

interface Group {
  id: string
  name: string
  description: string
  cover_image_url: string | null
  is_private: boolean
  member_count: number
  post_count: number
  created_at: string
  is_member: boolean
}

interface GroupsListProps {
  userId: string
}

export default function GroupsList({ userId }: GroupsListProps) {
  const supabase = createBrowserClient()
  const [allGroups, setAllGroups] = useState<Group[]>([])
  const [myGroups, setMyGroups] = useState<Group[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchGroups()
  }, [])

  const fetchGroups = async () => {
    try {
      // Fetch all public groups
      const { data: groups, error: groupsError } = await supabase
        .from("groups")
        .select("*")
        .order("member_count", { ascending: false })

      if (groupsError) throw groupsError

      // Fetch user's group memberships
      const { data: memberships, error: membershipsError } = await supabase
        .from("group_members")
        .select("group_id")
        .eq("user_id", userId)

      if (membershipsError) throw membershipsError

      const memberGroupIds = new Set(memberships.map((m) => m.group_id))

      const groupsWithMembership = (groups || []).map((group) => ({
        ...group,
        is_member: memberGroupIds.has(group.id),
      }))

      setAllGroups(groupsWithMembership)
      setMyGroups(groupsWithMembership.filter((g) => g.is_member))
    } catch (error: any) {
      console.error("Error fetching groups:", error?.message || error)
    } finally {
      setLoading(false)
    }
  }

  const handleJoinGroup = async (groupId: string, isPrivate: boolean) => {
    try {
      if (isPrivate) {
        // Create join request for private groups
        const { error } = await supabase.from("group_join_requests").insert({
          group_id: groupId,
          user_id: userId,
        })

        if (error) throw error
        alert("Join request sent! The group admin will review your request.")
      } else {
        // Directly join public groups
        const { error } = await supabase.from("group_members").insert({
          group_id: groupId,
          user_id: userId,
        })

        if (error) throw error
        fetchGroups()
      }
    } catch (error: any) {
      console.error("Error joining group:", error?.message || error)
      alert("Failed to join group. Please try again.")
    }
  }

  const handleLeaveGroup = async (groupId: string) => {
    if (!confirm("Are you sure you want to leave this group?")) return

    try {
      const { error } = await supabase.from("group_members").delete().eq("group_id", groupId).eq("user_id", userId)

      if (error) throw error
      fetchGroups()
    } catch (error: any) {
      console.error("Error leaving group:", error?.message || error)
      alert("Failed to leave group. Please try again.")
    }
  }

  const GroupCard = ({ group }: { group: Group }) => (
    <Card className="hover:shadow-md transition-shadow">
      <CardHeader>
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <div className="flex items-center gap-2 mb-2">
              <CardTitle className="text-lg">{group.name}</CardTitle>
              {group.is_private ? (
                <Lock className="w-4 h-4 text-neutral-500" />
              ) : (
                <Globe className="w-4 h-4 text-neutral-500" />
              )}
            </div>
            <CardDescription className="line-clamp-2">{group.description}</CardDescription>
          </div>
        </div>
      </CardHeader>
      <CardContent>
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-4 text-sm text-neutral-600">
            <div className="flex items-center gap-1">
              <Users className="w-4 h-4" />
              <span>{group.member_count} members</span>
            </div>
            <div className="flex items-center gap-1">
              <TrendingUp className="w-4 h-4" />
              <span>{group.post_count} posts</span>
            </div>
          </div>
        </div>
        <div className="flex gap-2">
          {group.is_member ? (
            <>
              <Link href={`/groups/${group.id}`} className="flex-1">
                <Button variant="outline" className="w-full bg-transparent">
                  View Group
                </Button>
              </Link>
              <Button variant="ghost" onClick={() => handleLeaveGroup(group.id)}>
                Leave
              </Button>
            </>
          ) : (
            <Button
              onClick={() => handleJoinGroup(group.id, group.is_private)}
              className="w-full bg-emerald-600 hover:bg-emerald-700"
            >
              {group.is_private ? "Request to Join" : "Join Group"}
            </Button>
          )}
        </div>
      </CardContent>
    </Card>
  )

  if (loading) {
    return <div className="text-center py-12">Loading groups...</div>
  }

  return (
    <Tabs defaultValue="all" className="w-full">
      <TabsList className="mb-6">
        <TabsTrigger value="all">All Groups ({allGroups.length})</TabsTrigger>
        <TabsTrigger value="my">My Groups ({myGroups.length})</TabsTrigger>
      </TabsList>

      <TabsContent value="all">
        {allGroups.length === 0 ? (
          <Card>
            <CardContent className="text-center py-12">
              <Users className="w-12 h-12 text-neutral-400 mx-auto mb-4" />
              <p className="text-neutral-600">No groups found. Be the first to create one!</p>
            </CardContent>
          </Card>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {allGroups.map((group) => (
              <GroupCard key={group.id} group={group} />
            ))}
          </div>
        )}
      </TabsContent>

      <TabsContent value="my">
        {myGroups.length === 0 ? (
          <Card>
            <CardContent className="text-center py-12">
              <Users className="w-12 h-12 text-neutral-400 mx-auto mb-4" />
              <p className="text-neutral-600">You haven't joined any groups yet.</p>
              <Link href="/groups">
                <Button className="mt-4 bg-emerald-600 hover:bg-emerald-700">Explore Groups</Button>
              </Link>
            </CardContent>
          </Card>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {myGroups.map((group) => (
              <GroupCard key={group.id} group={group} />
            ))}
          </div>
        )}
      </TabsContent>
    </Tabs>
  )
}
