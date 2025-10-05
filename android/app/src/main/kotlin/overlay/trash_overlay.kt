package overlay

import android.content.Context
import android.graphics.PixelFormat
import android.graphics.Point
import android.graphics.Rect
import android.os.Build
import android.view.*
import android.widget.FrameLayout
import android.widget.ImageView
import androidx.core.view.isVisible
import com.example.verify_clone.R
import kotlin.math.max
import kotlin.math.roundToInt

class TrashOverlay(
    private val context: Context,
    private val wm: WindowManager
) {
    private var view: View? = null
    private var params: WindowManager.LayoutParams? = null

    private var trashRoot: FrameLayout? = null
    private var trashCircle: FrameLayout? = null
    private var trashIcon: ImageView? = null

    private val hitPaddingDp = 28f

    private var lastHover = false

    fun show() {
        val overlayType =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE

        if (view != null) {
            if (!view!!.isVisible) {
                view!!.animate().cancel()
                view!!.alpha = 0f
                view!!.isVisible = true
                view!!.animate().alpha(1f).setDuration(120).start()
            }
            params?.let {
                it.y = bottomSafeOffset() + dp(32f)
                try { wm.updateViewLayout(view, it) } catch (_: Exception) {}
            }
            return
        }

        val flags = (
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                    or WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE
                    or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN
                    or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
            )

        params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            overlayType,
            flags,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
            x = 0
            y = bottomSafeOffset() + dp(32f)
        }

        view = LayoutInflater.from(context).inflate(R.layout.chat_trash, null).also { v ->
            trashRoot = v.findViewById(R.id.trash_root)
            trashCircle = v.findViewById(R.id.trash_circle)
            trashIcon = v.findViewById(R.id.trash_icon)
        }

        wm.addView(view, params)
        view!!.alpha = 0f
        view!!.isVisible = true
        view!!.animate().alpha(1f).setDuration(120).start()
        lastHover = false
    }

    fun hide() {
        val v = view ?: return
        if (!v.isVisible) return
        v.animate().cancel()
        v.animate().alpha(0f).setDuration(100).withEndAction {
            v.isVisible = false
            v.alpha = 0f
        }.start()
        lastHover = false
    }

    fun destroy() {
        val v = view ?: return
        try { wm.removeView(v) } catch (_: Exception) {}
        view = null
        params = null
        lastHover = false
    }

    fun setHovering(hover: Boolean) {
        if (hover == lastHover) {
        } else {
            val scale = if (hover) 1.15f else 1f
            trashCircle?.animate()?.scaleX(scale)?.scaleY(scale)?.setDuration(90)?.start()
            trashIcon?.animate()?.scaleX(scale)?.scaleY(scale)?.setDuration(90)?.start()
            lastHover = hover
        }
        params?.let {
            it.y = bottomSafeOffset() + dp(if (hover) 28f else 32f)
            try { wm.updateViewLayout(view, it) } catch (_: Exception) {}
        }
    }

    fun isOverTrash(bubbleRect: Rect): Boolean {
        val r = getCircleRectOnScreen() ?: return false
        val pad = dp(hitPaddingDp)
        r.inset(-pad, -pad)
        return Rect.intersects(bubbleRect, r)
    }

    fun getTrashCenter(): Point? {
        val r = getCircleRectOnScreen() ?: return null
        return Point(r.centerX(), r.centerY())
    }

    // --- Helpers ---

    private fun getCircleRectOnScreen(): Rect? {
        val circle = trashCircle ?: return null
        if (!circle.isShown || circle.width == 0 || circle.height == 0) return null
        val loc = IntArray(2)
        circle.getLocationOnScreen(loc)
        return Rect(loc[0], loc[1], loc[0] + circle.width, loc[1] + circle.height)
    }

    private fun bottomSafeOffset(): Int {
        return if (Build.VERSION.SDK_INT >= 30) {
            val metrics = wm.currentWindowMetrics
            val insets = metrics.windowInsets
            val nav = insets.getInsets(
                WindowInsets.Type.navigationBars() or WindowInsets.Type.systemGestures()
            )
            max(nav.bottom, 0)
        } else {
            0
        }
    }

    private fun dp(v: Float): Int = (v * context.resources.displayMetrics.density).roundToInt()
}
