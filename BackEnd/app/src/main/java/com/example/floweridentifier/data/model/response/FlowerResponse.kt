package com.example.floweridentifier.data.model.response

import android.os.Parcelable
import com.example.floweridentifier.data.model.Flower
import com.google.gson.annotations.SerializedName
import kotlinx.android.parcel.Parcelize

@Parcelize
data class FlowerResponse(
    val status: String,
    val message: String,
    val flower: Flower,
    @SerializedName("match_rate") val matchRate: Float,
) : Parcelable