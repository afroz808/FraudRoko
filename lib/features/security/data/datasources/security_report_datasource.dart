import 'package:flutter/services.dart';

class SecurityReportDataSource {
  static const MethodChannel _channel = MethodChannel('com.fraudroko/security');

  Future<Map<String, dynamic>> getSecurityReport() async {
    final result = await _channel.invokeMethod('getSecurityReport');

    return Map<String, dynamic>.from(result);
  }
}
