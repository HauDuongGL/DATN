/**
 * Supabase API Client for Flower Social Network
 * This file provides easy-to-use functions for all backend operations
 */

import { createClient } from './client';
import type { User } from '@supabase/supabase-js';

// Get Supabase client instance
const getSupabase = () => createClient();

// ==================== TYPES ====================

export interface Post {
    id: string;
    author_id: string;
    flower_name: string;
    flower_description?: string;
    flower_species?: string;
    planting_guide?: string;
    ai_confidence: number;
    image_url: string;
    image_thumbnail_url?: string;
    caption?: string;
    status: string;
    likes_count: number;
    comments_count: number;
    created_at: string;
    user?: UserProfile;
    is_liked_by_current_user?: boolean;
    location_name?: string;
    latitude?: number;
    longitude?: number;
}

export interface UserProfile {
    id: string;
    username: string;
    full_name?: string;
    display_name?: string;
    avatar_url?: string;
    bio?: string;
    posts_count?: number;
    followers_count?: number;
    following_count?: number;
    is_followed_by_current_user?: boolean;
}

export interface Comment {
    id: string;
    author_id: string;
    post_id: string;
    content: string;
    parent_comment_id?: string;
    created_at: string;
    updated_at: string;
    is_edited: boolean;
    user?: UserProfile;
    replies?: Comment[];
}

export interface Notification {
    id: string;
    recipient_id: string;
    actor_id: string;
    type: 'like' | 'comment' | 'follow' | 'mention' | 'post_created' | 'share';
    post_id?: string;
    comment_id?: string;
    message?: string;
    is_read: boolean;
    created_at: string;
    actor?: UserProfile;
}

// ==================== AUTHENTICATION ====================

export const auth = {
    async signUp(email: string, password: string, username: string, fullName?: string) {
        const supabase = getSupabase();
        return await supabase.auth.signUp({
            email,
            password,
            options: {
                data: {
                    username,
                    full_name: fullName || '',
                },
            },
        });
    },

    async signIn(email: string, password: string) {
        const supabase = getSupabase();
        return await supabase.auth.signInWithPassword({
            email,
            password,
        });
    },

    async signOut() {
        const supabase = getSupabase();
        return await supabase.auth.signOut();
    },

    async getCurrentUser(): Promise<User | null> {
        const supabase = getSupabase();
        const { data: { user } } = await supabase.auth.getUser();
        return user;
    },

    onAuthStateChange(callback: (user: User | null) => void) {
        const supabase = getSupabase();
        return supabase.auth.onAuthStateChange((event, session) => {
            callback(session?.user || null);
        });
    },
};

// ==================== POSTS ====================

export const posts = {
    async create(data: {
        authorId: string;
        flowerName: string;
        flowerDescription?: string;
        plantingGuide?: string;
        aiConfidence: number;
        imageUrl: string;
        caption?: string;
        latitude?: number;
        longitude?: number;
        locationName?: string;
    }): Promise<Post> {
        const supabase = getSupabase();
        const { data: post, error } = await supabase
            .from('posts')
            .insert({
                author_id: data.authorId,
                flower_name: data.flowerName,
                flower_description: data.flowerDescription,
                planting_guide: data.plantingGuide,
                ai_confidence: data.aiConfidence,
                image_url: data.imageUrl,
                caption: data.caption,
                latitude: data.latitude,
                longitude: data.longitude,
                location_name: data.locationName,
            })
            .select()
            .single();

        if (error) throw error;
        return post;
    },

    async getAll(page = 0, limit = 20): Promise<Post[]> {
        const supabase = getSupabase();
        const { data, error } = await supabase
            .from('posts')
            .select(`
        *,
        user:profiles!author_id(id, username, avatar_url, full_name)
      `)
            .eq('status', 'approved')
            .order('created_at', { ascending: false })
            .range(page * limit, (page + 1) * limit - 1);

        if (error) throw error;
        return data as Post[];
    },

    async getById(postId: string): Promise<Post> {
        const supabase = getSupabase();
        const { data, error } = await supabase
            .from('posts')
            .select(`
        *,
        user:profiles!author_id(id, username, avatar_url, full_name)
      `)
            .eq('id', postId)
            .single();

        if (error) throw error;
        return data as Post;
    },

    async getUserPosts(userId: string, page = 0, limit = 20): Promise<Post[]> {
        const supabase = getSupabase();
        const { data, error } = await supabase
            .from('posts')
            .select('*')
            .eq('author_id', userId)
            .eq('status', 'approved')
            .order('created_at', { ascending: false })
            .range(page * limit, (page + 1) * limit - 1);

        if (error) throw error;
        return data as Post[];
    },

    async delete(postId: string): Promise<void> {
        const supabase = getSupabase();
        const { error } = await supabase
            .from('posts')
            .delete()
            .eq('id', postId);

        if (error) throw error;
    },

    async uploadImage(file: File): Promise<string> {
        const supabase = getSupabase();
        const user = await auth.getCurrentUser();
        if (!user) throw new Error('User not authenticated');

        const fileName = `${Date.now()}_${file.name}`;
        const filePath = `${user.id}/${fileName}`;

        const { error: uploadError } = await supabase.storage
            .from('post-images')
            .upload(filePath, file);

        if (uploadError) throw uploadError;

        const { data } = supabase.storage
            .from('post-images')
            .getPublicUrl(filePath);

        return data.publicUrl;
    },

    async getTrending(daysBack = 7, limit = 20): Promise<Post[]> {
        const supabase = getSupabase();

        try {
            const { data, error } = await supabase.rpc('get_trending_posts', {
                days_back: daysBack,
                page_size: limit,
            });

            if (error) {
                // If RPC function doesn't exist, fall back to regular query with engagement sorting
                console.warn('get_trending_posts RPC failed, using fallback:', error.message);
                return this.getTrendingFallback(daysBack, limit);
            }

            return (data as Post[]) || [];
        } catch (error: any) {
            // Fallback if RPC call fails completely
            console.warn('get_trending_posts RPC error, using fallback:', error);
            return this.getTrendingFallback(daysBack, limit);
        }
    },

    async getTrendingFallback(daysBack = 7, limit = 20): Promise<Post[]> {
        const supabase = getSupabase();
        const cutoffDate = new Date();
        cutoffDate.setDate(cutoffDate.getDate() - daysBack);

        const { data, error } = await supabase
            .from('posts')
            .select(`
                *,
                user:profiles!author_id(id, username, avatar_url, full_name)
            `)
            .eq('status', 'approved')
            .gte('created_at', cutoffDate.toISOString())
            .order('likes_count', { ascending: false })
            .order('comments_count', { ascending: false })
            .order('created_at', { ascending: false })
            .limit(limit);

        if (error) throw error;
        return (data as Post[]) || [];
    },

    async getFollowingFeed(page = 0, limit = 20): Promise<Post[]> {
        const supabase = getSupabase();
        const user = await auth.getCurrentUser();

        if (!user) {
            // If not logged in, return empty array
            return [];
        }

        try {
            const { data, error } = await supabase.rpc('get_following_feed', {
                page_size: limit,
                page_offset: page * limit,
            });

            if (error) {
                // If RPC function doesn't exist, fall back to regular query
                console.warn('get_following_feed RPC failed, using fallback:', error.message);
                return this.getFollowingFeedFallback(user.id, page, limit);
            }

            return (data as Post[]) || [];
        } catch (error: any) {
            // Fallback if RPC call fails completely
            console.warn('get_following_feed RPC error, using fallback:', error);
            return this.getFollowingFeedFallback(user.id, page, limit);
        }
    },

    async getFollowingFeedFallback(userId: string, page = 0, limit = 20): Promise<Post[]> {
        const supabase = getSupabase();

        // Get list of users being followed
        const { data: follows, error: followsError } = await supabase
            .from('follows')
            .select('following_id')
            .eq('follower_id', userId);

        if (followsError) throw followsError;

        if (!follows || follows.length === 0) {
            return [];
        }

        const followingIds = follows.map(f => f.following_id);

        const { data, error } = await supabase
            .from('posts')
            .select(`
                *,
                user:profiles!author_id(id, username, avatar_url, full_name)
            `)
            .in('author_id', followingIds)
            .eq('status', 'approved')
            .order('created_at', { ascending: false })
            .range(page * limit, (page + 1) * limit - 1);

        if (error) throw error;
        return (data as Post[]) || [];
    },
};

// ==================== LIKES ====================

export const likes = {
    async like(postId: string, userId: string): Promise<void> {
        const supabase = getSupabase();
        const { error } = await supabase
            .from('likes')
            .insert({ post_id: postId, user_id: userId });

        if (error) throw error;
    },

    async unlike(postId: string, userId: string): Promise<void> {
        const supabase = getSupabase();
        const { error } = await supabase
            .from('likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', userId);

        if (error) throw error;
    },

    async isLiked(postId: string): Promise<boolean> {
        const supabase = getSupabase();
        const user = await auth.getCurrentUser();
        if (!user) return false;

        const { data, error } = await supabase
            .from('likes')
            .select()
            .eq('post_id', postId)
            .eq('user_id', user.id)
            .maybeSingle();

        if (error) throw error;
        return data !== null;
    },

    async getPostLikes(postId: string): Promise<any[]> {
        const supabase = getSupabase();
        const { data, error } = await supabase
            .from('likes')
            .select('*, user:profiles(id, username, avatar_url)')
            .eq('post_id', postId)
            .order('created_at', { ascending: false });

        if (error) throw error;
        return data;
    },
};

// ==================== COMMENTS ====================

export const comments = {
    async create(postId: string, content: string, authorId: string, parentCommentId?: string): Promise<Comment> {
        const supabase = getSupabase();
        const { data, error } = await supabase
            .from('comments')
            .insert({
                post_id: postId,
                content,
                author_id: authorId,
                parent_comment_id: parentCommentId,
            })
            .select(`
        *,
        user:profiles(id, username, avatar_url)
      `)
            .single();

        if (error) throw error;
        return data as Comment;
    },

    async getPostComments(postId: string): Promise<Comment[]> {
        const supabase = getSupabase();
        const { data, error } = await supabase
            .from('comments')
            .select(`
        *,
        user:profiles(id, username, avatar_url)
      `)
            .eq('post_id', postId)
            .is('parent_comment_id', null)
            .order('created_at', { ascending: false });

        if (error) throw error;
        return data as Comment[];
    },

    async getReplies(commentId: string): Promise<Comment[]> {
        const supabase = getSupabase();
        const { data, error } = await supabase
            .from('comments')
            .select(`
        *,
        user:profiles(id, username, avatar_url)
      `)
            .eq('parent_comment_id', commentId)
            .order('created_at', { ascending: true });

        if (error) throw error;
        return data as Comment[];
    },

    async update(commentId: string, content: string): Promise<Comment> {
        const supabase = getSupabase();
        const { data, error } = await supabase
            .from('comments')
            .update({ content })
            .eq('id', commentId)
            .select()
            .single();

        if (error) throw error;
        return data as Comment;
    },

    async delete(commentId: string): Promise<void> {
        const supabase = getSupabase();
        const { error } = await supabase
            .from('comments')
            .delete()
            .eq('id', commentId);

        if (error) throw error;
    },
};

// ==================== FOLLOWS ====================

export const follows = {
    async follow(userId: string): Promise<void> {
        const supabase = getSupabase();
        const user = await auth.getCurrentUser();
        if (!user) throw new Error('User not authenticated');

        // Check if already following by querying directly
        const { data: existing, error: checkError } = await supabase
            .from('follows')
            .select('id')
            .eq('following_id', userId)
            .eq('follower_id', user.id)
            .maybeSingle();

        if (checkError) {
            console.error('[Follow] Error checking existing follow:', checkError);
            // Continue anyway, might be a transient error
        }

        if (existing) {
            console.log('[Follow] Already following, skipping insert');
            return; // Already following, no need to insert
        }

        // Insert follow relationship
        // Use a promise-based approach to handle both sync errors and async trigger errors
        let insertError: any = null;
        let insertSucceeded = false;

        try {
            const result = await supabase
                .from('follows')
                .insert({
                    following_id: userId,
                    follower_id: user.id
                });

            insertError = result.error;
            // If no error, insert might have succeeded (even if trigger fails)
            if (!result.error) {
                insertSucceeded = true;
            }
        } catch (err: any) {
            // Catch any exception from trigger or Supabase client
            insertError = err;
            console.warn('[Follow] Exception during insert (may be trigger error):', {
                message: err?.message,
                code: err?.code,
                name: err?.name,
            });
            // Don't set insertSucceeded = false here, we'll verify later
        }

        // Always verify if follow was inserted, regardless of error
        // This handles cases where trigger fails but insert succeeds
        const { data: verifyData, error: verifyError } = await supabase
            .from('follows')
            .select('id')
            .eq('following_id', userId)
            .eq('follower_id', user.id)
            .maybeSingle();

        // If follow was successfully inserted (verified), return success
        if (verifyData) {
            // Suppress trigger errors in console if follow succeeded
            if (insertError && (
                insertError.message?.includes('notifications') ||
                insertError.message?.includes('user_id') ||
                insertError.message?.includes('actor_id') ||
                insertError.message?.includes('sender_id') ||
                insertError.code === 'P0001' || // PostgreSQL exception code
                insertError.code === '42703'    // PostgreSQL undefined column error
            )) {
                // Only log as debug, not as error since follow succeeded
                console.log('[Follow] Trigger error suppressed (follow succeeded):', {
                    message: insertError.message,
                    code: insertError.code,
                    hint: 'Run script 022_fix_follow_notification_trigger.sql to fix trigger.'
                });
            }
            console.log('[Follow] Successfully followed user:', userId);
            return;
        }

        // If verify failed and we have insert error, handle it
        if (verifyError) {
            console.error('[Follow] Error verifying follow:', verifyError);
        }

        // If follow was not inserted, check insert error
        if (insertError) {
            // If duplicate key error, ignore it (already following)
            if (insertError.code === '23505') {
                console.log('[Follow] Duplicate key error, already following');
                return;
            }

            // If it's a trigger error but follow wasn't inserted, that's a real problem
            // But first, let's wait a bit and verify again (race condition)
            await new Promise(resolve => setTimeout(resolve, 500));
            const { data: retryVerify } = await supabase
                .from('follows')
                .select('id')
                .eq('following_id', userId)
                .eq('follower_id', user.id)
                .maybeSingle();

            if (retryVerify) {
                console.log('[Follow] Follow verified on retry, succeeded');
                return;
            }

            // Create a proper error object with all details
            const followError = new Error(insertError.message || 'Failed to follow user');
            (followError as any).code = insertError.code;
            (followError as any).details = insertError.details;
            (followError as any).hint = insertError.hint;
            throw followError;
        }

        // This shouldn't happen, but just in case
        throw new Error('Follow was not inserted and no error was returned');
    },

    async unfollow(userId: string): Promise<void> {
        const supabase = getSupabase();
        const user = await auth.getCurrentUser();
        if (!user) throw new Error('User not authenticated');

        // Check if currently following by querying directly
        const { data: existing } = await supabase
            .from('follows')
            .select('id')
            .eq('following_id', userId)
            .eq('follower_id', user.id)
            .maybeSingle();

        if (!existing) {
            return; // Not following, no need to delete
        }

        const { error } = await supabase
            .from('follows')
            .delete()
            .eq('following_id', userId)
            .eq('follower_id', user.id);

        if (error) {
            // If not found error, ignore it (already unfollowed)
            if (error.code === 'PGRST116') {
                return;
            }
            // Create a proper error object with all details
            const unfollowError = new Error(error.message || 'Failed to unfollow user');
            (unfollowError as any).code = error.code;
            (unfollowError as any).details = error.details;
            (unfollowError as any).hint = error.hint;
            throw unfollowError;
        }
    },

    async isFollowing(userId: string): Promise<boolean> {
        const supabase = getSupabase();
        const user = await auth.getCurrentUser();
        if (!user) {
            console.log('[isFollowing] No user authenticated');
            return false;
        }

        const { data, error } = await supabase
            .from('follows')
            .select('id')
            .eq('following_id', userId)
            .eq('follower_id', user.id)
            .maybeSingle();

        if (error) {
            console.error('[isFollowing] Error checking follow status:', {
                message: error.message,
                code: error.code,
                details: error.details,
                hint: error.hint,
            });
            throw error;
        }

        const isFollowing = data !== null;
        console.log('[isFollowing] Result:', { userId, isFollowing, data });
        return isFollowing;
    },

    async getFollowers(userId: string): Promise<any[]> {
        const supabase = getSupabase();
        const { data, error } = await supabase
            .from('follows')
            .select('*, user:profiles!follower_id(id, username, avatar_url)')
            .eq('following_id', userId);

        if (error) throw error;
        return data;
    },

    async getFollowing(userId: string): Promise<any[]> {
        const supabase = getSupabase();

        // Try with join first
        let { data, error } = await supabase
            .from('follows')
            .select('*, user:profiles!following_id(id, username, avatar_url, full_name)')
            .eq('follower_id', userId)
            .order('created_at', { ascending: false });

        // If join fails, try without join and fetch profiles separately
        if (error) {
            console.warn('[getFollowing] Join query failed, trying fallback:', {
                message: error.message,
                code: error.code,
                details: error.details,
                hint: error.hint,
            });

            // Fallback: Get follows without join
            const { data: followsData, error: followsError } = await supabase
                .from('follows')
                .select('id, following_id, follower_id, created_at')
                .eq('follower_id', userId)
                .order('created_at', { ascending: false });

            if (followsError) {
                const getFollowingError = new Error(followsError.message || 'Failed to get following list');
                (getFollowingError as any).code = followsError.code;
                (getFollowingError as any).details = followsError.details;
                (getFollowingError as any).hint = followsError.hint;

                console.error('[getFollowing] Fallback query also failed:', {
                    message: followsError.message,
                    code: followsError.code,
                    details: followsError.details,
                    hint: followsError.hint,
                });

                throw getFollowingError;
            }

            if (!followsData || followsData.length === 0) {
                return [];
            }

            // Fetch profiles for each following_id
            const followingIds = followsData.map(f => f.following_id);
            const { data: profilesData, error: profilesError } = await supabase
                .from('profiles')
                .select('id, username, avatar_url, full_name')
                .in('id', followingIds);

            if (profilesError) {
                console.warn('[getFollowing] Failed to fetch profiles:', profilesError);
                // Return with minimal data
                return followsData.map((item: any) => ({
                    id: item.id,
                    following_id: item.following_id,
                    follower_id: item.follower_id,
                    created_at: item.created_at,
                    user: {
                        id: item.following_id,
                        username: 'unknown',
                        avatar_url: null,
                        full_name: null,
                    },
                }));
            }

            // Map profiles to follows
            const profileMap = new Map((profilesData || []).map((p: any) => [p.id, p]));
            return followsData.map((item: any) => ({
                id: item.id,
                following_id: item.following_id,
                follower_id: item.follower_id,
                created_at: item.created_at,
                user: profileMap.get(item.following_id) || {
                    id: item.following_id,
                    username: 'unknown',
                    avatar_url: null,
                    full_name: null,
                },
            }));
        }

        // Ensure data is properly formatted
        if (!data) return [];

        return data.map((item: any) => ({
            id: item.id,
            following_id: item.following_id,
            follower_id: item.follower_id,
            created_at: item.created_at,
            user: item.user || {
                id: item.following_id,
                username: 'unknown',
                avatar_url: null,
                full_name: null,
            },
        }));
    },
};

// ==================== USER PROFILE ====================

export const users = {
    async getProfile(userId: string): Promise<UserProfile> {
        const supabase = getSupabase();
        const { data, error } = await supabase
            .from('profiles')
            .select()
            .eq('id', userId)
            .single();

        if (error) throw error;
        return data as UserProfile;
    },

    async getProfileByUsername(username: string): Promise<UserProfile | null> {
        const supabase = getSupabase();
        const { data, error } = await supabase
            .from('profiles')
            .select()
            .eq('username', username)
            .maybeSingle();

        if (error) throw error;
        return (data as UserProfile) || null;
    },

    async updateProfile(updates: {
        username?: string;
        fullName?: string;
        bio?: string;
        avatarUrl?: string;
    }): Promise<UserProfile> {
        const supabase = getSupabase();
        const user = await auth.getCurrentUser();
        if (!user) throw new Error('User not authenticated');

        const updateData: any = {};
        if (updates.username) updateData.username = updates.username;
        if (updates.fullName) {
            updateData.full_name = updates.fullName;
            updateData.display_name = updates.fullName; // Sync display_name with full_name
        }
        if (updates.bio) updateData.bio = updates.bio;
        if (updates.avatarUrl) updateData.avatar_url = updates.avatarUrl;

        const { data, error } = await supabase
            .from('profiles')
            .update(updateData)
            .eq('id', user.id)
            .select()
            .single();

        if (error) throw error;
        return data as UserProfile;
    },
};

// ==================== NOTIFICATIONS ====================

export const notifications = {
    async getAll(page = 0, limit = 20): Promise<Notification[]> {
        const supabase = getSupabase();
        const user = await auth.getCurrentUser();
        if (!user) {
            console.warn('[Notifications] No user authenticated, returning empty array');
            return [];
        }

        try {
            // First try with join to profiles
            const { data, error } = await supabase
                .from('notifications')
                .select(`
                    *,
                    actor:profiles!actor_id(id, username, avatar_url, full_name)
                `)
                .eq('recipient_id', user.id)
                .order('created_at', { ascending: false })
                .range(page * limit, (page + 1) * limit - 1);

            if (error) {
                // If join fails, try without join
                console.warn('[Notifications] Query with join failed, trying without join:', error.message);
                const { data: simpleData, error: simpleError } = await supabase
                    .from('notifications')
                    .select('*')
                    .eq('recipient_id', user.id)
                    .order('created_at', { ascending: false })
                    .range(page * limit, (page + 1) * limit - 1);

                if (simpleError) {
                    console.error('[Notifications] Query error:', {
                        message: simpleError.message,
                        details: simpleError.details,
                        hint: simpleError.hint,
                        code: simpleError.code
                    });
                    return [];
                }

                return (simpleData as Notification[]) || [];
            }

            return (data as Notification[]) || [];
        } catch (error: any) {
            console.error('[Notifications] Failed to get all notifications:', {
                message: error?.message,
                details: error?.details,
                hint: error?.hint,
                code: error?.code,
                error
            });
            // Return empty array instead of throwing to prevent UI crashes
            return [];
        }
    },

    async create(input: {
        recipientId: string;
        type: Notification['type'];
        postId?: string;
        commentId?: string;
        message?: string;
    }): Promise<void> {
        const supabase = getSupabase();
        const user = await auth.getCurrentUser();
        if (!user) throw new Error('User not authenticated');

        const { error } = await supabase.from('notifications').insert({
            recipient_id: input.recipientId,
            actor_id: user.id,
            type: input.type,
            post_id: input.postId,
            comment_id: input.commentId,
            message: input.message,
        });

        if (error) throw error;
    },

    async markAsRead(notificationId: string): Promise<void> {
        const supabase = getSupabase();
        const { error } = await supabase
            .from('notifications')
            .update({ is_read: true })
            .eq('id', notificationId);

        if (error) throw error;
    },

    async markAllAsRead(): Promise<void> {
        const supabase = getSupabase();
        const user = await auth.getCurrentUser();
        if (!user) throw new Error('User not authenticated');

        const { error } = await supabase.rpc('mark_all_notifications_read', {
            target_user_id: user.id,
        });

        if (error) throw error;
    },

    async getUnreadCount(): Promise<number> {
        const supabase = getSupabase();
        const user = await auth.getCurrentUser();
        if (!user) return 0;

        const { count, error } = await supabase
            .from('notifications')
            .select('*', { count: 'exact', head: true })
            .eq('recipient_id', user.id)
            .eq('is_read', false);

        if (error) throw error;
        return count || 0;
    },

    subscribeToNotifications(callback: () => void) {
        const supabase = getSupabase();
        return supabase
            .channel('public:notifications')
            .on('postgres_changes', {
                event: '*',
                schema: 'public',
                table: 'notifications'
            }, callback)
            .subscribe();
    },
};

// ==================== SEARCH & DISCOVERY ====================

export const search = {
    async getSuggestions(query: string, limit = 10): Promise<string[]> {
        const supabase = getSupabase();
        const searchTerm = `%${query}%`;

        try {
            // Get distinct flower names that match the query
            const { data, error } = await supabase
                .from('posts')
                .select('flower_name')
                .eq('status', 'approved')
                .ilike('flower_name', searchTerm)
                .limit(limit * 2); // Get more to account for duplicates

            if (error) {
                console.warn('getSuggestions error:', error);
                return [];
            }

            if (!data || data.length === 0) {
                return [];
            }

            // Get unique flower names and sort by relevance (exact match first, then alphabetical)
            const uniqueNames = Array.from(new Set(data.map((p: any) => p.flower_name)))
                .filter((name): name is string => !!name)
                .sort((a, b) => {
                    // Exact match first
                    const aExact = a.toLowerCase().startsWith(query.toLowerCase());
                    const bExact = b.toLowerCase().startsWith(query.toLowerCase());
                    if (aExact && !bExact) return -1;
                    if (!aExact && bExact) return 1;
                    // Then alphabetical
                    return a.localeCompare(b);
                })
                .slice(0, limit);

            return uniqueNames;
        } catch (error) {
            console.warn('getSuggestions error:', error);
            return [];
        }
    },
    async posts(query: string, page = 0, limit = 20): Promise<Post[]> {
        const supabase = getSupabase();

        try {
            const { data, error } = await supabase.rpc('search_posts', {
                search_query: query,
                page_size: limit,
                page_offset: page * limit,
            });

            if (error) {
                // If RPC function doesn't exist, fall back to regular query with text search
                console.warn('search_posts RPC failed, using fallback:', error.message);
                return this.postsFallback(query, page, limit);
            }

            return (data as Post[]) || [];
        } catch (error: any) {
            // Fallback if RPC call fails completely
            console.warn('search_posts RPC error, using fallback:', error);
            return this.postsFallback(query, page, limit);
        }
    },

    async postsFallback(query: string, page = 0, limit = 20): Promise<Post[]> {
        const supabase = getSupabase();
        const searchTerm = `%${query}%`;

        console.log('[Search Fallback] Searching for:', query, 'with term:', searchTerm);

        // First, let's check if there are any posts at all
        const { data: testData, error: testError } = await supabase
            .from('posts')
            .select('id, flower_name, status')
            .limit(5);

        console.log('[Search Fallback] Test query - Total posts sample:', testData?.length, 'Error:', testError);
        if (testData && testData.length > 0) {
            console.log('[Search Fallback] Sample posts:', testData.map(p => ({ id: p.id, name: p.flower_name, status: p.status })));
        }

        // Try searching without status filter first to see if we get any results
        let { data, error } = await supabase
            .from('posts')
            .select(`
                *,
                user:profiles!author_id(id, username, avatar_url, full_name)
            `)
            .ilike('flower_name', searchTerm)
            .order('created_at', { ascending: false })
            .limit(limit);

        console.log('[Search Fallback] Query without status filter - Results:', data?.length, 'Error:', error);

        if (error) {
            console.error('[Search Fallback] Error searching flower_name (no status filter):', error);
        }

        // If we got results, filter by status in memory if needed
        if (data && data.length > 0) {
            const filtered = data.filter((post: any) => !post.status || post.status === 'approved');
            console.log('[Search Fallback] After status filter:', filtered.length, 'results');
            if (filtered.length > 0) {
                return (filtered as Post[]).slice(page * limit, (page + 1) * limit);
            }
        }

        // If no results, try with status filter
        console.log('[Search Fallback] Trying with status filter...');
        const { data: dataWithStatus, error: errorWithStatus } = await supabase
            .from('posts')
            .select(`
                *,
                user:profiles!author_id(id, username, avatar_url, full_name)
            `)
            .eq('status', 'approved')
            .ilike('flower_name', searchTerm)
            .order('created_at', { ascending: false })
            .limit(limit);

        console.log('[Search Fallback] Query with status filter - Results:', dataWithStatus?.length, 'Error:', errorWithStatus);

        if (!errorWithStatus && dataWithStatus && dataWithStatus.length > 0) {
            return (dataWithStatus as Post[]) || [];
        }

        // Try other fields if flower_name didn't work
        console.log('[Search Fallback] Trying caption field...');
        const { data: captionData, error: captionError } = await supabase
            .from('posts')
            .select(`
                *,
                user:profiles!author_id(id, username, avatar_url, full_name)
            `)
            .ilike('caption', searchTerm)
            .order('created_at', { ascending: false })
            .limit(limit);

        console.log('[Search Fallback] Caption search - Results:', captionData?.length, 'Error:', captionError);

        if (!captionError && captionData && captionData.length > 0) {
            const filtered = captionData.filter((post: any) => !post.status || post.status === 'approved');
            if (filtered.length > 0) {
                return (filtered as Post[]) || [];
            }
        }

        // Try flower_species
        console.log('[Search Fallback] Trying flower_species field...');
        const { data: speciesData, error: speciesError } = await supabase
            .from('posts')
            .select(`
                *,
                user:profiles!author_id(id, username, avatar_url, full_name)
            `)
            .ilike('flower_species', searchTerm)
            .order('created_at', { ascending: false })
            .limit(limit);

        console.log('[Search Fallback] Species search - Results:', speciesData?.length, 'Error:', speciesError);

        if (!speciesError && speciesData && speciesData.length > 0) {
            const filtered = speciesData.filter((post: any) => !post.status || post.status === 'approved');
            if (filtered.length > 0) {
                return (filtered as Post[]) || [];
            }
        }

        console.log('[Search Fallback] No results found after all attempts');
        return [];
    },

    async getTrending(daysBack = 7, limit = 20): Promise<Post[]> {
        const supabase = getSupabase();

        try {
            const { data, error } = await supabase.rpc('get_trending_posts', {
                days_back: daysBack,
                page_size: limit,
            });

            if (error) {
                // If RPC function doesn't exist, fall back to regular query with engagement sorting
                console.warn('get_trending_posts RPC failed, using fallback:', error.message);
                return this.getTrendingFallback(daysBack, limit);
            }

            return (data as Post[]) || [];
        } catch (error: any) {
            // Fallback if RPC call fails completely
            console.warn('get_trending_posts RPC error, using fallback:', error);
            return this.getTrendingFallback(daysBack, limit);
        }
    },

    async getTrendingFallback(daysBack = 7, limit = 20): Promise<Post[]> {
        const supabase = getSupabase();
        const cutoffDate = new Date();
        cutoffDate.setDate(cutoffDate.getDate() - daysBack);

        const { data, error } = await supabase
            .from('posts')
            .select(`
                *,
                user:profiles!author_id(id, username, avatar_url, full_name)
            `)
            .eq('status', 'approved')
            .gte('created_at', cutoffDate.toISOString())
            .order('likes_count', { ascending: false })
            .order('comments_count', { ascending: false })
            .order('created_at', { ascending: false })
            .limit(limit);

        if (error) throw error;
        return (data as Post[]) || [];
    },

    async getFollowingFeed(page = 0, limit = 20): Promise<Post[]> {
        const supabase = getSupabase();
        const { data, error } = await supabase.rpc('get_following_feed', {
            page_size: limit,
            page_offset: page * limit,
        });

        if (error) throw error;
        return data as Post[];
    },
};

// Export all
export default {
    auth,
    posts,
    likes,
    comments,
    follows,
    users,
    notifications,
    search,
};
