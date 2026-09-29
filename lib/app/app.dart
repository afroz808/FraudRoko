import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../core/localization/locale_provider.dart';
import '../l10n/generated/app_localizations.dart';

import 'app_theme.dart';
import '../features/splash/presentation/splash_screen.dart';

class FraudRokoApp extends StatelessWidget {
  const FraudRokoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'FraudRoko',

      theme: AppTheme.lightTheme,

      locale: localeProvider.locale,

      supportedLocales: AppLocalizations.supportedLocales,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: const SplashScreen(),
    );
  }
}
