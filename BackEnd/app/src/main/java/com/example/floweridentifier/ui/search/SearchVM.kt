package com.example.floweridentifier.ui.search

import android.app.Application
import androidx.lifecycle.MutableLiveData
import com.example.floweridentifier.data.model.response.Result
import com.example.floweridentifier.data.repository.Repository
import com.example.floweridentifier.ui.base.BaseViewModel
import com.example.floweridentifier.utils.ResponseState

class SearchVM(private val repository: Repository, application: Application) :
    BaseViewModel(application) {
    val resultSearch = MutableLiveData<ResponseState<List<Result>>>()

    fun searchFlower(name: String) {

    }
}