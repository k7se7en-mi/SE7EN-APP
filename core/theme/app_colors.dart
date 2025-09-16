import 'package:flutter/material.dart';

class AppColors {
  // من طلبك:
  static const Color brownDark = Color(0xFF6B4F3A); // بني داكن
  static const Color brownLight = Color(0xFF8D6E5B); // بني أفتح
  static const Color blueLight = Color(0xFFB3E5FC);  // أزرق فاتح (أساسي للـ glass)
  static const Color blueSky  = Color(0xFFA7D8F8);   // أزرق سماوي باهت (لمسات)

  // إضافات للهوية:
  static const Color orangeDeep = Color(0xFFFF6A00); // برتقالي قوي
  static const Color black      = Colors.black;
  static const Color white      = Colors.white;

  // شفافية حدود الزجاج
  static Color glassBorder = Colors.white.withValues(alpha: 0.35);

  // خلفية عامة متدرجة (غامق -> أزرق فاتح خافت)
  static const LinearGradient appBgGradient = LinearGradient(
    colors: [Color(0xFF0E0E10), Color(0xFF10141A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // تدرّج خفيف داخل الزجاج (لمسة بني خفيفة جداً)
  static const LinearGradient glassInnerGradient = LinearGradient(
    colors: [
      Color(0x22FFFFFF),
      Color(0x1A6B4F3A), // بني داكن شفاف جدًا
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
