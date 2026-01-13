package com.example.floweridentifier

import android.app.Application
import com.example.floweridentifier.BuildConfig
import com.example.floweridentifier.di.networkModule
import com.example.floweridentifier.di.repositoryModule
import com.example.floweridentifier.di.roomModule
import com.example.floweridentifier.di.viewModelModule
import org.koin.android.ext.koin.androidContext
import org.koin.android.ext.koin.androidLogger
import org.koin.core.context.startKoin
import org.koin.core.logger.Level

class Application : Application() {

    override fun onCreate() {
        super.onCreate()
        startKoin {
            androidLogger(if (BuildConfig.DEBUG) Level.ERROR else Level.NONE)
            androidContext(this@Application)
            modules(
                listOf(
                    networkModule,
                    roomModule,
                    repositoryModule,
                    viewModelModule,
                )
            )
        }
    }
}