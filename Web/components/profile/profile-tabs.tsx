"use client"

import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import type { ReactNode } from "react"

interface ProfileTabsProps {
  children: ReactNode
}

export function ProfileTabs({ children }: ProfileTabsProps) {
  return (
    <Tabs defaultValue="posts" className="w-full">
      <TabsList className="w-full justify-start border-b border-slate-200 bg-transparent">
        <TabsTrigger value="posts" className="data-[state=active]:border-b-2 data-[state=active]:border-emerald-600">
          Posts
        </TabsTrigger>
        <TabsTrigger value="liked" className="data-[state=active]:border-b-2 data-[state=active]:border-emerald-600">
          Liked
        </TabsTrigger>
      </TabsList>
      <TabsContent value="posts" className="mt-6">
        {children}
      </TabsContent>
      <TabsContent value="liked" className="mt-6">
        <div className="rounded-lg bg-white p-12 text-center shadow">
          <p className="text-slate-600">Liked posts feature coming soon</p>
        </div>
      </TabsContent>
    </Tabs>
  )
}
