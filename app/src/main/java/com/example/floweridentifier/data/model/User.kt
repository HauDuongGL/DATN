package com.example.floweridentifier.data.model

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class User(
    var name: String,
    var isCurrentUser: Boolean,
    var avatar: Int
) : Parcelable