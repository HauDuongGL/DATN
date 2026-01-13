package com.example.floweridentifier.data.database

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.example.floweridentifier.data.model.FlowerImage

@Dao
interface FlowerImageDao {
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(flowerImage: FlowerImage)
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(images: List<FlowerImage>)
    
    @Query("SELECT * FROM FlowerImage WHERE flowerName = :flowerName")
    suspend fun getImagesByFlowerName(flowerName: String): List<FlowerImage>
    
    @Query("SELECT * FROM FlowerImage WHERE flowerName = :flowerName LIMIT :limitCount")
    suspend fun getImagesByFlowerNameWithLimit(flowerName: String, limitCount: Int): List<FlowerImage>
    
    @Query("DELETE FROM FlowerImage WHERE flowerName = :flowerName")
    suspend fun deleteByFlowerName(flowerName: String)
    
    @Query("DELETE FROM FlowerImage")
    suspend fun deleteAll()
}
