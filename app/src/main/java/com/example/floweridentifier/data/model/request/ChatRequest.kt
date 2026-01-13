package com.example.floweridentifier.data.model.request

import com.google.gson.annotations.SerializedName

data class ChatRequest(
    @SerializedName("messages")
    val messages: List<ChatMessage>,
    @SerializedName("model")
    val model: String = "llama-3.3-70b-versatile"
)

data class ChatMessage(
    @SerializedName("role")
    val role: String,
    @SerializedName("content")
    val content: String
)
