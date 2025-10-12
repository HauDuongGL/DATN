package com.example.floweridentifier.ui.main.myplants

import android.app.Application
import com.example.floweridentifier.data.repository.Repository
import com.example.floweridentifier.ui.base.BaseViewModel

class MyPlantVM(private val repo: Repository, application: Application) :
    BaseViewModel(application) {

    val myFlowers = repo.getMyFlowers()
}