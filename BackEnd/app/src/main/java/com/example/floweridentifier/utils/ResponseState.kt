package com.example.floweridentifier.utils

sealed class ResponseState<out T> {
    data class Initial<T>(val initialItem: T) : ResponseState<T>()
    object Loading : ResponseState<Nothing>()
    data class Error(val mess: String) : ResponseState<Nothing>()
    data class Success<T>(val item: T, val mess: String) : ResponseState<T>()
}