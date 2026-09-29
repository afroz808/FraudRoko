import 'package:flutter/services.dart';

class AppSettingsChannel {
  static const MethodChannel _channel = MethodChannel("fraudroko/app_settings");

  static Future<void> openAppSettings(String packageName) async {
    try {
      await _channel.invokeMethod("openAppSettings", {
        "packageName": packageName,
      });
    } catch (_) {}
  }
}
