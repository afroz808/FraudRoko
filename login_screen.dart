import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/auth_service.dart';
import 'signup_screen.dart';
import 'reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _loading = false;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context)!;

    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _message(l10n.emailRequired);
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => _loading = true);

    try {
      await _authService.signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        await _animateAndPop();
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('EMAIL_LOGIN_ERROR: code=${e.code} message=${e.message}');
      if (!mounted) return;

      final message = switch (e.code) {
        'invalid-input' => 'Please enter your email and password.',
        'too-many-requests' =>
          'Too many login attempts. Please try again later.',
        'network-request-failed' =>
          'Internet connection failed. Please check your internet and try again.',
        'invalid-email' => 'Please enter a valid email address.',
        'user-disabled' => 'This account has been disabled. Please contact support.',
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' =>
          'Email or password is incorrect.',
        'operation-not-allowed' =>
          'Email/password login is not enabled. Please contact support.',
        'api-key-not-valid' ||
        'app-not-authorized' =>
          'App authentication configuration is invalid. Please update the app.',
        _ => '${l10n.loginFailed} (${e.code})',
      };

      _message(message);
      setState(() => _loading = false);
    } catch (e) {
      debugPrint('EMAIL_LOGIN_UNEXPECTED_ERROR: $e');
      if (!mounted) return;
      if (!mounted) return;

      _message(l10n.somethingWentWrong);
      setState(() => _loading = false);
    }
  }


  Future<void> _googleLogin() async {
    final l10n = AppLocalizations.of(context)!;

    FocusScope.of(context).unfocus();

    setState(() => _loading = true);

    try {
      await _authService.signInWithGoogle();

      if (mounted) {
        await _animateAndPop();
      }
    } on FirebaseAuthException {
      if (!mounted) return;

      _message(l10n.googleSignInFailed);

      setState(() => _loading = false);
    } catch (_) {
      if (!mounted) return;

      _message(l10n.googleSignInFailed);
      setState(() => _loading = false);
    }
  }

  Future<void> _animateAndPop() async {
    if (!mounted) return;

    Navigator.of(context).pop(true);
  }

  void _message(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.login),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 2),

              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 72,
                      height: 72,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.18),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        size: 46,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    l10n.welcomeBack,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  l10n.loginToYourAccount,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              _AnimatedField(
                animation: _animationController,
                intervalStart: 0.15,
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !_loading,
                  decoration: InputDecoration(
                    labelText: l10n.emailLabel,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.textSecondary.withValues(alpha: 0.20),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              _AnimatedField(
                animation: _animationController,
                intervalStart: 0.22,
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  enabled: !_loading,
                  onSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    labelText: l10n.passwordLabel,
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.textSecondary.withValues(alpha: 0.20),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    suffixIcon: IconButton(
                      tooltip: l10n.showPassword,
                      onPressed: _loading
                          ? null
                          : () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          key: ValueKey(_obscurePassword),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 0),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _loading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ResetPasswordScreen(),
                            ),
                          );
                        },
                  child: Text(l10n.forgotPassword),
                ),
              ),

              const SizedBox(height: 2),

              _AnimatedField(
                animation: _animationController,
                intervalStart: 0.32,
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: _loading ? 0 : 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: _loading
                          ? const SizedBox(
                              key: ValueKey('loading'),
                              width: 23,
                              height: 23,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              l10n.signIn,
                              key: const ValueKey('signin'),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: AppColors.textSecondary.withValues(alpha: 0.20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      l10n.or,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppColors.textSecondary.withValues(alpha: 0.20),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _AnimatedField(
                animation: _animationController,
                intervalStart: 0.40,
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : _googleLogin,
                    icon: const Icon(Icons.g_mobiledata, size: 29),
                    label: Text(
                      l10n.continueWithGoogle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide(
                        color: AppColors.textSecondary.withValues(alpha: 0.25),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const SizedBox(height: 18),

              FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            );
                          },
                    child: Text(
                      '${l10n.dontHaveAccount} ${l10n.createAccount}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedField extends StatelessWidget {
  const _AnimatedField({
    required this.animation,
    required this.intervalStart,
    required this.child,
  });

  final AnimationController animation;
  final double intervalStart;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animationValue = CurvedAnimation(
      parent: animation,
      curve: Interval(
        intervalStart,
        (intervalStart + 0.45).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return FadeTransition(
      opacity: animationValue,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(animationValue),
        child: child,
      ),
    );
  }
}
