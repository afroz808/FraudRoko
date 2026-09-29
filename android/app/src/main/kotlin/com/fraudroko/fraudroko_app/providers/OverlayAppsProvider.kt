package com.fraudroko.fraudroko_app.providers

import android.content.Context
import android.os.Build
import android.provider.Settings

class OverlayAppsProvider(
    private val context: Context
) {

    fun getOverlayStatus(): HashMap<String, Any> {

        val result = hashMapOf<String, Any>()

        val overlayEnabled =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                Settings.canDrawOverlays(context)
            } else {
                true
            }

        result["overlayPermissionEnabled"] = overlayEnabled

        return result
    }
}