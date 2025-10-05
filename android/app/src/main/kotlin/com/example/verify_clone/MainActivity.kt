package com.example.verify_clone

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

// EXIF + Java time imports (bị thiếu nên build fail)
import androidx.exifinterface.media.ExifInterface
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

import overlay.OverlayPermission
import overlay.StatusBubbleService

class MainActivity : FlutterActivity() {

    private val METHOD_CH = "deeplink/methods"
    private val EVENT_CH  = "deeplink/events"

    private val OVERLAY_OLD = "chat.overlay"
    private val OVERLAY_NEW = "overlay/commands"

    private var eventsSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // --- Deep link: method channel ---
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CH)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialLink" -> result.success(intent?.dataString)
                    else -> result.notImplemented()
                }
            }

        // --- Deep link: event channel ---
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CH)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventsSink = events
                }
                override fun onCancel(arguments: Any?) {
                    eventsSink = null
                }
            })

        // --- Overlay (new) ---
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, OVERLAY_NEW)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "canDraw" -> result.success(OverlayPermission.canDraw(this))
                    "openOverlayPermission" -> {
                        OverlayPermission.openSettings(this)
                        result.success(true)
                    }
                    "start" -> {
                        val ctx = this@MainActivity
                        android.util.Log.d("OverlayDBG", "MainActivity received start")
                        android.widget.Toast.makeText(ctx, "Starting overlay...", android.widget.Toast.LENGTH_SHORT).show()
                        val i = Intent(ctx, StatusBubbleService::class.java)
                        if (Build.VERSION.SDK_INT >= 26) ctx.startForegroundService(i) else ctx.startService(i)
                        result.success(true)
                    }
                    "stop" -> {
                        stopService(Intent(this, StatusBubbleService::class.java))
                        result.success(true)
                    }
                    "setBadge" -> {
                        val count = (call.argument<Int>("count") ?: 0).coerceAtLeast(0)
                        val i = Intent(this, StatusBubbleService::class.java).apply {
                            action = "set_badge"
                            putExtra("count", count)
                        }
                        startService(i)
                        result.success(true)
                    }
                    "openChat" -> {
                        val cid = call.argument<String>("cid")
                        val i = Intent(this, StatusBubbleService::class.java).apply {
                            action = "open_chat"
                            putExtra("cid", cid)
                        }
                        startService(i)
                        result.success(true)
                    }
                    "requestPermission" -> {
                        if (OverlayPermission.canDraw(this)) {
                            result.success(true)
                        } else {
                            OverlayPermission.openSettings(this)
                            result.success(true)
                        }
                    }
                    "startOverlay" -> {
                        val i = Intent(this, StatusBubbleService::class.java)
                        if (Build.VERSION.SDK_INT >= 26) startForegroundService(i) else startService(i)
                        result.success(true)
                    }
                    "stopOverlay" -> {
                        stopService(Intent(this, StatusBubbleService::class.java))
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        // --- Overlay (legacy) ---
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, OVERLAY_OLD)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "canDrawOverlays" -> result.success(OverlayPermission.canDraw(this))
                    "requestOverlayPermission" -> {
                        OverlayPermission.openSettings(this)
                        result.success(true)
                    }
                    "startChatHead" -> {
                        val i = Intent(this, StatusBubbleService::class.java)
                        if (Build.VERSION.SDK_INT >= 26) startForegroundService(i) else startService(i)
                        result.success(true)
                    }
                    "stopChatHead" -> {
                        stopService(Intent(this, StatusBubbleService::class.java))
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        // --- EXIF writer ---
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "exif_writer")
            .setMethodCallHandler { call, result ->
                if (call.method == "writeGps") {
                    val path = call.argument<String>("path")
                    val lat  = call.argument<Double>("lat")
                    val lng  = call.argument<Double>("lng")
                    val takenAt = call.argument<Long>("takenAt")

                    if (path == null || lat == null || lng == null) {
                        result.error("ARG", "Missing path/lat/lng", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val exif = ExifInterface(path)
                        exif.setLatLong(lat, lng)

                        takenAt?.let {
                            val d = Date(it)
                            val dt = SimpleDateFormat("yyyy:MM:dd HH:mm:ss", Locale.US).format(d)
                            val dOnly = SimpleDateFormat("yyyy:MM:dd", Locale.US).format(d)
                            val tOnly = SimpleDateFormat("HH:mm:ss", Locale.US).format(d)
                            exif.setAttribute(ExifInterface.TAG_DATETIME_ORIGINAL, dt)
                            exif.setAttribute(ExifInterface.TAG_GPS_DATESTAMP, dOnly)
                            exif.setAttribute(ExifInterface.TAG_GPS_TIMESTAMP, tOnly)
                        }

                        exif.saveAttributes()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("WRITE_EXIF_FAIL", e.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        intent.dataString?.let { link -> eventsSink?.success(link) }
    }
}
