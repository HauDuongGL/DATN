package com.example.floweridentifier.data.repository

import com.example.floweridentifier.data.model.Flower
import com.example.floweridentifier.data.model.FlowerImage
import com.example.floweridentifier.data.model.Message
import com.example.floweridentifier.data.repository.local.LocalImpl
import com.example.floweridentifier.data.repository.local.LocalRepo
import com.example.floweridentifier.data.repository.openai.OpenAiData
import com.example.floweridentifier.data.repository.remote.RemoteImpl
import com.example.floweridentifier.data.repository.remote.RemoteRepo
import okhttp3.MultipartBody

class Repository(
    private val remoteRepo: RemoteImpl,
    private val localRepo: LocalImpl,
    private val openAiData: OpenAiData
) : RemoteRepo,
    LocalRepo {
    override suspend fun recognizeFlower(image: MultipartBody.Part) =
        remoteRepo.recognizeFlower(image)

    override suspend fun descriptionFlower(nameFlower: String) =
        remoteRepo.descriptionFlower(nameFlower)

    override suspend fun generateAnswerMessage(messagesHistory: List<Message>) =
        openAiData.generateAnswerMessage(messagesHistory)

    override fun getFlowers() = localRepo.getFlowers()
    override fun getMyFlowers() = localRepo.getMyFlowers()
    override fun getDescFlower(addedAt: Long) = localRepo.getDescFlower(addedAt)
    override fun getDescFlower(name: String) = localRepo.getDescFlower(name)

    override suspend fun insert(flower: Flower) = localRepo.insert(flower)

    override suspend fun delete(flower: Flower) = localRepo.delete(flower)
    override suspend fun getMessage(offset: Int) = localRepo.getMessage(offset)

    override suspend fun addMessage(message: Message) = localRepo.addMessage(message)

    override suspend fun deleteAllMessage() = localRepo.deleteAllMessage()

    // FlowerImage operations
    override suspend fun insertFlowerImage(flowerImage: FlowerImage) =
        localRepo.insertFlowerImage(flowerImage)

    override suspend fun insertFlowerImages(images: List<FlowerImage>) =
        localRepo.insertFlowerImages(images)

    override suspend fun getFlowerImages(flowerName: String): List<FlowerImage> =
        localRepo.getFlowerImages(flowerName)

    override suspend fun getFlowerImagesWithLimit(flowerName: String, limit: Int): List<FlowerImage> =
        localRepo.getFlowerImagesWithLimit(flowerName, limit)

    override suspend fun deleteFlowerImagesByName(flowerName: String) =
        localRepo.deleteFlowerImagesByName(flowerName)
}