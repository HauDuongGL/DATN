"use client"

import { useState, useEffect } from "react"
import { useRouter } from "next/navigation"
import { users as usersApi, auth } from "@/lib/supabase/api"
import type { UserProfile } from "@/lib/supabase/api"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Loader2, User } from "lucide-react"
import { toast } from "sonner"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"

export function ProfileForm() {
    const router = useRouter()
    const [profile, setProfile] = useState<UserProfile | null>(null)
    const [loading, setLoading] = useState(true)
    const [isSubmitting, setIsSubmitting] = useState(false)

    const [formData, setFormData] = useState({
        fullName: "",
        username: "",
        bio: "",
    })

    useEffect(() => {
        loadProfile()
    }, [])

    const loadProfile = async () => {
        try {
            const user = await auth.getCurrentUser()
            if (!user) {
                router.push("/login")
                return
            }

            const data = await usersApi.getProfile(user.id)
            setProfile(data)
            setFormData({
                fullName: data.full_name || "",
                username: data.username || "",
                bio: data.bio || "",
            })
        } catch (error) {
            console.error("Error loading profile:", error)
            toast.error("Failed to load profile settings")
        } finally {
            setLoading(false)
        }
    }

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault()
        setIsSubmitting(true)

        try {
            await usersApi.updateProfile({
                fullName: formData.fullName,
                username: formData.username,
                bio: formData.bio,
            })
            toast.success("Profile updated successfully")
            router.refresh()
        } catch (error) {
            console.error("Error updating profile:", error)
            toast.error("Failed to update profile")
        } finally {
            setIsSubmitting(false)
        }
    }

    if (loading) {
        return (
            <div className="flex justify-center py-12">
                <Loader2 className="h-8 w-8 animate-spin text-green-500" />
            </div>
        )
    }

    return (
        <form onSubmit={handleSubmit} className="space-y-6">
            <Card className="border-green-100">
                <CardHeader>
                    <CardTitle>Public Profile</CardTitle>
                    <CardDescription>
                        This information will be displayed publicly to other users.
                    </CardDescription>
                </CardHeader>
                <CardContent className="space-y-6">
                    <div className="flex flex-col sm:flex-row gap-6 items-center sm:items-start">
                        <div className="relative group">
                            <Avatar className="h-24 w-24 border-2 border-green-100">
                                <AvatarImage src={profile?.avatar_url} />
                                <AvatarFallback className="bg-green-50 text-green-700 text-xl">
                                    {formData.fullName?.[0]?.toUpperCase() || formData.username?.[0]?.toUpperCase() || "U"}
                                </AvatarFallback>
                            </Avatar>
                            <div className="mt-2 text-center">
                                <p className="text-xs text-muted-foreground italic">Avatar upload coming soon</p>
                            </div>
                        </div>

                        <div className="flex-1 space-y-4 w-full">
                            <div className="space-y-2">
                                <Label htmlFor="fullName">Full Name</Label>
                                <Input
                                    id="fullName"
                                    value={formData.fullName}
                                    onChange={(e) => setFormData({ ...formData, fullName: e.target.value })}
                                    placeholder="Your full name"
                                    className="focus-visible:ring-green-500"
                                />
                            </div>

                            <div className="space-y-2">
                                <Label htmlFor="username">Username</Label>
                                <Input
                                    id="username"
                                    value={formData.username}
                                    onChange={(e) => setFormData({ ...formData, username: e.target.value })}
                                    placeholder="username"
                                    className="focus-visible:ring-green-500"
                                />
                                <p className="text-xs text-muted-foreground">
                                    Your unique handle on the platform.
                                </p>
                            </div>
                        </div>
                    </div>

                    <div className="space-y-2">
                        <Label htmlFor="bio">Bio</Label>
                        <Textarea
                            id="bio"
                            value={formData.bio}
                            onChange={(e) => setFormData({ ...formData, bio: e.target.value })}
                            placeholder="Tell us about yourself and your passion for flowers..."
                            rows={4}
                            className="resize-none focus-visible:ring-green-500"
                        />
                        <p className="text-xs text-muted-foreground">
                            Brief description for your profile. Maximum 160 characters.
                        </p>
                    </div>
                </CardContent>
                <CardFooter className="bg-slate-50 border-t flex justify-end py-4">
                    <Button
                        type="submit"
                        disabled={isSubmitting}
                        className="bg-green-600 hover:bg-green-700 text-white"
                    >
                        {isSubmitting ? (
                            <>
                                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                                Saving...
                            </>
                        ) : "Save Changes"}
                    </Button>
                </CardFooter>
            </Card>
        </form>
    )
}
