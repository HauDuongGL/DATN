package com.example.floweridentifier.data.model

data class NotificationDto(
    val id: String,
    val recipient_id: String,
    val actor_id: String?,
    val type: String,
    val post_id: String?,
    val comment_id: String?,
    val message: String?,
    val is_read: Boolean,
    val created_at: String,
    val actor: ActorProfileDto?
)

data class ActorProfileDto(
    val username: String?,
    val full_name: String?,
    val avatar_url: String?
)

data class NotificationItem(
    val id: String,
    val type: String,
    val message: String,
    val createdAt: String,
    val actorName: String?,
    val actorAvatar: String?,
    val isRead: Boolean
)
