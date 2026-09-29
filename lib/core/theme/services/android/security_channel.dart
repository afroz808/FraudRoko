import 'package:flutter/services.dart';

class SecurityChannel {
  SecurityChannel._();

  static const MethodChannel _channel = MethodChannel('com.fraudroko/security');

  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final result = await _channel.invokeMethod('getDeviceInfo');

    return Map<String, dynamic>.from(result);
  }

  static Future<bool> isScreenLockEnabled() async {
    return await _channel.invokeMethod('isScreenLockEnabled');
  }

  static Future<bool> isDeveloperOptionsEnabled() async {
    return await _channel.invokeMethod('isDeveloperOptionsEnabled');
  }

  static Future<bool> isUsbDebuggingEnabled() async {
    return await _channel.invokeMethod('isUsbDebuggingEnabled');
  }

  static Future<bool> isDeviceEncrypted() async {
    return await _channel.invokeMethod('isDeviceEncrypted');
  }

  static Future<bool> isRooted() async {
    return await _channel.invokeMethod('isRooted');
  }
}
