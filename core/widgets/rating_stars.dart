import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating; // 0..5
  final double size;
  final Color color;
  final int max;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 14,
    this.color = const Color(0xFFFFC107),
    this.max = 5,
  });

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (i) {
        if (i < full) {
          return Icon(Icons.star, size: size, color: color);
        } else if (i == full && half) {
          return Icon(Icons.star_half, size: size, color: color);
        }
        return Icon(Icons.star_border, size: size, color: color);
      }),
    );
  }
}