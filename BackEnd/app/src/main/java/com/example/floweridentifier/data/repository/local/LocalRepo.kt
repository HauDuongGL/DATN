package com.example.floweridentifier.data.repository.local

import androidx.lifecycle.LiveData
import com.example.floweridentifier.data.model.Flower
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
}