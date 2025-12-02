package com.example.floweridentifier.ui.descflower

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.example.floweridentifier.data.model.Flower
import com.example.floweridentifier.data.repository.Repository
import com.example.floweridentifier.ui.base.BaseViewModel
import com.example.floweridentifier.utils.ImageStorageHelper
import com.example.floweridentifier.utils.ResponseState
import kotlinx.coroutines.launch

class FlowerVM(private val repository: Repository, application: Application) :
    BaseViewModel(application) {
    val flowerResponseState = MutableLiveData<ResponseState<Flower>>()
    val someImagesResponseState = MutableLiveData<ResponseState<MutableList<String>>>()

    fun descriptionFlower(nameFlower: String) {
        viewModelScope.launch {
            flowerResponseState.postValue(ResponseState.Loading)
            try {
                val result = repository.descriptionFlower(nameFlower)
                if (result.status == "success") {
                    flowerResponseState.postValue(
                        ResponseState.Success(
                            result.flower,
                            result.message
                        )
                    )
                } else
                    flowerResponseState.postValue(ResponseState.Error(result.message))
            } catch (ex: Exception) {
                flowerResponseState.postValue(ex.message?.let { ResponseState.Error(it) })
            }
        }
    }

    fun getSomeImages(nameFlower: String, amount: Int) {
        viewModelScope.launch {
            someImagesResponseState.postValue(ResponseState.Loading)
            try {
                // Lấy hình ảnh từ database
                var images = repository.getFlowerImagesWithLimit(nameFlower, amount)

                // Nếu database chưa có hình ảnh, khởi tạo từ assets
                if (images.isEmpty()) {
                    val initializedImages = ImageStorageHelper.initializeFlowerImages(
                        getApplication(),
                        nameFlower
                    )
                    
                    if (initializedImages.isNotEmpty()) {
                        // Lưu vào database
                        repository.insertFlowerImages(initializedImages)
                        // Lấy lại với limit
                        images = repository.getFlowerImagesWithLimit(nameFlower, amount)
                    }
                }

                // Lọc ra các hình ảnh tồn tại và shuffle
                val existingImages = images
                    .filter { ImageStorageHelper.imageExists(it.imageUrl) }
                    .shuffled()
                    .take(amount)

                if (existingImages.isNotEmpty()) {
                    val imagePaths = existingImages.map { it.imageUrl }.toMutableList()
                    someImagesResponseState.postValue(ResponseState.Success(imagePaths, ""))
                } else {
                    someImagesResponseState.postValue(
                        ResponseState.Error("No images found for $nameFlower. Please add images to assets/flowers/$nameFlower/")
                    )
                }
            } catch (ex: Exception) {
                someImagesResponseState.postValue(
                    ResponseState.Error("Failed to load images: ${ex.message}")
                )
            }
        }
    }

    fun insertFlower(flower: Flower) = viewModelScope.launch {
        repository.insert(flower)
    }

    fun getDescFlower(name: String) = repository.getDescFlower(name)
}