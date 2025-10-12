package com.example.floweridentifier.data.repository.local

import com.example.floweridentifier.data.database.AppDatabase
import com.example.floweridentifier.data.model.Flower
import com.example.floweridentifier.data.model.Message

class LocalImpl(private val appDB: AppDatabase) : LocalRepo {
    override fun getFlowers() = appDB.flowerDao().getFlowers()
    override fun getMyFlowers() = appDB.flowerDao().getMyFlowers()
    override fun getDescFlower(addedAt: Long) = appDB.flowerDao().getDescFlower(addedAt)
    override fun getDescFlower(name: String) = appDB.flowerDao().getDescFlower(name)

    override suspend fun insert(flower: Flower) = appDB.flowerDao().insert(flower)

    override suspend fun delete(flower: Flower) = appDB.flowerDao().delete(flower)
    override suspend fun getMessage(offset: Int) = appDB.messageDao().getMessage(offset)

    override suspend fun addMessage(message: Message) = appDB.messageDao().addMessage(message)

    override suspend fun deleteAllMessage() = appDB.messageDao().deleteAllMessage()
}