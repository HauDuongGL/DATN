"use client"

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Bell } from "lucide-react"

export default function NotificationsSettingsPage() {
    return (
        <div className="space-y-6">
            <div>
                <h2 className="text-2xl font-bold tracking-tight text-slate-900">Notification Settings</h2>
                <p className="text-muted-foreground">
                    Choose which notifications you want to receive and how.
                </p>
            </div>

            <Card className="border-green-100">
                <CardHeader>
                    <CardTitle>Preferences</CardTitle>
                    <CardDescription>Configure your notification channels.</CardDescription>
                </CardHeader>
                <CardContent className="py-12 flex flex-col items-center justify-center text-center">
                    <div className="bg-green-50 p-4 rounded-full mb-4">
                        <Bell className="h-8 w-8 text-green-600" />
                    </div>
                    <h3 className="text-lg font-semibold">Coming Soon</h3>
                    <p className="text-sm text-muted-foreground max-w-xs">
                        We're currently working on customizable notification settings. Stay tuned!
                    </p>
                </CardContent>
            </Card>
        </div>
    )
}
