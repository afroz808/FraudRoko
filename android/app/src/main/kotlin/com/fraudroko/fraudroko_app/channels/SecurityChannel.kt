package com.fraudroko.fraudroko_app.channels

import android.content.Context
import com.fraudroko.fraudroko_app.providers.SecurityReportProvider
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class SecurityChannel(
    messenger: BinaryMessenger,
    private val context: Context
) : MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL = "com.fraudroko/security"
    }

    private val channel =
        MethodChannel(messenger, CHANNEL)

    private val securityReportProvider =
        SecurityReportProvider(context)

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result
    ) {

        when (call.method) {

            "getSecurityReport" -> {
                result.success(
                    securityReportProvider.getSecurityReport()
                )
            }

            "getDailySecurityReports" -> {
                result.success(
                    getDailySecurityReports()
                )
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun getAppName(packageName: String): String {
        if (packageName.isBlank()) {
            return packageName
        }

        return try {
            val applicationInfo =
                context.packageManager.getApplicationInfo(
                    packageName,
                    0
                )

            context.packageManager
                .getApplicationLabel(applicationInfo)
                .toString()
                .ifBlank { packageName }

        } catch (_: Exception) {
            packageName
        }
    }

    private fun appNamesFromJsonArray(
        array: org.json.JSONArray?
    ): List<String> {
        if (array == null) {
            return emptyList()
        }

        val names = ArrayList<String>()

        for (i in 0 until array.length()) {
            val packageName = array.optString(i)

            if (packageName.isNotBlank()) {
                names.add(getAppName(packageName))
            }
        }

        return names.distinct().sorted()
    }

    private fun appDetailsFromJsonArray(
        array: org.json.JSONArray?
    ): List<HashMap<String, String>> {
        if (array == null) {
            return emptyList()
        }

        val details = ArrayList<HashMap<String, String>>()

        for (i in 0 until array.length()) {
            val packageName = array.optString(i)

            if (packageName.isBlank()) {
                continue
            }

            details.add(
                hashMapOf(
                    "packageName" to packageName,
                    "appName" to getAppName(packageName)
                )
            )
        }

        return details
    }

    private fun getDailySecurityReports():
        ArrayList<HashMap<String, Any>> {

        val storage =
            com.fraudroko.fraudroko_app.monitor
                .DailySecurityReportStorage(context)

        val reports =
            ArrayList<HashMap<String, Any>>()

        for (report in storage.getAllReports()) {

            val item =
                hashMapOf<String, Any>(
                    "day" to report.optString("day"),
                    "timestamp" to report.optLong("timestamp"),
                    "developerOptionsEnabled" to
                        report.optBoolean("developerOptionsEnabled"),
                    "usbDebuggingEnabled" to
                        report.optBoolean("usbDebuggingEnabled"),
                    "screenLockEnabled" to
                        report.optBoolean("screenLockEnabled"),
                    "hiddenApps" to
                        appNamesFromJsonArray(report.optJSONArray("hiddenApps")),
                    "hiddenAppPackages" to
                        jsonArrayToList(report.optJSONArray("hiddenApps")),
                    "unknownSourceApps" to
                        appNamesFromJsonArray(report.optJSONArray("unknownSourceApps")),
                    "unknownSourceAppPackages" to
                        jsonArrayToList(report.optJSONArray("unknownSourceApps")),
                    "accessibilityApps" to
                        appNamesFromJsonArray(report.optJSONArray("accessibilityApps")),
                    "accessibilityAppPackages" to
                        jsonArrayToList(report.optJSONArray("accessibilityApps")),
                    "notificationAccessApps" to
                        appNamesFromJsonArray(report.optJSONArray("notificationAccessApps")),
                    "notificationAccessAppPackages" to
                        jsonArrayToList(report.optJSONArray("notificationAccessApps")),
                    "deviceAdminApps" to
                        appNamesFromJsonArray(report.optJSONArray("deviceAdminApps")),
                    "deviceAdminAppPackages" to
                        jsonArrayToList(report.optJSONArray("deviceAdminApps")),
                    "hiddenAppDetails" to
                        appDetailsFromJsonArray(report.optJSONArray("hiddenApps")),
                    "unknownSourceAppDetails" to
                        appDetailsFromJsonArray(report.optJSONArray("unknownSourceApps")),
                    "accessibilityAppDetails" to
                        appDetailsFromJsonArray(report.optJSONArray("accessibilityApps")),
                    "notificationAccessAppDetails" to
                        appDetailsFromJsonArray(report.optJSONArray("notificationAccessApps")),
                    "deviceAdminAppDetails" to
                        appDetailsFromJsonArray(report.optJSONArray("deviceAdminApps"))
                )

            reports.add(item)
        }

        return reports
    }

    private fun jsonArrayToList(
        array: org.json.JSONArray?
    ): ArrayList<String> {

        val list =
            ArrayList<String>()

        if (array == null) {
            return list
        }

        for (i in 0 until array.length()) {
            val value =
                array.optString(i)

            if (value.isNotBlank()) {
                list.add(value)
            }
        }

        return list
    }


}
