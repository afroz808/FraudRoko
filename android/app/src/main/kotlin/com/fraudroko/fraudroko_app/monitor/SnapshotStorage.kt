package com.fraudroko.fraudroko_app.monitor

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

class SnapshotStorage(
    context: Context
) {

    companion object {
        private const val PREF_NAME = "fraudroko_security"
        private const val KEY_SNAPSHOT = "security_snapshot"
    }

    private val preferences =
        context.getSharedPreferences(
            PREF_NAME,
            Context.MODE_PRIVATE
        )

    fun save(snapshot: SecuritySnapshot) {

        preferences.edit()
            .putString(
                KEY_SNAPSHOT,
                snapshotToJson(snapshot).toString()
            )
            .apply()
    }

    fun load(): SecuritySnapshot? {

        val jsonString =
            preferences.getString(KEY_SNAPSHOT, null)
                ?: return null

        return try {

            jsonToSnapshot(
                JSONObject(jsonString)
            )

        } catch (e: Exception) {

            null
        }
    }

    private fun snapshotToJson(
        snapshot: SecuritySnapshot
    ): JSONObject {

        return JSONObject().apply {

            put("timestamp", snapshot.timestamp)

            put(
                "developerOptionsEnabled",
                snapshot.developerOptionsEnabled
            )

            put(
                "usbDebuggingEnabled",
                snapshot.usbDebuggingEnabled
            )

            put(
                "screenLockEnabled",
                snapshot.screenLockEnabled
            )

            put(
                "totalApps",
                snapshot.totalApps
            )

            put(
                "safeApps",
                snapshot.safeApps
            )

            put(
                "hiddenApps",
                JSONArray(snapshot.hiddenApps)
            )

            put(
                "unknownSourceApps",
                JSONArray(snapshot.unknownSourceApps)
            )

            put(
                "accessibilityApps",
                JSONArray(snapshot.accessibilityApps)
            )

            put(
                "notificationAccessApps",
                JSONArray(snapshot.notificationAccessApps)
            )

            put(
                "deviceAdminApps",
                JSONArray(snapshot.deviceAdminApps)
            )
        }
    }

    private fun jsonToSnapshot(
        json: JSONObject
    ): SecuritySnapshot {

        return SecuritySnapshot(

            timestamp =
                json.getLong("timestamp"),

            developerOptionsEnabled =
                json.getBoolean("developerOptionsEnabled"),

            usbDebuggingEnabled =
                json.getBoolean("usbDebuggingEnabled"),

            screenLockEnabled =
                json.getBoolean("screenLockEnabled"),

            totalApps =
                json.optInt("totalApps", 0),

            safeApps =
                json.optInt("safeApps", 0),

            hiddenApps =
                if (json.has("hiddenApps")) {
                    jsonArrayToList(
                        json.getJSONArray("hiddenApps")
                    )
                } else {
                    emptyList()
                },

            unknownSourceApps =
                jsonArrayToList(
                    json.getJSONArray("unknownSourceApps")
                ),

            accessibilityApps =
                jsonArrayToList(
                    json.getJSONArray("accessibilityApps")
                ),

            notificationAccessApps =
                jsonArrayToList(
                    json.getJSONArray("notificationAccessApps")
                ),

            deviceAdminApps =
                jsonArrayToList(
                    json.getJSONArray("deviceAdminApps")
                )
        )
    }

    private fun jsonArrayToList(
        array: JSONArray
    ): List<String> {

        val list = mutableListOf<String>()

        for (i in 0 until array.length()) {
            list.add(array.getString(i))
        }

        return list
    }
}