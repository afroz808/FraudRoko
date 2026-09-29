import 'package:flutter/services.dart';

class DailySecurityReportDataSource {
  static const MethodChannel _channel = MethodChannel('com.fraudroko/security');

  Future<List<Map<String, dynamic>>> getReports() async {
    final result = await _channel.invokeMethod<List<dynamic>>(
      'getDailySecurityReports',
    );

    return (result ?? [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }
}
