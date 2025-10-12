package com.example.floweridentifier.data.model

import android.os.Parcelable
import androidx.room.Embedded
import androidx.room.Entity
import androidx.room.PrimaryKey
import kotlinx.parcelize.Parcelize

@Entity(tableName = "Message")
@Parcelize
data class Message(
    @Embedded
    val user: User,
    var content: String,
    var created: Long,
    @PrimaryKey
    val id: String
) : Parcelable
