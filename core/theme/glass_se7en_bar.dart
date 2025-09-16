import 'dart:ui';
import 'package:flutter/material.dart';

class GlassMenuItem {
  final String label;
  final IconData? icon;
  const GlassMenuItem(this.label, {this.icon});
}

/// شريط قوائم زجاجي أفقي مع اختيار عنصر واحد فقط.
/// لا يتبع الثيم في الألوان؛ المفعّل بالأزرق فقط.
class GlassMenuBar extends StatelessWidget {
  const GlassMenuBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
    this.rtl = true,
    this.expand = false,        // true = توزيع متساوٍ، false = سكرول أفقي
    this.height = 56,
  });

  final List<GlassMenuItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final bool rtl;
  final bool expand;
  final double height;

  static const Color _blue = Color(0xFF007BFF);
  static const Color _base = Color(0xFFF1E6DE);

  @override
  Widget build(BuildContext context) {
    final content = Row(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      children: List.generate(items.length, (i) {
        final it = items[i];
        final selected = i == currentIndex;

        final child = _GlassMenuChip(
          label: it.label,
          icon: it.icon,
          selected: selected,
          onTap: () => onChanged(i),
        );

        return expand
            ? Expanded(child: child)
            : Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: child);
      }),
    );

    final inner = expand
        ? content
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: rtl,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: content,
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: const Color(0x26FFFFFF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x33FFFFFF)),
            boxShadow: [
              BoxShadow(
                color: const Color(0x66000000).withOpacity(0.10),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.centerLeft,
          child: inner,
        ),
      ),
    );
  }
}

class _GlassMenuChip extends StatelessWidget {
  const _GlassMenuChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  static const Color _blue = Color(0xFF007BFF);
  static const Color _base = Color(0xFFF1E6DE);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, selected ? -6 : 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _blue : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: selected ? Colors.white : _base),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : _base.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}