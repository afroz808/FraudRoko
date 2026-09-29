package com.fraudroko.fraudroko_app.providers

import android.app.KeyguardManager
import android.content.Context
import android.os.Build
import android.provider.Settings
import java.io.File

class SecuritySettingsProvider(
    private val context: Context
) {

    fun getSecuritySettings(): HashMap<String, Any> {

        val security = hashMapOf<String, Any>()

        // Screen Lock
        val keyguardManager =
            context.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager

        val screenLockEnabled = keyguardManager.isDeviceSecure

        // Lock Type
        val lockType = if (screenLockEnabled) {
            "Secure Lock"
        } else {
            "None"
        }

        // Device Encryption
        // Android public API se reliable encryption status sab versions par
        // available nahi hota. Isliye agar screen secure hai to best effort
        // value return karte hain.
        val deviceEncrypted = screenLockEnabled

        // Developer Options
        val developerOptionsEnabled =
            Settings.Global.getInt(
                context.contentResolver,
                Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
                0
            ) != 0

        // USB Debugging
        val usbDebuggingEnabled =
            Settings.Global.getInt(
                context.contentResolver,
                Settings.Global.ADB_ENABLED,
                0
            ) != 0

        // Root Detection
        val rootPaths = listOf(
            "/system/bin/su",
            "/system/xbin/su",
            "/sbin/su",
            "/system/su",
            "/system/bin/.ext/su",
            "/system/usr/we-need-root/su",
            "/system/app/Superuser.apk",
            "/system/app/Magisk.apk",
            "/system/app/MagiskManager.apk",
            "/system/bin/magisk",
            "/system/xbin/magisk"
        )

        val rootDetected = rootPaths.any { path ->
            File(path).exists()
        }

        // Emulator Detection
        val emulatorDetected =
            Build.FINGERPRINT.startsWith("generic") ||
            Build.FINGERPRINT.contains("emulator", true) ||
            Build.MODEL.contains("Emulator", true) ||
            Build.MODEL.contains("Android SDK", true) ||
            Build.MANUFACTURER.contains("Genymotion", true) ||
            Build.BRAND.startsWith("generic") ||
            Build.DEVICE.startsWith("generic") ||
            Build.PRODUCT.contains("sdk", true) ||
            Build.PRODUCT.contains("emulator", true) ||
            Build.HARDWARE.contains("goldfish", true) ||
            Build.HARDWARE.contains("ranchu", true) ||
            Build.BOARD.contains("goldfish", true)

        security["screenLockEnabled"] = screenLockEnabled
        security["lockType"] = lockType
        security["deviceEncrypted"] = deviceEncrypted
        security["developerOptionsEnabled"] = developerOptionsEnabled
        security["usbDebuggingEnabled"] = usbDebuggingEnabled
        security["rootDetected"] = rootDetected
        security["isEmulator"] = emulatorDetected

        security["securityPatch"] =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                Build.VERSION.SECURITY_PATCH
            } else {
                "Unknown"
            }

        return security
    }
}