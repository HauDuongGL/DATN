package com.example.floweridentifier.data.database

import androidx.room.Database
import androidx.room.RoomDatabase
import com.example.floweridentifier.data.model.Flower
import com.example.floweridentifier.data.model.Message

@Database(
    entities = [Flower::class, Message::class],
    version = 1,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun flowerDao(): FlowerDao
    abstract fun messageDao(): MessageDao
}
