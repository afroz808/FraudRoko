package com.fraudroko.fraudroko_app.engines

import android.content.Context
import android.content.pm.PackageInstaller
import android.content.pm.PackageManager
import android.os.Build

class InstallerAnalyzer(
    private val context: Context
) {

    private val packageManager: PackageManager =
        context.packageManager

    companion object {

        private const val PLAY_STORE =
            "com.android.vending"

        private const val SAMSUNG_STORE =
            "com.sec.android.app.samsungapps"

        private const val XIAOMI_STORE =
            "com.xiaomi.mipicks"

        private const val HUAWEI_STORE =
            "com.huawei.appmarket"

        private const val AMAZON_STORE =
            "com.amazon.venezia"
    }

    fun analyze(
        packageName: String,
        isSystemApp: Boolean
    ): HashMap<String, Any?> {

        if (isSystemApp) {
            return hashMapOf(
                "installerPackage" to null,
                "installerName" to "System App",
                "sourceType" to "SYSTEM",
                "trusted" to true
            )
        }

        val installSource =
            getInstallSource(packageName)

        val installerPackage =
            installSource.installingPackage

        val initiatingPackage =
            installSource.initiatingPackage

        val detectedInstaller =
            installerPackage ?: initiatingPackage

        val installerName =
            getInstallerName(detectedInstaller)

        val sourceType =
            getSourceType(
                detectedInstaller,
                installSource.packageSource
            )

        val trusted =
            isTrustedStore(
                detectedInstaller,
                installSource.packageSource
            )

        return hashMapOf(
            "installerPackage" to detectedInstaller,
            "installerName" to installerName,
            "sourceType" to sourceType,
            "trusted" to trusted
        )
    }

    private data class InstallSourceResult(
        val installingPackage: String?,
        val initiatingPackage: String?,
        val packageSource: Int?
    )

    private fun getInstallSource(
        packageName: String
    ): InstallSourceResult {

        return try {

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {

                val info =
                    packageManager.getInstallSourceInfo(
                        packageName
                    )

                val packageSource =
                    if (
                        Build.VERSION.SDK_INT >=
                        Build.VERSION_CODES.TIRAMISU
                    ) {
                        info.packageSource
                    } else {
                        null
                    }

                InstallSourceResult(
                    installingPackage =
                        info.installingPackageName,
                    initiatingPackage =
                        info.initiatingPackageName,
                    packageSource =
                        packageSource
                )

            } else {

                @Suppress("DEPRECATION")
                InstallSourceResult(
                    installingPackage =
                        packageManager.getInstallerPackageName(
                            packageName
                        ),
                    initiatingPackage = null,
                    packageSource = null
                )
            }

        } catch (_: Exception) {

            InstallSourceResult(
                installingPackage = null,
                initiatingPackage = null,
                packageSource = null
            )
        }
    }

    private fun getInstallerName(
        installerPackage: String?
    ): String {

        return when (installerPackage) {

            PLAY_STORE ->
                "Google Play Store"

            SAMSUNG_STORE ->
                "Samsung Galaxy Store"

            XIAOMI_STORE ->
                "Xiaomi GetApps"

            HUAWEI_STORE ->
                "Huawei AppGallery"

            AMAZON_STORE ->
                "Amazon Appstore"

            null ->
                "स्रोत की जानकारी उपलब्ध नहीं"

            else ->
                installerPackage
        }
    }

    private fun isTrustedStore(
        installerPackage: String?,
        packageSource: Int?
    ): Boolean {

        if (installerPackage in setOf(
                PLAY_STORE,
                SAMSUNG_STORE,
                XIAOMI_STORE,
                HUAWEI_STORE,
                AMAZON_STORE
            )
        ) {
            return true
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {

            return packageSource ==
                PackageInstaller.PACKAGE_SOURCE_STORE
        }

        return false
    }

    private fun getSourceType(
        installerPackage: String?,
        packageSource: Int?
    ): String {

        when (installerPackage) {

            PLAY_STORE ->
                return "PLAY_STORE"

            SAMSUNG_STORE ->
                return "SAMSUNG_STORE"

            XIAOMI_STORE ->
                return "XIAOMI_STORE"

            HUAWEI_STORE ->
                return "HUAWEI_STORE"

            AMAZON_STORE ->
                return "AMAZON_STORE"
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {

            when (packageSource) {

                PackageInstaller.PACKAGE_SOURCE_STORE ->
                    return "OTHER_STORE"

                PackageInstaller.PACKAGE_SOURCE_LOCAL_FILE ->
                    return "LOCAL_FILE"

                PackageInstaller.PACKAGE_SOURCE_DOWNLOADED_FILE ->
                    return "DOWNLOADED_FILE"

                PackageInstaller.PACKAGE_SOURCE_OTHER ->
                    return "OTHER_SOURCE"
            }
        }

        return "UNKNOWN_SOURCE"
    }
}