package com.example.floweridentifier.data.remote

import com.example.floweridentifier.data.model.NotificationDto
import okhttp3.MultipartBody
import okhttp3.RequestBody
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.Multipart
import retrofit2.http.PATCH
import retrofit2.http.POST
import retrofit2.http.Part
import retrofit2.http.Path
import retrofit2.http.Query

interface SupabaseApi {
    // Auth
    @POST("/auth/v1/signup")
    suspend fun signUp(@Body body: RequestBody, @Header("apikey") apiKey: String): Response<AuthResponse>

    @POST("/auth/v1/token?grant_type=password")
    suspend fun signIn(@Body body: RequestBody, @Header("apikey") apiKey: String): Response<AuthResponse>

    // Storage
    @POST("storage/v1/object/post-images/{path}")
    suspend fun uploadImage(
        @Path("path", encoded = true) path: String,
        @Header("Authorization") token: String,
        @Header("apikey") apiKey: String,
        @Body file: RequestBody
    ): Response<Unit>

    // Update FCM token on profile
    @PATCH("/rest/v1/profiles")
    suspend fun updateProfileFcmToken(
        @Header("Authorization") token: String,
        @Header("apikey") apiKey: String,
        @Header("Prefer") prefer: String = "return=minimal",
        @Query("id") idFilter: String,
        @Body body: Map<String, String>
    ): Response<Unit>

    // Notifications (PostgREST)
    @GET("/rest/v1/notifications")
    suspend fun getNotifications(
        @Header("Authorization") token: String,
        @Header("apikey") apiKey: String,
        @Query("recipient_id") recipientIdFilter: String,
        @Query("order") order: String = "created_at.desc",
        @Query("limit") limit: Int = 50,
        @Query("select") select: String = "*,actor:profiles!notifications_actor_id_fkey(full_name,username,avatar_url)"
    ): Response<List<NotificationDto>>

    @PATCH("/rest/v1/notifications")
    suspend fun markNotificationAsRead(
        @Header("Authorization") token: String,
        @Header("apikey") apiKey: String,
        @Header("Prefer") prefer: String = "return=minimal",
        @Query("id") idFilter: String,
        @Body body: Map<String, Boolean>
    ): Response<Unit>

    @POST("/rest/v1/rpc/mark_all_notifications_read")
    suspend fun markAllNotificationsRead(
        @Header("Authorization") token: String,
        @Header("apikey") apiKey: String,
        @Body body: Map<String, String>
    ): Response<Unit>

    // Get user profile
    @GET("/rest/v1/profiles")
    suspend fun getProfile(
        @Header("Authorization") token: String,
        @Header("apikey") apiKey: String,
        @Query("id") idFilter: String,
        @Query("select") select: String = "id,full_name,username,avatar_url,bio"
    ): Response<List<ProfileDto>>
    
    // Create user profile if doesn't exist
    @POST("/rest/v1/profiles")
    suspend fun createProfile(
        @Header("Authorization") token: String,
        @Header("apikey") apiKey: String,
        @Header("Prefer") prefer: String = "return=representation",
        @Body body: Map<String, Any>
    ): Response<List<ProfileDto>>
}

data class AuthResponse(
    val access_token: String,
    val token_type: String,
    val expires_in: Long,
    val refresh_token: String,
    val user: User
)

data class User(
    val id: String,
    val email: String
)

data class ProfileDto(
    val id: String,
    val full_name: String?,
    val username: String?,
    val avatar_url: String?,
    val bio: String?
)
