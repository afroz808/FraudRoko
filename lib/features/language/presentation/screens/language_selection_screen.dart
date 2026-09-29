import 'package:flutter/material.dart';
import '../../../../../core/localization/app_text.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/locale_provider.dart';
import '../../../home/presentation/home_screen.dart';
import '../widgets/animated_background.dart';
import '../widgets/animated_logo.dart';
import '../widgets/continue_button.dart';
import '../widgets/language_card.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with SingleTickerProviderStateMixin {
  Locale _selectedLocale = const Locale("mr");

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, .12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final provider = Provider.of<LocaleProvider>(context, listen: false);

    await provider.setLocale(_selectedLocale);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        children: [
                          const AnimatedLogo(),

                          const SizedBox(height: 18),

                          Text(
                            AppText.t(context, "Select Language"),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            AppText.t(context, "Select a language to continue"),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 20),

                          LanguageCard(
                            flag: "🇮🇳",
                            title: AppText.t(context, "मराठी"),
                            subtitle: "मराठीत पुढे सुरू ठेवा",
                            selected: _selectedLocale.languageCode == "mr",
                            onTap: () {
                              setState(() {
                                _selectedLocale = const Locale("mr");
                              });
                            },
                          ),

                          LanguageCard(
                            flag: "🇮🇳",
                            title: AppText.t(context, "हिन्दी"),
                            subtitle: "हिन्दी में जारी रखें",
                            selected: _selectedLocale.languageCode == "hi",
                            onTap: () {
                              setState(() {
                                _selectedLocale = const Locale("hi");
                              });
                            },
                          ),

                          LanguageCard(
                            flag: "🇬🇧",
                            title: AppText.t(context, "English"),
                            subtitle: AppText.t(context, "Continue in English"),
                            selected: _selectedLocale.languageCode == "en",
                            onTap: () {
                              setState(() {
                                _selectedLocale = const Locale("en");
                              });
                            },
                          ),

                          const SizedBox(height: 20),

                          ContinueButton(onPressed: _continue),

                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
