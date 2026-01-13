package com.example.floweridentifier.ui.recognition

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.example.floweridentifier.data.model.response.Result
import com.example.floweridentifier.data.repository.Repository
import com.example.floweridentifier.ui.base.BaseViewModel
import com.example.floweridentifier.utils.ResponseState
import com.google.firebase.storage.FirebaseStorage
import com.google.firebase.storage.StorageReference
import kotlinx.coroutines.launch
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.asRequestBody
import java.io.File

class RecognitionVM(private val repository: Repository, application: Application) :
    BaseViewModel(application) {

    val resultRecognition = MutableLiveData<ResponseState<List<Result>>>()

    fun recognizeFlower(imageFile: File, area: String) {
        viewModelScope.launch {
            resultRecognition.postValue(ResponseState.Loading)
            try {
                android.util.Log.d("RecognitionVM", "Starting recognition for file: ${imageFile.absolutePath}")
                
                if (!imageFile.exists()) {
                    android.util.Log.e("RecognitionVM", "File does not exist: ${imageFile.absolutePath}")
                    resultRecognition.postValue(ResponseState.Error("File does not exist"))
                    return@launch
                }
                
                var filePath = imageFile.name
                val splitFileName =
                    filePath.split("\\.".toRegex()).dropLastWhile { it.isEmpty() }.toTypedArray()
                filePath =
                    splitFileName[0] + "_" + System.currentTimeMillis() + "." + splitFileName[1]

                android.util.Log.d("RecognitionVM", "Sending request with filename: $filePath")
                
                val requestFile = imageFile.asRequestBody("image/jpeg".toMediaTypeOrNull())
                val body = MultipartBody.Part.createFormData("file", filePath, requestFile)
                
                android.util.Log.d("RecognitionVM", "File size: ${imageFile.length()} bytes")
                
                val result = repository.recognizeFlower(body)
                
                android.util.Log.d("RecognitionVM", "Response received - status: ${result.status}, results count: ${result.results.size}")
                
                if (result.status == "success") {
                    android.util.Log.d("RecognitionVM", "Recognition successful: ${result.results.map { it.nameFlower }}")
                    resultRecognition.postValue(
                        ResponseState.Success(
                            result.results,
                            result.message
                        )
                    )
                } else {
                    android.util.Log.e("RecognitionVM", "Recognition failed: ${result.message}")
                    resultRecognition.postValue(ResponseState.Error(result.message))
                }
            } catch (ex: Exception) {
                android.util.Log.e("RecognitionVM", "Exception during recognition", ex)
                resultRecognition.postValue(ResponseState.Error(ex.message ?: "Unknown error: ${ex.javaClass.simpleName}"))
            }
        }
    }

//    fun getSimilarImage(nameFlower: String, callback: (String) -> Unit) {
//        FirebaseStorage.getInstance().reference.child(nameFlower).listAll()
//            .addOnSuccessListener { listResult ->
//                mutableListOf<StorageReference>().apply {
//                     listResult.items.forEach {
//                        if (it.name.endsWith(".jpg")) {
//                            add(it)
//                        }
//                    }
//                    shuffle()
//                }[0].downloadUrl.addOnSuccessListener {
//                    callback.invoke(it.toString())
//                }.addOnFailureListener {
//                    callback.invoke("Error")
//                }
//            }.addOnFailureListener {
//                callback.invoke("Error")
//            }
//    }
}