import 'package:flutter/material.dart';

/// ارتفاع شريط الـ GlassBottomNav
const double kGlassNavHeight = 60.0;

/// أقصى عرض للشريط الزجاجي السفلي لضمان نفس المقاس على الشاشات الكبيرة
const double kGlassNavMaxWidth = 520.0;

/// فراغ سفلي آمن نعتمد عليه في أي صفحة لتجنّب Overflow.
class BottomBarSpacer extends StatelessWidget {
  const BottomBarSpacer({super.key, this.extra = 16});

  /// مسافة إضافية اختيارية فوق الفراغ الأساسي
  final double extra;

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    return SizedBox(height: kGlassNavHeight + bottomSafe + extra);
  }
}

/// مزيّن جاهز يضيف Padding سفلي لصفحات الـ ListView/SingleChildScrollView
class WithBottomPadding extends StatelessWidget {
  const WithBottomPadding({super.key, required this.child, this.extra = 16});
  final Widget child;
  final double extra;

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: kGlassNavHeight + bottomSafe + extra),
      child: child,
    );
  }
}
