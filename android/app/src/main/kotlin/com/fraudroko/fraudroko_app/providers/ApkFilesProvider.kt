package com.fraudroko.fraudroko_app.providers

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import java.io.File

class ApkFilesProvider(
    private val context: Context
) {

    private val packageManager: PackageManager =
        context.packageManager

    fun getApkFiles(): HashMap<String, Any> {

        val result = hashMapOf<String, Any>()

        val apkFiles =
            arrayListOf<HashMap<String, Any>>()

        val roots =
            getAllowedRoots()

        for (root in roots) {

            scanDirectory(
                directory = root,
                apkFiles = apkFiles
            )
        }

        result["totalApkFiles"] =
            apkFiles.size

        result["apkFiles"] =
            apkFiles

        return result
    }

    private fun getAllowedRoots(): List<File> {

        val roots =
            mutableListOf<File>()

        context.getExternalFilesDir(null)?.let {
            roots.add(it)
        }

        return roots
    }

    private fun scanDirectory(
        directory: File,
        apkFiles: MutableList<HashMap<String, Any>>
    ) {

        if (!directory.exists() || !directory.isDirectory) {
            return
        }

        val children =
            try {
                directory.listFiles()
            } catch (_: SecurityException) {
                null
            } ?: return

        for (file in children) {

            if (file.isDirectory) {

                scanDirectory(
                    directory = file,
                    apkFiles = apkFiles
                )

                continue
            }

            if (!file.isFile) {
                continue
            }

            if (
                !file.name
                    .lowercase()
                    .endsWith(".apk")
            ) {
                continue
            }

            val apk =
                inspectApk(file)

            apkFiles.add(apk)
        }
    }

    private fun inspectApk(
        file: File
    ): HashMap<String, Any> {

        val result =
            hashMapOf<String, Any>()

        result["fileName"] =
            file.name

        result["fileSize"] =
            file.length()

        result["lastModified"] =
            file.lastModified()

        result["installed"] =
            false

        result["path"] =
            file.absolutePath

        try {

            val packageInfo =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {

                    packageManager.getPackageArchiveInfo(
                        file.absolutePath,
                        PackageManager.GET_PERMISSIONS
                    )

                } else {

                    @Suppress("DEPRECATION")
                    packageManager.getPackageArchiveInfo(
                        file.absolutePath,
                        PackageManager.GET_PERMISSIONS
                    )
                }

            if (packageInfo != null) {

                val applicationInfo =
                    packageInfo.applicationInfo

                if (applicationInfo != null) {

                    applicationInfo.sourceDir =
                        file.absolutePath

                    applicationInfo.publicSourceDir =
                        file.absolutePath

                    result["appName"] =
                        packageManager
                            .getApplicationLabel(
                                applicationInfo
                            )
                            .toString()

                    result["packageName"] =
                        packageInfo.packageName

                    result["versionName"] =
                        packageInfo.versionName
                            ?: "Unknown"

                    result["validApk"] =
                        true

                    result["installed"] =
                        isPackageInstalled(
                            packageInfo.packageName
                        )
                }

            } else {

                result["appName"] =
                    file.nameWithoutExtension

                result["packageName"] =
                    ""

                result["versionName"] =
                    "Unknown"

                result["validApk"] =
                    false
            }

        } catch (_: Exception) {

            result["appName"] =
                file.nameWithoutExtension

            result["packageName"] =
                ""

            result["versionName"] =
                "Unknown"

            result["validApk"] =
                false
        }

        return result
    }

    private fun isPackageInstalled(
        packageName: String
    ): Boolean {

        if (packageName.isBlank()) {
            return false
        }

        return try {

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {

                packageManager.getPackageInfo(
                    packageName,
                    PackageManager.PackageInfoFlags.of(0)
                )

            } else {

                @Suppress("DEPRECATION")
                packageManager.getPackageInfo(
                    packageName,
                    0
                )
            }

            true

        } catch (_: PackageManager.NameNotFoundException) {

            false
        }
    }
}
