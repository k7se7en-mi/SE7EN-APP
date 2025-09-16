import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PriceText extends StatelessWidget {
  final double price;
  final double iconSize;
  final Color? color;

  const PriceText(
    this.price, {
    super.key,
    this.iconSize = 18,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          price.toStringAsFixed(2),
          style: TextStyle(
            color: color ?? Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        SvgPicture.asset(
          'assets/icons/riyal.svg', // ← أيقونة الريال الجديد
          width: iconSize,
          height: iconSize,
          color: color,
        ),
      ],
    );
  }
}