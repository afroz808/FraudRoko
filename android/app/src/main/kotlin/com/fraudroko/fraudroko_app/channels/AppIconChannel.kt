package com.fraudroko.fraudroko_app.channels

import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.Base64
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class AppIconChannel(
    private val context: Context,
    messenger: BinaryMessenger
) {

    private val channel = MethodChannel(
        messenger,
        "fraudroko/app_icon"
    )

    init {

        channel.setMethodCallHandler { call, result ->

            when (call.method) {

                "getAppIcon" -> {

                    val packageName =
                        call.argument<String>("packageName")

                    if (packageName == null) {
                        result.success(null)
                        return@setMethodCallHandler
                    }

                    val drawable = loadIconRobust(packageName)

                    if (drawable == null) {
                        result.success(null)
                        return@setMethodCallHandler
                    }

                    try {

                        val bitmap =
                            drawable.toBitmap()

                        val stream =
                            ByteArrayOutputStream()

                        bitmap.compress(
                            Bitmap.CompressFormat.PNG,
                            100,
                            stream
                        )

                        val bytes =
                            stream.toByteArray()

                        result.success(
                            Base64.encodeToString(
                                bytes,
                                Base64.NO_WRAP
                            )
                        )

                    } catch (_: Exception) {

                        result.success(null)

                    }

                }

                else -> result.notImplemented()

            }

        }

    }

    // Hidden/suspicious apps often have their launcher entry disabled, which can
    // make the plain getApplicationIcon(packageName) call fail on some Android
    // versions. Retry once with broader match flags before giving up, so the
    // security report can still show the real app icon instead of falling back
    // to the generic placeholder.
    private fun loadIconRobust(packageName: String): Drawable? {

        try {
            return context.packageManager.getApplicationIcon(packageName)
        } catch (_: Exception) {
            // fall through to the broader lookup below
        }

        return try {
            val appInfo = context.packageManager.getApplicationInfo(
                packageName,
                PackageManager.MATCH_DISABLED_COMPONENTS
            )
            context.packageManager.getApplicationIcon(appInfo)
        } catch (_: Exception) {
            null
        }
    }

    private fun Drawable.toBitmap(): Bitmap {

        if (this is BitmapDrawable) {
            bitmap?.let {
                return it
            }
        }

        val bitmap = Bitmap.createBitmap(
            intrinsicWidth.coerceAtLeast(1),
            intrinsicHeight.coerceAtLeast(1),
            Bitmap.Config.ARGB_8888
        )

        val canvas = Canvas(bitmap)

        setBounds(
            0,
            0,
            canvas.width,
            canvas.height
        )

        draw(canvas)

        return bitmap
    }
}