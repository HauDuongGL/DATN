package com.example.floweridentifier.data.repository.remote

import com.example.floweridentifier.data.model.Message
import com.example.floweridentifier.data.model.response.FlowerResponse
import com.example.floweridentifier.data.model.response.RecognitionResponse
import okhttp3.MultipartBody
import retrofit2.http.Body

interface RemoteRepo {
    suspend fun recognizeFlower(image: MultipartBody.Part): RecognitionResponse

    suspend fun descriptionFlower(@Body nameFlower: String): FlowerResponse

    suspend fun generateAnswerMessage(messagesHistory: List<Message>): Message?
}