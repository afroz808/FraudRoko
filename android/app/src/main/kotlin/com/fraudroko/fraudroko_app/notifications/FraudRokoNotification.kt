package com.fraudroko.fraudroko_app.notifications

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build

object FraudRokoNotification {

    const val CHANNEL_ID = "fraudroko_security"

    fun createChannel(context: Context) {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            val channel = NotificationChannel(
                CHANNEL_ID,
                "FraudRoko Security",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {

                description =
                    "Security alerts from FraudRoko"

                enableLights(true)

                enableVibration(true)
            }

            val manager =
                context.getSystemService(
                    NotificationManager::class.java
                )

            manager.createNotificationChannel(channel)
        }
    }
}