package com.example.floweridentifier.ui.recognition

import android.app.Application
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.example.floweridentifier.data.model.response.Result
import com.example.floweridentifier.data.repository.Repository
import com.example.floweridentifier.ui.base.BaseViewModel
import com.example.floweridentifier.utils.ResponseState
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
                var filePath = imageFile.name
                val splitFileName =
                    filePath.split("\\.".toRegex()).dropLastWhile { it.isEmpty() }.toTypedArray()
                filePath =
                    splitFileName[0] + "_" + System.currentTimeMillis() + "." + splitFileName[1]

                val result = repository.recognizeFlower(
                    MultipartBody.Part.createFormData(
                        "file",
                        filePath,
                        imageFile.asRequestBody("image/*".toMediaTypeOrNull())
                    )
                )
                if (result.status == "success")
                    resultRecognition.postValue(
                        ResponseState.Success(
                            result.results,
                            result.message
                        )
                    )
                else
                    resultRecognition.postValue(ResponseState.Error(result.message))
            } catch (ex: Exception) {
                resultRecognition.postValue(ex.message?.let { ResponseState.Error(it) })
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
