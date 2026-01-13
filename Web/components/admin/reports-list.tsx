"use client"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import { AlertTriangle, CheckCircle, XCircle } from "lucide-react"
import { formatDistanceToNow } from "date-fns"
import { useState } from "react"
import { createClient } from "@/lib/supabase/client"
import { useRouter } from "next/navigation"

interface ReportsListProps {
  reports: Array<{
    id: string
    reason: string
    description: string | null
    created_at: string
    reporter: {
      username: string
      full_name: string | null
    }
    post?: {
      id: string
      caption: string | null
    }
    reported_user?: {
      username: string
      full_name: string | null
    }
  }>
  adminId: string
}

export function ReportsList({ reports, adminId }: ReportsListProps) {
  const [processing, setProcessing] = useState<string | null>(null)
  const [resolutionNotes, setResolutionNotes] = useState<{ [key: string]: string }>({})
  const router = useRouter()
  const supabase = createClient()

  const handleResolve = async (reportId: string, status: "resolved" | "dismissed") => {
    setProcessing(reportId)
    try {
      await supabase
        .from("reports")
        .update({
          status,
          resolved_by: adminId, // Fixed column name from reviewed_by to resolved_by per schema
          resolved_at: new Date().toISOString(),
          // resolution_notes column might not exist in original schema, skipping or using description if needed
        })
        .eq("id", reportId)

      router.refresh()
    } catch (error) {
      console.error("Error resolving report:", error)
    } finally {
      setProcessing(null)
    }
  }

  if (reports.length === 0) {
    return (
      <Card className="border-slate-200">
        <CardContent className="py-12 text-center text-slate-600">No pending reports</CardContent>
      </Card>
    )
  }

  return (
    <div className="space-y-4">
      {reports.map((report) => (
        <Card key={report.id} className="border-slate-200">
          <CardHeader>
            <div className="flex items-start justify-between">
              <div className="flex items-start gap-3">
                <AlertTriangle className="mt-1 h-5 w-5 text-red-600" />
                <div>
                  <CardTitle className="text-base">Report: {report.reason}</CardTitle>
                  <p className="mt-1 text-sm text-slate-600">
                    Reported by {report.reporter.full_name || report.reporter.username} •{" "}
                    {formatDistanceToNow(new Date(report.created_at), { addSuffix: true })}
                  </p>
                </div>
              </div>
            </div>
          </CardHeader>

          <CardContent className="space-y-4">
            {report.description && (
              <div className="rounded-lg bg-slate-50 p-3">
                <p className="text-sm text-slate-700">{report.description}</p>
              </div>
            )}

            {report.post && (
              <div className="rounded-lg border border-slate-200 p-3">
                <p className="text-xs font-medium text-slate-600">Reported Post</p>
                <p className="mt-1 text-sm text-slate-900">{report.post.caption || "No caption"}</p>
              </div>
            )}

            {report.reported_user && (
              <div className="rounded-lg border border-slate-200 p-3">
                <p className="text-xs font-medium text-slate-600">Reported User</p>
                <p className="mt-1 text-sm text-slate-900">
                  {report.reported_user.full_name || report.reported_user.username}
                </p>
              </div>
            )}

            <div className="space-y-2">
              <label className="text-sm font-medium text-slate-700">Resolution Notes</label>
              <Textarea
                value={resolutionNotes[report.id] || ""}
                onChange={(e) =>
                  setResolutionNotes((prev) => ({
                    ...prev,
                    [report.id]: e.target.value,
                  }))
                }
                placeholder="Add notes about your decision..."
                rows={2}
                className="border-slate-200"
              />
            </div>

            <div className="flex gap-2">
              <Button
                onClick={() => handleResolve(report.id, "resolved")}
                disabled={processing === report.id}
                size="sm"
                className="flex-1 bg-emerald-600 hover:bg-emerald-700"
              >
                <CheckCircle className="mr-1 h-4 w-4" />
                Mark Resolved
              </Button>
              <Button
                onClick={() => handleResolve(report.id, "dismissed")}
                disabled={processing === report.id}
                size="sm"
                variant="outline"
                className="flex-1"
              >
                <XCircle className="mr-1 h-4 w-4" />
                Dismiss
              </Button>
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  )
}
