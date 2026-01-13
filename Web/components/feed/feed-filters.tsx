/**
 * Feed Filters Component
 * Filter tabs for feed (Latest, Trending, Following)
 */

'use client';

import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { TrendingUp, Clock, Users } from 'lucide-react';

interface FeedFiltersProps {
    value: 'latest' | 'trending' | 'following';
    onChange: (value: 'latest' | 'trending' | 'following') => void;
}

export function FeedFilters({ value, onChange }: FeedFiltersProps) {
    return (
        <Tabs value={value} onValueChange={(v) => onChange(v as any)} className="w-full">
            <TabsList className="grid w-full grid-cols-3">
                <TabsTrigger value="latest" className="gap-2">
                    <Clock className="h-4 w-4" />
                    <span className="hidden sm:inline">Latest</span>
                </TabsTrigger>
                <TabsTrigger value="trending" className="gap-2">
                    <TrendingUp className="h-4 w-4" />
                    <span className="hidden sm:inline">Trending</span>
                </TabsTrigger>
                <TabsTrigger value="following" className="gap-2">
                    <Users className="h-4 w-4" />
                    <span className="hidden sm:inline">Following</span>
                </TabsTrigger>
            </TabsList>
        </Tabs>
    );
}
