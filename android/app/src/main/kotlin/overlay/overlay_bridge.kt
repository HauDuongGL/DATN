package overlay

import android.content.Context
import android.content.Intent

class OverlayBridge(private val context: Context) {
    fun canDraw(): Boolean = OverlayPermission.canDraw(context)
    fun openPermissionPage() = OverlayPermission.openSettings(context)

    fun start() {
        if (!canDraw()) return
        OverlayNotification.ensureChannel(context)
        val i = Intent(context, StatusBubbleService::class.java)
        context.startForegroundService(i)
    }

    fun stop() {
        val i = Intent(context, StatusBubbleService::class.java)
        context.stopService(i)
    }
}