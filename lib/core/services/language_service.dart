// lib/core/services/language_service.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';

  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  bool get isEnglish => _currentLocale.languageCode == 'en';

  LanguageService() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);

      if (savedLanguage != null) {
        _currentLocale = Locale(savedLanguage);
        notifyListeners();
      }
    } catch (e) {
      // If there's an error loading preferences, use default language
      _currentLocale = const Locale('en');
    }
  }

  Future<void> changeLanguage(bool isEnglish) async {
    final newLocale = isEnglish ? const Locale('en') : const Locale('uk');

    if (_currentLocale != newLocale) {
      _currentLocale = newLocale;

      // Save the language preference
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, newLocale.languageCode);
      } catch (e) {
        // Handle error if needed, but don't prevent language change
      }

      notifyListeners();
    }
  }

  Future<void> toggleLanguage() async {
    await changeLanguage(!isEnglish);
  }
}
