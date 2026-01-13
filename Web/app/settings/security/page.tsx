"use client"

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Shield } from "lucide-react"

export default function SecuritySettingsPage() {
    return (
        <div className="space-y-6">
            <div>
                <h2 className="text-2xl font-bold tracking-tight text-slate-900">Security Settings</h2>
                <p className="text-muted-foreground">
                    Manage your account security and authentication methods.
                </p>
            </div>

            <Card className="border-green-100">
                <CardHeader>
                    <CardTitle>Password & Authentication</CardTitle>
                    <CardDescription>Keep your account secure with the latest security features.</CardDescription>
                </CardHeader>
                <CardContent className="py-12 flex flex-col items-center justify-center text-center">
                    <div className="bg-green-50 p-4 rounded-full mb-4">
                        <Shield className="h-8 w-8 text-green-600" />
                    </div>
                    <h3 className="text-lg font-semibold">Coming Soon</h3>
                    <p className="text-sm text-muted-foreground max-w-xs">
                        Password change and two-factor authentication are being implemented.
                    </p>
                </CardContent>
            </Card>
        </div>
    )
}
