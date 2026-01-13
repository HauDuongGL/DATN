package com.example.floweridentifier.utils

import android.content.Context
import android.content.SharedPreferences

object PreferenceHelper {
    private const val PREF_NAME = "flower_auth_pref"
    private const val KEY_ACCESS_TOKEN = "access_token"
    private const val KEY_USER_EMAIL = "user_email"
    private const val KEY_USER_ID = "user_id"
    private const val KEY_FCM_TOKEN = "fcm_token"

    private fun getPreferences(context: Context): SharedPreferences {
        return context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
    }

    fun saveAuthToken(context: Context, token: String, email: String, userId: String) {
        getPreferences(context).edit().apply {
            putString(KEY_ACCESS_TOKEN, token)
            putString(KEY_USER_EMAIL, email)
            putString(KEY_USER_ID, userId)
            apply()
        }
    }

    fun getToken(context: Context): String? {
        return getPreferences(context).getString(KEY_ACCESS_TOKEN, null)
    }

    fun getUserId(context: Context): String? {
        return getPreferences(context).getString(KEY_USER_ID, null)
    }

    fun saveFcmToken(context: Context, token: String) {
        getPreferences(context).edit().apply {
            putString(KEY_FCM_TOKEN, token)
            apply()
        }
    }

    fun getFcmToken(context: Context): String? {
        return getPreferences(context).getString(KEY_FCM_TOKEN, null)
    }

    fun clear(context: Context) {
        getPreferences(context).edit().clear().apply()
    }

    fun isLoggedIn(context: Context): Boolean {
        return getToken(context) != null
    }
    
    fun getEmail(context: Context): String? {
        return getPreferences(context).getString(KEY_USER_EMAIL, null)
    }
}
