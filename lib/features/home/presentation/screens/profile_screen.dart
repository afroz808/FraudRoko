import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fraudroko_app/features/premium/data/services/premium_config_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_text.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/presentation/login_screen.dart';
import '../../../premium/presentation/screens/premium_purchase_screen.dart';
import '../../../security/data/services/security_scan_access_service.dart';
import '../../../notifications/presentation/widgets/notification_permission_dialog.dart';
import '../widgets/bottom_navigation_widget.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          AppText.t(context, 'Your Profile'),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(initialIndex: 3),
      body: StreamBuilder<User?>(
        stream: _authService.authStateChanges,
        builder: (context, snapshot) {
          final user = snapshot.data;
          final loggedIn = user != null;

          final name = user?.displayName?.trim().isNotEmpty == true
              ? user!.displayName!.trim()
              : loggedIn
              ? (user.email?.split('@').first ?? '')
              : '';

          final email = user?.email ?? '';

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            children: [
              // ---------------------------------------------------------------
              // PROFILE HEADER
              // ---------------------------------------------------------------
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE8EDF3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.10),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.20),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 44,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loggedIn ? email : AppText.t(context, 'Not logged in'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (loggedIn && user.emailVerified) ...[
                      const SizedBox(height: 9),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              size: 15,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              AppText.t(context, 'Email Verified'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: loggedIn
                          ? OutlinedButton.icon(
                              onPressed: () async {
                                await _authService.signOut();
                              },
                              icon: const Icon(Icons.logout_rounded),
                              label: Text(AppText.t(context, 'Logout')),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.login_rounded),
                              label: Text(
                                AppText.t(context, 'Login / Create Account'),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ---------------------------------------------------------------
              // PREMIUM
              // ---------------------------------------------------------------
              _SectionTitle(title: AppText.t(context, 'Premium')),

              const SizedBox(height: 10),

              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (sheetContext) {
                      final height = MediaQuery.sizeOf(sheetContext).height;

                      return SafeArea(
                        child: Container(
                          constraints: BoxConstraints(maxHeight: height * 0.82),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF7FAFF),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                          ),
                          child: const _PremiumCard(),
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1565FF), Color(0xFF0D47C9)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppText.t(context, 'Premium Plan'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              AppText.t(context, 'Premium protection subtitle'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              '₹99 / महीना  •  ₹999 / साल',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 17,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------------------------------------------------------------
              // SETTINGS
              // ---------------------------------------------------------------
              _SectionTitle(title: AppText.t(context, 'Settings')),

              const SizedBox(height: 10),

              _ProfileTile(
                icon: Icons.security_rounded,
                title: AppText.t(context, 'Account & Security'),
                subtitle: AppText.t(
                  context,
                  'Manage your account and security',
                ),
                onTap: () {
                  final user = _authService.currentUser;

                  if (user == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                    return;
                  }

                  showModalBottomSheet<void>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (sheetContext) {
                      return _AccountSecuritySheet(authService: _authService);
                    },
                  );
                },
              ),

              _ProfileTile(
                icon: Icons.language_rounded,
                title: AppText.t(context, 'Language'),
                subtitle: _currentLanguageName(context),
                onTap: () async {
                  final provider = context.read<LocaleProvider>();

                  final selected = await showModalBottomSheet<Locale>(
                    context: context,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (sheetContext) {
                      final currentCode = context
                          .read<LocaleProvider>()
                          .locale
                          .languageCode;

                      return SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 42,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD9DEE7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                AppText.t(context, 'Select Language'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),

                              _LanguageOption(
                                title: 'मराठी',
                                subtitle: 'मराठीत पुढे सुरू ठेवा',
                                locale: const Locale('mr'),
                                selected: currentCode == 'mr',
                              ),

                              _LanguageOption(
                                title: 'हिन्दी',
                                subtitle: 'हिन्दी में जारी रखें',
                                locale: const Locale('hi'),
                                selected: currentCode == 'hi',
                              ),

                              _LanguageOption(
                                title: 'English',
                                subtitle: 'Continue in English',
                                locale: const Locale('en'),
                                selected: currentCode == 'en',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );

                  if (selected != null) {
                    await provider.setLocale(selected);
                  }
                },
              ),

              _ProfileTile(
                icon: Icons.notifications_none_rounded,
                title: AppText.t(context, 'Notifications'),
                subtitle: AppText.t(context, 'Security alerts and updates'),
                onTap: () async {
                  await NotificationPermissionDialog.show(context);
                },
              ),

              _ProfileTile(
                icon: Icons.help_outline_rounded,
                title: AppText.t(context, 'Help & Support'),
                subtitle: AppText.t(context, 'Get help with FraudRoko'),
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (sheetContext) {
                      return SafeArea(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(26),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 42,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD9DEE7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                AppText.t(context, 'Help & Support'),
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppText.t(
                                  context,
                                  'For any problem with FraudRoko, contact us.',
                                ),
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _SupportContactTile(
                                icon: Icons.email_outlined,
                                title: AppText.t(context, 'Email Support'),
                                value: 'fraudroko.support@gmail.com',
                                onTap: () async {
                                  final uri = Uri(
                                    scheme: 'mailto',
                                    path: 'fraudroko.support@gmail.com',
                                  );

                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  }
                                },
                              ),
                              const SizedBox(height: 10),
                              _SupportContactTile(
                                icon: Icons.chat_outlined,
                                title: AppText.t(context, 'WhatsApp Support'),
                                value: '+91 94210 15620',
                                onTap: () async {
                                  final uri = Uri.parse(
                                    'https://wa.me/919421015620',
                                  );

                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(sheetContext),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.textPrimary,
                                    side: const BorderSide(
                                      color: Color(0xFFE1E6ED),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(AppText.t(context, 'Close')),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 18),

              // ---------------------------------------------------------------
              // LEGAL / ABOUT
              // ---------------------------------------------------------------
              _SectionTitle(title: AppText.t(context, 'About')),

              const SizedBox(height: 10),

              _SimpleTile(
                icon: Icons.privacy_tip_outlined,
                title: AppText.t(context, 'Privacy Policy'),
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (sheetContext) {
                      return SafeArea(
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 620),
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(26),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    width: 42,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD9DEE7),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.10,
                                        ),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: const Icon(
                                        Icons.privacy_tip_outlined,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 13),
                                    Expanded(
                                      child: Text(
                                        AppText.t(context, 'Privacy Policy'),
                                        style: const TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 22),
                                _PrivacySection(
                                  title: AppText.t(
                                    context,
                                    'Your Privacy Matters',
                                  ),
                                  text: AppText.t(
                                    context,
                                    'Privacy Policy Intro',
                                  ),
                                ),
                                _PrivacySection(
                                  title: AppText.t(context, 'Account Information'),
                                  text: AppText.t(
                                    context,
                                    'Account Information Details',
                                  ),
                                ),
                                _PrivacySection(
                                  title: AppText.t(context, 'Permissions & Why'),
                                  text: AppText.t(
                                    context,
                                    'Permissions & Why Details',
                                  ),
                                ),
                                _PrivacySection(
                                  title: AppText.t(context, 'Installed Apps'),
                                  text: AppText.t(
                                    context,
                                    'Installed Apps Details',
                                  ),
                                ),
                                _PrivacySection(
                                  title: AppText.t(
                                    context,
                                    'Device Security Information',
                                  ),
                                  text: AppText.t(
                                    context,
                                    'Device Security Information Details',
                                  ),
                                ),
                                _PrivacySection(
                                  title: AppText.t(context, 'Notifications Data'),
                                  text: AppText.t(
                                    context,
                                    'Notifications Data Details',
                                  ),
                                ),
                                _PrivacySection(
                                  title: AppText.t(context, 'Link Scan Data'),
                                  text: AppText.t(
                                    context,
                                    'Link Scan Data Details',
                                  ),
                                ),
                                _PrivacySection(
                                  title: AppText.t(context, 'Analytics Information'),
                                  text: AppText.t(
                                    context,
                                    'Analytics Information Details',
                                  ),
                                ),
                                _PrivacySection(
                                  title: AppText.t(context, 'Who We Share With'),
                                  text: AppText.t(
                                    context,
                                    'Who We Share With Details',
                                  ),
                                ),
                                _PrivacySection(
                                  title: AppText.t(context, 'What We Do Not Do'),
                                  text: AppText.t(
                                    context,
                                    'What We Do Not Do Details',
                                  ),
                                ),
                                _PrivacySection(
                                  title: AppText.t(context, 'Data Deletion & Choices'),
                                  text: AppText.t(
                                    context,
                                    'Data Deletion & Choices Details',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        Navigator.pop(sheetContext),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.textPrimary,
                                      side: const BorderSide(
                                        color: Color(0xFFE1E6ED),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Text(AppText.t(context, 'Close')),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              _SimpleTile(
                icon: Icons.description_outlined,
                title: AppText.t(context, 'Terms & Conditions'),
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (sheetContext) {
                      return SafeArea(
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 620),
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(26),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    width: 42,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD9DEE7),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.10,
                                        ),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: const Icon(
                                        Icons.description_outlined,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 13),
                                    Expanded(
                                      child: Text(
                                        AppText.t(
                                          context,
                                          'Terms & Conditions',
                                        ),
                                        style: const TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 22),
                                _PrivacySection(
                                  title: AppText.t(context, 'Using FraudRoko'),
                                  text: AppText.t(
                                    context,
                                    'Using FraudRoko Details',
                                  ),
                                ),
                                _PrivacySection(
                                  title: AppText.t(context, 'Your Responsibility'),
                                  text: AppText.t(context, 'Your Responsibility Details'),
                                ),
                                _PrivacySection(
                                  title: AppText.t(context, 'Security Results'),
                                  text: AppText.t(
                                    context,
                                    'Security Results Details',
                                  ),
                                ),
                                _PrivacySection(
                                  title: AppText.t(context, 'Third-Party Services'),
                                  text: AppText.t(
                                    context,
                                    'Third-Party Services Details',
                                  ),
                                ),
                                _PrivacySection(
                                  title: AppText.t(context, 'Changes to the Service'),
                                  text: AppText.t(
                                    context,
                                    'Changes to the Service Details',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        Navigator.pop(sheetContext),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.textPrimary,
                                      side: const BorderSide(
                                        color: Color(0xFFE1E6ED),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Text(AppText.t(context, 'Close')),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              _SimpleTile(
                icon: Icons.info_outline_rounded,
                title: AppText.t(context, 'About FraudRoko'),
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (sheetContext) {
                      return SafeArea(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(26),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.10,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.shield_rounded,
                                  color: AppColors.primary,
                                  size: 27,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'FraudRoko',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppText.t(context, 'Cyber Security Assistant'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _AboutRow(
                                icon: Icons.info_outline_rounded,
                                title: AppText.t(context, 'Version'),
                                value: '1.0.0',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppText.t(
                                  context,
                                  'About FraudRoko Description',
                                ),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '© FraudRoko',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(sheetContext),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.textPrimary,
                                    side: const BorderSide(
                                      color: Color(0xFFE1E6ED),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(AppText.t(context, 'Close')),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  'FraudRoko',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _currentLanguageName(BuildContext context) {
  final code = context.watch<LocaleProvider>().locale.languageCode;

  switch (code) {
    case 'mr':
      return 'मराठी';
    case 'en':
      return 'English';
    case 'hi':
    default:
      return 'हिन्दी';
  }
}

class _AccountSecuritySheet extends StatelessWidget {
  const _AccountSecuritySheet({required this.authService});

  final AuthService authService;

  Future<void> _resetPassword(BuildContext context, String email) async {
    try {
      await authService.sendPasswordResetEmail(email);

      if (!context.mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppText.t(context, 'Password reset email sent.')),
        ),
      );
    } on FirebaseAuthException catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppText.t(context, 'Password reset email sent.')),
        ),
      );
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppText.t(dialogContext, 'Delete Account')),
          content: Text(
            AppText.t(
              dialogContext,
              'Your account and account-related access data will be permanently deleted. Payment records may be retained where required. If you have an active Google Play subscription, cancel it separately to stop future charges.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(AppText.t(dialogContext, 'Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(AppText.t(dialogContext, 'Delete Account')),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final user = authService.currentUser;
    if (user == null) return;

    try {
      final providers = user.providerData.map((p) => p.providerId).toSet();

      if (providers.contains('password')) {
        final passwordController = TextEditingController();

        final password = await showDialog<String>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(AppText.t(dialogContext, 'Delete Account')),
              content: TextField(
                controller: passwordController,
                obscureText: true,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: AppText.t(dialogContext, 'Password'),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(AppText.t(dialogContext, 'Cancel')),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext, passwordController.text),
                  child: Text(AppText.t(dialogContext, 'Continue')),
                ),
              ],
            );
          },
        );

        passwordController.dispose();

        if (password == null || password.isEmpty || !context.mounted) return;

        await authService.reauthenticateWithEmail(password);
      } else if (providers.contains('google.com')) {
        await authService.reauthenticateWithGoogle();
      }

      // The user has re-authenticated above. Firebase Auth supports direct
      // client-side deletion, so account deletion does not require Cloud Functions.
      final currentUser = authService.currentUser;
      if (currentUser == null) {
        throw FirebaseAuthException(
          code: 'no-current-user',
          message: 'No signed-in user found.',
        );
      }

      // Remove the account's own server-managed entitlement documents before
      // deleting Firebase Auth. Google Play payment records remain with Google.
      final firestore = FirebaseFirestore.instance;
      final uid = currentUser.uid;
      await firestore.collection('premium_entitlements').doc(uid).delete();

      final courseSnapshot = await firestore
          .collection('course_entitlements')
          .where('uid', isEqualTo: uid)
          .get();
      if (courseSnapshot.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (final doc in courseSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      await currentUser.delete();
      await SecurityScanAccessService.clearLocalAccessData();

      if (!context.mounted) return;
      final rootNavigator = Navigator.of(context, rootNavigator: true);
      rootNavigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );

    } on FirebaseAuthException catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message ??
                AppText.t(
                  context,
                  'Unable to delete account. Please try again.',
                ),
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppText.t(context, 'Unable to delete account. Please try again.'),
          ),
        ),
      );
    }
  }

  Future<void> _sendVerification(BuildContext context) async {
    try {
      await authService.sendEmailVerification();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppText.t(context, 'Verification email sent.'))),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppText.t(context, 'Unable to send verification email.'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    final email = user?.email ?? '';

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9DEE7),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              AppText.t(context, 'Account & Security'),
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 18),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.email_outlined,
                color: AppColors.primary,
              ),
              title: Text(
                AppText.t(context, 'Email'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(email),
            ),

            const Divider(),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                user?.emailVerified == true
                    ? Icons.verified_rounded
                    : Icons.warning_amber_rounded,
                color: user?.emailVerified == true
                    ? AppColors.success
                    : Colors.orange,
              ),
              title: Text(
                user?.emailVerified == true
                    ? AppText.t(context, 'Email Verified')
                    : AppText.t(context, 'Email Not Verified'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: user?.emailVerified == true
                  ? Text(AppText.t(context, 'Your email is verified.'))
                  : Text(
                      AppText.t(
                        context,
                        'Verify your email for better security.',
                      ),
                    ),
              trailing: user?.emailVerified == true
                  ? null
                  : TextButton(
                      onPressed: () => _sendVerification(context),
                      child: Text(AppText.t(context, 'Verify')),
                    ),
            ),

            const Divider(),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.lock_reset_rounded,
                color: AppColors.primary,
              ),
              title: Text(
                AppText.t(context, 'Reset Password'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(AppText.t(context, 'Send a password reset email')),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
              onTap: email.isEmpty
                  ? null
                  : () => _resetPassword(context, email),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => _deleteAccount(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(AppText.t(context, 'Delete Account')),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse('https://fraudroko-delete.web.app/');

                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(AppText.t(context, 'Account Deletion Webpage')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: Color(0xFFE1E6ED)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(AppText.t(context, 'Close')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.locale,
    required this.selected,
  });

  final String title;
  final String subtitle;
  final Locale locale;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(13),
        ),
        child: const Icon(Icons.language_rounded, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : const Icon(
              Icons.radio_button_unchecked_rounded,
              color: AppColors.textSecondary,
            ),
      onTap: () {
        Navigator.pop(context, locale);
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE8EDF3)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11.5,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportContactTile extends StatelessWidget {
  const _SupportContactTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F9FC),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.open_in_new_rounded,
                size: 19,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleTile extends StatelessWidget {
  const _SimpleTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xFFE8EDF3)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _PremiumCard extends StatefulWidget {
  const _PremiumCard();

  @override
  State<_PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<_PremiumCard>
    with SingleTickerProviderStateMixin {
  PremiumConfig? _premiumConfig;
  StreamSubscription<PremiumConfig>? _premiumConfigSubscription;
  Timer? _offerCountdownTimer;
  Duration _offerRemaining = Duration.zero;

  String _selectedPlan = 'monthly';

  @override
  void initState() {
    super.initState();

    _premiumConfigSubscription = PremiumConfigService.instance
        .watchConfig()
        .listen((config) {
          if (!mounted) return;

          setState(() {
            _premiumConfig = config;
          });

          _updateOfferCountdown();
        });

    _offerCountdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateOfferCountdown(),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _float = Tween<double>(
      begin: -4,
      end: 4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glow = Tween<double>(
      begin: 0.55,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _premiumConfigSubscription?.cancel();
    _offerCountdownTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _updateOfferCountdown() {
    final config = _premiumConfig;

    if (config == null || !config.offerEnabled || config.offerEnd == null) {
      if (_offerRemaining != Duration.zero && mounted) {
        setState(() {
          _offerRemaining = Duration.zero;
        });
      }
      return;
    }

    final now = DateTime.now();

    if (config.offerStart != null && now.isBefore(config.offerStart!)) {
      if (_offerRemaining != Duration.zero && mounted) {
        setState(() {
          _offerRemaining = Duration.zero;
        });
      }
      return;
    }

    final remaining = config.offerEnd!.difference(now);

    if (remaining.isNegative || remaining == Duration.zero) {
      if (mounted) {
        setState(() {
          _offerRemaining = Duration.zero;
        });
      }
      return;
    }

    if (mounted && (_offerRemaining.inSeconds != remaining.inSeconds)) {
      setState(() {
        _offerRemaining = remaining;
      });
    }
  }

  String _formatCountdown(Duration duration) {
    if (duration <= Duration.zero) return '';

    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    }

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _startPremiumPayment(String plan) async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PremiumPurchaseScreen(initialPlan: plan),
      ),
    );
  }

  late final AnimationController _controller;
  late final Animation<double> _float;
  late final Animation<double> _glow;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18 * _glow.value),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFEEF6FF),
                  Color(0xFFDCEBFF),
                  Color(0xFFFFFFFF),
                ],
              ),
              border: Border.all(color: const Color(0xFFD5E5FA), width: 1),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildHero(context),
                  const SizedBox(height: 12),
                  _buildFeatureTiles(context),
                  const SizedBox(height: 12),
                  _buildBenefits(context),
                  const SizedBox(height: 12),
                  _buildPlans(context),
                  const SizedBox(height: 12),
                  _buildUpgradeButton(context),
                  const SizedBox(height: 8),
                  _buildTrustRow(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      height: 190,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 8, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFE9F3FF), Color(0xFF1877F2)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FraudRoko',
                  style: const TextStyle(
                    color: Color(0xFF1565FF),
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  AppText.t(context, 'Premium'),
                  style: const TextStyle(
                    color: Color(0xFF172033),
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppText.t(context, 'Premium protection subtitle'),
                  style: const TextStyle(
                    color: Color(0xFF4F5B6B),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Transform.translate(
              offset: Offset(0, _float.value),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF1565FF,
                          ).withValues(alpha: 0.22 * _glow.value),
                          blurRadius: 30,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 112,
                    height: 126,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4AA3FF), Color(0xFF0754D8)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x55000000),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.shield_rounded,
                        color: Colors.white,
                        size: 74,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 12,
                    child: Transform.rotate(
                      angle: 0.08,
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Color(0xFFFFC107),
                        size: 38,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTiles(BuildContext context) {
    final features = [
      (
        Icons.shield_outlined,
        AppText.t(context, 'Premium continuous security'),
      ),
      (
        Icons.visibility_off_outlined,
        AppText.t(context, 'Premium hidden app check'),
      ),
      (
        Icons.notifications_active_outlined,
        AppText.t(context, 'Premium threat alert'),
      ),
      (
        Icons.security_rounded,
        AppText.t(context, 'Premium dangerous app alert'),
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: features.map((item) {
          return Expanded(
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(item.$1, color: AppColors.primary, size: 27),
                ),
                const SizedBox(height: 7),
                Text(
                  item.$2,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF202733),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBenefits(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565FF), Color(0xFF0D47C9)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                color: Color(0xFFFFD54F),
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                AppText.t(context, 'Premium'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _BenefitLine(
            icon: Icons.security_rounded,
            text: AppText.t(context, 'Premium dangerous app alert'),
          ),
          _BenefitLine(
            icon: Icons.visibility_off_outlined,
            text: AppText.t(context, 'Premium hidden app check'),
          ),
          _BenefitLine(
            icon: Icons.notifications_active_outlined,
            text: AppText.t(context, 'Premium threat alert'),
          ),
          _BenefitLine(
            icon: Icons.shield_outlined,
            text: AppText.t(context, 'Premium continuous security'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlans(BuildContext context) {
    final config = _premiumConfig;

    final monthlyPrice = config == null
        ? '₹99'
        : '₹${config.priceFor('monthly').toStringAsFixed(0)}';

    final yearlyPrice = config == null
        ? '₹999'
        : '₹${config.priceFor('yearly').toStringAsFixed(0)}';

    final monthlyOfferActive = config?.isOfferActiveFor('monthly') ?? false;

    final yearlyOfferActive = config?.isOfferActiveFor('yearly') ?? false;

    final showOffer = monthlyOfferActive || yearlyOfferActive;

    return Column(
      children: [
        if (showOffer && config != null && config.offerTitle.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFD8A8)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_offer_rounded,
                  color: Color(0xFFE8590C),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    config.offerTitle,
                    style: const TextStyle(
                      color: Color(0xFF9C2C00),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (_offerRemaining > Duration.zero)
                  Text(
                    _formatCountdown(_offerRemaining),
                    style: const TextStyle(
                      color: Color(0xFFE8590C),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPlan = 'monthly'),
                child: _PlanCard(
                  selected: _selectedPlan == 'monthly',
                  title: AppText.t(context, 'Month'),
                  price: monthlyPrice,
                  suffix: '/ ${AppText.t(context, 'Month')}',
                  subtitle: monthlyOfferActive
                      ? 'Offer price'
                      : AppText.t(context, 'Premium monthly security'),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPlan = 'yearly'),
                child: _PlanCard(
                  selected: _selectedPlan == 'yearly',
                  title: AppText.t(context, 'Year'),
                  price: yearlyPrice,
                  suffix: '/ ${AppText.t(context, 'Year')}',
                  subtitle: yearlyOfferActive
                      ? 'Offer price'
                      : AppText.t(context, 'Save ₹189'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpgradeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => _startPremiumPayment(_selectedPlan),
        icon: const Icon(Icons.workspace_premium_rounded, color: Colors.white),
        label: Text(
          AppText.t(context, 'Upgrade to Premium'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 5,
          shadowColor: AppColors.primary.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _buildTrustRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.verified_user_outlined, color: Colors.green, size: 18),
        const SizedBox(width: 6),
        Text(
          AppText.t(context, 'Secure payment'),
          style: const TextStyle(
            color: Color(0xFF667085),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('•'),
        ),
        Text(
          AppText.t(context, 'Cancel anytime'),
          style: const TextStyle(
            color: Color(0xFF667085),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _BenefitLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final bool selected;
  final String title;
  final String price;
  final String suffix;
  final String subtitle;

  const _PlanCard({
    required this.selected,
    required this.title,
    required this.price,
    required this.suffix,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 122,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppColors.primary : const Color(0xFFE4E7EC),
          width: selected ? 2 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF475467),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? AppColors.primary : const Color(0xFFD0D5DD),
                size: 21,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  color: selected ? AppColors.primary : const Color(0xFF16A34A),
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  suffix,
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF667085), fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}
