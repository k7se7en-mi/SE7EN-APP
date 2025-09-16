import 'dart:ui';
import 'package:flutter/material.dart';

class GlassNavItemData {
  final IconData icon;
  final String label;
  const GlassNavItemData({required this.icon, required this.label});
}

/// شريط سفلي زجاجي: العناصر وسط الشريط (Icon + Label معًا)
/// ألوانه ثابتة (لا يتبع الثيم) — المحدد فقط أزرق.
class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.rtl = true,
    this.height = 86, // ارتفاع كافي لعرض الأيقونة والاسم داخل الشريط
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassNavItemData> items;
  final bool rtl;
  final double height;

  static const Color _blue = Color(0xFF007BFF); // الأزرق الوحيد
  static const Color _base = Color(0xFFF1E6DE); // أوف وايت غير مرتبط بالثيم

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(22)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: const Color(0x26FFFFFF), // زجاجي شفاف
                border: Border.all(color: const Color(0x33FFFFFF)),
                borderRadius: const BorderRadius.all(Radius.circular(22)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x66000000).withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(items.length, (i) {
                  final d = items[i];
                  final selected = i == currentIndex;
                  return _NavButton(
                    icon: d.icon,
                    label: d.label,
                    selected: selected,
                    onTap: () => onTap(i),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const Color _blue = Color(0xFF007BFF);
  static const Color _base = Color(0xFFF1E6DE);

  @override
  Widget build(BuildContext context) {
    // عنصر متوسّط الشريط: أيقونة داخل كبسولة + الاسم تحتها، كلاهما في الوسط
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, selected ? -8 : 0, 0),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected ? _blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 24,
                  color: selected ? Colors.white : _base,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? _blue : _base.withOpacity(0.9),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}