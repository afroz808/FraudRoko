package com.fraudroko.fraudroko_app.engines

class SecurityRuleEngine {

    fun analyze(
        securitySettings: HashMap<String, Any>,
        accessibility: HashMap<String, Any>,
        notificationAccess: HashMap<String, Any>,
        deviceAdmins: HashMap<String, Any>,
        overlay: HashMap<String, Any>,
        bootloader: HashMap<String, Any>,
        installedApps: HashMap<String, Any>
    ): HashMap<String, Any> {

        var score = 100

        val safe = arrayListOf<HashMap<String, String>>()
        val warning = arrayListOf<HashMap<String, String>>()
        val critical = arrayListOf<HashMap<String, String>>()

        // Installed-app risk signals
        val apps = installedApps["apps"] as? List<*>

        val hasHiddenSuspiciousApp = apps?.any { item ->
            val app = item as? Map<*, *> ?: return@any false
            app["hiddenApp"] == true &&
                app["systemApp"] != true &&
                app["enabled"] == true &&
                app["trustedInstaller"] != true
        } == true

        val hasUnknownSourceSuspiciousApp = apps?.any { item ->
            val app = item as? Map<*, *> ?: return@any false
            val source = app["sourceType"]?.toString()?.uppercase()
            val sensitive = app["sensitivePermissions"] as? List<*>

            app["systemApp"] != true &&
                app["enabled"] == true &&
                app["trustedInstaller"] != true &&
                source in setOf(
                    "LOCAL_FILE",
                    "DOWNLOADED_FILE",
                    "OTHER_SOURCE",
                    "UNKNOWN_SOURCE"
                ) &&
                (
                    app["hiddenApp"] == true ||
                    (sensitive?.size ?: 0) >= 5
                )
        } == true

        fun addSafe(title: String, message: String) {
            safe.add(
                hashMapOf(
                    "title" to title,
                    "message" to message
                )
            )
        }

        fun addWarning(title: String, message: String, penalty: Int) {
            score -= penalty

            warning.add(
                hashMapOf(
                    "title" to title,
                    "message" to message
                )
            )
        }

        fun addCritical(title: String, message: String, penalty: Int) {
            score -= penalty

            critical.add(
                hashMapOf(
                    "title" to title,
                    "message" to message
                )
            )
        }

        // Hidden suspicious app
        if (hasHiddenSuspiciousApp) {
            addCritical(
                "Hidden App Risk",
                "A suspicious hidden app was detected.",
                20
            )
        }

        // Unknown-source suspicious app
        if (hasUnknownSourceSuspiciousApp) {
            addCritical(
                "Unknown Source App",
                "A suspicious app from an untrusted source was detected.",
                15
            )
        }

        // Screen Lock
        if (securitySettings["screenLockEnabled"] as? Boolean == true) {
            addSafe(
                "Screen Lock",
                "Your phone is protected."
            )
        } else {
            addCritical(
                "No Screen Lock",
                "Anyone can unlock your phone.",
                4
            )
        }

        // Security Patch
        val securityPatch =
            securitySettings["securityPatch"]?.toString() ?: "Unknown"

        if (
            securityPatch.isBlank() ||
            securityPatch.equals("Unknown", ignoreCase = true)
        ) {
            addCritical(
                "Security Update",
                "Security patch information is unavailable.",
                0
            )
        } else {
            addSafe(
                "Security Update",
                "Security patch information is available."
            )
        }

        // Developer Options
        if (securitySettings["developerOptionsEnabled"] as? Boolean == true) {
            addWarning(
                "Developer Options",
                "Developer options are enabled.",
                1
            )
        } else {
            addSafe(
                "Developer Options",
                "Developer options are disabled."
            )
        }

        // USB Debugging
        if (securitySettings["usbDebuggingEnabled"] as? Boolean == true) {
            addWarning(
                "USB Debugging",
                "USB debugging is enabled.",
                4
            )
        } else {
            addSafe(
                "USB Debugging",
                "USB debugging is disabled."
            )
        }

        // Root
        if (securitySettings["rootDetected"] as? Boolean == true) {
            addCritical(
                "Root Detected",
                "Root access detected.",
                25
            )
        } else {
            addSafe(
                "Root",
                "Root not detected."
            )
        }

        // Emulator
        if (securitySettings["isEmulator"] as? Boolean == true) {
            addWarning(
                "Emulator",
                "Running on emulator.",
                0
            )
        }

        // Accessibility
        val accessibilityEnabled =
            accessibility["accessibilityEnabled"] as? Boolean ?: false

        if (accessibilityEnabled) {
            addWarning(
                "Accessibility Services",
                "One or more accessibility services are enabled.",
                6
            )
        } else {
            addSafe(
                "Accessibility",
                "No accessibility services enabled."
            )
        }

        // Notification Access
        val notificationEnabled =
            notificationAccess["notificationAccessEnabled"] as? Boolean ?: false

        if (notificationEnabled) {
            // Notification access is a sensitive capability, but enabled access alone is not a
            // security issue. Legitimate apps may use it. Keep it visible for review without
            // lowering the security score.
            addSafe(
                "Notification Access",
                "Notification access is enabled. Review the apps that have this access."
            )
        } else {
            addSafe(
                "Notification Access",
                "No notification access granted."
            )
        }

        // Device Admin
        val hasAdmins =
            deviceAdmins["hasDeviceAdmins"] as? Boolean ?: false

        if (hasAdmins) {
            addWarning(
                "Device Admin",
                "Device administrator apps are active.",
                10
            )
        } else {
            addSafe(
                "Device Admin",
                "No active device administrators."
            )
        }

        // Overlay
        val overlayEnabled =
            overlay["overlayEnabled"] as? Boolean ?: false

        if (overlayEnabled) {
            addWarning(
                "Overlay Apps",
                "Apps can display over other apps.",
                4
            )
        } else {
            addSafe(
                "Overlay",
                "No overlay permission detected."
            )
        }

        // Bootloader
        val unlocked =
            bootloader["bootloaderUnlocked"] as? Boolean ?: false

        if (unlocked) {
            addWarning(
                "Bootloader",
                "Bootloader appears unlocked.",
                8
            )
        } else {
            addSafe(
                "Bootloader",
                "Bootloader appears locked."
            )
        }

        if (score < 0) score = 0
        if (score > 100) score = 100

        return hashMapOf(
            "score" to score,
            "safe" to safe,
            "warning" to warning,
            "critical" to critical
        )
    }
}