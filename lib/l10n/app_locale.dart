import 'package:flutter/material.dart';

class AppLocale {
  static const String english = 'en';
  static const String danish = 'da';
  static const String german = 'de';
  static const String spanish = 'es';

  static const List<Locale> supportedLocales = [
    Locale(english),
    Locale(danish),
    Locale(german),
    Locale(spanish),
  ];

  static const List<String> supportedLanguageCodes = [
    english,
    danish,
    german,
    spanish,
  ];

  static String normalizeLanguageCode(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    switch (normalized) {
      case 'en':
      case 'eng':
      case 'english':
        return english;
      case 'da':
      case 'danish':
      case 'dansk':
        return danish;
      case 'de':
      case 'german':
      case 'deutsch':
        return german;
      case 'es':
      case 'spanish':
      case 'espanol':
      case 'español':
        return spanish;
      default:
        return english;
    }
  }

  static Locale localeFromPreference(String? value) {
    final code = normalizeLanguageCode(value);
    return supportedLocales.firstWhere(
      (locale) => locale.languageCode == code,
      orElse: () => const Locale(english),
    );
  }

  static String preferenceFromDeviceLocale(Locale locale) {
    final code = normalizeLanguageCode(locale.languageCode);
    return supportedLanguageCodes.contains(code) ? code : english;
  }
}
