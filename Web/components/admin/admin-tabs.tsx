import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { AdminPostList } from "@/components/admin/admin-post-list"
import { ReportsList } from "@/components/admin/reports-list"

interface AdminTabsProps {
  posts: Array<{
    id: string
    caption: string | null
    flower_name: string | null
    created_at: string
    author: {
      id: string
      username: string
      full_name: string | null
    }
    post_media: Array<{
      media_url: string
    }>
  }>
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

export function AdminTabs({ posts, reports, adminId }: AdminTabsProps) {
  return (
    <Tabs defaultValue="posts" className="w-full">
      <TabsList className="w-full justify-start">
        <TabsTrigger value="posts">Manage Posts ({posts.length})</TabsTrigger>
        <TabsTrigger value="reports">Reports ({reports.length})</TabsTrigger>
      </TabsList>

      <TabsContent value="posts" className="mt-6">
        <AdminPostList posts={posts} adminId={adminId} />
      </TabsContent>

      <TabsContent value="reports" className="mt-6">
        <ReportsList reports={reports} adminId={adminId} />
      </TabsContent>
    </Tabs>
  )
}

