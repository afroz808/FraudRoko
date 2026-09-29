package com.fraudroko.fraudroko_app.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import com.fraudroko.fraudroko_app.notifications.NotificationHelper
import com.fraudroko.fraudroko_app.providers.InstalledAppsProvider

class AppInstallReceiver : BroadcastReceiver() {

    companion object {
        // Security incident मिलने के बाद notification लगभग 15–20 sec
        // के अंदर दिखेगी।
        private const val NOTIFICATION_DELAY_MS = 15_000L
    }

    override fun onReceive(
        context: Context,
        intent: Intent
    ) {

        val packageName =
            intent.data?.schemeSpecificPart ?: return

        when (intent.action) {

            Intent.ACTION_PACKAGE_ADDED -> {

                // App update को नया install incident नहीं मानेंगे।
                if (
                    intent.getBooleanExtra(
                        Intent.EXTRA_REPLACING,
                        false
                    )
                ) {
                    return
                }

                Handler(Looper.getMainLooper()).postDelayed({

                    val app =
                        InstalledAppsProvider(context)
                            .getApp(packageName)
                            ?: return@postDelayed

                    @Suppress("UNCHECKED_CAST")
                    val installer =
                        app["installer"] as? Map<String, Any?>

                    val trustedInstaller =
                        installer?.get("trusted") as? Boolean ?: false

                    val installerName =
                        installer?.get("installerName") as? String
                            ?: "Unknown Source"

                    val appName =
                        app["appName"] as? String ?: packageName

                    val hiddenApp =
                        app["hiddenApp"] as? Boolean ?: false

                    /*
                     * IMPORTANT:
                     *
                     * Normal / trusted app:
                     *     कोई notification नहीं.
                     *
                     * Outside-source app:
                     *     security alert.
                     *
                     * Hidden third-party app:
                     *     security alert.
                     *
                     * Permission count alone:
                     *     notification नहीं.
                     */

                    when {

                        hiddenApp && !trustedInstaller -> {

                            NotificationHelper(context)
                                .showSecurityAlert(
                                    title = "🚨 FraudRoko Alert",
                                    message =
                                        "$appName एक hidden third-party app के रूप में मिला। कृपया इसे verify करें।",
                                    notificationId =
                                        packageName.hashCode()
                                )
                        }

                        !trustedInstaller -> {

                            NotificationHelper(context)
                                .showSecurityAlert(
                                    title = "🟠 FraudRoko Alert",
                                    message =
                                        "$appName $installerName से install हुआ है। अगर आपने इसे खुद install नहीं किया है, तो इसे verify करें।",
                                    notificationId =
                                        packageName.hashCode()
                                )
                        }

                        else -> {
                            // Trusted / official-store app.
                            // कोई notification नहीं.
                        }
                    }

                }, NOTIFICATION_DELAY_MS)
            }

            Intent.ACTION_PACKAGE_REMOVED -> {
                // App removal अपने आप में security incident नहीं है।
                // इसलिए कोई notification नहीं.
            }
        }
    }
}