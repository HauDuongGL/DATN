package com.example.floweridentifier.ui.main.home

import android.app.Application
import com.example.floweridentifier.data.repository.Repository
import com.example.floweridentifier.ui.base.BaseViewModel

class HomeVM(private val repo: Repository, application: Application) : BaseViewModel(application) {
    val flowersRecent = repo.getFlowers()

}