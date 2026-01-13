'use client';

import { SidebarMenu } from '@/components/feed/sidebar-menu';
import { Button } from '@/components/ui/button';
import { Store } from 'lucide-react';
import Link from 'next/link';

export default function MarketplacePage() {
    return (
        <div className="min-h-screen bg-gradient-to-b from-green-50 to-white">
            <SidebarMenu />
            <div className="lg:ml-[280px]">
                <div className="container mx-auto max-w-4xl px-6 py-12">
                    <div className="text-center">
                        <Store className="h-16 w-16 mx-auto mb-4 text-gray-400" />
                        <h1 className="text-3xl font-bold mb-2">Marketplace</h1>
                        <p className="text-gray-600 mb-6">Tính năng đang được phát triển</p>
                        <Link href="/feed">
                            <Button>Quay lại Feed</Button>
                        </Link>
                    </div>
                </div>
            </div>
        </div>
    );
}
