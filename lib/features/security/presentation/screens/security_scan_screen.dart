import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:fraudroko_app/features/security/presentation/security_screen.dart';
import '../providers/security_provider.dart';
import '../../../../core/localization/app_text.dart';
import '../../../../features/auth/data/auth_service.dart';
import '../../../../features/auth/presentation/login_screen.dart';
import '../../../../features/premium/presentation/screens/premium_purchase_screen.dart';
import '../../data/services/security_scan_access_service.dart';

class SecurityScanScreen extends StatefulWidget {
  const SecurityScanScreen({super.key});

  @override
  State<SecurityScanScreen> createState() => _SecurityScanScreenState();
}

class _SecurityScanScreenState extends State<SecurityScanScreen>
    with TickerProviderStateMixin {
  late AnimationController _shieldController;
  late AnimationController _scanController;

  Timer? _statusTimer;
  late final SecurityProvider _provider;
  int _progress = 0;
  int _currentStatus = 0;
  bool _finished = false;
  bool _scanStarted = false;
  String? _scanError;

  final List<String> _statusList = [
    'Checking phone lock...',
    'Checking security settings...',
    'Checking installed apps...',
    'Checking accessibility...',
    'Checking notification access...',
    'Checking device security...',
    'Preparing security report...',
  ];

  @override
  void initState() {
    super.initState();

    _provider = SecurityProvider();

    _shieldController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scanStarted) return;
    _scanStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _runRealScan();
    });
  }

  Future<void> _runRealScan() async {
    if (!mounted) return;

    _statusTimer?.cancel();
    setState(() {
      _progress = 0;
      _currentStatus = 0;
      _scanError = null;
      _finished = false;
    });
    final user = AuthService().currentUser;
    if (user == null) {
      final loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (!mounted) return;
      if (AuthService().currentUser == null && loggedIn != true) {
        _showScanError('Please login before starting a security scan.');
        return;
      }
      if (AuthService().currentUser == null) {
        _showScanError('Please login before starting a security scan.');
        return;
      }
      await _continueScanAfterLogin();
      return;
    }

    SecurityScanAccessResult access;
    try {
      access = await SecurityScanAccessService.instance.claimScanAccess();
    } on FirebaseAuthException catch (e) {
      _showScanError(
        e.code == 'login-required'
            ? 'Please login before starting a security scan.'
            : 'Could not verify scan access. Please try again.',
      );
      return;
    } catch (_) {
      _showScanError('Could not verify scan access. Please try again.');
      return;
    }

    if (!access.allowed) {
      _stopScanTimers();
      if (!mounted) return;
      await _showPremiumLimitDialog(access);
      if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
        Navigator.of(context).pop();
      }
      return;
    }

    _scanController.reset();
    _startStatusAnimation();
    final progressAnimation = _scanController.forward();

    await _provider.scanPhone();

    if (!mounted) return;
    if (_provider.error != null || _provider.securityResult == null) {
      _showScanError('Scan could not be completed. Please try again.');
      return;
    }

    // Keep the visible progress smooth for seven seconds. The real scan runs
    // independently; 100% is shown only after both are complete.
    await progressAnimation;
    if (!mounted) return;

    // Only reach 100% after the real scan has completed and the visible progress has elapsed.
    setState(() {
      _progress = 100;
      _currentStatus = _statusList.length - 1;
    });

    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (!mounted || _finished) return;
    _finished = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SecurityScreen(initialResult: _provider.securityResult),
      ),
    );
  }

  Future<void> _continueScanAfterLogin() async {
    if (!mounted) return;
    if (AuthService().currentUser == null) {
      _showScanError('Please login before starting a security scan.');
      return;
    }
    await _runRealScan();
  }

  void _stopScanTimers() {
    _statusTimer?.cancel();
    _statusTimer = null;
  }

  void _showScanError(String message) {
    if (!mounted) return;
    _stopScanTimers();
    setState(() {
      _scanError = message;
    });
  }

  Future<void> _retryScan() async {
    if (!mounted || _finished) return;
    await _runRealScan();
  }

  Future<void> _showPremiumLimitDialog(SecurityScanAccessResult access) async {
    final locale = Localizations.localeOf(context).languageCode;
    final title = switch (locale) {
      'mr' => 'तुमचे 2 मोफत सुरक्षा स्कॅन संपले आहेत',
      'en' => 'Your 2 Free Security Scans Are Over',
      _ => 'आपके 2 फ्री सिक्योरिटी स्कैन खत्म हो गए हैं',
    };
    final message = switch (locale) {
      'mr' => 'सायबर फसवणूक होण्याची वाट पाहू नका. आजची छोटी सुरक्षा पायरी उद्याच्या मोठ्या डिजिटल नुकसानीपासून वाचवू शकते.',
      'en' => 'Don’t wait for a cyber fraud to happen. A small security step today can help protect you from a bigger digital loss tomorrow.',
      _ => 'साइबर फ्रॉड होने का इंतज़ार मत करें। आज उठाया गया छोटा सुरक्षा कदम आपको कल के बड़े डिजिटल नुकसान से बचाने में मदद कर सकता है।',
    };
    final buy = switch (locale) {
      'mr' => 'आता Premium घ्या',
      'en' => 'BUY NOW',
      _ => 'BUY NOW',
    };

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Text(message, style: const TextStyle(height: 1.45)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(locale == 'mr' ? 'नंतर' : locale == 'en' ? 'Later' : 'बाद में'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PremiumPurchaseScreen()),
                );
              },
              child: Text(buy),
            ),
          ],
        );
      },
    );
  }

  void _startStatusAnimation() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (!mounted || _finished) {
        timer.cancel();
        return;
      }
      if (_currentStatus < _statusList.length - 1) {
        setState(() => _currentStatus++);
      }
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _provider.dispose();

    _shieldController.dispose();
    _scanController.dispose();

    super.dispose();
  }

  String _installedAppsDisclosure(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'hi':
        return 'FraudRoko installed apps को केवल फोन की security जांच के लिए देखता है।';
      case 'mr':
        return 'FraudRoko installed apps फक्त फोनची security तपासण्यासाठी पाहतो.';
      default:
        return 'FraudRoko checks installed apps only to perform the phone security scan.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: const Color(0xffF6F9FD),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: Column(
            children: [
              // ============================================================
              // ANIMATED SHIELD
              // ============================================================
              AnimatedBuilder(
                animation: _shieldController,
                builder: (context, child) {
                  final value = _shieldController.value;

                  return Transform.scale(
                    scale: 1.0 + (value * 0.055),
                    child: Container(
                      width: 142,
                      height: 142,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xff1565FF,
                            ).withValues(alpha: 0.18 + (value * 0.12)),
                            blurRadius: 28 + (value * 15),
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xff163C78), Color(0xff0D1C35)],
                          ),
                          border: Border.all(
                            color: const Color(0xff1565FF),
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Image.asset(
                            'assets/images/fraudroko_app_icon.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 34),

              // ============================================================
              // TITLE
              // ============================================================
              Text(
                AppText.t(context, "Phone Security Scan"),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xff111827),
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                AppText.t(context, "Checking your phone security..."),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xff64748B),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 30),

              // ============================================================
              // SCAN CARD
              // ============================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xff1D3965)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xff1565FF,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.security_rounded,
                            color: Color(0xff4D91FF),
                            size: 24,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppText.t(context, "Security check"),
                                style: TextStyle(
                                  color: Color(0xff111827),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 4),

                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: Text(
                                  _scanError == null
                                      ? AppText.t(context, _statusList[_currentStatus])
                                      : AppText.t(context, _scanError!),
                                  key: ValueKey('${_currentStatus}_$_scanError'),
                                  style: const TextStyle(
                                    color: Color(0xff64748B),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        if (_scanError == null && !_finished)
                          const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Color(0xff3D8BFF),
                            ),
                          )
                        else
                          const SizedBox(width: 22, height: 22),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // ======================================================
                    // 0 → 100 PROGRESS BAR
                    // ======================================================
                    AnimatedBuilder(
                      animation: _scanController,
                      builder: (context, child) {
                        final value = _scanError == null && !_finished
                            ? _scanController.value
                            : _progress / 100;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: value,
                            minHeight: 9,
                            backgroundColor: const Color(0xff273142),
                            color: const Color(0xff1565FF),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    // ======================================================
                    // BIG 0 → 100 NUMBER
                    // ======================================================
                    AnimatedBuilder(
                      animation: _scanController,
                      builder: (context, child) {
                        final percent = _scanError == null && !_finished
                            ? (_scanController.value * 100).floor().clamp(0, 100)
                            : _progress;
                        return Text(
                          "$percent%",
                          style: const TextStyle(
                            color: Color(0xff111827),
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 4),

                    Text(
                      (_scanError == null && !_finished)
                          ? AppText.t(context, "Security check in progress")
                          : AppText.t(context, "Security check complete"),
                      style: const TextStyle(
                        color: Color(0xff64748B),
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ======================================================
                    // STEP DOTS
                    // ======================================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_statusList.length, (index) {
                        final active = index <= _currentStatus;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 20 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xff1565FF)
                                : const Color(0xff374151),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              if (_scanError != null) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _retryScan,
                    child: Text(AppText.t(context, "Try Again")),
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // ============================================================
              // USER MESSAGE
              // ============================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xff64748B),
                    size: 16,
                  ),

                  const SizedBox(width: 6),

                  Flexible(
                    child: Text(
                      AppText.t(context, "Please don't close the app."),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xff64748B),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xffE0E8F2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.privacy_tip_outlined, color: Color(0xff2165B5), size: 18),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        _installedAppsDisclosure(context),
                        style: const TextStyle(color: Color(0xff64748B), fontSize: 11, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
