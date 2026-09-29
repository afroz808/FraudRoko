package com.fraudroko.fraudroko_app.monitor

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

class DailySecurityReportStorage(
    context: Context
) {

    companion object {
        private const val PREF_NAME = "fraudroko_daily_security_report"
        private const val KEY_REPORTS = "reports"
    }

    private val prefs =
        context.getSharedPreferences(
            PREF_NAME,
            Context.MODE_PRIVATE
        )

    fun saveCheck(snapshot: SecuritySnapshot) {

        val reports =
            loadReports().toMutableList()

        val today =
            dayKey(snapshot.timestamp)

        reports.removeAll {
            it.optString("day") == today &&
            it.optLong("timestamp") == snapshot.timestamp
        }

        reports.add(
            JSONObject().apply {
                put("day", today)
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
        )

        while (reports.size > 21) {
            reports.removeAt(0)
        }

        saveReports(reports)
    }

    fun getTodayChecks(): List<JSONObject> {

        val today =
            dayKey(System.currentTimeMillis())

        return loadReports()
            .filter {
                it.optString("day") == today
            }
            .sortedBy {
                it.optLong("timestamp")
            }
    }

    fun saveDailyReport(report: JSONObject) {

        val reports =
            loadDailyReports().toMutableList()

        val today =
            dayKey(System.currentTimeMillis())

        reports.removeAll {
            it.optString("day") == today
        }

        report.put("day", today)
        report.put(
            "timestamp",
            System.currentTimeMillis()
        )

        reports.add(report)

        // Keep a rolling 7-day history.
        // Reports older than 7 days are removed automatically.
        val cutoff = System.currentTimeMillis() - (7L * 24L * 60L * 60L * 1000L)

        reports.removeAll {
            it.optLong("timestamp") < cutoff
        }

        val array = JSONArray()

        reports.forEach {
            array.put(it)
        }

        prefs.edit()
            .putString(
                "daily_reports",
                array.toString()
            )
            .apply()
    }

    fun getDailyReports(): List<JSONObject> {

        return cleanupDailyReports()
            .sortedByDescending {
                it.optLong("timestamp")
            }
    }

    private fun cleanupDailyReports(): List<JSONObject> {

        val reports = loadDailyReports()
            .sortedByDescending {
                it.optLong("timestamp")
            }

        val cleaned = ArrayList<JSONObject>()
        val reportsPerDay = HashMap<String, Int>()

        for (report in reports) {

            val day = report.optString("day")

            if (day.isBlank()) {
                continue
            }

            val count = reportsPerDay[day] ?: 0

            // Keep maximum 2 reports for one date.
            if (count >= 2) {
                continue
            }

            cleaned.add(report)
            reportsPerDay[day] = count + 1
        }

        val array = JSONArray()

        cleaned
            .sortedBy {
                it.optLong("timestamp")
            }
            .forEach {
                array.put(it)
            }

        prefs.edit()
            .putString(
                "daily_reports",
                array.toString()
            )
            .apply()

        return cleaned
    }


    private fun loadDailyReports(): List<JSONObject> {

        val raw =
            prefs.getString(
                "daily_reports",
                null
            ) ?: return emptyList()

        return try {

            val array = JSONArray(raw)

            buildList {
                for (i in 0 until array.length()) {
                    add(array.getJSONObject(i))
                }
            }

        } catch (_: Exception) {

            emptyList()
        }
    }


    fun getAllReports(): List<JSONObject> {
        return loadReports()
            .sortedByDescending {
                it.optLong("timestamp")
            }
    }

    fun hasTodayReportSent(): Boolean {

        val today =
            dayKey(System.currentTimeMillis())

        return prefs.getString(
            "last_report_day",
            ""
        ) == today
    }

    fun markTodayReportSent() {

        prefs.edit()
            .putString(
                "last_report_day",
                dayKey(System.currentTimeMillis())
            )
            .apply()
    }

    private fun loadReports(): List<JSONObject> {

        val raw =
            prefs.getString(
                KEY_REPORTS,
                null
            ) ?: return emptyList()

        return try {

            val array =
                JSONArray(raw)

            buildList {

                for (i in 0 until array.length()) {
                    add(array.getJSONObject(i))
                }
            }

        } catch (_: Exception) {

            emptyList()
        }
    }

    private fun saveReports(
        reports: List<JSONObject>
    ) {

        val array = JSONArray()

        reports.forEach {
            array.put(it)
        }

        prefs.edit()
            .putString(
                KEY_REPORTS,
                array.toString()
            )
            .apply()
    }

    private fun dayKey(
        timestamp: Long
    ): String {

        val calendar =
            java.util.Calendar
                .getInstance()
                .apply {
                    timeInMillis = timestamp
                }

        return String.format(
            java.util.Locale.US,
            "%04d-%02d-%02d",
            calendar.get(
                java.util.Calendar.YEAR
            ),
            calendar.get(
                java.util.Calendar.MONTH
            ) + 1,
            calendar.get(
                java.util.Calendar.DAY_OF_MONTH
            )
        )
    }
}
