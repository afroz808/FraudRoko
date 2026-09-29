import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/app_text.dart';
import '../data/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _message(AppText.t(context, 'Enter your registered email.'));
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      await _authService.sendPasswordResetEmail(email);

      if (!mounted) return;

      setState(() {
        _loading = false;
        _sent = true;
      });
    } on FirebaseAuthException catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _sent = true;
      });
    } catch (_) {
      if (!mounted) return;

      _message(
        AppText.t(context, 'Unable to send reset email. Please try again.'),
      );
      setState(() => _loading = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppText.t(context, 'Reset Password'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                AppText.t(context, 'Reset Password'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                AppText.t(
                  context,
                  'Enter your registered email to receive a password reset link.',
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                enabled: !_loading && !_sent,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: AppText.t(context, 'Email'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              if (_sent)
                Text(
                  AppText.t(
                    context,
                    'If an account uses this email, a password reset link has been sent.',
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: _loading || _sent ? null : _sendResetLink,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(AppText.t(context, 'Send Reset Link')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
