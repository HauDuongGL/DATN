package com.example.floweridentifier.data.database

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.example.floweridentifier.data.model.Message

@Dao
interface MessageDao {
    @Query("SELECT * FROM Message ORDER BY created DESC LIMIT 20 OFFSET :offset")
    suspend fun getMessage(offset: Int): List<Message>

    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun addMessage(message: Message)

    @Query("DELETE FROM Message")
    suspend fun deleteAllMessage()
}