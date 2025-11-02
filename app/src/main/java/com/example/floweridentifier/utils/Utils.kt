package com.example.floweridentifier.utils

import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

object Utils {
    private const val TYPE_TIME_HH_MM = "HH:mm"
    private const val TYPE_TIME_YY_MM_DD_HH_MM_SS = "yyyy-MM-dd'T'HH:mm:ss"

    fun dateFormatToTimeHour(timestamp: Long): String {
        val netDate = Date(timestamp)
        val sdf = SimpleDateFormat(TYPE_TIME_YY_MM_DD_HH_MM_SS, Locale.getDefault())
        val str = sdf.format(netDate)

        try {
            val simpleDateFormat =
                SimpleDateFormat(TYPE_TIME_YY_MM_DD_HH_MM_SS, Locale.getDefault())
            var date = simpleDateFormat.parse(str)
            try {
                val instance = Calendar.getInstance()
                if (date != null) {
                    instance.time = date
                    date = instance.time
                    val simpleDateFormatHhMM =
                        SimpleDateFormat(TYPE_TIME_HH_MM, Locale.getDefault())
                    return simpleDateFormatHhMM.format(date!!)
                }
                return ""
            } catch (e: java.lang.Exception) {
                return ""
            }
        } catch (e2: java.lang.Exception) {
            return ""
        }
    }
}