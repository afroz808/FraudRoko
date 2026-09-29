import 'package:flutter/material.dart';

import '../../../../core/analytics/analytics_service.dart';

import '../../data/datasources/device_info_datasource.dart';
import '../../data/repositories/security_repository_impl.dart';
import '../../domain/models/security_scan_result.dart';

class SecurityProvider extends ChangeNotifier {
  late final SecurityRepositoryImpl _repository;

  SecurityProvider() {
    _repository = SecurityRepositoryImpl(DeviceInfoDataSource());
  }

  SecurityScanResult? securityResult;
  bool isLoading = false;

  String? error;

  Future<void> scanPhone() async {
    if (isLoading) return;
    try {
      isLoading = true;
      error = null;

      notifyListeners();

      securityResult = await _repository.scanPhone();
      await AnalyticsService.instance.logSecurityScan();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
