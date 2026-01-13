/**
 * Search Page
 * Search for posts, users, and flowers
 */

'use client';

import { useState, useEffect, useRef } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import Link from 'next/link';
import Image from 'next/image';
import { ArrowLeft, Search as SearchIcon, Loader2, TrendingUp } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import { search as searchApi } from '@/lib/supabase/api';
import type { Post } from '@/lib/supabase/api';
import { toast } from 'sonner';

export default function SearchPage() {
    const router = useRouter();
    const searchParams = useSearchParams();
    const initialQuery = searchParams.get('q') || '';

    const [query, setQuery] = useState(initialQuery);
    const [searchResults, setSearchResults] = useState<Post[]>([]);
    const [trendingPosts, setTrendingPosts] = useState<Post[]>([]);
    const [loading, setLoading] = useState(false);
    const [activeTab, setActiveTab] = useState('posts');
    const [suggestions, setSuggestions] = useState<string[]>([]);
    const [showSuggestions, setShowSuggestions] = useState(false);
    const [loadingSuggestions, setLoadingSuggestions] = useState(false);
    const searchInputRef = useRef<HTMLInputElement>(null);
    const suggestionsRef = useRef<HTMLDivElement>(null);

    useEffect(() => {
        loadTrending();
        if (initialQuery) {
            handleSearch(initialQuery);
        }
    }, []);

    // Load suggestions when query changes (debounced)
    useEffect(() => {
        if (!query.trim()) {
            setSuggestions([]);
            setShowSuggestions(false);
            return;
        }

        const timer = setTimeout(async () => {
            setLoadingSuggestions(true);
            try {
                const suggs = await searchApi.getSuggestions(query.trim(), 8);
                setSuggestions(suggs);
                setShowSuggestions(suggs.length > 0);
            } catch (error) {
                console.error('Error loading suggestions:', error);
                setSuggestions([]);
            } finally {
                setLoadingSuggestions(false);
            }
        }, 300); // Debounce 300ms

        return () => clearTimeout(timer);
    }, [query]);

    // Close suggestions when clicking outside
    useEffect(() => {
        const handleClickOutside = (event: MouseEvent) => {
            if (
                suggestionsRef.current &&
                !suggestionsRef.current.contains(event.target as Node) &&
                searchInputRef.current &&
                !searchInputRef.current.contains(event.target as Node)
            ) {
                setShowSuggestions(false);
            }
        };

        document.addEventListener('mousedown', handleClickOutside);
        return () => document.removeEventListener('mousedown', handleClickOutside);
    }, []);

    const loadTrending = async () => {
        try {
            const data = await searchApi.getTrending(7, 10);
            setTrendingPosts(data);
        } catch (error: any) {
            console.error('Error loading trending:', {
                message: error?.message,
                details: error?.details,
                hint: error?.hint,
                code: error?.code,
                error: error
            });
            // Set empty array on error to prevent UI issues
            setTrendingPosts([]);
        }
    };

    const handleSearch = async (searchQuery: string) => {
        if (!searchQuery.trim()) {
            setSearchResults([]);
            return;
        }

        setLoading(true);
        try {
            const results = await searchApi.posts(searchQuery.trim());
            setSearchResults(results);
        } catch (error: any) {
            console.error('Error searching:', {
                message: error?.message,
                details: error?.details,
                hint: error?.hint,
                code: error?.code,
                error: error
            });
            toast.error('Search failed');
            // Set empty array on error to prevent UI issues
            setSearchResults([]);
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        setShowSuggestions(false);
        handleSearch(query);
        // Update URL
        router.push(`/search?q=${encodeURIComponent(query)}`);
    };

    const handleSuggestionClick = (suggestion: string) => {
        setQuery(suggestion);
        setShowSuggestions(false);
        handleSearch(suggestion);
        router.push(`/search?q=${encodeURIComponent(suggestion)}`);
    };

    return (
        <div className="min-h-screen bg-gradient-to-b from-green-50 to-white">
            {/* Header */}
            <header className="sticky top-0 z-40 bg-white/80 backdrop-blur-md border-b">
                <div className="container mx-auto max-w-2xl px-4 py-4">
                    <div className="flex items-center gap-3">
                        <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => router.back()}
                        >
                            <ArrowLeft className="h-5 w-5" />
                        </Button>

                        <form onSubmit={handleSubmit} className="flex-1 relative">
                            <div className="relative">
                                <SearchIcon className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground z-10" />
                                <Input
                                    ref={searchInputRef}
                                    type="search"
                                    placeholder="Search flowers, posts, users..."
                                    value={query}
                                    onChange={(e) => {
                                        setQuery(e.target.value);
                                        if (e.target.value.trim()) {
                                            setShowSuggestions(true);
                                        }
                                    }}
                                    onFocus={() => {
                                        if (suggestions.length > 0) {
                                            setShowSuggestions(true);
                                        }
                                    }}
                                    className="pl-10"
                                    autoFocus
                                />
                                
                                {/* Suggestions Dropdown */}
                                {showSuggestions && query.trim() && (
                                    <div
                                        ref={suggestionsRef}
                                        className="absolute top-full left-0 right-0 mt-1 bg-white border border-gray-200 rounded-lg shadow-lg z-50 max-h-64 overflow-y-auto"
                                    >
                                        {loadingSuggestions ? (
                                            <div className="p-4 text-center text-sm text-muted-foreground">
                                                <Loader2 className="h-4 w-4 animate-spin mx-auto" />
                                            </div>
                                        ) : suggestions.length > 0 ? (
                                            <div className="py-2">
                                                {suggestions.map((suggestion, index) => (
                                                    <button
                                                        key={index}
                                                        type="button"
                                                        onClick={() => handleSuggestionClick(suggestion)}
                                                        className="w-full text-left px-4 py-2 hover:bg-green-50 transition-colors flex items-center gap-2"
                                                    >
                                                        <SearchIcon className="h-4 w-4 text-muted-foreground" />
                                                        <span className="text-sm">{suggestion}</span>
                                                    </button>
                                                ))}
                                            </div>
                                        ) : (
                                            <div className="p-4 text-center text-sm text-muted-foreground">
                                                No suggestions found
                                            </div>
                                        )}
                                    </div>
                                )}
                            </div>
                        </form>
                    </div>
                </div>
            </header>

            <main className="container mx-auto max-w-2xl px-4 py-6">
                {query.trim() ? (
                    // Search Results
                    <div>
                        <Tabs value={activeTab} onValueChange={setActiveTab}>
                            <TabsList className="grid w-full grid-cols-3 mb-6">
                                <TabsTrigger value="posts">Posts</TabsTrigger>
                                <TabsTrigger value="users">Users</TabsTrigger>
                                <TabsTrigger value="flowers">Flowers</TabsTrigger>
                            </TabsList>

                            <TabsContent value="posts">
                                {loading ? (
                                    <div className="flex justify-center py-12">
                                        <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
                                    </div>
                                ) : searchResults.length === 0 ? (
                                    <Card>
                                        <CardContent className="p-12 text-center">
                                            <p className="text-muted-foreground">
                                                No posts found for "{query}"
                                            </p>
                                        </CardContent>
                                    </Card>
                                ) : (
                                    <div className="grid grid-cols-3 gap-1 md:gap-2">
                                        {searchResults.map((post) => (
                                            <Link key={post.id} href={`/post-new/${post.id}`}>
                                                <div className="relative aspect-square overflow-hidden rounded-lg bg-muted hover:opacity-90 transition-opacity group">
                                                    <Image
                                                        src={post.image_url}
                                                        alt={post.flower_name}
                                                        fill
                                                        className="object-cover"
                                                    />
                                                    <div className="absolute inset-0 bg-black/0 group-hover:bg-black/20 transition-colors" />
                                                    <div className="absolute bottom-2 left-2 right-2">
                                                        <Badge variant="secondary" className="text-xs">
                                                            {post.flower_name}
                                                        </Badge>
                                                    </div>
                                                </div>
                                            </Link>
                                        ))}
                                    </div>
                                )}
                            </TabsContent>

                            <TabsContent value="users">
                                <Card>
                                    <CardContent className="p-12 text-center">
                                        <p className="text-muted-foreground">
                                            User search coming soon...
                                        </p>
                                    </CardContent>
                                </Card>
                            </TabsContent>

                            <TabsContent value="flowers">
                                <Card>
                                    <CardContent className="p-12 text-center">
                                        <p className="text-muted-foreground">
                                            Flower encyclopedia coming soon...
                                        </p>
                                    </CardContent>
                                </Card>
                            </TabsContent>
                        </Tabs>
                    </div>
                ) : (
                    // Trending/Explore
                    <div className="space-y-6">
                        <div className="flex items-center gap-2">
                            <TrendingUp className="h-5 w-5 text-orange-500" />
                            <h2 className="text-xl font-bold">Trending This Week</h2>
                        </div>

                        {trendingPosts.length === 0 ? (
                            <Card>
                                <CardContent className="p-12 text-center">
                                    <p className="text-muted-foreground">
                                        No trending posts yet
                                    </p>
                                </CardContent>
                            </Card>
                        ) : (
                            <div className="grid grid-cols-3 gap-1 md:gap-2">
                                {trendingPosts.map((post) => (
                                    <Link key={post.id} href={`/post-new/${post.id}`}>
                                        <div className="relative aspect-square overflow-hidden rounded-lg bg-muted hover:opacity-90 transition-opacity group">
                                            <Image
                                                src={post.image_url}
                                                alt={post.flower_name}
                                                fill
                                                className="object-cover"
                                            />
                                            <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />
                                            <div className="absolute bottom-2 left-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                                <p className="text-white text-xs font-semibold truncate">
                                                    {post.flower_name}
                                                </p>
                                                <p className="text-white/80 text-xs">
                                                    ❤️ {post.likes_count}
                                                </p>
                                            </div>
                                        </div>
                                    </Link>
                                ))}
                            </div>
                        )}

                        {/* Search Suggestions */}
                        <div className="mt-8">
                            <h3 className="font-semibold mb-3">Popular Searches</h3>
                            <div className="flex flex-wrap gap-2">
                                {['Rose', 'Sunflower', 'Tulip', 'Orchid', 'Lily', 'Daisy'].map((flower) => (
                                    <Button
                                        key={flower}
                                        variant="outline"
                                        size="sm"
                                        onClick={() => {
                                            setQuery(flower);
                                            handleSearch(flower);
                                        }}
                                    >
                                        {flower}
                                    </Button>
                                ))}
                            </div>
                        </div>
                    </div>
                )}
            </main>
        </div>
    );
}
