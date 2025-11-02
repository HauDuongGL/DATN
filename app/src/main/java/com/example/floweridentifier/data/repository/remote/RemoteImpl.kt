package com.example.floweridentifier.data.repository.remote

import com.example.floweridentifier.data.model.Message
import com.example.floweridentifier.data.remote.Api
import okhttp3.MultipartBody

class RemoteImpl(private val api: Api) : RemoteRepo {
    override suspend fun recognizeFlower(image: MultipartBody.Part) = api.recognizeFlower(image)

    override suspend fun descriptionFlower(nameFlower: String) = api.descriptionFlower(nameFlower)
    override suspend fun generateAnswerMessage(messagesHistory: List<Message>) = null
}