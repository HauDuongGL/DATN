package overlay

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.graphics.Color
import android.os.Build

object OverlayNotification {
    const val CHANNEL_ID = "chat_head_overlay"
    private const val CHANNEL_NAME = "Chat Head Overlay"

    fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (nm.getNotificationChannel(CHANNEL_ID) == null) {
                val ch = NotificationChannel(CHANNEL_ID, CHANNEL_NAME, NotificationManager.IMPORTANCE_MIN)
                ch.enableLights(false)
                ch.enableVibration(false)
                ch.lightColor = Color.BLUE
                ch.lockscreenVisibility = Notification.VISIBILITY_PRIVATE
                nm.createNotificationChannel(ch)
            }
        }
    }

    fun build(context: Context): Notification {
        ensureChannel(context)
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_ID)
        } else {
            Notification.Builder(context)
        }
        return builder
            .setContentTitle("Chat head is running")
            .setContentText("Tap bubble to open chat")
            .setSmallIcon(android.R.drawable.stat_notify_chat)
            .setOngoing(true)
            .build()
    }
}
