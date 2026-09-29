package com.fraudroko.fraudroko_app.workers

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.fraudroko.fraudroko_app.monitor.DailySecurityReportStorage
import com.fraudroko.fraudroko_app.notifications.NotificationHelper

class DailySecurityReportWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    private val storage =
        DailySecurityReportStorage(context)

    private val notificationHelper =
        NotificationHelper(context)

    override suspend fun doWork(): Result {

        return try {

            // आज की 3 security checks
            val checks =
                storage.getTodayChecks()

            // आज की report पहले ही भेजी जा चुकी है
            if (storage.hasTodayReportSent()) {
                return Result.success()
            }

            if (checks.isEmpty()) {
                return Result.success()
            }

            val latest =
                checks.last()

            val totalChecks =
                checks.size

            val hiddenApps =
                latest.optJSONArray("hiddenApps")?.length() ?: 0

            val unknownApps =
                latest.optJSONArray("unknownSourceApps")?.length() ?: 0

            val deviceAdminApps =
                latest.optJSONArray("deviceAdminApps")?.length() ?: 0

            val usbDebugging =
                latest.optBoolean(
                    "usbDebuggingEnabled",
                    false
                )

            // Daily Report contains only meaningful security risks.
            val problemCount =
                hiddenApps +
                unknownApps +
                deviceAdminApps +
                if (usbDebugging) 1 else 0

            val title =
                "📊 FraudRoko Daily Security Report"

            val message =
                if (problemCount == 0) {

                    "आज आपके फोन की सुरक्षा ठीक रही। " +
                    "$totalChecks सुरक्षा जाँच पूरी हुईं। " +
                    "कोई बड़ी समस्या नहीं मिली।"

                } else {

                    "आज आपके फोन की सुरक्षा जाँची गई। " +
                    "$totalChecks जाँचों में " +
                    "$problemCount सुरक्षा से जुड़ी बातें मिलीं। " +
                    "कृपया FraudRoko में जाकर उन्हें देखें।"
                }

            val savedReport =
                org.json.JSONObject().apply {
                    put("title", title)
                    put("message", message)
                    put("totalChecks", totalChecks)
                    put("hiddenApps", hiddenApps)
                    put("unknownApps", unknownApps)
                    put("deviceAdminApps", deviceAdminApps)
                    put("usbDebugging", usbDebugging)
                    put("problemCount", problemCount)
                }

            storage.saveDailyReport(savedReport)

            notificationHelper.showSecurityAlert(
                title = title,
                message = message,
                notificationId = 9001,
                securityType = "daily_security_report"
            )

            storage.markTodayReportSent()

            Result.success()

        } catch (e: Exception) {

            e.printStackTrace()

            Result.retry()
        }
    }
}
