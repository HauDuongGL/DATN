package overlay

import android.content.Context
import android.content.res.Resources
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.PixelFormat
import android.graphics.Point
import android.graphics.Rect
import android.os.Build
import android.util.Log
import android.view.*
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.view.ContextThemeWrapper
import androidx.core.view.isVisible
import com.example.verify_clone.R
import io.flutter.FlutterInjector
import kotlin.math.abs
import kotlin.math.max

class OverlayWindow(
    private val context: Context,
    private val windowManager: WindowManager,
    private val onClick: () -> Unit,
    private val onPositionChanged: (Int, Int) -> Unit,
    private val onDragStateChanged: (dragging: Boolean, bubbleRect: Rect?) -> Unit
) {
    private var view: View? = null
    private lateinit var params: WindowManager.LayoutParams
    private val prefs = PrefsLocal(context)

    private var badgeView: TextView? = null
    private var avatarView: ImageView? = null
    private var root: FrameLayout? = null

    private var bubbleW = 64
    private var bubbleH = 64
    private val defaultSizeDp = 64

    // touch state
    private var initialX = 0
    private var initialY = 0
    private var downX = 0f
    private var downY = 0f
    private var isClick = true
    private val clickSlopPx by lazy { dpToPx(6) }

    // --- flag bật/tắt click (tắt mặc định) ---
    private var clicksEnabled: Boolean = false
    fun setClicksEnabled(enabled: Boolean) {
        clicksEnabled = enabled
        view?.isClickable = enabled
        view?.isFocusable = enabled
        if (!enabled) view?.foreground = null
    }

    fun show() {
        if (view != null) return

        val inflater = themedInflater()
        view = inflater.inflate(R.layout.chat_head, null)

        root = view!!.findViewById(R.id.chat_head_root)
        badgeView = view!!.findViewById(R.id.chat_head_badge)
        avatarView = view!!.findViewById(R.id.chat_head_icon)

        val layoutType =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE

        val sizePx = dpToPx(defaultSizeDp)

        val flags =
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS

        params = WindowManager.LayoutParams(
            sizePx,
            sizePx,
            layoutType,
            flags,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            val saved = prefs.getPos()
            val topInset = statusBarInset(windowManager)
            x = saved?.first ?: dpToPx(16)
            y = saved?.second ?: (topInset + dpToPx(16))
        }

        setChatHeadIconFromAsset("assets/images/pending_img.png")

        try {
            windowManager.addView(view, params)
            Log.d("OverlayDBG", "addView OK")
        } catch (t: Throwable) {
            Log.e("OverlayDBG", "addView failed", t)
            throw t
        }

        root?.viewTreeObserver?.addOnGlobalLayoutListener(object : ViewTreeObserver.OnGlobalLayoutListener {
            override fun onGlobalLayout() {
                root?.viewTreeObserver?.removeOnGlobalLayoutListener(this)
                bubbleW = root?.width?.takeIf { it > 0 } ?: sizePx
                bubbleH = root?.height?.takeIf { it > 0 } ?: sizePx
                clampInsideSafeArea()
                safeUpdate()
            }
        })

        attachDrag(view!!)
    }

    fun hide() {
        view?.let { v ->
            try { windowManager.removeView(v) } catch (_: Exception) {}
        }
        view = null
    }

    fun setBadge(count: Int) {
        if (count <= 0) {
            badgeView?.isVisible = false
        } else {
            badgeView?.isVisible = true
            badgeView?.text = if (count > 99) "99+" else count.toString()
        }
    }

    fun setChatHeadIconFromAsset(assetPath: String) {
        val loader = FlutterInjector.instance().flutterLoader()
        try {
            loader.startInitialization(context.applicationContext)
            loader.ensureInitializationComplete(context.applicationContext, null)
        } catch (_: Throwable) {}
        val key = runCatching { loader.getLookupKeyForAsset(assetPath) }.getOrElse { assetPath }

        val bmp: Bitmap? = runCatching {
            context.assets.open(key).use { BitmapFactory.decodeStream(it) }
        }.getOrNull()

        val finalBmp = bmp?.let { trimTransparent(it) }
            ?: BitmapFactory.decodeResource(context.resources, R.mipmap.ic_launcher)
        avatarView?.setImageBitmap(finalBmp)
    }

    fun setBubbleSizeDp(sizeDp: Int) {
        val sizePx = dpToPx(sizeDp)
        params.width = sizePx
        params.height = sizePx
        bubbleW = sizePx
        bubbleH = sizePx
        clampInsideSafeArea()
        safeUpdate()
    }

    // ---------- Drag & Snap ----------

    private fun attachDrag(target: View) {
        target.setOnTouchListener { _, e ->
            when (e.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    isClick = true
                    initialX = params.x
                    initialY = params.y
                    downX = e.rawX
                    downY = e.rawY
                    onDragStateChanged(true, currentRectOnScreen())
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = (e.rawX - downX).toInt()
                    val dy = (e.rawY - downY).toInt()
                    if (isClick && (abs(dx) > clickSlopPx || abs(dy) > clickSlopPx)) isClick = false

                    params.x = initialX + dx
                    params.y = initialY + dy
                    clampInsideSafeArea()
                    safeUpdate()
                    onDragStateChanged(true, currentRectOnScreen())
                    true
                }
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                    if (isClick) {
                        if (clicksEnabled) {
                            onClick.invoke()
                            onDragStateChanged(false, null)
                        } else {
                            // coi như không click: snap & lưu vị trí
                            snapToEdge()
                            onPositionChanged(params.x, params.y)
                            onDragStateChanged(false, currentRectOnScreen())
                            prefs.savePos(params.x, params.y)
                        }
                    } else {
                        snapToEdge()
                        onPositionChanged(params.x, params.y)
                        onDragStateChanged(false, currentRectOnScreen())
                        prefs.savePos(params.x, params.y)
                    }
                    true
                }
                else -> false
            }
        }
    }

    private fun currentRectOnScreen(): Rect {
        val v = view ?: return Rect(0, 0, 0, 0)
        val loc = IntArray(2)
        v.getLocationOnScreen(loc)
        return Rect(loc[0], loc[1], loc[0] + max(v.width, bubbleW), loc[1] + max(v.height, bubbleH))
    }

    private fun snapToEdge() {
        val safe = safeArea(windowManager)
        val leftX = safe.left
        val rightX = safe.right - bubbleW
        val centerX = params.x + bubbleW / 2
        val safeCenter = safe.left + safe.width() / 2
        params.x = if (centerX < safeCenter) leftX else rightX
        clampInsideSafeArea()
        safeUpdate()
    }

    private fun clampInsideSafeArea() {
        val safe = safeArea(windowManager)
        val minX = safe.left
        val maxX = safe.right - bubbleW
        val minY = safe.top
        val maxY = safe.bottom - bubbleH
        params.x = params.x.coerceIn(minX, maxX)
        params.y = params.y.coerceIn(minY, maxY)
    }

    private fun safeUpdate() {
        try { windowManager.updateViewLayout(view, params) }
        catch (t: Throwable) { Log.e("OverlayDBG", "updateViewLayout failed", t) }
    }

    // ---------- Helpers: screen & insets ----------

    private fun safeArea(wm: WindowManager): Rect {
        return if (Build.VERSION.SDK_INT >= 30) {
            val metrics = wm.currentWindowMetrics
            val insets = metrics.windowInsets
            val status = insets.getInsets(WindowInsets.Type.statusBars())
            val nav = insets.getInsets(
                WindowInsets.Type.navigationBars() or WindowInsets.Type.systemGestures()
            )
            val b = metrics.bounds
            Rect(b.left, b.top + status.top, b.right, b.bottom - max(nav.bottom, 0))
        } else {
            val p = Point()
            @Suppress("DEPRECATION") wm.defaultDisplay.getSize(p)
            val topInset = legacyStatusBarHeight()
            Rect(0, topInset, p.x, p.y)
        }
    }

    private fun statusBarInset(wm: WindowManager): Int {
        return if (Build.VERSION.SDK_INT >= 30) {
            val metrics = wm.currentWindowMetrics
            metrics.windowInsets.getInsets(WindowInsets.Type.statusBars()).top
        } else legacyStatusBarHeight()
    }

    private fun legacyStatusBarHeight(): Int {
        val resId = Resources.getSystem().getIdentifier("status_bar_height", "dimen", "android")
        return if (resId > 0) Resources.getSystem().getDimensionPixelSize(resId) else 0
    }

    private fun dpToPx(dp: Int): Int = (dp * context.resources.displayMetrics.density).toInt()

    private fun trimTransparent(src: Bitmap, alphaThreshold: Int = 5): Bitmap {
        val w = src.width
        val h = src.height
        val pixels = IntArray(w * h)
        src.getPixels(pixels, 0, w, 0, 0, w, h)

        var top = 0
        var left = 0
        var right = w - 1
        var bottom = h - 1

        // top
        loop@ for (y in 0 until h) {
            val off = y * w
            for (x in 0 until w) if ((pixels[off + x] ushr 24) > alphaThreshold) { top = y; break@loop }
        }
        // bottom
        loop@ for (y in h - 1 downTo top) {
            val off = y * w
            for (x in 0 until w) if ((pixels[off + x] ushr 24) > alphaThreshold) { bottom = y; break@loop }
        }
        // left
        loop@ for (x in 0 until w) {
            for (y in top..bottom) if ((pixels[y * w + x] ushr 24) > alphaThreshold) { left = x; break@loop }
        }
        // right
        loop@ for (x in w - 1 downTo left) {
            for (y in top..bottom) if ((pixels[y * w + x] ushr 24) > alphaThreshold) { right = x; break@loop }
        }

        if (left == 0 && top == 0 && right == w - 1 && bottom == h - 1) return src
        return Bitmap.createBitmap(src, left, top, right - left + 1, bottom - top + 1)
    }

    private fun themedInflater(): LayoutInflater {
        val themeId = try {
            val id = context.resources.getIdentifier("Theme_VerifyClone", "style", context.packageName)
            if (id != 0) id else R.style.Theme_VerifyClone
        } catch (_: Exception) {
            android.R.style.Theme_DeviceDefault_Light_NoActionBar
        }
        val wrapper = ContextThemeWrapper(context, themeId)
        return LayoutInflater.from(wrapper)
    }
}

private class PrefsLocal(ctx: Context) {
    private val sp = ctx.getSharedPreferences("overlay_prefs", Context.MODE_PRIVATE)
    fun getPos(): Pair<Int, Int>? =
        if (sp.contains("x") && sp.contains("y")) sp.getInt("x", 0) to sp.getInt("y", 0) else null
    fun savePos(x: Int, y: Int) { sp.edit().putInt("x", x).putInt("y", y).apply() }
}
