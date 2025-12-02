package com.example.floweridentifier.data.model

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "FlowerImage")
data class FlowerImage(
    @PrimaryKey(autoGenerate = true)
    val id: Int = 0,
    val flowerName: String,  // Tên loài hoa
    val imageUrl: String     // URL hoặc path của hình ảnh
)
