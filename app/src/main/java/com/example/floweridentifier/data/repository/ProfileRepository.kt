package com.example.floweridentifier.data.repository

import com.example.floweridentifier.data.remote.ProfileDto
import com.example.floweridentifier.data.remote.SupabaseApi
import com.example.floweridentifier.utils.Constants
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

class ProfileRepository {
    private val api: SupabaseApi

    init {
        val retrofit = Retrofit.Builder()
            .baseUrl(Constants.SUPABASE_URL)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
        api = retrofit.create(SupabaseApi::class.java)
    }

    suspend fun getProfile(userId: String, token: String): Result<ProfileDto?> {
        return try {
            val authToken = "Bearer $token"
            android.util.Log.d("ProfileRepository", "Fetching profile for userId: $userId")
            val response = api.getProfile(authToken, Constants.SUPABASE_KEY, "eq.$userId")
            android.util.Log.d("ProfileRepository", "Response code: ${response.code()}, isSuccessful: ${response.isSuccessful}")
            
            if (response.isSuccessful) {
                val profiles = response.body()
                if (profiles != null && profiles.isNotEmpty()) {
                    val profile = profiles.first()
                    android.util.Log.d("ProfileRepository", "Found profile: id=${profile.id}, " +
                            "full_name=${profile.full_name}, " +
                            "username=${profile.username}, avatar_url=${profile.avatar_url}")
                    Result.success(profile)
                } else {
                    android.util.Log.d("ProfileRepository", "Response body is null or empty")
                    Result.success(null)
                }
            } else {
                val errorBody = response.errorBody()?.string()
                android.util.Log.e("ProfileRepository", "API error: ${response.code()}, body: $errorBody")
                Result.failure(Exception("API error ${response.code()}: $errorBody"))
            }
        } catch (e: Exception) {
            android.util.Log.e("ProfileRepository", "Exception while fetching profile", e)
            Result.failure(e)
        }
    }
    
    suspend fun createProfileIfNotExists(userId: String, email: String, token: String): Result<ProfileDto?> {
        return try {
            val authToken = "Bearer $token"
            android.util.Log.d("ProfileRepository", "Creating profile for userId: $userId, email: $email")
            
            // Extract username from email (part before @)
            val username = email.substringBefore("@")
            
            // Build profile data map, only include non-null values
            val profileData = mutableMapOf<String, Any>(
                "id" to userId,
                "email" to email,
                "username" to username
            )
            // Note: full_name, display_name, avatar_url are optional and can be null
            // Supabase will handle null values, but we'll omit them to avoid issues
            
            val response = api.createProfile(
                authToken, 
                Constants.SUPABASE_KEY,
                "return=representation",
                profileData
            )
            android.util.Log.d("ProfileRepository", "Create profile response code: ${response.code()}, isSuccessful: ${response.isSuccessful}")
            
            if (response.isSuccessful && response.body() != null) {
                val profiles = response.body()!!
                android.util.Log.d("ProfileRepository", "Profile created successfully")
                Result.success(profiles.firstOrNull())
            } else {
                val errorBody = response.errorBody()?.string()
                android.util.Log.e("ProfileRepository", "Failed to create profile: ${response.code()}, body: $errorBody")
                // If profile already exists, try to get it
                if (response.code() == 409 || errorBody?.contains("duplicate") == true) {
                    android.util.Log.d("ProfileRepository", "Profile already exists, fetching it...")
                    return getProfile(userId, token)
                }
                Result.failure(Exception("Failed to create profile: ${response.code()}: $errorBody"))
            }
        } catch (e: Exception) {
            android.util.Log.e("ProfileRepository", "Exception while creating profile", e)
            Result.failure(e)
        }
    }
}
