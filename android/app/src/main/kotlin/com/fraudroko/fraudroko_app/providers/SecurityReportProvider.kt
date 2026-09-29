package com.fraudroko.fraudroko_app.providers

import android.content.Context
import com.fraudroko.fraudroko_app.engines.SecurityRuleEngine
import com.fraudroko.fraudroko_app.notifications.NotificationHelper

class SecurityReportProvider(
    private val context: Context
) {

    private val deviceInfoProvider =
        DeviceInfoProvider()

    private val bootloaderProvider =
        BootloaderProvider()

    private val overlayAppsProvider =
        OverlayAppsProvider(context)

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

    private val securityRuleEngine =
        SecurityRuleEngine()

    private val notificationHelper =
        NotificationHelper(context)

    fun getSecurityReport(): HashMap<String, Any> {

        val report =
            hashMapOf<String, Any>()

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

        val overlay =
            overlayAppsProvider.getOverlayStatus()

        val bootloader =
            bootloaderProvider.getBootloaderStatus()

        val securityAnalysis =
            securityRuleEngine.analyze(
                securitySettings,
                accessibility,
                notificationAccess,
                deviceAdmins,
                overlay,
                bootloader,
                installedApps
            )

        /*
         * Suspicious hidden-app alert.
         *
         * We only alert when:
         * - non-system app
         * - enabled
         * - installed from an untrusted source
         * - no normal launcher entry
         *
         * This avoids treating normal Android/system components as hidden threats.
         */
        val installedAppList =
            (installedApps["apps"] as? List<*>)
                ?.mapNotNull { it as? Map<String, Any> }
                ?: emptyList()

        for (app in installedAppList) {
            val packageName =
                app["packageName"] as? String
                    ?: continue

            val appName =
                app["appName"] as? String
                    ?: packageName

            val systemApp =
                app["systemApp"] as? Boolean
                    ?: false

            val enabled =
                app["enabled"] as? Boolean
                    ?: false

            val installer =
                app["installer"] as? Map<*, *>

            val trustedInstaller =
                installer?.get("trusted") as? Boolean
                    ?: false

            if (systemApp || !enabled || trustedInstaller) {
                continue
            }

            val hasLauncher =
                try {
                    context.packageManager
                        .getLaunchIntentForPackage(packageName) != null
                } catch (_: Exception) {
                    true
                }

            if (!hasLauncher) {
                notificationHelper.showSecurityAlert(
                    title = "Suspicious hidden app: $appName",
                    message =
                        "$appName is installed from an untrusted source and does not appear to have a normal launcher entry. Review this app.",
                    notificationId =
                        "hidden_app_$packageName".hashCode(),
                    packageName = packageName,
                    securityType = "hidden_app"
                )
            }
        }

        /*
         * Find application name from package name.
         */
        fun getAppName(
            packageName: String
        ): String {

            if (packageName.isBlank()) {
                return ""
            }

            val apps =
                (installedApps["apps"] as? List<*>)
                    ?.mapNotNull { it as? Map<String, Any> }
                    ?: emptyList()

            for (app in apps) {

                val appPackage =
                    app["packageName"] as? String
                        ?: continue

                if (appPackage == packageName) {

                    return app["appName"] as? String
                        ?: packageName
                }
            }

            return packageName
        }

        /*
         * Get enabled accessibility packages.
         */
        fun getAccessibilityPackages():
            List<String> {

            @Suppress("UNCHECKED_CAST")
            val services =
                accessibility["services"]
                    as? ArrayList<HashMap<String, String>>
                    ?: arrayListOf()

            return services
                .mapNotNull {
                    it["packageName"]
                }
                .filter {
                    it.isNotBlank()
                }
                .distinct()
        }

        /*
         * Get notification access packages.
         */
        fun getNotificationPackages():
            List<String> {

            @Suppress("UNCHECKED_CAST")
            val services =
                notificationAccess["services"]
                    as? ArrayList<HashMap<String, String>>
                    ?: arrayListOf()

            return services
                .mapNotNull {
                    it["packageName"]
                }
                .filter {
                    it.isNotBlank()
                }
                .distinct()
        }

        /*
         * Get active device-admin packages.
         */
        fun getDeviceAdminPackages():
            List<String> {

            @Suppress("UNCHECKED_CAST")
            val admins =
                deviceAdmins["deviceAdmins"]
                    as? ArrayList<HashMap<String, String>>
                    ?: arrayListOf()

            return admins
                .mapNotNull {
                    it["packageName"]
                }
                .filter {
                    it.isNotBlank()
                }
                .distinct()
        }

        /*
         * Security warnings
         */
        @Suppress("UNCHECKED_CAST")
        val warnings =
            securityAnalysis["warning"]
                as? ArrayList<HashMap<String, String>>
                ?: arrayListOf()

        for (warning in warnings) {

            val originalTitle =
                warning["title"]
                    ?: continue

            val originalMessage =
                warning["message"]
                    ?: continue

            when (originalTitle) {

                "Accessibility Services" -> {

                    val packages =
                        getAccessibilityPackages()

                    if (packages.isEmpty()) {

                        notificationHelper.showSecurityAlert(
                            title =
                                "Accessibility access enabled",
                            message =
                                "One or more accessibility services are enabled. Review Accessibility settings if you do not recognize them.",
                            notificationId =
                                "accessibility".hashCode(),
                            securityType =
                                "accessibility"
                        )

                    } else {

                        for (packageName in packages) {

                            val appName =
                                getAppName(packageName)

                            notificationHelper.showSecurityAlert(
                                title =
                                    "Accessibility access: $appName",
                                message =
                                    "$appName has Accessibility access. Review it if you do not recognize this app.",
                                notificationId =
                                    "accessibility_$packageName"
                                        .hashCode(),
                                packageName =
                                    packageName,
                                securityType =
                                    "accessibility"
                            )
                        }
                    }
                }

                "Notification Access" -> {

                    // Scan result is kept, but no standalone notification is sent.

                }

                "Device Admin" -> {

                    val packages =
                        getDeviceAdminPackages()

                    if (packages.isEmpty()) {

                        notificationHelper.showSecurityAlert(
                            title =
                                "Device administrator active",
                            message =
                                originalMessage,
                            notificationId =
                                "device_admin"
                                    .hashCode(),
                            securityType =
                                "device_admin"
                        )

                    } else {

                        for (packageName in packages) {

                            val appName =
                                getAppName(packageName)

                            notificationHelper.showSecurityAlert(
                                title =
                                    "Device admin: $appName",
                                message =
                                    "$appName has device administrator privileges. Review it if you do not recognize this app.",
                                notificationId =
                                    "device_admin_$packageName"
                                        .hashCode(),
                                packageName =
                                    packageName,
                                securityType =
                                    "device_admin"
                            )
                        }
                    }
                }

                "Overlay Apps" -> {

                    notificationHelper.showSecurityAlert(
                        title =
                            "Overlay permission enabled",
                        message =
                            "An app can display content over other apps. Review this permission if you do not recognize the app.",
                        notificationId =
                            "overlay".hashCode(),
                        securityType =
                            "overlay"
                    )
                }

                "Developer Options" -> {

                    notificationHelper.showSecurityAlert(
                        title =
                            "Developer Options enabled",
                        message =
                            "Developer Options are enabled. Review them if you did not enable them.",
                        notificationId =
                            "developer_options".hashCode(),
                        securityType =
                            "developer_options"
                    )
                }

                "USB Debugging" -> {

                    notificationHelper.showSecurityAlert(
                        title =
                            "USB Debugging enabled",
                        message =
                            "USB debugging is enabled. Review Developer Options if you did not enable it.",
                        notificationId =
                            "usb_debugging".hashCode(),
                        securityType =
                            "usb_debugging"
                    )
                }

                else -> {

                    notificationHelper.showSecurityAlert(
                        title =
                            originalTitle,
                        message =
                            originalMessage,
                        notificationId =
                            originalTitle.hashCode()
                    )
                }
            }
        }

        /*
         * Security critical alerts
         */
        @Suppress("UNCHECKED_CAST")
        val criticalAlerts =
            securityAnalysis["critical"]
                as? ArrayList<HashMap<String, String>>
                ?: arrayListOf()

        for (critical in criticalAlerts) {

            val originalTitle =
                critical["title"]
                    ?: continue

            val originalMessage =
                critical["message"]
                    ?: continue

            when (originalTitle) {

                "No Screen Lock" -> {

                    notificationHelper.showSecurityAlert(
                        title =
                            "Critical: No Screen Lock",
                        message =
                            "Your phone does not have a screen lock. Anyone with physical access may be able to unlock it.",
                        notificationId =
                            "critical_screen_lock"
                                .hashCode()
                    )
                }

                "Root Detected" -> {

                    notificationHelper.showSecurityAlert(
                        title =
                            "Critical: Root detected",
                        message =
                            "Root access was detected on this device. Review your device security configuration.",
                        notificationId =
                            "critical_root"
                                .hashCode()
                    )
                }

                else -> {

                    notificationHelper.showSecurityAlert(
                        title =
                            "Critical: $originalTitle",
                        message =
                            originalMessage,
                        notificationId =
                            "critical_$originalTitle"
                                .hashCode()
                    )
                }
            }
        }

        report["deviceInfo"] =
            deviceInfoProvider.getDeviceInfo()

        report["securitySettings"] =
            securitySettings

        report["installedApps"] =
            installedApps

        report["accessibility"] =
            accessibility

        report["notificationAccess"] =
            notificationAccess

        report["deviceAdmins"] =
            deviceAdmins

        report["overlay"] =
            overlay

        report["bootloader"] =
            bootloader

        report["securityAnalysis"] =
            securityAnalysis

        return report
    }
}