package com.example.floweridentifier.data.database

import androidx.room.Database
import androidx.room.RoomDatabase
import com.example.floweridentifier.data.model.Flower
import com.example.floweridentifier.data.model.FlowerImage
import com.example.floweridentifier.data.model.Message

@Database(
    entities = [Flower::class, Message::class, FlowerImage::class],
    version = 2,  // Increased version for migration
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun flowerDao(): FlowerDao
    abstract fun messageDao(): MessageDao
    abstract fun flowerImageDao(): FlowerImageDao
}
