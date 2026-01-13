package com.example.floweridentifier.data.repository

import com.example.floweridentifier.data.remote.AuthResponse
import com.example.floweridentifier.data.remote.SupabaseApi
import com.example.floweridentifier.utils.Constants
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

class AuthRepository {
    private val api: SupabaseApi

    init {
        val retrofit = Retrofit.Builder()
            .baseUrl(Constants.SUPABASE_URL)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
        api = retrofit.create(SupabaseApi::class.java)
    }

    suspend fun signUp(email: String, pass: String): Result<AuthResponse> {
        return try {
            val json = JSONObject().apply {
                put("email", email)
                put("password", pass)
            }
            val body = json.toString().toRequestBody("application/json".toMediaTypeOrNull())
            val response = api.signUp(body, Constants.SUPABASE_KEY)
            if (response.isSuccessful && response.body() != null) {
                Result.success(response.body()!!)
            } else {
                Result.failure(Exception(response.errorBody()?.string() ?: "Sign up failed"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun signIn(email: String, pass: String): Result<AuthResponse> {
        return try {
            val json = JSONObject().apply {
                put("email", email)
                put("password", pass)
            }
            val body = json.toString().toRequestBody("application/json".toMediaTypeOrNull())
            val response = api.signIn(body, Constants.SUPABASE_KEY)
            if (response.isSuccessful && response.body() != null) {
                Result.success(response.body()!!)
            } else {
                Result.failure(Exception(response.errorBody()?.string() ?: "Sign in failed"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
