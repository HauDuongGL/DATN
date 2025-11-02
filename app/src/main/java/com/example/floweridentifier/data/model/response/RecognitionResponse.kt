package com.example.floweridentifier.data.model.response

import com.google.gson.annotations.SerializedName

data class RecognitionResponse(
    val status: String,
    val message: String,
    val results: List<Result>
)

data class Result(
    @SerializedName("name_flower") val nameFlower: String,
    @SerializedName("areas") val areas: List<String>,
    @SerializedName("match_rate") val matchRate: Int,
    var imageUri: String? = "",
    var inArea: Boolean = false
)