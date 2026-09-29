import 'dart:async';

class AuthSecurityGuard {
  AuthSecurityGuard({
    this.otpExpiry = const Duration(minutes: 5),
    this.resendCooldown = const Duration(seconds: 30),
    this.maxOtpAttempts = 5,
    this.maxOtpRequests = 5,
    this.requestWindow = const Duration(minutes: 15),
    this.lockoutDuration = const Duration(minutes: 15),
  });

  final Duration otpExpiry;
  final Duration resendCooldown;
  final int maxOtpAttempts;
  final int maxOtpRequests;
  final Duration requestWindow;
  final Duration lockoutDuration;

  DateTime? _otpExpiresAt;
  DateTime? _lastOtpSentAt;
  DateTime? _lockedUntil;

  int _otpAttempts = 0;
  int _otpRequests = 0;
  DateTime? _requestWindowStartedAt;

  Timer? _timer;

  bool get isLocked {
    final lockedUntil = _lockedUntil;
    if (lockedUntil == null) return false;

    if (DateTime.now().isBefore(lockedUntil)) {
      return true;
    }

    _lockedUntil = null;
    _otpAttempts = 0;
    return false;
  }

  Duration get remainingLockout {
    final lockedUntil = _lockedUntil;
    if (lockedUntil == null) return Duration.zero;

    final remaining = lockedUntil.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Duration get remainingResendCooldown {
    final lastSent = _lastOtpSentAt;
    if (lastSent == null) return Duration.zero;

    final remaining = resendCooldown - DateTime.now().difference(lastSent);

    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get canResend => !isLocked && remainingResendCooldown == Duration.zero;

  bool get otpExpired {
    final expiresAt = _otpExpiresAt;
    if (expiresAt == null) return true;

    return DateTime.now().isAfter(expiresAt);
  }

  int get remainingOtpAttempts {
    final remaining = maxOtpAttempts - _otpAttempts;
    return remaining < 0 ? 0 : remaining;
  }

  void startOtpSession() {
    if (isLocked) {
      throw StateError('AUTH_TEMPORARILY_LOCKED');
    }

    _otpExpiresAt = DateTime.now().add(otpExpiry);
    _lastOtpSentAt = DateTime.now();

    _registerOtpRequest();
  }

  void recordFailedOtpAttempt() {
    if (isLocked) {
      throw StateError('AUTH_TEMPORARILY_LOCKED');
    }

    _otpAttempts++;

    if (_otpAttempts >= maxOtpAttempts) {
      _lockedUntil = DateTime.now().add(lockoutDuration);
    }
  }

  void resetOtpAttempts() {
    _otpAttempts = 0;
  }

  void dispose() {
    _timer?.cancel();
  }

  void _registerOtpRequest() {
    final now = DateTime.now();

    if (_requestWindowStartedAt == null ||
        now.difference(_requestWindowStartedAt!) >= requestWindow) {
      _requestWindowStartedAt = now;
      _otpRequests = 0;
    }

    _otpRequests++;

    if (_otpRequests > maxOtpRequests) {
      _lockedUntil = now.add(lockoutDuration);
      throw StateError('AUTH_TOO_MANY_REQUESTS');
    }
  }
}
