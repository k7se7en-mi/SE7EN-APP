import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const _key = 'theme_mode'; // 'light' | 'dark' | 'system'
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get materialMode => _mode;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getString(_key);
    _mode = switch (v) {
      'light' => ThemeMode.light,
      'dark'  => ThemeMode.dark,
      _       => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> setMode(ThemeMode m) async {
    _mode = m;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, switch (m) {
      ThemeMode.light => 'light',
      ThemeMode.dark  => 'dark',
      _               => 'system',
    });
    notifyListeners();
  }

  // اختصار للتبديل بين فاتح/داكن
  Future<void> toggle() async =>
      setMode(_mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
}