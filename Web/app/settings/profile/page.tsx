"use client"

import { ProfileForm } from "@/components/profile/profile-form"

export default function ProfileSettingsPage() {
    return (
        <div className="space-y-6">
            <div>
                <h2 className="text-2xl font-bold tracking-tight text-slate-900">Profile Settings</h2>
                <p className="text-muted-foreground">
                    Manage your public profile and how others see you on the network.
                </p>
            </div>
            <ProfileForm />
        </div>
    )
}
