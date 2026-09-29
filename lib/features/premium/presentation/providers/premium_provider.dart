import 'package:flutter/foundation.dart';

import '../../data/repositories/premium_repository_impl.dart';
import '../../domain/entities/premium_status.dart';
import '../../domain/usecases/get_premium_status.dart';

class PremiumProvider extends ChangeNotifier {
  final GetPremiumStatus _getPremiumStatus;

  PremiumStatus _status = PremiumStatus.free;
  bool _isLoading = false;

  PremiumProvider()
    : _getPremiumStatus = const GetPremiumStatus(PremiumRepositoryImpl());

  PremiumStatus get status => _status;

  bool get isPremium => _status == PremiumStatus.premium;

  bool get isLoading => _isLoading;

  Future<void> loadStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _status = await _getPremiumStatus();
    } catch (_) {
      // Safe fallback: never grant Premium on an error.
      _status = PremiumStatus.free;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
