package com.example.floweridentifier.data.model

import android.os.Parcelable
import androidx.room.Entity
import androidx.room.PrimaryKey
import kotlinx.parcelize.Parcelize

@Parcelize
@Entity(tableName = "Flower")
data class Flower(
    var name: String,
    val desc: String,
    val species: String,
    val care: String,
    var save: Boolean = false,
    @PrimaryKey var addedAt: Long? = null,
    var imageRecognition: String? = null
) : Parcelable {
    constructor(name: String, desc: String, species: String, care: String) : this(
        name, desc, species, care, false, null, null
    )
}