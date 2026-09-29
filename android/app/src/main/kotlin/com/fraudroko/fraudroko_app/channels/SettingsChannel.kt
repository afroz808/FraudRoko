package com.fraudroko.fraudroko_app.channels

import android.content.Context
import android.content.Intent
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class SettingsChannel(
    private val context: Context,
    messenger: BinaryMessenger
) {

    private val channel =
        MethodChannel(
            messenger,
            "fraudroko/settings"
        )

    init {

        channel.setMethodCallHandler { call, result ->

            when (call.method) {

                "openSecuritySettings" -> {

                    context.startActivity(
                        Intent(Settings.ACTION_SECURITY_SETTINGS).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                    )

                    result.success(true)
                }

                "openDeveloperOptions" -> {

                    context.startActivity(
                        Intent(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                    )

                    result.success(true)
                }

                "openSystemUpdate" -> {

                    // ACTION_SYSTEM_UPDATE_SETTINGS sab Android versions me available nahi hota.
                    // Isliye Settings screen open kar rahe hain.

                    context.startActivity(
                        Intent(Settings.ACTION_SETTINGS).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                    )

                    result.success(true)
                }

                "openAccessibilitySettings" -> {

                    context.startActivity(
                        Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                    )

                    result.success(true)
                }

                "openNotificationAccessSettings" -> {

                    context.startActivity(
                        Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                    )

                    result.success(true)
                }

                "openOverlaySettings" -> {

                    context.startActivity(
                        Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                    )

                    result.success(true)
                }

                "openAppDetails" -> {

                    val packageName = call.argument<String>("packageName")

                    if (packageName.isNullOrBlank()) {
                        result.error(
                            "INVALID_PACKAGE",
                            "Package name is required.",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    val intent = Intent(
                        Settings.ACTION_APPLICATION_DETAILS_SETTINGS
                    ).apply {
                        data = android.net.Uri.parse("package:$packageName")
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }

                    context.startActivity(intent)
                    result.success(true)
                }

                else -> result.notImplemented()
            }

        }
    }
}