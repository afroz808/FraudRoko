import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../core/localization/locale_provider.dart';
import '../../notifications/presentation/widgets/notification_permission_dialog.dart';

import 'widgets/phone_security_card.dart';
import 'widgets/scam_alert_card.dart';
import 'widgets/quick_actions_card.dart';
import 'widgets/bottom_navigation_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _networkTimer;
  bool _offline = false;

  Future<void> _checkInternet() async {
    try {
      final response = await http
          .get(Uri.parse('https://clients3.google.com/generate_204'))
          .timeout(const Duration(seconds: 3));
      if (!mounted) return;
      setState(() => _offline = response.statusCode != 204);
    } catch (_) {
      if (!mounted) return;
      setState(() => _offline = true);
    }
  }
  @override
  void initState() {
    super.initState();

    // ============================================================
    // FIRST-TIME NOTIFICATION PERMISSION
    // ============================================================
    _checkInternet();
    _networkTimer = Timer.periodic(const Duration(seconds: 15), (_) => _checkInternet());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await NotificationPermissionDialog.show(context);
      if (!mounted) return;

    });
  }

  @override
  void dispose() {
    _networkTimer?.cancel();
    super.dispose();
  }

  String _offlineText(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'hi':
        return 'इंटरनेट कनेक्ट करें। FraudRoko की कुछ सुविधाओं के लिए इंटरनेट जरूरी है।';
      case 'mr':
        return 'इंटरनेट कनेक्ट करा. FraudRoko च्या काही सुविधांसाठी इंटरनेट आवश्यक आहे.';
      default:
        return 'Connect to the internet. Some FraudRoko features need an internet connection.';
    }
  }

  // ============================================================
  // LANGUAGE SELECTOR
  // ============================================================
  Future<void> _showLanguageSelector() async {
    if (!mounted) return;

    final currentLanguage = Localizations.localeOf(context).languageCode;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (sheetContext) {
        return _LanguageSelectorSheet(
          currentLanguage: currentLanguage,
          onSelected: (languageCode, languageName) {
            final provider = Provider.of<LocaleProvider>(
              context,
              listen: false,
            );

            provider.setLocale(Locale(languageCode));

            Navigator.of(sheetContext).pop();

            // Small confirmation after language changes.
            Future.delayed(const Duration(milliseconds: 180), () {
              if (!mounted) return;

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    duration: const Duration(milliseconds: 1800),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    backgroundColor: const Color(0xff0F4C81),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    content: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _languageChangedText(languageCode, languageName),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
            });
          },
        );
      },
    );
  }

  String _languageChangedText(String languageCode, String languageName) {
    switch (languageCode) {
      case 'hi':
        return 'भाषा बदल गई • हिन्दी चुनी गई';

      case 'mr':
        return 'भाषा बदलली • मराठी निवडली';

      case 'en':
      default:
        return 'Language changed • English selected';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      bottomNavigationBar: const BottomNavigationWidget(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Keep the content comfortably readable on phones and tablets.
            final horizontal = constraints.maxWidth >= 600 ? 28.0 : 18.0;
            final maxContentWidth = 760.0;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_offline) ...[
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7E8),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFF3D28A)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.wifi_off_rounded, size: 19, color: Color(0xFFA16207)),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  _offlineText(context),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.35,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF854D0E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Compact, consistent product header.
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF3FF),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFD4E5FB)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0D1565FF),
                              blurRadius: 18,
                              offset: Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 78,
                                child: Image.asset(
                                  'assets/images/fraudroko_logo.png',
                                  fit: BoxFit.contain,
                                  alignment: Alignment.centerLeft,
                                  cacheWidth: 420,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _AnimatedHeaderButton(
                              onTap: () async {
                                await NotificationPermissionDialog.openFromHeader(context);
                              },
                              child: _HeaderIconButton(
                                icon: Icons.notifications_none_rounded,
                                showDot: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _AnimatedHeaderButton(
                              onTap: _showLanguageSelector,
                              child: _HeaderIconButton(
                                icon: Icons.language_rounded,
                                label: _languageLabel(Localizations.localeOf(context).languageCode),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      const PhoneSecurityCard(),
                      const SizedBox(height: 18),
                      const ScamAlertCard(),
                      const SizedBox(height: 24),
                      const QuickActionsCard(),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _languageLabel(String code) {

    switch (code) {
      case 'hi':
        return 'भाषा';

      case 'mr':
        return 'भाषा';

      case 'en':
      default:
        return 'Language';
    }
  }
}

// ==========================================================================
// COMPACT HEADER BUTTON
// ==========================================================================

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final bool showDot;

  const _HeaderIconButton({
    required this.icon,
    this.label,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: label == null ? 48 : 62,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFD4E2F4)),
      ),
      child: Stack(
        children: [
          Center(
            child: label == null
                ? Icon(icon, size: 25, color: const Color(0xFF173B6C))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 21, color: const Color(0xFF2165B5)),
                      const SizedBox(height: 1),
                      Flexible(
                        child: Text(
                          label!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2165B5),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          if (showDot)
            Positioned(
              right: 8,
              top: 7,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ANIMATED HEADER BUTTON
// ==========================================================================

class _AnimatedHeaderButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedHeaderButton({required this.child, required this.onTap});

  @override
  State<_AnimatedHeaderButton> createState() => _AnimatedHeaderButtonState();
}

class _AnimatedHeaderButtonState extends State<_AnimatedHeaderButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onTapDown: (_) {
        setState(() {
          _pressed = true;
        });
      },

      onTapUp: (_) {
        setState(() {
          _pressed = false;
        });

        widget.onTap();
      },

      onTapCancel: () {
        setState(() {
          _pressed = false;
        });
      },

      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// ==========================================================================
// LANGUAGE SELECTOR
// ==========================================================================

class _LanguageSelectorSheet extends StatefulWidget {
  final String currentLanguage;
  final void Function(String languageCode, String languageName) onSelected;

  const _LanguageSelectorSheet({
    required this.currentLanguage,
    required this.onSelected,
  });

  @override
  State<_LanguageSelectorSheet> createState() => _LanguageSelectorSheetState();
}

class _LanguageSelectorSheetState extends State<_LanguageSelectorSheet> {
  late String _selectedLanguage;

  final List<_LanguageItem> _languages = const [
    _LanguageItem(code: 'hi', name: 'हिन्दी', subtitle: 'Hindi', flag: '🇮🇳'),
    _LanguageItem(
      code: 'en',
      name: 'English',
      subtitle: 'English',
      flag: '🇬🇧',
    ),
    _LanguageItem(code: 'mr', name: 'मराठी', subtitle: 'Marathi', flag: '🇮🇳'),
  ];

  @override
  void initState() {
    super.initState();

    _selectedLanguage = widget.currentLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --------------------------------------------------------------
            // HANDLE
            // --------------------------------------------------------------
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xffD1D5DB),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 20),

            // --------------------------------------------------------------
            // TITLE
            // --------------------------------------------------------------
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xffEEF4FF),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.language_rounded,
                    color: Color(0xff1557C8),
                    size: 24,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _sheetTitle(widget.currentLanguage),
                        style: const TextStyle(
                          color: Color(0xff111827),
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        _sheetSubtitle(widget.currentLanguage),
                        style: const TextStyle(
                          color: Color(0xff64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // --------------------------------------------------------------
            // LANGUAGE OPTIONS
            // --------------------------------------------------------------
            ..._languages.map((language) {
              final isSelected = _selectedLanguage == language.code;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    if (_selectedLanguage == language.code) {
                      return;
                    }

                    setState(() {
                      _selectedLanguage = language.code;
                    });

                    // Small selection animation moment.
                    Future.delayed(const Duration(milliseconds: 180), () {
                      if (!mounted) return;

                      widget.onSelected(language.code, language.name);
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xffEEF5FF)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xff1565FF)
                            : const Color(0xffE5E7EB),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          language.flag,
                          style: const TextStyle(fontSize: 25),
                        ),

                        const SizedBox(width: 13),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                language.name,
                                style: TextStyle(
                                  color: const Color(0xff111827),
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 2),

                              Text(
                                language.subtitle,
                                style: const TextStyle(
                                  color: Color(0xff64748B),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),

                        AnimatedScale(
                          scale: isSelected ? 1.0 : 0.7,
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutBack,
                          child: AnimatedOpacity(
                            opacity: isSelected ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 180),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: Color(0xff1565FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _sheetTitle(String language) {
    switch (language) {
      case 'en':
        return 'Choose Language';

      case 'mr':
        return 'भाषा निवडा';

      case 'hi':
      default:
        return 'भाषा चुनें';
    }
  }

  String _sheetSubtitle(String language) {
    switch (language) {
      case 'en':
        return 'Select the language you want to use';

      case 'mr':
        return 'तुम्हाला वापरायची भाषा निवडा';

      case 'hi':
      default:
        return 'अपनी पसंद की भाषा चुनें';
    }
  }
}

// ==========================================================================
// LANGUAGE MODEL
// ==========================================================================

class _LanguageItem {
  final String code;
  final String name;
  final String subtitle;
  final String flag;

  const _LanguageItem({
    required this.code,
    required this.name,
    required this.subtitle,
    required this.flag,
  });
}
