package com.example.floweridentifier.data.database

import androidx.lifecycle.LiveData
import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.example.floweridentifier.data.model.Flower

@Dao
interface FlowerDao {
    @Query("SELECT * FROM flower")
    fun getFlowers(): LiveData<MutableList<Flower>>

    @Query("SELECT * FROM flower WHERE save = 1")
    fun getMyFlowers(): LiveData<MutableList<Flower>>

    @Query("SELECT * FROM flower WHERE addedAt = :addedAt")
    fun getDescFlower(addedAt: Long): Flower

    @Query("SELECT * FROM flower WHERE name = :name")
    fun getDescFlower(name: String): Flower?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(flower: Flower)

    @Delete
    suspend fun delete(flower: Flower)
}