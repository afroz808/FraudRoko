package com.fraudroko.fraudroko_app.providers

import android.content.Context
import android.provider.Settings

class NotificationAccessProvider(
    private val context: Context
) {

    fun getNotificationAccess(): HashMap<String, Any> {

        val result = hashMapOf<String, Any>()

        val listeners =
            Settings.Secure.getString(
                context.contentResolver,
                "enabled_notification_listeners"
            ) ?: ""

        val appList = arrayListOf<HashMap<String, String>>()

        if (listeners.isNotBlank()) {

            listeners.split(":").forEach { listener ->

                val item = hashMapOf<String, String>()

                val parts = listener.split("/")

                item["packageName"] =
                    parts.getOrNull(0) ?: ""

                item["serviceName"] =
                    parts.getOrNull(1) ?: ""

                appList.add(item)
            }
        }

        result["notificationAccessEnabled"] =
            appList.isNotEmpty()

        result["totalNotificationAccessApps"] =
            appList.size

        result["services"] =
            appList

        return result
    }
}