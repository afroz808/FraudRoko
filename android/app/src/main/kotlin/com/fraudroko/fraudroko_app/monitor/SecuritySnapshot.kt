package com.fraudroko.fraudroko_app.monitor

data class SecuritySnapshot(

    val timestamp: Long,

    val developerOptionsEnabled: Boolean,

    val usbDebuggingEnabled: Boolean,

    val screenLockEnabled: Boolean,

    val totalApps: Int,

    val safeApps: Int,

    val hiddenApps: List<String>,

    val unknownSourceApps: List<String>,

    val accessibilityApps: List<String>,

    val notificationAccessApps: List<String>,

    val deviceAdminApps: List<String>

)
