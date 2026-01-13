package com.example.floweridentifier.data.repository.remote

import com.example.floweridentifier.data.model.Message
import com.example.floweridentifier.data.remote.Api
import okhttp3.MultipartBody

class RemoteImpl(private val api: Api) : RemoteRepo {
    override suspend fun recognizeFlower(image: MultipartBody.Part) = api.recognizeFlower(image)

    override suspend fun descriptionFlower(nameFlower: String) = api.descriptionFlower(nameFlower)
    override suspend fun generateAnswerMessage(messagesHistory: List<Message>): Message? {
        return try {
            val chatMessages = messagesHistory.filter { it.content.isNotEmpty() }.map {
                com.example.floweridentifier.data.model.request.ChatMessage(
                    role = if (it.user.isCurrentUser) "user" else "assistant",
                    content = it.content
                )
            }
            val request = com.example.floweridentifier.data.model.request.ChatRequest(messages = chatMessages)
            val response = api.chat(request)
            
            if (response.status == "success" && response.reply != null) {
                Message(
                    user = com.example.floweridentifier.utils.NetworkConfig.botUser,
                    content = response.reply,
                    created = System.currentTimeMillis(),
                    id = System.currentTimeMillis().toString()
                )
            } else {
                null
            }
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
}