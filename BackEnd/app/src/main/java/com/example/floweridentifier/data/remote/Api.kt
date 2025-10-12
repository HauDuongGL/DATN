package com.example.floweridentifier.data.remote

import com.example.floweridentifier.data.model.response.FlowerResponse
import com.example.floweridentifier.data.model.response.RecognitionResponse
import okhttp3.MultipartBody
import retrofit2.http.GET
import retrofit2.http.Multipart
import retrofit2.http.POST
import retrofit2.http.Part
import retrofit2.http.Path

interface Api {
    @Multipart
    @POST("/recognition")
    suspend fun recognizeFlower(@Part image: MultipartBody.Part): RecognitionResponse

    @GET("/description/{nameFlower}")
    suspend fun descriptionFlower(@Path("nameFlower") nameFlower: String): FlowerResponse
}