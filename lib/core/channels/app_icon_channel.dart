import 'dart:convert';

import 'package:flutter/services.dart';

class AppIconChannel {
  static const MethodChannel _channel = MethodChannel("fraudroko/app_icon");

  static Future<Uint8List?> getAppIcon(String packageName) async {
    try {
      final String? base64 = await _channel.invokeMethod("getAppIcon", {
        "packageName": packageName,
      });

      if (base64 == null || base64.isEmpty) {
        return null;
      }

      return base64Decode(base64);
    } catch (_) {
      return null;
    }
  }
}
