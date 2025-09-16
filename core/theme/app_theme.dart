import 'package:flutter/material.dart';

class AppColors {
  static const Color orange = Color(0xFFFF6A00); // برتقالي رئيسي
  static const Color blue   = Color(0xFF007BFF); // أزرق مساعد
  static const Color brown  = Color(0xFF4E342E); // بني بدل الأسود
}

class AppTheme {
  // ثيم نهاري
  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.orange,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: AppColors.orange,
          secondary: AppColors.blue,
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.brown,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      );

  // ثيم ليلي
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.orange,
        scaffoldBackgroundColor: AppColors.brown,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.orange,
          secondary: AppColors.blue,
          surface: AppColors.brown,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      );
}