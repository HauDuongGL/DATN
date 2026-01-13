import { Card, CardContent } from "@/components/ui/card"
import { Users, FileText, Clock, AlertTriangle } from "lucide-react"

interface AdminStatsProps {
  totalUsers: number
  totalPosts: number
  pendingReports: number
}

export function AdminStats({ totalUsers, totalPosts, pendingReports }: AdminStatsProps) {
  return (
    <div className="mb-6 grid gap-4 md:grid-cols-2 lg:grid-cols-3">
      <Card className="border-slate-200">
        <CardContent className="flex items-center gap-4 p-6">
          <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-blue-100">
            <Users className="h-6 w-6 text-blue-600" />
          </div>
          <div>
            <p className="text-sm text-slate-600">Total Users</p>
            <p className="text-2xl font-bold text-slate-900">{totalUsers}</p>
          </div>
        </CardContent>
      </Card>

      <Card className="border-slate-200">
        <CardContent className="flex items-center gap-4 p-6">
          <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-emerald-100">
            <FileText className="h-6 w-6 text-emerald-600" />
          </div>
          <div>
            <p className="text-sm text-slate-600">Total Posts</p>
            <p className="text-2xl font-bold text-slate-900">{totalPosts}</p>
          </div>
        </CardContent>
      </Card>

      <Card className="border-slate-200">
        <CardContent className="flex items-center gap-4 p-6">
          <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-red-100">
            <AlertTriangle className="h-6 w-6 text-red-600" />
          </div>
          <div>
            <p className="text-sm text-slate-600">Pending Reports</p>
            <p className="text-2xl font-bold text-slate-900">{pendingReports}</p>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
