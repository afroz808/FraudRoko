package com.fraudroko.fraudroko_app.workers

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import java.util.Calendar
import java.util.concurrent.TimeUnit
import com.fraudroko.fraudroko_app.monitor.DailySecurityReportStorage
import com.fraudroko.fraudroko_app.monitor.SecurityChangeDetector
import com.fraudroko.fraudroko_app.monitor.SecurityMonitor
import com.fraudroko.fraudroko_app.monitor.SnapshotStorage
import com.fraudroko.fraudroko_app.notifications.NotificationHelper

class SecurityWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    private val monitor =
        SecurityMonitor(context)

    private val storage =
        SnapshotStorage(context)

    private val dailyStorage =
        DailySecurityReportStorage(context)

    private val detector =
        SecurityChangeDetector()

    private val notificationHelper =
        NotificationHelper(context)

    private fun scheduleNextSecurityCheck() {

        val now =
            Calendar.getInstance()

        val nextCheck =
            Calendar.getInstance().apply {

                val hour =
                    now.get(Calendar.HOUR_OF_DAY)

                when {
                    hour < 9 -> {
                        set(Calendar.HOUR_OF_DAY, 9)
                    }

                    hour < 15 -> {
                        set(Calendar.HOUR_OF_DAY, 15)
                    }

                    hour < 19 -> {
                        set(Calendar.HOUR_OF_DAY, 19)
                    }

                    else -> {
                        add(
                            Calendar.DAY_OF_YEAR,
                            1
                        )

                        set(
                            Calendar.HOUR_OF_DAY,
                            9
                        )
                    }
                }

                set(
                    Calendar.MINUTE,
                    0
                )

                set(
                    Calendar.SECOND,
                    0
                )

                set(
                    Calendar.MILLISECOND,
                    0
                )
            }

        val delay =
            (
                nextCheck.timeInMillis -
                now.timeInMillis
            ).coerceAtLeast(0L)

        val request =
            OneTimeWorkRequestBuilder<SecurityWorker>()
                .setInitialDelay(
                    delay,
                    TimeUnit.MILLISECONDS
                )
                .build()

        WorkManager.getInstance(applicationContext)
            .enqueueUniqueWork(
                "FraudRokoSecurityMonitor",
                ExistingWorkPolicy.REPLACE,
                request
            )
    }

    override suspend fun doWork(): Result {

        return try {

            val previousSnapshot =
                storage.load()

            val currentSnapshot =
                monitor.createSnapshot()

            /*
             * Save every real background check.
             * These snapshots are later used for the 9 PM report.
             */
            dailyStorage.saveCheck(
                currentSnapshot
            )

            /*
             * Existing security-change detection stays active.
             */
            val changes =
                detector.detectChanges(
                    previousSnapshot,
                    currentSnapshot
                )

            /*
             * Notification Access changes are intentionally
             * excluded from standalone background alerts,
             * matching the existing FraudRoko behaviour.
             */
            val actionableChanges =
                changes.filter {
                    it.securityType != "notification_access"
                }

            if (actionableChanges.isNotEmpty()) {

                val securityType =
                    if (actionableChanges.size == 1) {
                        actionableChanges.first()
                            .securityType
                    } else {
                        "security_changes"
                    }

                val packageName =
                    if (actionableChanges.size == 1) {
                        actionableChanges.first()
                            .packageName
                    } else {
                        ""
                    }

                notificationHelper.showSecurityAlert(
                    title =
                        "🚨 FraudRoko Alert",
                    message =
                        "",
                    notificationId =
                        2000,
                    packageName =
                        packageName,
                    securityType =
                        securityType
                )
            }

            /*
             * Save current state so the same change
             * does not repeatedly trigger an alert.
             */
            storage.save(
                currentSnapshot
            )

            /*
             * Schedule the next daily security check.
             *
             * Daily check windows:
             * 09:00
             * 15:00
             * 19:00
             *
             * After the 19:00 check, the next check is
             * scheduled for 09:00 on the following day.
             */
            scheduleNextSecurityCheck()

            Result.success()

        } catch (e: Exception) {

            e.printStackTrace()

            Result.retry()
        }
    }
}
