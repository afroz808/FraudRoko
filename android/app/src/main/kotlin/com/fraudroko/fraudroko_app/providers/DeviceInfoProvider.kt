package com.fraudroko.fraudroko_app.providers

import android.os.Build

class DeviceInfoProvider {

    fun getDeviceInfo(): HashMap<String, Any?> {

        val deviceInfo = hashMapOf<String, Any?>()

        deviceInfo["androidVersion"] = Build.VERSION.RELEASE
        deviceInfo["sdkInt"] = Build.VERSION.SDK_INT
        deviceInfo["manufacturer"] = Build.MANUFACTURER
        deviceInfo["brand"] = Build.BRAND
        deviceInfo["model"] = Build.MODEL
        deviceInfo["device"] = Build.DEVICE
        deviceInfo["product"] = Build.PRODUCT
        deviceInfo["hardware"] = Build.HARDWARE
        deviceInfo["board"] = Build.BOARD
        deviceInfo["bootloader"] = Build.BOOTLOADER
        deviceInfo["fingerprint"] = Build.FINGERPRINT

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            deviceInfo["securityPatch"] = Build.VERSION.SECURITY_PATCH
        } else {
            deviceInfo["securityPatch"] = "Unknown"
        }

        deviceInfo["isPhysicalDevice"] =
            !Build.FINGERPRINT.contains("generic", ignoreCase = true)

        return deviceInfo
    }
}