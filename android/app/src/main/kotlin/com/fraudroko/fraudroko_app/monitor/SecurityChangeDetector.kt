package com.fraudroko.fraudroko_app.monitor

data class SecurityChange(
    val title: String,
    val message: String,
    val securityType: String,
    val packageName: String = ""
)

class SecurityChangeDetector {

    fun detectChanges(
        oldSnapshot: SecuritySnapshot?,
        newSnapshot: SecuritySnapshot
    ): List<SecurityChange> {

        if (oldSnapshot == null) {
            return emptyList()
        }

        val changes = mutableListOf<SecurityChange>()

        // =========================================
        // DEVELOPER OPTIONS
        // =========================================

        if (
            !oldSnapshot.developerOptionsEnabled &&
            newSnapshot.developerOptionsEnabled
        ) {
            changes.add(
                SecurityChange(
                    title = "Developer Options",
                    message = "",
                    securityType = "developer_options"
                )
            )
        }

        // =========================================
        // USB DEBUGGING
        // =========================================

        if (
            !oldSnapshot.usbDebuggingEnabled &&
            newSnapshot.usbDebuggingEnabled
        ) {
            changes.add(
                SecurityChange(
                    title = "USB Debugging",
                    message = "",
                    securityType = "usb_debugging"
                )
            )
        }

        // =========================================
        // SCREEN LOCK REMOVED
        // =========================================

        if (
            oldSnapshot.screenLockEnabled &&
            !newSnapshot.screenLockEnabled
        ) {
            changes.add(
                SecurityChange(
                    title = "Screen Lock",
                    message = "",
                    securityType = "screen_lock"
                )
            )
        }

        // =========================================
        // HIDDEN APPS
        // =========================================

        val newHiddenApps =
            newSnapshot.hiddenApps -
            oldSnapshot.hiddenApps

        newHiddenApps.forEach {

            changes.add(
                SecurityChange(
                    title = "Hidden Application",
                    message = "",
                    securityType = "hidden_app",
                    packageName = it
                )
            )
        }

        // =========================================
        // UNKNOWN / OUTSIDE SOURCE APPS
        // =========================================

        val newUnknownSourceApps =
            newSnapshot.unknownSourceApps -
            oldSnapshot.unknownSourceApps

        newUnknownSourceApps.forEach {

            changes.add(
                SecurityChange(
                    title = "Unknown Source App",
                    message = "",
                    securityType = "unknown_source_app"
                )
            )
        }

        // =========================================
        // ACCESSIBILITY
        // =========================================

        val newAccessibilityApps =
            newSnapshot.accessibilityApps -
            oldSnapshot.accessibilityApps

        newAccessibilityApps.forEach {

            changes.add(
                SecurityChange(
                    title = "Accessibility",
                    message = "",
                    securityType = "accessibility"
                )
            )
        }

        // =========================================
        // NOTIFICATION ACCESS
        // =========================================

        val newNotificationApps =
            newSnapshot.notificationAccessApps -
            oldSnapshot.notificationAccessApps

        newNotificationApps.forEach {

            changes.add(
                SecurityChange(
                    title = "Notification Access",
                    message = "",
                    securityType = "notification_access"
                )
            )
        }

        // =========================================
        // DEVICE ADMIN
        // =========================================

        val newDeviceAdminApps =
            newSnapshot.deviceAdminApps -
            oldSnapshot.deviceAdminApps

        newDeviceAdminApps.forEach {

            changes.add(
                SecurityChange(
                    title = "Device Admin",
                    message = "",
                    securityType = "device_admin"
                )
            )
        }

        return changes
    }
}
