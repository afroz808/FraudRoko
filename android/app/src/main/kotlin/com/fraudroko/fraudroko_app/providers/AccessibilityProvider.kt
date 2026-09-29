package com.fraudroko.fraudroko_app.providers

import android.content.ComponentName
import android.content.Context
import android.provider.Settings

class AccessibilityProvider(
    private val context: Context
) {

    fun getAccessibilityServices(): HashMap<String, Any> {

        val result = hashMapOf<String, Any>()

        val accessibilityEnabled =
            try {
                Settings.Secure.getInt(
                    context.contentResolver,
                    Settings.Secure.ACCESSIBILITY_ENABLED,
                    0
                ) == 1
            } catch (_: Exception) {
                false
            }

        val enabledServices =
            try {
                Settings.Secure.getString(
                    context.contentResolver,
                    Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
                ) ?: ""
            } catch (_: Exception) {
                ""
            }

        val appList =
            arrayListOf<HashMap<String, String>>()

        if (accessibilityEnabled && enabledServices.isNotBlank()) {

            enabledServices
                .split(":")
                .map { it.trim() }
                .filter { it.isNotBlank() }
                .forEach { serviceString ->

                    val component =
                        ComponentName.unflattenFromString(serviceString)

                    if (component != null) {

                        val item =
                            hashMapOf<String, String>()

                        item["packageName"] =
                            component.packageName

                        item["serviceName"] =
                            component.className

                        appList.add(item)
                    }
                }
        }

        result["accessibilityEnabled"] =
            accessibilityEnabled

        result["totalAccessibilityServices"] =
            appList.size

        result["services"] =
            appList

        return result
    }
}