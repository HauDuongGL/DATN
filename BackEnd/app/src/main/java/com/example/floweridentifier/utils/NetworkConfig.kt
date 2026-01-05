package com.example.floweridentifier.utils

import com.example.floweridentifier.data.model.User

object NetworkConfig {
    const val BASE_URL = "https://mozell-conservant-deceivably.ngrok-free.dev/"

    // Default chat gpt3 api key, update when open app
    var OPEN_API_KEY = "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"

    // Mock data for chat gpt
    val botUser = User("Bot", false, 0)
    val felixUser = User("Felix", true, 0)
}