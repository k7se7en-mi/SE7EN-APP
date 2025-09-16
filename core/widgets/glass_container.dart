// ignore_for_file: deprecated_member_use, unused_import

import 'dart:ui';
import 'package:flutter/material.dart';
import 'glass_config.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  /// 16–24 مناسب عادة
  final double blur;
  /// يُطبّق على لون التينت النهائي
  final double opacity;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final BoxBorder? border;
  /// إن مرّرت لونًا فهو يَغلِب الحساب التلقائي
  final Color? tint;
  /// لو false يوقف الـ Blur (أداء أعلى)
  final bool heavy;
  /// إظهار نسيج خفيف (اختياري)
  final bool showNoise;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 20,
    this.opacity = 0.18,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.border,
    this.tint,
    this.heavy = true,
    this.showNoise = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // لون زجاج افتراضي خفيف من الـ scheme
    final baseTint = tint ??
        (isDark
            ? Colors.white.withOpacity(0.12)  // لمسة فاتحة على الداكن
            : Colors.black.withOpacity(0.08)  // لمسة داكنة على الفاتح
        );

    final glassColor = baseTint.withOpacity(opacity.clamp(0.0, 1.0));

    // إطار خفيف افتراضي
    final defaultBorderColor =
        isDark ? Colors.white.withOpacity(0.18) : Colors.black.withOpacity(0.10);

    final deco = BoxDecoration(
      color: glassColor,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(isDark ? 0.06 : 0.10),
          Colors.white.withOpacity(isDark ? 0.02 : 0.04),
        ],
      ),
      borderRadius: borderRadius,
      border: border ?? Border.all(color: defaultBorderColor, width: 1),
      boxShadow: [
        // ظل لطيف يعطي عمق بدون مبالغة
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.22 : 0.12),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(isDark ? 0.04 : 0.06),
          blurRadius: 8,
          spreadRadius: -6,
        ),
      ],
    );

    final core = Container(
      padding: padding,
      decoration: deco,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          child,
          if (showNoise)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: Opacity(
                  opacity: 0.06,
                  // لو الصورة غير موجودة، ما يطيّح التطبيق
                  child: Image.asset(
                    'assets/textures/noise.png',
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.low,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (!heavy) {
      // وضع خفيف بدون Blur (لأداء أعلى على الأجهزة القديمة/الويب)
      return ClipRRect(
        borderRadius: borderRadius,
        child: Material(type: MaterialType.transparency, child: core),
      );
    }

    // وضع زجاجي كامل مع Blur
    return ClipRRect(
      borderRadius: borderRadius,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Material(type: MaterialType.transparency, child: core),
        ),
      ),
    );
  }
}