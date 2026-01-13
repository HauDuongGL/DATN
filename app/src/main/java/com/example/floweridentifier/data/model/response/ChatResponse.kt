package com.example.floweridentifier.data.model.response

import com.google.gson.annotations.SerializedName

data class ChatResponse(
    @SerializedName("status")
    val status: String,
    @SerializedName("message")
    val message: String,
    @SerializedName("reply")
    val reply: String?
)
