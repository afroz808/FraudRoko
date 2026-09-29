package com.fraudroko.fraudroko_app.providers

import android.os.Build

class BootloaderProvider {

    fun getBootloaderStatus(): HashMap<String, Any> {

        val result = hashMapOf<String, Any>()

        val unlocked =
            Build.TAGS?.contains("test-keys") == true

        result["bootloaderUnlocked"] = unlocked

        result["bootloader"] =
            if (unlocked) {
                "Unlocked"
            } else {
                "Locked"
            }

        return result
    }
}