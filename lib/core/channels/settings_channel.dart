import 'package:flutter/services.dart';

class SettingsChannel {
  static const MethodChannel _channel = MethodChannel('fraudroko/settings');

  static Future<void> openSecuritySettings() async {
    await _channel.invokeMethod('openSecuritySettings');
  }

  static Future<void> openDeveloperOptions() async {
    await _channel.invokeMethod('openDeveloperOptions');
  }

  static Future<void> openSystemUpdate() async {
    await _channel.invokeMethod('openSystemUpdate');
  }

  static Future<void> openAccessibilitySettings() async {
    await _channel.invokeMethod('openAccessibilitySettings');
  }

  static Future<void> openNotificationAccessSettings() async {
    await _channel.invokeMethod('openNotificationAccessSettings');
  }

  static Future<void> openOverlaySettings() async {
    await _channel.invokeMethod('openOverlaySettings');
  }

  static Future<void> openAppDetails(String packageName) async {
    await _channel.invokeMethod('openAppDetails', {'packageName': packageName});
  }
}
