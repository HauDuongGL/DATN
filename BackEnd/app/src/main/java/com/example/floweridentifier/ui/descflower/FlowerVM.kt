package com.example.floweridentifier.ui.descflower

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.example.floweridentifier.data.model.Flower
import com.example.floweridentifier.data.repository.Repository
import com.example.floweridentifier.ui.base.BaseViewModel
import com.example.floweridentifier.utils.ResponseState
import com.google.firebase.storage.FirebaseStorage
import com.google.firebase.storage.StorageReference
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
            val someImages = mutableListOf<String>()

            val storageRef = FirebaseStorage.getInstance().reference.child(nameFlower)
            // List all the files in the folder
            storageRef.listAll().addOnSuccessListener { listResult ->
                val images = mutableListOf<StorageReference>()
                listResult.items.forEach {
                    if (it.name.endsWith(".jpg")) {
                        images.add(it)
                    }
                }
                images.shuffle()

                val selectedImages = images.take(amount)

                selectedImages.forEach {
                    it.downloadUrl.addOnSuccessListener { uri ->
                        someImages.add(uri.toString())
                        someImagesResponseState.postValue(ResponseState.Success(someImages, ""))
                    }.addOnFailureListener {
                        someImagesResponseState.postValue(ResponseState.Error("Error"))
                    }
                }

            }.addOnFailureListener {
                someImagesResponseState.postValue(ResponseState.Error("Error"))
            }
        }
    }

    fun insertFlower(flower: Flower) = viewModelScope.launch {
        repository.insert(flower)
    }

    fun getDescFlower(name: String) = repository.getDescFlower(name)
}