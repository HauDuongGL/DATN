"use client"

import { useEffect, useState } from "react"
import { createBrowserClient } from "@/lib/supabase/client"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { MoreHorizontal, Trash2, Shield, User } from "lucide-react"
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { formatDistanceToNow } from "date-fns"

interface GroupMembersTabProps {
    groupId: string
    isAdmin: boolean
    currentUserId: string
}

export function GroupMembersTab({ groupId, isAdmin, currentUserId }: GroupMembersTabProps) {
    const supabase = createBrowserClient()
    const [members, setMembers] = useState<any[]>([])
    const [loading, setLoading] = useState(true)

    useEffect(() => {
        fetchMembers()
    }, [])

    const fetchMembers = async () => {
        try {
            const { data, error } = await supabase
                .from("group_members")
                .select(`
          *,
          profile:profiles!user_id (*)
        `)
                .eq("group_id", groupId)
                .order("role", { ascending: true }) // admin first (alphabetically 'admin' < 'member')

            if (error) throw error
            setMembers(data || [])
        } catch (error) {
            console.error("Error fetching members:", error)
        } finally {
            setLoading(false)
        }
    }

    const handleRemoveMember = async (userId: string) => {
        if (!confirm("Are you sure you want to remove this member?")) return
        try {
            const { error } = await supabase
                .from("group_members")
                .delete()
                .eq("group_id", groupId)
                .eq("user_id", userId)

            if (error) throw error
            setMembers((prev) => prev.filter((m) => m.user_id !== userId))
        } catch (error) {
            console.error("Error removing member:", error)
        }
    }

    if (loading) {
        return <div className="text-center py-8">Loading members...</div>
    }

    return (
        <div className="space-y-4">
            {members.map((member) => (
                <Card key={member.user_id} className="p-4 flex items-center justify-between">
                    <div className="flex items-center gap-3">
                        <Avatar>
                            <AvatarImage src={member.profile?.avatar_url} />
                            <AvatarFallback>{member.profile?.display_name?.[0] || "?"}</AvatarFallback>
                        </Avatar>
                        <div>
                            <div className="font-semibold flex items-center gap-2">
                                {member.profile?.display_name || "Unknown User"}
                                {member.role === "admin" && (
                                    <span className="text-xs bg-emerald-100 text-emerald-700 px-2 py-0.5 rounded-full flex items-center gap-1">
                                        <Shield className="w-3 h-3" /> Admin
                                    </span>
                                )}
                            </div>
                            <p className="text-xs text-slate-500">
                                Joined {formatDistanceToNow(new Date(member.joined_at), { addSuffix: true })}
                            </p>
                        </div>
                    </div>

                    {isAdmin && member.user_id !== currentUserId && member.role !== 'admin' && (
                        <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                                <Button variant="ghost" size="icon">
                                    <MoreHorizontal className="w-4 h-4" />
                                </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end">
                                <DropdownMenuItem onClick={() => handleRemoveMember(member.user_id)} className="text-red-600">
                                    <Trash2 className="w-4 h-4 mr-2" />
                                    Remove from Group
                                </DropdownMenuItem>
                            </DropdownMenuContent>
                        </DropdownMenu>
                    )}
                </Card>
            ))}

            {members.length === 0 && (
                <div className="text-center py-12 text-neutral-500">No members found.</div>
            )}
        </div>
    )
}
