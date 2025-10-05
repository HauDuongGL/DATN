package utils

import android.content.Context
import android.content.SharedPreferences

class Prefs(ctx: Context) {
    private val p: SharedPreferences =
        ctx.getSharedPreferences("overlay_prefs", Context.MODE_PRIVATE)

    fun savePos(x: Int, y: Int) = p.edit().putInt("x", x).putInt("y", y).apply()
    fun getX(default: Int = 0) = p.getInt("x", default)
    fun getY(default: Int = 200) = p.getInt("y", default)

    fun setEnabled(enabled: Boolean) = p.edit().putBoolean("enabled", enabled).apply()
    fun isEnabled() = p.getBoolean("enabled", false)

    fun saveX(x: Int) = p.edit().putInt("x", x).apply()
    fun saveY(y: Int) = p.edit().putInt("y", y).apply()
}