package com.example.floweridentifier.data.repository

import com.example.floweridentifier.data.remote.SupabaseApi
import com.example.floweridentifier.utils.Constants
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.asRequestBody
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.io.File

class StorageRepository {
    private val api: SupabaseApi

    init {
        val retrofit = Retrofit.Builder()
            .baseUrl(Constants.SUPABASE_URL)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
        api = retrofit.create(SupabaseApi::class.java)
    }

    suspend fun uploadImage(file: File, userId: String, accessToken: String): Result<String> {
        return try {
            // Sanitize filename to avoid URL encoding issues
            val safeName = file.name.replace("[^a-zA-Z0-9.-]".toRegex(), "_")
            val fileName = "${System.currentTimeMillis()}_${safeName}"
            val path = if (userId.isNotEmpty()) "$userId/$fileName" else fileName
            
            val requestFile = file.asRequestBody("image/*".toMediaTypeOrNull())
            
            val response = api.uploadImage(path, "Bearer $accessToken", Constants.SUPABASE_KEY, requestFile)
            
            if (response.isSuccessful) {
                // Construct public URL
                val publicUrl = "${Constants.SUPABASE_URL}/storage/v1/object/public/post-images/$path"
                Result.success(publicUrl)
            } else {
                val errorBody = response.errorBody()?.string() ?: "Unknown error"
                Result.failure(Exception("Upload failed: ${response.code()} $errorBody"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
