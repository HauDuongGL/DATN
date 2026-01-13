package com.example.floweridentifier.data.repository.remote

import android.util.Log
import com.example.floweridentifier.data.model.Message
import com.example.floweridentifier.data.remote.Api
import okhttp3.MultipartBody

class RemoteImpl(private val api: Api) : RemoteRepo {
    override suspend fun recognizeFlower(image: MultipartBody.Part): com.example.floweridentifier.data.model.response.RecognitionResponse {
        Log.d("RemoteImpl", "recognizeFlower called, sending request to API")
        return try {
            val result = api.recognizeFlower(image)
            Log.d("RemoteImpl", "API call successful - status: ${result.status}, results: ${result.results.size}")
            result
        } catch (e: Exception) {
            Log.e("RemoteImpl", "API call failed", e)
            throw e
        }
    }

    override suspend fun descriptionFlower(nameFlower: String) = api.descriptionFlower(nameFlower)
    override suspend fun generateAnswerMessage(messagesHistory: List<Message>) = null
}