package com.example.floweridentifier.data.repository

import com.example.floweridentifier.data.model.NotificationDto
import com.example.floweridentifier.data.model.NotificationItem
import com.example.floweridentifier.data.remote.SupabaseApi
import com.example.floweridentifier.utils.Constants
import com.example.floweridentifier.utils.PreferenceHelper
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

class NotificationRepository {
    private val api: SupabaseApi

    init {
        val client = OkHttpClient.Builder().build()
        val retrofit = Retrofit.Builder()
            .baseUrl(Constants.SUPABASE_URL)
            .client(client)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
        api = retrofit.create(SupabaseApi::class.java)
    }

    suspend fun fetchNotifications(context: android.content.Context): Result<List<NotificationItem>> {
        val token = PreferenceHelper.getToken(context) ?: return Result.failure(Exception("Missing token"))
        val userId = PreferenceHelper.getUserId(context) ?: return Result.failure(Exception("Missing user"))
        return try {
            val response = api.getNotifications(
                token = "Bearer $token",
                apiKey = Constants.SUPABASE_KEY,
                recipientIdFilter = "eq.$userId"
            )
            if (response.isSuccessful && response.body() != null) {
                val mapped = response.body()!!.map { it.toItem() }
                Result.success(mapped)
            } else {
                val body = response.errorBody()?.string() ?: "Failed to load notifications"
                val message = if (body.contains("JWT expired")) "JWT_EXPIRED" else body
                Result.failure(Exception(message))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun markAsRead(context: android.content.Context, id: String): Result<Unit> {
        val token = PreferenceHelper.getToken(context) ?: return Result.failure(Exception("Missing token"))
        return try {
            val response = api.markNotificationAsRead(
                token = "Bearer $token",
                apiKey = Constants.SUPABASE_KEY,
                idFilter = "eq.$id",
                body = mapOf("is_read" to true)
            )
            if (response.isSuccessful) {
                Result.success(Unit)
            } else {
                val body = response.errorBody()?.string() ?: "Mark failed"
                val message = if (body.contains("JWT expired")) "JWT_EXPIRED" else body
                Result.failure(Exception(message))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun markAllAsRead(context: android.content.Context): Result<Unit> {
        val token = PreferenceHelper.getToken(context) ?: return Result.failure(Exception("Missing token"))
        val userId = PreferenceHelper.getUserId(context) ?: return Result.failure(Exception("Missing user"))
        return try {
            val response = api.markAllNotificationsRead(
                token = "Bearer $token",
                apiKey = Constants.SUPABASE_KEY,
                body = mapOf("target_user_id" to userId)
            )
            if (response.isSuccessful) {
                Result.success(Unit)
            } else {
                val body = response.errorBody()?.string() ?: "Mark all failed"
                val message = if (body.contains("JWT expired")) "JWT_EXPIRED" else body
                Result.failure(Exception(message))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    private fun NotificationDto.toItem(): NotificationItem = NotificationItem(
        id = id,
        type = type,
        message = message ?: defaultMessage(type),
        createdAt = created_at,
        actorName = actor?.full_name ?: actor?.username,
        actorAvatar = actor?.avatar_url,
        isRead = is_read
    )

    private fun defaultMessage(type: String): String = when (type) {
        "like" -> "đã thích bài viết của bạn"
        "comment" -> "đã bình luận về bài viết của bạn"
        "follow" -> "đã theo dõi bạn"
        "post_created" -> "đã đăng một bài viết mới"
        "share" -> "đã chia sẻ bài viết của bạn"
        else -> "đã tương tác"
    }
}
