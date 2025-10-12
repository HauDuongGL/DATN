package com.example.floweridentifier.di

import androidx.room.Room
import com.example.floweridentifier.BuildConfig
import com.example.floweridentifier.data.database.AppDatabase
import com.example.floweridentifier.data.remote.Api
import com.example.floweridentifier.data.repository.Repository
import com.example.floweridentifier.data.repository.local.LocalImpl
import com.example.floweridentifier.data.repository.openai.OpenAiData
import com.example.floweridentifier.data.repository.remote.RemoteImpl
import com.example.floweridentifier.ui.chatbot.ChatViewModel
import com.example.floweridentifier.ui.descflower.FlowerVM
import com.example.floweridentifier.ui.main.home.HomeVM
import com.example.floweridentifier.ui.main.myplants.MyPlantVM
import com.example.floweridentifier.ui.recognition.RecognitionVM
import com.example.floweridentifier.ui.search.SearchVM
import com.example.floweridentifier.utils.Constants
import com.google.gson.GsonBuilder
import okhttp3.Cache
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import org.koin.android.ext.koin.androidApplication
import org.koin.android.ext.koin.androidContext
import org.koin.androidx.viewmodel.dsl.viewModel
import org.koin.dsl.module
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit

private const val TIME_OUT = 100_000L
private const val cacheSize = (5 * 1024 * 1024).toLong()

val networkModule = module {
    single {
        val logging = HttpLoggingInterceptor().apply {
            level =
                if (BuildConfig.DEBUG) HttpLoggingInterceptor.Level.BODY else HttpLoggingInterceptor.Level.NONE
        }

        val okHttpClient = OkHttpClient.Builder()
            .cache(Cache(androidContext().cacheDir, cacheSize))
            .addInterceptor(logging)
            .connectTimeout(TIME_OUT, TimeUnit.MILLISECONDS)
            .writeTimeout(TIME_OUT, TimeUnit.MILLISECONDS)
            .readTimeout(TIME_OUT, TimeUnit.MILLISECONDS)
            .build()

        Retrofit.Builder()
            .baseUrl(Constants.BASE_URL)
            .client(okHttpClient)
            .addConverterFactory(GsonConverterFactory.create(GsonBuilder().create()))
            .build()
            .create(Api::class.java)
    }
}

val roomModule = module {
    single {
        Room.databaseBuilder(
            androidApplication(),
            AppDatabase::class.java,
            Constants.DATABASE_NAME
        ).allowMainThreadQueries().fallbackToDestructiveMigration().build()
    }
}

val repositoryModule = module {
    single { RemoteImpl(get()) }
    single { LocalImpl(get()) }
    single { OpenAiData() }
    single { Repository(get(), get(), get()) }
}


val viewModelModule = module {
    viewModel { FlowerVM(get(), androidApplication()) }
    viewModel { HomeVM(get(), androidApplication()) }
    viewModel { MyPlantVM(get(), androidApplication()) }
    viewModel { RecognitionVM(get(), androidApplication()) }
    viewModel { ChatViewModel(get(), androidApplication()) }
    viewModel { SearchVM(get(), androidApplication()) }
}
