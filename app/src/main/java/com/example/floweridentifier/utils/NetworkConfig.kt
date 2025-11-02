package com.example.floweridentifier.utils

import com.example.floweridentifier.data.model.User

object NetworkConfig {
    const val BASE_URL = "https://config.phucanhthanh.com/api/v1/"

    var OPEN_API_KEY = ""

    // Mock data for chat gpt
    val botUser = User("Bot", false, 0)
    val felixUser = User("Felix", true, 0)
}
