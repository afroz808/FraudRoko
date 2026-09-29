import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/localization/app_text.dart';
import '../../data/services/fcm_service.dart';

class NotificationPermissionDialog extends StatelessWidget {
  const NotificationPermissionDialog({super.key});

  static Future<void> show(BuildContext context) async {
    final status = await Permission.notification.status;

    if (status.isGranted || !context.mounted) {
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const NotificationPermissionDialog(),
    );
  }

  static Future<void> openFromHeader(BuildContext context) async {
    final status = await Permission.notification.status;

    if (status.isGranted) {
      // Permission already ON.
      // No permission dialog needed.
      return;
    }

    if (!context.mounted) return;

    // If Android allows requesting again, show our dialog.
    if (status.isDenied) {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => const NotificationPermissionDialog(),
      );
      return;
    }

    // Permanently denied / blocked.
    if (status.isPermanentlyDenied || status.isRestricted) {
      await _showSettingsDialog(context);
    }
  }

  static Future<void> _showSettingsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xffEAF4FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            AppText.t(dialogContext, "🔔 Notifications बंद हैं"),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff0F4C81),
            ),
          ),
          content: Text(
            AppText.t(
              dialogContext,
              "FraudRoko की सुरक्षा सूचनाएँ पाने के लिए फोन की Settings में Notifications चालू करें।",
            ),
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(AppText.t(dialogContext, "बाद में")),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1565FF),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(AppText.t(dialogContext, "Settings खोलें")),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xffEAF4FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text(
        AppText.t(context, "🔔 FraudRoko की सुरक्षा सूचनाएँ चालू रखें"),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xff0F4C81),
        ),
      ),
      content: Text(
        AppText.t(
          context,
          "सुरक्षा समस्या या संदिग्ध बदलाव मिलते ही FraudRoko आपको तुरंत बताएगा।",
        ),
        style: const TextStyle(
          fontSize: 14,
          height: 1.4,
          color: Colors.black87,
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final permission = await Permission.notification.request();

              if (permission.isGranted || permission.isLimited) {
                await FcmService.syncPermission();
              }

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff1565FF),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              AppText.t(context, "सूचनाएँ चालू करें"),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
