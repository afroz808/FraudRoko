package com.fraudroko.fraudroko_app.providers

import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import com.fraudroko.fraudroko_app.engines.InstallerAnalyzer
import com.fraudroko.fraudroko_app.engines.PermissionAnalyzer

class InstalledAppsProvider(
    private val context: Context
) {

    private val packageManager: PackageManager =
        context.packageManager

    private val permissionAnalyzer =
        PermissionAnalyzer

    private val installerAnalyzer =
        InstallerAnalyzer(context)

    fun getInstalledApps(): HashMap<String, Any> {

        val result = hashMapOf<String, Any>()

        val installedPackages = getInstalledPackages()

        var totalApps = 0
        var userApps = 0
        var systemApps = 0
        var disabledApps = 0
        var hiddenApps = 0

        val appList = arrayListOf<HashMap<String, Any>>()

        for (packageInfo in installedPackages) {

            val applicationInfo =
                packageInfo.applicationInfo ?: continue

            totalApps++

            val isSystemApp =
                (applicationInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0

            if (isSystemApp) {
                systemApps++
            } else {
                userApps++
            }

            if (!applicationInfo.enabled) {
                disabledApps++
            }

            val requestedPermissions =
                packageInfo.requestedPermissions?.toList()
                    ?: emptyList()

            val permissionReport =
                permissionAnalyzer.analyze(requestedPermissions)

            val installerReport =
                installerAnalyzer.analyze(
                    packageInfo.packageName,
                    isSystemApp
                )

            // Installer/source type
            val sourceType =
                installerReport["sourceType"]?.toString()
                    ?: "UNKNOWN_SOURCE"

            /*
             * IMPORTANT:
             *
             * Hidden app का मतलब सिर्फ launcher में icon
             * नहीं होना नहीं है।
             *
             * System apps, Play Store apps और official stores
             * को hidden apps में नहीं दिखाना है।
             *
             * Hidden detection केवल बाहर से install हुए
             * third-party apps पर होगी।
             */
            val hiddenApp =
                isHiddenThirdPartyApp(
                    applicationInfo = applicationInfo,
                    sourceType = sourceType,
                    isSystemApp = isSystemApp
                )

            if (hiddenApp) {
                hiddenApps++
            }

            val app = hashMapOf<String, Any>()

            app["appName"] =
                packageManager
                    .getApplicationLabel(applicationInfo)
                    .toString()

            app["packageName"] =
                packageInfo.packageName

            app["versionName"] =
                packageInfo.versionName ?: "Unknown"

            app["versionCode"] =
                getVersionCode(packageInfo)

            app["firstInstallTime"] =
                packageInfo.firstInstallTime

            app["lastUpdateTime"] =
                packageInfo.lastUpdateTime

            app["targetSdk"] =
                applicationInfo.targetSdkVersion

            app["enabled"] =
                applicationInfo.enabled

            app["systemApp"] =
                isSystemApp

            app["hiddenApp"] =
                hiddenApp

            app["requestedPermissions"] =
                requestedPermissions

            app["permissionAnalysis"] =
                permissionReport

            app["installer"] =
                installerReport

            appList.add(app)
        }

        result["totalApps"] =
            totalApps

        result["userApps"] =
            userApps

        result["systemApps"] =
            systemApps

        result["disabledApps"] =
            disabledApps

        result["hiddenApps"] =
            hiddenApps

        result["apps"] =
            appList

        return result
    }

    fun getApp(
        packageName: String
    ): HashMap<String, Any>? {

        return try {

            val packageInfo =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {

                    packageManager.getPackageInfo(
                        packageName,
                        PackageManager.PackageInfoFlags.of(
                            PackageManager.GET_PERMISSIONS.toLong()
                        )
                    )

                } else {

                    @Suppress("DEPRECATION")
                    packageManager.getPackageInfo(
                        packageName,
                        PackageManager.GET_PERMISSIONS
                    )
                }

            val applicationInfo =
                packageInfo.applicationInfo
                    ?: return null

            val isSystemApp =
                (applicationInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0

            val requestedPermissions =
                packageInfo.requestedPermissions?.toList()
                    ?: emptyList()

            val permissionReport =
                permissionAnalyzer.analyze(
                    requestedPermissions
                )

            val installerReport =
                installerAnalyzer.analyze(
                    packageName,
                    isSystemApp
                )

            val sourceType =
                installerReport["sourceType"]?.toString()
                    ?: "UNKNOWN_SOURCE"

            /*
             * Same hidden-app rule used by the complete
             * installed-app scan.
             */
            val hiddenApp =
                isHiddenThirdPartyApp(
                    applicationInfo = applicationInfo,
                    sourceType = sourceType,
                    isSystemApp = isSystemApp
                )

            val app = hashMapOf<String, Any>()

            app["appName"] =
                packageManager
                    .getApplicationLabel(applicationInfo)
                    .toString()

            app["packageName"] =
                packageInfo.packageName

            app["versionName"] =
                packageInfo.versionName ?: "Unknown"

            app["versionCode"] =
                getVersionCode(packageInfo)

            app["firstInstallTime"] =
                packageInfo.firstInstallTime

            app["lastUpdateTime"] =
                packageInfo.lastUpdateTime

            app["targetSdk"] =
                applicationInfo.targetSdkVersion

            app["enabled"] =
                applicationInfo.enabled

            app["systemApp"] =
                isSystemApp

            app["hiddenApp"] =
                hiddenApp

            app["requestedPermissions"] =
                requestedPermissions

            app["permissionAnalysis"] =
                permissionReport

            app["installer"] =
                installerReport

            app

        } catch (_: Exception) {

            null
        }
    }

    /**
     * Hidden app detection.
     *
     * IMPORTANT:
     * केवल third-party outside-installed apps को
     * hidden माना जाएगा।
     *
     * System / Play Store / official store apps
     * hidden नहीं माने जाएंगे।
     */
    private fun isHiddenThirdPartyApp(
        applicationInfo: ApplicationInfo,
        sourceType: String,
        isSystemApp: Boolean
    ): Boolean {

        // 1. System apps को कभी hidden नहीं दिखाना
        if (isSystemApp) {
            return false
        }

        // 2. केवल बाहर से install हुए apps
        val isOutsideSource =
            sourceType == "LOCAL_FILE" ||
            sourceType == "DOWNLOADED_FILE" ||
            sourceType == "OTHER_SOURCE" ||
            sourceType == "UNKNOWN_SOURCE"

        if (!isOutsideSource) {
            return false
        }

        // 3. Launcher में app दिखाई देता है या नहीं
        val launcherVisible =
            isLauncherVisible(
                applicationInfo.packageName
            )

        // 4. Outside APK + launcher में नहीं = Hidden
        return !launcherVisible
    }

    private fun isLauncherVisible(
        packageName: String
    ): Boolean {

        return try {

            val intent =
                Intent(Intent.ACTION_MAIN).apply {
                    addCategory(Intent.CATEGORY_LAUNCHER)
                    setPackage(packageName)
                }

            packageManager
                .queryIntentActivities(
                    intent,
                    0
                )
                .isNotEmpty()

        } catch (_: Exception) {

            false
        }
    }

    private fun getInstalledPackages(): List<PackageInfo> {

        return if (
            Build.VERSION.SDK_INT >=
            Build.VERSION_CODES.TIRAMISU
        ) {

            packageManager.getInstalledPackages(
                PackageManager.PackageInfoFlags.of(
                    PackageManager.GET_PERMISSIONS.toLong()
                )
            )

        } else {

            @Suppress("DEPRECATION")
            packageManager.getInstalledPackages(
                PackageManager.GET_PERMISSIONS
            )
        }
    }

    private fun getVersionCode(
        packageInfo: PackageInfo
    ): Long {

        return if (
            Build.VERSION.SDK_INT >=
            Build.VERSION_CODES.P
        ) {

            packageInfo.longVersionCode

        } else {

            @Suppress("DEPRECATION")
            packageInfo.versionCode.toLong()
        }
    }
}