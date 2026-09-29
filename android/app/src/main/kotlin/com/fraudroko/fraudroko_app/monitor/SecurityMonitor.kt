package com.fraudroko.fraudroko_app.monitor

import android.content.Context
import com.fraudroko.fraudroko_app.providers.AccessibilityProvider
import com.fraudroko.fraudroko_app.providers.DeviceAdminProvider
import com.fraudroko.fraudroko_app.providers.InstalledAppsProvider
import com.fraudroko.fraudroko_app.providers.NotificationAccessProvider
import com.fraudroko.fraudroko_app.providers.SecuritySettingsProvider

class SecurityMonitor(
    context: Context
) {

    private val securitySettingsProvider =
        SecuritySettingsProvider(context)

    private val installedAppsProvider =
        InstalledAppsProvider(context)

    private val accessibilityProvider =
        AccessibilityProvider(context)

    private val notificationAccessProvider =
        NotificationAccessProvider(context)

    private val deviceAdminProvider =
        DeviceAdminProvider(context)

    fun createSnapshot(): SecuritySnapshot {

        val securitySettings =
            securitySettingsProvider.getSecuritySettings()

        val installedApps =
            installedAppsProvider.getInstalledApps()

        val accessibility =
            accessibilityProvider.getAccessibilityServices()

        val notificationAccess =
            notificationAccessProvider.getNotificationAccess()

        val deviceAdmins =
            deviceAdminProvider.getDeviceAdmins()

        val hiddenApps = mutableListOf<String>()
        val unknownSourceApps = mutableListOf<String>()
        val accessibilityApps = mutableListOf<String>()
        val notificationApps = mutableListOf<String>()
        val deviceAdminApps = mutableListOf<String>()

        var totalApps = 0
        var safeApps = 0

        // Installed Apps
        @Suppress("UNCHECKED_CAST")
        val appList =
            installedApps["apps"] as? ArrayList<HashMap<String, Any>>
                ?: arrayListOf()

        for (app in appList) {

            val packageName =
                app["packageName"] as? String ?: ""

            if (packageName.isBlank()) {
                continue
            }

            totalApps++

            val installer =
                app["installer"] as? HashMap<String, Any>
                    ?: continue

            val trusted =
          installer["trusted"] as? Boolean ?: false

            val systemApp =
           app["systemApp"] as? Boolean ?: false

            val installerName =
             installer["installerName"] as? String ?: ""

            val hiddenApp =
                app["hiddenApp"] as? Boolean ?: false

            if (hiddenApp && packageName.isNotBlank()) {
                hiddenApps.add(packageName)
            }

         
            // Count only real user apps installed from Unknown Source

         if (
               !trusted &&
               !systemApp &&
               installerName == "Unknown Source" &&
              packageName.isNotBlank()
) {
    unknownSourceApps.add(packageName)
}

            /*
             * "Safe" here means the app does not currently match
             * FraudRoko's tracked hidden-app or unknown-source
             * conditions. This is not a malware-free guarantee.
             */
            if (
                !systemApp &&
                !hiddenApp &&
                !(
                    !trusted &&
                    installerName == "Unknown Source"
                )
            ) {
                safeApps++
            }
        }

        // Accessibility
        @Suppress("UNCHECKED_CAST")
        val accessibilityServices =
            accessibility["services"] as? ArrayList<HashMap<String, String>>
                ?: arrayListOf()

        for (service in accessibilityServices) {

            val packageName =
                service["packageName"] ?: ""

            if (packageName.isNotBlank()) {
                accessibilityApps.add(packageName)
            }
        }

        // Notification Access
        @Suppress("UNCHECKED_CAST")
        val notificationServices =
            notificationAccess["services"] as? ArrayList<HashMap<String, String>>
                ?: arrayListOf()

        for (service in notificationServices) {

            val packageName =
                service["packageName"] ?: ""

            if (packageName.isNotBlank()) {
                notificationApps.add(packageName)
            }
        }

        // Device Admin
        @Suppress("UNCHECKED_CAST")
        val admins =
            deviceAdmins["deviceAdmins"] as? ArrayList<HashMap<String, String>>
                ?: arrayListOf()

        for (admin in admins) {

            val packageName =
                admin["packageName"] ?: ""

            if (packageName.isNotBlank()) {
                deviceAdminApps.add(packageName)
            }
        }

        return SecuritySnapshot(

            timestamp = System.currentTimeMillis(),

            developerOptionsEnabled =
                securitySettings["developerOptionsEnabled"] as? Boolean ?: false,

            usbDebuggingEnabled =
                securitySettings["usbDebuggingEnabled"] as? Boolean ?: false,

            screenLockEnabled =
                securitySettings["screenLockEnabled"] as? Boolean ?: false,

            totalApps =
                totalApps,

            safeApps =
                safeApps,

            hiddenApps =
                hiddenApps.distinct().sorted(),

            unknownSourceApps =
                unknownSourceApps.distinct().sorted(),

            accessibilityApps =
                accessibilityApps.distinct().sorted(),

            notificationAccessApps =
                notificationApps.distinct().sorted(),

            deviceAdminApps =
                deviceAdminApps.distinct().sorted()
        )
    }
}