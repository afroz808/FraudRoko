package com.fraudroko.fraudroko_app

import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.fraudroko.fraudroko_app.channels.SecurityChannel
import com.fraudroko.fraudroko_app.channels.SettingsChannel
import com.fraudroko.fraudroko_app.channels.AppSettingsChannel
import com.fraudroko.fraudroko_app.channels.AppIconChannel
import com.fraudroko.fraudroko_app.notifications.FraudRokoNotification
import com.fraudroko.fraudroko_app.workers.SecurityWorker
import com.fraudroko.fraudroko_app.workers.DailySecurityReportWorker
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {

    private var securityChannel: SecurityChannel? = null
    private var appIconChannel: AppIconChannel? = null

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        FraudRokoNotification.createChannel(
            applicationContext
        )

        securityChannel =
            SecurityChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                this
            )

        SettingsChannel(
            applicationContext,
            flutterEngine.dartExecutor.binaryMessenger
        )

        AppSettingsChannel(
            applicationContext,
            flutterEngine.dartExecutor.binaryMessenger
        )

        appIconChannel =
            AppIconChannel(
                applicationContext,
                flutterEngine.dartExecutor.binaryMessenger
            )

        scheduleInitialSecurityCheck()
        scheduleDailyReportWorker()
    }

    private fun scheduleInitialSecurityCheck() {

        val workRequest =
            OneTimeWorkRequestBuilder<SecurityWorker>()
                .build()

        WorkManager.getInstance(applicationContext)
            .enqueueUniqueWork(
                "FraudRokoInitialSecurityCheck",
                ExistingWorkPolicy.KEEP,
                workRequest
            )
    }


    private fun scheduleSecurityWorker() {

        val now =
            java.util.Calendar.getInstance()

        val nextCheck =
            java.util.Calendar.getInstance().apply {

                val hour =
                    now.get(java.util.Calendar.HOUR_OF_DAY)

                val nextHour =
                    when {
                        hour < 9 -> 9
                        hour < 15 -> 15
                        hour < 19 -> 19
                        else -> 9
                    }

                if (hour >= 19) {
                    add(
                        java.util.Calendar.DAY_OF_YEAR,
                        1
                    )
                }

                set(
                    java.util.Calendar.HOUR_OF_DAY,
                    nextHour
                )
                set(
                    java.util.Calendar.MINUTE,
                    0
                )
                set(
                    java.util.Calendar.SECOND,
                    0
                )
                set(
                    java.util.Calendar.MILLISECOND,
                    0
                )
            }

        val delay =
            nextCheck.timeInMillis -
            now.timeInMillis

        val workRequest =
            OneTimeWorkRequestBuilder<SecurityWorker>()
                .setInitialDelay(
                    delay,
                    TimeUnit.MILLISECONDS
                )
                .build()

        WorkManager.getInstance(applicationContext)
            .enqueueUniqueWork(
                "FraudRokoSecurityMonitor",
                ExistingWorkPolicy.KEEP,
                workRequest
            )
    }


    private fun scheduleDailyReportWorker() {

        val now =
            java.util.Calendar.getInstance()

        val nextNinePm =
            java.util.Calendar.getInstance().apply {
                set(
                    java.util.Calendar.HOUR_OF_DAY,
                    21
                )
                set(
                    java.util.Calendar.MINUTE,
                    0
                )
                set(
                    java.util.Calendar.SECOND,
                    0
                )
                set(
                    java.util.Calendar.MILLISECOND,
                    0
                )

                if (!after(now)) {
                    add(
                        java.util.Calendar.DAY_OF_YEAR,
                        1
                    )
                }
            }

        val delay =
            nextNinePm.timeInMillis -
            now.timeInMillis

        val reportRequest =
            androidx.work.PeriodicWorkRequestBuilder<
                DailySecurityReportWorker
            >(
                24,
                TimeUnit.HOURS
            )
                .setInitialDelay(
                    delay,
                    TimeUnit.MILLISECONDS
                )
                .build()

        WorkManager.getInstance(applicationContext)
            .enqueueUniquePeriodicWork(
                "FraudRokoDailySecurityReport",
                ExistingPeriodicWorkPolicy.UPDATE,
                reportRequest
            )
    }
}