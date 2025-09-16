import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController {
  LocaleController._();
  static final LocaleController instance = LocaleController._();

  // Default Arabic
  final ValueNotifier<Locale> locale = ValueNotifier<Locale>(const Locale('ar'));

  String get code => locale.value.languageCode;
  bool get isArabic => code == 'ar';
  bool get isEnglish => code == 'en';

  Future<void> loadSaved({Locale? fallback}) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final saved = sp.getString('language');
      if (saved != null && saved.isNotEmpty) {
        locale.value = Locale(saved);
      } else if (fallback != null) {
        locale.value = fallback;
      }
    } catch (_) {
      // Ignore, stick with default
    }
  }

  Future<void> setLanguage(String code) async {
    final lc = code.isEmpty ? 'ar' : code;
    locale.value = Locale(lc);
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString('language', lc);
    } catch (_) {
      // Ignore persistence failures
    }
  }
}

