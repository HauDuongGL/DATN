package com.example.floweridentifier.fcm

import android.content.Context
import com.example.floweridentifier.data.remote.SupabaseApi
import com.example.floweridentifier.utils.Constants
import com.example.floweridentifier.utils.PreferenceHelper
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

object SupabaseTokenUpdater {

    private val api: SupabaseApi by lazy {
        val client = OkHttpClient.Builder().build()
        val retrofit = Retrofit.Builder()
            .baseUrl(Constants.SUPABASE_URL)
            .client(client)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
        retrofit.create(SupabaseApi::class.java)
    }

    suspend fun updateFcmToken(context: Context, fcmToken: String) {
        val accessToken = PreferenceHelper.getToken(context) ?: return
        val userId = PreferenceHelper.getUserId(context) ?: return

        api.updateProfileFcmToken(
            token = "Bearer $accessToken",
            apiKey = Constants.SUPABASE_KEY,
            idFilter = "eq.$userId",
            body = mapOf("fcm_token" to fcmToken)
        )
    }
}

