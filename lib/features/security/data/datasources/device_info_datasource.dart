import 'package:flutter/services.dart';

class DeviceInfoDataSource {
  static const MethodChannel _channel = MethodChannel('com.fraudroko/security');

  Future<Map<String, dynamic>> getDeviceInfo() async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'getSecurityReport',
    );

    if (result == null) {
      return {};
    }

    return result.map((key, value) => MapEntry(key.toString(), value));
  }
}
