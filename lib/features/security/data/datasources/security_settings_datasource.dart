import 'package:flutter/services.dart';

class SecuritySettingsDataSource {
  static const MethodChannel _channel = MethodChannel('com.fraudroko/security');

  Future<Map<String, dynamic>> getSecuritySettings() async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'getSecuritySettings',
    );

    return result ?? {};
  }
}
