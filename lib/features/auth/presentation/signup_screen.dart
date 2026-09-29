import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/app_text.dart';
import '../data/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _authService = AuthService();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty) {
      _message(AppText.t(context, 'Name is required.'));
      return;
    }

    if (email.isEmpty) {
      _message(AppText.t(context, 'Email is required.'));
      return;
    }

    if (password.isEmpty) {
      _message(AppText.t(context, 'Password is required.'));
      return;
    }

    if (password != confirmPassword) {
      _message(AppText.t(context, 'Passwords do not match.'));
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      final credential = await _authService.createAccountWithEmail(
        email,
        password,
      );

      await credential.user?.updateDisplayName(name);
      await _authService.sendEmailVerification();
      await _authService.signOut();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppText.t(context, 'Account created successfully.')),
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      final message = switch (e.code) {
        'email-already-in-use' => AppText.t(
          context,
          'This email is already registered.',
        ),
        'invalid-email' => AppText.t(context, 'Please enter a valid email.'),
        'weak-password' => AppText.t(context, 'Password is too weak.'),
        _ => AppText.t(context, 'Unable to create account. Please try again.'),
      };

      _message(message);
      setState(() => _loading = false);
    } catch (_) {
      if (!mounted) return;

      _message(
        AppText.t(context, 'Unable to create account. Please try again.'),
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
      appBar: AppBar(title: Text(AppText.t(context, 'Create Account'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                AppText.t(context, 'Create your account'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                enabled: !_loading,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: AppText.t(context, 'Full Name'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                enabled: !_loading,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: AppText.t(context, 'Email'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                enabled: !_loading,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: AppText.t(context, 'Password'),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                enabled: !_loading,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (!_loading) {
                    _createAccount();
                  }
                },
                decoration: InputDecoration(
                  labelText: AppText.t(context, 'Confirm Password'),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: _loading ? null : _createAccount,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(AppText.t(context, 'Create Account')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
