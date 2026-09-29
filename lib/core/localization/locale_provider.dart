import 'package:flutter/material.dart';
import 'language_service.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('hi');

  Locale get locale => _locale;

  Future<void> loadSavedLocale() async {
    _locale = await LanguageService.loadLocale();
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;

    await LanguageService.saveLocale(locale);

    notifyListeners();
  }
}
