package com.fraudroko.fraudroko_app.engines

object PermissionAnalyzer {

    private val normalPermissions = setOf(

        android.Manifest.permission.INTERNET,
        android.Manifest.permission.ACCESS_NETWORK_STATE,
        android.Manifest.permission.ACCESS_WIFI_STATE,
        android.Manifest.permission.VIBRATE,
        android.Manifest.permission.WAKE_LOCK,
        android.Manifest.permission.FOREGROUND_SERVICE,
        android.Manifest.permission.POST_NOTIFICATIONS

    )

    private val sensitivePermissions = setOf(

        android.Manifest.permission.CAMERA,
        android.Manifest.permission.RECORD_AUDIO,

        android.Manifest.permission.ACCESS_FINE_LOCATION,
        android.Manifest.permission.ACCESS_COARSE_LOCATION,

        android.Manifest.permission.READ_CONTACTS,
        android.Manifest.permission.WRITE_CONTACTS,

        android.Manifest.permission.READ_CALENDAR,
        android.Manifest.permission.WRITE_CALENDAR,

        android.Manifest.permission.READ_PHONE_STATE,
        android.Manifest.permission.CALL_PHONE,

        android.Manifest.permission.READ_SMS,
        android.Manifest.permission.RECEIVE_SMS,
        android.Manifest.permission.SEND_SMS,

        android.Manifest.permission.READ_EXTERNAL_STORAGE,
        android.Manifest.permission.WRITE_EXTERNAL_STORAGE,

        android.Manifest.permission.BLUETOOTH_CONNECT,
        android.Manifest.permission.BLUETOOTH_SCAN,

        android.Manifest.permission.NEARBY_WIFI_DEVICES

    )

    fun analyze(
        permissions: List<String>
    ): HashMap<String, Any> {

        val result = hashMapOf<String, Any>()

        val normal = arrayListOf<String>()
        val sensitive = arrayListOf<String>()
        val unknown = arrayListOf<String>()

        permissions.forEach { permission ->

            when {

                normalPermissions.contains(permission) ->
                    normal.add(permission)

                sensitivePermissions.contains(permission) ->
                    sensitive.add(permission)

                else ->
                    unknown.add(permission)
            }
        }

        result["normalPermissions"] = normal
        result["sensitivePermissions"] = sensitive
        result["unknownPermissions"] = unknown

        result["normalCount"] = normal.size
        result["sensitiveCount"] = sensitive.size
        result["unknownCount"] = unknown.size

        return result
    }
}