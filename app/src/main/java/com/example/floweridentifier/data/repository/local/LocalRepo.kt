package com.example.floweridentifier.data.repository.local

import androidx.lifecycle.LiveData
import com.example.floweridentifier.data.model.Flower
import com.example.floweridentifier.data.model.FlowerImage
import com.example.floweridentifier.data.model.Message

interface LocalRepo {
    fun getFlowers(): LiveData<MutableList<Flower>>

    fun getMyFlowers(): LiveData<MutableList<Flower>>
    fun getDescFlower(addedAt: Long): Flower

    fun getDescFlower(name: String): Flower?

    suspend fun insert(flower: Flower)

    suspend fun delete(flower: Flower)

    suspend fun getMessage(offset: Int): List<Message>

    suspend fun addMessage(message: Message)

    suspend fun deleteAllMessage()

    // FlowerImage operations
    suspend fun insertFlowerImage(flowerImage: FlowerImage)

    suspend fun insertFlowerImages(images: List<FlowerImage>)

    suspend fun getFlowerImages(flowerName: String): List<FlowerImage>

    suspend fun getFlowerImagesWithLimit(flowerName: String, limit: Int): List<FlowerImage>

    suspend fun deleteFlowerImagesByName(flowerName: String)
}