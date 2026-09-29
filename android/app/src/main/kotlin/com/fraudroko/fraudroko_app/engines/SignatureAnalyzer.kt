package com.fraudroko.fraudroko_app.engines

import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import java.security.MessageDigest

class SignatureAnalyzer(
    private val context: Context
) {

    private val packageManager =
        context.packageManager

    fun analyze(
        packageName: String
    ): HashMap<String, Any?> {

        return try {

            val packageInfo = getPackageInfo(packageName)

            if (packageInfo == null) {

                hashMapOf(
                    "available" to false
                )

            } else {

                val signatureBytes =
                    getSignatureBytes(packageInfo)

                if (signatureBytes == null) {

                    hashMapOf(
                        "available" to false
                    )

                } else {

                    hashMapOf(
                        "available" to true,
                        "sha256" to digest(signatureBytes, "SHA-256"),
                        "sha1" to digest(signatureBytes, "SHA-1")
                    )

                }
            }

        } catch (_: Exception) {

            hashMapOf(
                "available" to false
            )

        }
    }

    private fun getPackageInfo(
        packageName: String
    ): PackageInfo? {

        return try {

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {

                packageManager.getPackageInfo(
                    packageName,
                    PackageManager.GET_SIGNING_CERTIFICATES
                )

            } else {

                @Suppress("DEPRECATION")
                packageManager.getPackageInfo(
                    packageName,
                    PackageManager.GET_SIGNATURES
                )

            }

        } catch (_: Exception) {

            null

        }
    }

    private fun getSignatureBytes(
        packageInfo: PackageInfo
    ): ByteArray? {

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {

            val info = packageInfo.signingInfo ?: return null

            val signatures =
                if (info.hasMultipleSigners()) {
                    info.apkContentsSigners
                } else {
                    info.signingCertificateHistory
                }

            signatures.firstOrNull()?.toByteArray()

        } else {

            @Suppress("DEPRECATION")
            packageInfo.signatures
                ?.firstOrNull()
                ?.toByteArray()

        }
    }

    private fun digest(
        bytes: ByteArray,
        algorithm: String
    ): String {

        val md =
            MessageDigest.getInstance(algorithm)

        val hash =
            md.digest(bytes)

        return hash.joinToString(":") {

            "%02X".format(it)

        }
    }
}