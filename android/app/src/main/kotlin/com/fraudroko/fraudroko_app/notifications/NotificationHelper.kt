package com.fraudroko.fraudroko_app.notifications

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.fraudroko.fraudroko_app.MainActivity
import com.fraudroko.fraudroko_app.R

class NotificationHelper(
    private val context: Context
) {

    companion object {

        const val CHANNEL_ID = "fraudroko_security"

        const val CHANNEL_NAME = "Security Alerts"

        const val CHANNEL_DESCRIPTION =
            "FraudRoko Security Notifications"
    }

    init {
        createNotificationChannel()
    }

    private fun createNotificationChannel() {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            )

            channel.description =
                CHANNEL_DESCRIPTION

            channel.enableLights(true)
            channel.enableVibration(true)

            val manager =
                context.getSystemService(
                    NotificationManager::class.java
                )

            manager.createNotificationChannel(channel)
        }
    }

    private fun getSelectedLanguage(): String {

        val prefs =
            context.getSharedPreferences(
                "FlutterSharedPreferences",
                Context.MODE_PRIVATE
            )

        return prefs.getString(
            "flutter.selected_language",
            "hi"
        ) ?: "hi"
    }

    private fun reviewActionText(): String {

        return when (getSelectedLanguage()) {

            "mr" -> "आता तपासा →"

            "en" -> "Review now →"

            else -> "अभी जाँच करें →"
        }
    }

    private fun reviewButtonText(): String {

        return when (getSelectedLanguage()) {

            "mr" -> "तपासा"

            "en" -> "Review"

            else -> "जाँच करें"
        }
    }

    /*
     * =========================================================
     * NOTIFICATION ACCESS
     * =========================================================
     */

    private fun localizedNotificationAccessTitle(
        packageName: String
    ): String {

        val appName =
            if (packageName.isNotBlank()) {

                try {

                    context.packageManager
                        .getApplicationInfo(
                            packageName,
                            0
                        )
                        .loadLabel(
                            context.packageManager
                        )
                        .toString()

                } catch (_: Exception) {

                    packageName
                }

            } else {

                ""
            }

        return when (getSelectedLanguage()) {

            "mr" -> {

                if (appName.isNotBlank()) {
                    "सूचना प्रवेश: $appName"
                } else {
                    "सूचना प्रवेश सुरू आहे"
                }
            }

            "en" -> {

                if (appName.isNotBlank()) {
                    "Notification access: $appName"
                } else {
                    "Notification access enabled"
                }
            }

            else -> {

                if (appName.isNotBlank()) {
                    "नोटिफिकेशन एक्सेस: $appName"
                } else {
                    "नोटिफिकेशन एक्सेस चालू है"
                }
            }
        }
    }

    private fun localizedNotificationAccessMessage(
        packageName: String
    ): String {

        val appName =
            if (packageName.isNotBlank()) {

                try {

                    context.packageManager
                        .getApplicationInfo(
                            packageName,
                            0
                        )
                        .loadLabel(
                            context.packageManager
                        )
                        .toString()

                } catch (_: Exception) {

                    packageName
                }

            } else {

                ""
            }

        return when (getSelectedLanguage()) {

            "mr" -> {

                if (appName.isNotBlank()) {

                    "$appName तुमच्या सूचना वाचू शकते. " +
                        "तुम्ही या अॅपला परवानगी दिली नसेल तर ते तपासा."

                } else {

                    "एका अॅपला तुमच्या सूचना वाचण्याची परवानगी मिळाली आहे. " +
                        "तुम्ही परवानगी दिली नसेल तर ते तपासा."
                }
            }

            "en" -> {

                if (appName.isNotBlank()) {

                    "$appName can read your notifications. " +
                        "Review it if you do not recognize this app."

                } else {

                    "An app can read your notifications. " +
                        "Review it if you did not grant this access."
                }
            }

            else -> {

                if (appName.isNotBlank()) {

                    "$appName आपकी notifications पढ़ सकता है। " +
                        "अगर आपने इसे अनुमति नहीं दी है, तो इसे जाँचें।"

                } else {

                    "एक ऐप को आपकी notifications पढ़ने की अनुमति मिली है। " +
                        "अगर आपने अनुमति नहीं दी है, तो इसे जाँचें।"
                }
            }
        }
    }

    /*
     * =========================================================
     * CENTRAL TITLE LOCALIZATION
     * =========================================================
     */

    private fun getLocalizedTitle(
        title: String,
        securityType: String
    ): String {

        return when (getSelectedLanguage()) {

            "mr" -> when (securityType) {

                "accessibility" ->
                    "Accessibility प्रवेश"

                "device_admin" ->
                    "डिव्हाइस अॅडमिन"

                "overlay" ->
                    "ओव्हरले परवानगी सुरू आहे"

                "developer_options" ->
                    "डेव्हलपर पर्याय सुरू आहेत"

                "usb_debugging" ->
                    "USB डीबगिंग सुरू आहे"

                "screen_lock" ->
                    "फोनची सुरक्षा कमकुवत झाली"

                "unknown_source_app" ->
                    "बाहेरील स्रोतावरून ॲप इंस्टॉल झाले"

                "critical_screen_lock" ->
                    "गंभीर: स्क्रीन लॉक नाही"

                "critical_root" ->
                    "गंभीर: Root आढळले"

                "security_changes" ->
                    "फोनच्या सुरक्षेत बदल आढळले"

                else ->
                    title
            }

            "en" -> when (securityType) {

                "accessibility" ->
                    "Accessibility Access"

                "device_admin" ->
                    "Device Admin"

                "overlay" ->
                    "Overlay Permission Enabled"

                "developer_options" ->
                    "Developer Options Enabled"

                "usb_debugging" ->
                    "USB Debugging Enabled"

                "screen_lock" ->
                    "Phone Security Weakened"

                "unknown_source_app" ->
                    "App Installed From Outside Source"

                "critical_screen_lock" ->
                    "Critical: No Screen Lock"

                "critical_root" ->
                    "Critical: Root Detected"

                "security_changes" ->
                    "Security Changes Detected"

                else ->
                    title
            }

            else -> when (securityType) {

                "accessibility" ->
                    "Accessibility access"

                "device_admin" ->
                    "Device Admin"

                "overlay" ->
                    "ओवरले अनुमति चालू है"

                "developer_options" ->
                    "डेवलपर विकल्प चालू हैं"

                "usb_debugging" ->
                    "USB Debugging चालू है"

                "screen_lock" ->
                    "फोन की सुरक्षा कमजोर हुई"

                "unknown_source_app" ->
                    "बाहर से ऐप इंस्टॉल हुआ"

                "critical_screen_lock" ->
                    "गंभीर: स्क्रीन लॉक नहीं है"

                "critical_root" ->
                    "गंभीर: Root मिला"

                "security_changes" ->
                    "फोन की सुरक्षा में बदलाव मिले हैं"

                else ->
                    title
            }
        }
    }

    /*
     * =========================================================
     * CENTRAL MESSAGE LOCALIZATION
     * =========================================================
     */

    private fun getLocalizedMessage(
        message: String,
        securityType: String
    ): String {

        return when (getSelectedLanguage()) {

            "mr" -> when (securityType) {

                "accessibility" ->
                    "एका अॅपला Accessibility प्रवेश मिळाला आहे. " +
                        "तुम्ही ही परवानगी दिली नसेल तर तपासा."

                "device_admin" ->
                    "एका अॅपला फोनवर विशेष नियंत्रण मिळाले आहे. " +
                        "तुम्ही ही परवानगी दिली नसेल तर तपासा."

                "overlay" ->
                    "एका अॅपला इतर अॅप्सच्या वर सामग्री दाखवण्याची परवानगी आहे. " +
                        "तुम्ही ही परवानगी दिली नसेल तर तपासा."

                "developer_options" ->
                    "डेव्हलपर पर्याय सुरू आहेत. " +
                        "तुम्ही ते सुरू केले नसल्यास तपासा."

                "usb_debugging" ->
                    "USB डीबगिंग सुरू आहे. " +
                        "तुम्ही ते सुरू केले नसल्यास तपासा."

                "screen_lock" ->
                    "स्क्रीन लॉक काढण्यात आला आहे. " +
                        "तुमच्या फोनवर स्क्रीन लॉक लावा."

                "unknown_source_app" ->
                    "एक अॅप Play Store च्या बाहेरून इंस्टॉल झाले आहे. " +
                        "तुम्ही ते स्वतः इंस्टॉल केले नसेल तर तपासा."

                "critical_screen_lock" ->
                    "तुमच्या फोनवर स्क्रीन लॉक नाही. " +
                        "फोनवर प्रत्यक्ष प्रवेश असलेली व्यक्ती तो अनलॉक करू शकते."

                "critical_root" ->
                    "या डिव्हाइसवर Root access आढळला आहे. " +
                        "तुमच्या फोनची सुरक्षा तपासा."

                "security_changes" ->
                    "तुमच्या फोनच्या सुरक्षेत अनेक बदल आढळले आहेत. " +
                        "कृपया ते तपासा."

                else ->
                    message
            }

            "en" -> when (securityType) {

                "accessibility" ->
                    "An app has Accessibility access. " +
                        "Review it if you did not grant this permission."

                "device_admin" ->
                    "An app has device administrator privileges. " +
                        "Review it if you did not grant this permission."

                "overlay" ->
                    "An app can display content over other apps. " +
                        "Review this permission if you did not grant it."

                "developer_options" ->
                    "Developer Options are enabled. " +
                        "Review them if you did not enable them."

                "usb_debugging" ->
                    "USB debugging is enabled. " +
                        "Review Developer Options if you did not enable it."

                "screen_lock" ->
                    "The screen lock has been removed. " +
                        "Set a screen lock on your phone."

                "unknown_source_app" ->
                    "An app was installed from outside the Play Store. " +
                        "Review it if you did not install it."

                "critical_screen_lock" ->
                    "Your phone does not have a screen lock. " +
                        "Anyone with physical access may be able to unlock it."

                "critical_root" ->
                    "Root access was detected on this device. " +
                        "Review your device security configuration."

                "security_changes" ->
                    "Multiple security changes were detected on your phone. " +
                        "Please review them."

                else ->
                    message
            }

            else -> when (securityType) {

                "accessibility" ->
                    "एक ऐप को Accessibility access मिला है। " +
                        "अगर आपने यह अनुमति नहीं दी है, तो जाँचें।"

                "device_admin" ->
                    "एक ऐप को फोन का विशेष control मिला है। " +
                        "अगर आपने यह अनुमति नहीं दी है, तो जाँचें।"

                "overlay" ->
                    "एक ऐप दूसरे ऐप्स के ऊपर content दिखा सकता है। " +
                        "अगर आपने यह अनुमति नहीं दी है, तो जाँचें।"

                "developer_options" ->
                    "डेवलपर विकल्प चालू हैं। " +
                        "अगर आपने इन्हें चालू नहीं किया है, तो जाँचें।"

                "usb_debugging" ->
                    "USB Debugging चालू है। " +
                        "अगर आपने इसे चालू नहीं किया है, तो Developer Options जाँचें।"

                "screen_lock" ->
                    "फोन का Screen Lock हटा दिया गया है। " +
                        "अपने फोन पर Screen Lock लगाएँ।"

                "unknown_source_app" ->
                    "एक ऐप Play Store के बाहर से इंस्टॉल हुआ है। " +
                        "अगर आपने इसे खुद इंस्टॉल नहीं किया है, तो जाँचें।"

                "critical_screen_lock" ->
                    "आपके फोन में Screen Lock नहीं है। " +
                        "अपने फोन पर Screen Lock लगाएँ।"

                "critical_root" ->
                    "इस फोन में Root access पाया गया है। " +
                        "अपनी device security settings जाँचें।"

                "security_changes" ->
                    "आपके फोन की सुरक्षा में कई बदलाव मिले हैं। " +
                        "कृपया उन्हें जाँचें।"

                else ->
                    message
            }
        }
    }

    /*
     * =========================================================
     * SHOW SECURITY ALERT
     * =========================================================
     */

    fun showSecurityAlert(
        title: String,
        message: String,
        notificationId: Int,
        packageName: String = "",
        securityType: String = ""
    ) {
        // FRAUDROKO_NOTIFICATION_LANGUAGE_FIX
        val fraudRokoLanguage = getSelectedLanguage()

        fun fraudRokoLocalizedTitle(original: String): String {
            return when (fraudRokoLanguage) {
                "hi" -> when {
                    securityType == "hidden_app" ->
                        if (original.contains(":"))
                            "छुपा हुआ खतरनाक ऐप:" + original.substringAfter(":")
                        else "छुपा हुआ खतरनाक ऐप मिला"

                    securityType == "accessibility" ->
                        if (original.contains(":"))
                            "एक्सेसिबिलिटी की अनुमति:" + original.substringAfter(":")
                        else "एक्सेसिबिलिटी की अनुमति चालू है"

                    securityType == "device_admin" ->
                        if (original.contains(":"))
                            "फोन का विशेष नियंत्रण:" + original.substringAfter(":")
                        else "फोन का विशेष नियंत्रण चालू है"

                    securityType == "overlay" ->
                        "दूसरे ऐप के ऊपर दिखने की अनुमति चालू है"

                    securityType == "developer_options" ->
                        "डेवलपर विकल्प चालू हैं"

                    securityType == "usb_debugging" ->
                        "USB डिबगिंग चालू है"

                    original == "Encryption" ->
                        "एन्क्रिप्शन"

                    original == "No Screen Lock" ||
                    original == "Critical: No Screen Lock" ->
                        "फोन में स्क्रीन लॉक नहीं है"

                    original == "Root Detected" ||
                    original == "Critical: Root detected" ->
                        "फोन में रूट एक्सेस मिला है"

                    original == "Accessibility Services" ->
                        "एक्सेसिबिलिटी सेवाएं"

                    original == "Notification Access" ->
                        "नोटिफिकेशन की अनुमति"

                    original == "Overlay Apps" ->
                        "दूसरे ऐप के ऊपर दिखने की अनुमति"

                    original == "Bootloader" ->
                        "बूटलोडर अनलॉक है"

                    original == "Developer Options" ->
                        "डेवलपर विकल्प"

                    original == "USB Debugging" ->
                        "USB डिबगिंग"

                    original == "Hidden App Risk" ->
                        "छुपा हुआ खतरनाक ऐप मिला"

                    original == "Unknown Source App" ->
                        "अनजान जगह से आया खतरनाक ऐप मिला"

                    else -> original
                }

                "mr" -> when {
                    securityType == "hidden_app" ->
                        if (original.contains(":"))
                            "लपलेले धोकादायक ॲप:" + original.substringAfter(":")
                        else "लपलेले धोकादायक ॲप सापडले"

                    securityType == "accessibility" ->
                        if (original.contains(":"))
                            "अॅक्सेसिबिलिटीची परवानगी:" + original.substringAfter(":")
                        else "अॅक्सेसिबिलिटीची परवानगी सुरू आहे"

                    securityType == "device_admin" ->
                        if (original.contains(":"))
                            "फोनचे विशेष नियंत्रण:" + original.substringAfter(":")
                        else "फोनचे विशेष नियंत्रण सुरू आहे"

                    securityType == "overlay" ->
                        "इतर ॲप्सच्या वर दिसण्याची परवानगी सुरू आहे"

                    securityType == "developer_options" ->
                        "डेव्हलपर पर्याय सुरू आहेत"

                    securityType == "usb_debugging" ->
                        "USB डिबगिंग सुरू आहे"

                    original == "Encryption" ->
                        "एन्क्रिप्शन"

                    original == "No Screen Lock" ||
                    original == "Critical: No Screen Lock" ->
                        "फोनवर स्क्रीन लॉक नाही"

                    original == "Root Detected" ||
                    original == "Critical: Root detected" ->
                        "फोनमध्ये रूट ॲक्सेस मिळाला आहे"

                    original == "Accessibility Services" ->
                        "अॅक्सेसिबिलिटी सेवा"

                    original == "Notification Access" ->
                        "नोटिफिकेशनची परवानगी"

                    original == "Overlay Apps" ->
                        "इतर ॲप्सच्या वर दिसण्याची परवानगी"

                    original == "Bootloader" ->
                        "बूटलोडर अनलॉक आहे"

                    original == "Developer Options" ->
                        "डेव्हलपर पर्याय"

                    original == "USB Debugging" ->
                        "USB डिबगिंग"

                    original == "Hidden App Risk" ->
                        "लपलेले धोकादायक ॲप सापडले"

                    original == "Unknown Source App" ->
                        "अनजान ठिकाणाहून आलेले धोकादायक ॲप सापडले"

                    else -> original
                }

                else -> original
            }
        }

        fun fraudRokoLocalizedMessage(original: String): String {
            return when (fraudRokoLanguage) {
                "hi" -> when {
                    securityType == "hidden_app" ->
                        "आपके फोन में एक छुपा हुआ खतरनाक ऐप मिला है।"

                    securityType == "accessibility" ->
                        "एक या अधिक ऐप को एक्सेसिबिलिटी की अनुमति मिली हुई है। जिसे आप नहीं पहचानते, उसकी जांच करें।"

                    securityType == "device_admin" ->
                        "इस ऐप को फोन का विशेष नियंत्रण मिला हुआ है। जिसे आप नहीं पहचानते, उसकी जांच करें।"

                    securityType == "overlay" ->
                        "एक ऐप दूसरे ऐप के ऊपर दिखाई दे सकता है। जिसे आप नहीं पहचानते, उसकी जांच करें।"

                    securityType == "developer_options" ->
                        "डेवलपर विकल्प चालू हैं। अगर आपने इन्हें चालू नहीं किया है, तो इन्हें बंद करें।"

                    securityType == "usb_debugging" ->
                        "USB डिबगिंग चालू है। अगर आपने इसे चालू नहीं किया है, तो इसे बंद करें।"

                    original == "Device encryption could not be verified." ->
                        "डिवाइस एन्क्रिप्शन की पुष्टि नहीं हो सकी।"

                    original == "Your phone does not have a screen lock. Anyone with physical access may be able to unlock it." ->
                        "आपके फोन में स्क्रीन लॉक नहीं है। फोन तक पहुंच रखने वाला कोई व्यक्ति इसे खोल सकता है।"

                    original == "A suspicious hidden app was detected." ->
                        "आपके फोन में एक छुपा हुआ खतरनाक ऐप मिला है।"

                    original == "Root access was detected on this device. Review your device security configuration." ->
                        "आपके फोन में रूट एक्सेस मिला है। फोन की सुरक्षा सेटिंग जांचें।"

                    original.contains("untrusted source") ->
                        "यह ऐप भरोसेमंद जगह से इंस्टॉल नहीं किया गया है। इसकी जांच करें।"

                    original.contains("Bootloader appears unlocked") ->
                        "फोन का बूटलोडर अनलॉक है।"

                    else -> original
                }

                "mr" -> when {
                    securityType == "hidden_app" ->
                        "तुमच्या फोनमध्ये एक लपलेले धोकादायक ॲप सापडले आहे."

                    securityType == "accessibility" ->
                        "एक किंवा अधिक ॲप्सना अॅक्सेसिबिलिटीची परवानगी दिलेली आहे. तुम्ही ओळखत नसलेल्या ॲपची तपासणी करा."

                    securityType == "device_admin" ->
                        "या ॲपला फोनचे विशेष नियंत्रण मिळाले आहे. तुम्ही ओळखत नसलेल्या ॲपची तपासणी करा."

                    securityType == "overlay" ->
                        "एक ॲप इतर ॲप्सच्या वर दिसू शकते. तुम्ही ओळखत नसलेल्या ॲपची तपासणी करा."

                    securityType == "developer_options" ->
                        "डेव्हलपर पर्याय सुरू आहेत. तुम्ही ते सुरू केले नसतील तर बंद करा."

                    securityType == "usb_debugging" ->
                        "USB डिबगिंग सुरू आहे. तुम्ही ते सुरू केले नसेल तर बंद करा."

                    original == "Device encryption could not be verified." ->
                        "डिव्हाइस एन्क्रिप्शनची पुष्टी करता आली नाही."

                    original == "Your phone does not have a screen lock. Anyone with physical access may be able to unlock it." ->
                        "तुमच्या फोनवर स्क्रीन लॉक नाही. फोनपर्यंत पोहोच असलेली व्यक्ती तो उघडू शकते."

                    original == "A suspicious hidden app was detected." ->
                        "तुमच्या फोनमध्ये एक लपलेले धोकादायक ॲप सापडले आहे."

                    original == "Root access was detected on this device. Review your device security configuration." ->
                        "तुमच्या फोनमध्ये रूट ॲक्सेस मिळाला आहे. फोनच्या सुरक्षा सेटिंग्ज तपासा."

                    original.contains("untrusted source") ->
                        "हे ॲप विश्वासार्ह ठिकाणाहून इंस्टॉल केलेले नाही. त्याची तपासणी करा."

                    original.contains("Bootloader appears unlocked") ->
                        "फोनचा बूटलोडर अनलॉक आहे."

                    else -> original
                }

                else -> original
            }
        }


        val finalTitle =
            if (securityType == "notification_access") {

                localizedNotificationAccessTitle(
                    packageName
                )

            } else {

                fraudRokoLocalizedTitle(
                    getLocalizedTitle(
                        title,
                        securityType
                    )
                )
            }

        val finalMessage =
            if (securityType == "notification_access") {

                localizedNotificationAccessMessage(
                    packageName
                )

            } else {

                fraudRokoLocalizedMessage(
                    getLocalizedMessage(
                        message,
                        securityType
                    )
                )
            }

        val settingsIntent =
            createSettingsIntent(
                securityType = securityType,
                packageName = packageName
            )

        val contentIntent =
            if (settingsIntent != null) {

                settingsIntent

            } else {

                Intent(
                    context,
                    MainActivity::class.java
                ).apply {

                    flags =
                        Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP

                    putExtra(
                        "packageName",
                        packageName
                    )

                    putExtra(
                        "securityType",
                        securityType
                    )
                }
            }

        val pendingIntent =
            PendingIntent.getActivity(
                context,
                notificationId,
                contentIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or
                    PendingIntent.FLAG_IMMUTABLE
            )

        val builder =
            NotificationCompat.Builder(
                context,
                CHANNEL_ID
            )
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(finalTitle)
                .setContentText(finalMessage)
                .setStyle(
                    NotificationCompat.BigTextStyle()
                        .bigText(finalMessage)
                )
                .setPriority(
                    NotificationCompat.PRIORITY_DEFAULT
                )

                .setVisibility(
                    NotificationCompat.VISIBILITY_PRIVATE
                )

                .setContentIntent(
                    pendingIntent
                )

                .setAutoCancel(true)

                .setShowWhen(true)

                .setOnlyAlertOnce(true)

        if (settingsIntent != null) {

            val reviewPendingIntent =
                PendingIntent.getActivity(
                    context,
                    notificationId + 100000,
                    settingsIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or
                        PendingIntent.FLAG_IMMUTABLE
                )

            builder.addAction(
                NotificationCompat.Action.Builder(
                    0,
                    reviewButtonText(),
                    reviewPendingIntent
                ).build()
            )
        }

        if (
            Build.VERSION.SDK_INT >=
            Build.VERSION_CODES.TIRAMISU
        ) {

            if (
                ActivityCompat.checkSelfPermission(
                    context,
                    Manifest.permission.POST_NOTIFICATIONS
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                return
            }
        }

        try {

            NotificationManagerCompat
                .from(context)
                .notify(
                    notificationId,
                    builder.build()
                )

        } catch (_: SecurityException) {
            // Notification permission not granted
        }
    }

    /*
     * =========================================================
     * SETTINGS INTENTS
     * =========================================================
     */

    private fun createSettingsIntent(
        securityType: String,
        packageName: String
    ): Intent? {

        return try {

            when (securityType) {

                "accessibility" -> {

                    Intent(
                        Settings.ACTION_ACCESSIBILITY_SETTINGS
                    )
                }

                "notification_access" -> {

                    Intent(
                        Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS
                    )
                }

                "device_admin" -> {

                    Intent(
                        Settings.ACTION_SECURITY_SETTINGS
                    )
                }

                "overlay" -> {

                    if (
                        packageName.isNotBlank() &&
                        Build.VERSION.SDK_INT >=
                        Build.VERSION_CODES.M
                    ) {

                        Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse(
                                "package:$packageName"
                            )
                        )

                    } else {

                        Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION
                        )
                    }
                }

                "developer_options" -> {

                    Intent(
                        Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS
                    )
                }

                "usb_debugging" -> {

                    Intent(
                        Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS
                    )
                }

                else -> {
                    null
                }
            }

        } catch (_: Exception) {

            null
        }
    }
}