import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../premium/data/repositories/premium_repository_impl.dart';
import '../../../premium/domain/entities/premium_status.dart';

class SecurityScanAccessResult {
  final bool allowed;
  final bool premium;
  final int usedFreeScans;
  final int freeScanLimit;

  const SecurityScanAccessResult({
    required this.allowed,
    required this.premium,
    required this.usedFreeScans,
    required this.freeScanLimit,
  });

  int get remainingFreeScans =>
      (freeScanLimit - usedFreeScans).clamp(0, freeScanLimit).toInt();
}

class SecurityScanAccessService {
  SecurityScanAccessService._();

  static final SecurityScanAccessService instance =
      SecurityScanAccessService._();

  static const int _freeScanLimit = 2;
  static const String _scanCountKey = 'fraudroko_free_scan_count';

  Future<SecurityScanAccessResult> claimScanAccess() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'login-required',
        message: 'Login required before starting a security scan.',
      );
    }

    final prefs = await SharedPreferences.getInstance();

    // Premium access is granted only from the server-verified entitlement.
    // Never persist a local boolean as proof of an active subscription.
    bool premium = false;
    try {
      final premiumStatus = await const PremiumRepositoryImpl().getPremiumStatus();
      premium = premiumStatus == PremiumStatus.premium;
    } catch (_) {
      // A backend/network failure must never grant Premium. Free scan access
      // can continue using the local two-scan counter.
      premium = false;
    }

    final used = (prefs.getInt(_scanCountKey) ?? 0).clamp(0, _freeScanLimit);

    if (premium) {
      return const SecurityScanAccessResult(
        allowed: true,
        premium: true,
        usedFreeScans: 0,
        freeScanLimit: _freeScanLimit,
      );
    }

    if (used >= _freeScanLimit) {
      return SecurityScanAccessResult(
        allowed: false,
        premium: false,
        usedFreeScans: used,
        freeScanLimit: _freeScanLimit,
      );
    }

    final nextCount = used + 1;
    await prefs.setInt(_scanCountKey, nextCount);

    return SecurityScanAccessResult(
      allowed: true,
      premium: false,
      usedFreeScans: nextCount,
      freeScanLimit: _freeScanLimit,
    );
  }

  static Future<void> clearLocalAccessData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scanCountKey);
  }
}
