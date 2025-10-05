// app/src/main/java/overlay/StatusBubbleService.kt
package overlay

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.view.WindowManager
import androidx.core.app.NotificationCompat
import com.example.verify_clone.R

class StatusBubbleService : Service() {

    private val CHANNEL_ID = "overlay_chathead"
    private val NOTI_ID = 1002

    private lateinit var wm: WindowManager
    private var window: OverlayWindow? = null
    private var trash: TrashOverlay? = null
    private var trashVisible = false

    override fun onCreate() {
        super.onCreate()
        createChannel()
        startForeground(NOTI_ID, buildNotification("Chat head is running"))

        val canDraw = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
            android.provider.Settings.canDrawOverlays(this) else true
        Log.d("OverlayDBG", "canDrawOverlays=$canDraw")

        if (!canDraw) {
            stopForeground(STOP_FOREGROUND_DETACH)
            stopSelf()
            return
        }

        wm = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        trash = TrashOverlay(this, wm)

        window = OverlayWindow(
            context = this,
            windowManager = wm,
            onClick = { openChat(null) },
            onPositionChanged = { x, y -> Log.d("OverlayDBG","pos=($x,$y)") },
            onDragStateChanged = { dragging, rect ->
                if (dragging) {
                    if (!trashVisible) { trash?.show(); trashVisible = true }
                    val over = rect != null && trash?.isOverTrash(rect) == true
                    trash?.setHovering(over)
                } else {
                    val over = rect != null && trash?.isOverTrash(rect) == true
                    if (over) stopSelf()
                    trash?.hide()
                    trashVisible = false
                }
            }
        ).apply {
            show()
            setClicksEnabled(false) // <-- ĐÚNG TÊN HÀM
            setChatHeadIconFromAsset("assets/images/pending_img.png")
            setBadge(3)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "set_badge" -> window?.setBadge(intent.getIntExtra("count", 0))
            "open_chat" -> {
                val cid = intent.getStringExtra("cid")
                openChat(cid)
            }
        }
        return START_STICKY
    }

    private fun openChat(cid: String?) {
        val uri = if (cid.isNullOrBlank())
            Uri.parse("exerciseapp://chat")
        else
            Uri.parse("exerciseapp://chat?cid=$cid")

        val i = Intent(Intent.ACTION_VIEW, uri).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            `package` = packageName // ép mở trong app của bạn
        }

        try {
            if (i.resolveActivity(packageManager) != null) {
                startActivity(i)
            } else {
                // Fallback: mở MainActivity nếu chưa cấu hình intent-filter
                val fallback = Intent(this, Class.forName("com.example.verify_clone.MainActivity")).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                    putExtra("deeplink_fallback", uri.toString())
                }
                startActivity(fallback)
            }
        } catch (e: Exception) {
            Log.e("OverlayDBG", "openChat failed", e)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        try { window?.hide() } catch (_: Exception) {}
        try { trash?.destroy() } catch (_: Exception) {}
        stopForeground(STOP_FOREGROUND_REMOVE)
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val ch = NotificationChannel(
                CHANNEL_ID, "Overlay Service", NotificationManager.IMPORTANCE_MIN
            )
            getSystemService(NotificationManager::class.java).createNotificationChannel(ch)
        }
    }

    private fun buildNotification(text: String): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Overlay")
            .setContentText(text)
            .setOngoing(true)
            .setSilent(true)
            .build()
    }
}
