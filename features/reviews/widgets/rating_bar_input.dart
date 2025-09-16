import 'package:flutter/material.dart';

class RatingBarInput extends StatefulWidget {
  final double initial;
  final ValueChanged<double> onChanged;
  final double size;

  const RatingBarInput({
    super.key,
    this.initial = 4.0,
    required this.onChanged,
    this.size = 28,
  });

  @override
  State<RatingBarInput> createState() => _RatingBarInputState();
}

class _RatingBarInputState extends State<RatingBarInput> {
  late double value;

  @override
  void initState() {
    super.initState();
    value = widget.initial.clamp(0, 5);
  }

  void _set(double v) {
    setState(() => value = v);
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final idx = i + 1;
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          iconSize: widget.size,
          onPressed: () => _set(idx.toDouble()),
          icon: Icon(
            idx <= value ? Icons.star : Icons.star_border,
            color: const Color(0xFFFFC107),
          ),
        );
      }),
    );
  }
}