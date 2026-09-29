package com.fraudroko.fraudroko_app.channels

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class AppSettingsChannel(
    private val context: Context,
    messenger: BinaryMessenger
) {

    private val channel = MethodChannel(
        messenger,
        "fraudroko/app_settings"
    )

    init {

        channel.setMethodCallHandler { call, result ->

            when (call.method) {

                "openAppSettings" -> {

                    val packageName =
                        call.argument<String>("packageName")

                    if (packageName == null) {

                        result.error(
                            "INVALID_PACKAGE",
                            "Package name missing",
                            null
                        )

                        return@setMethodCallHandler
                    }

                    val intent = Intent(
                        Settings.ACTION_APPLICATION_DETAILS_SETTINGS
                    ).apply {

                        data = Uri.parse("package:$packageName")

                        addFlags(
                            Intent.FLAG_ACTIVITY_NEW_TASK
                        )
                    }

                    context.startActivity(intent)

                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }
}