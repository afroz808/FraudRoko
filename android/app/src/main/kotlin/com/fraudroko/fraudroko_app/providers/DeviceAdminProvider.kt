package com.fraudroko.fraudroko_app.providers

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context

class DeviceAdminProvider(
    private val context: Context
) {

    fun getDeviceAdmins(): HashMap<String, Any> {

        val result = hashMapOf<String, Any>()

        val devicePolicyManager =
            context.getSystemService(
                Context.DEVICE_POLICY_SERVICE
            ) as DevicePolicyManager

        val adminList = arrayListOf<HashMap<String, String>>()

        val activeAdmins: List<ComponentName> =
            devicePolicyManager.activeAdmins ?: emptyList()

        for (admin in activeAdmins) {

            val item = hashMapOf<String, String>()

            item["packageName"] =
                admin.packageName

            item["className"] =
                admin.className

            adminList.add(item)
        }

        result["hasDeviceAdmins"] =
            adminList.isNotEmpty()

        result["totalDeviceAdmins"] =
            adminList.size

        result["deviceAdmins"] =
            adminList

        return result
    }
}