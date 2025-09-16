import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_controller.dart';

class ThemeModeTile extends StatelessWidget {
  const ThemeModeTile({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ThemeController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('المظهر', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(
              value: ThemeMode.system,
              icon: Icon(Icons.auto_mode),
              label: Text('اتّباع النظام'),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              icon: Icon(Icons.light_mode),
              label: Text('نهاري'),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              icon: Icon(Icons.dark_mode),
              label: Text('ليلي'),
            ),
          ],
          selected: {ctrl.materialMode},
          showSelectedIcon: false,
          onSelectionChanged: (set) {
            final mode = set.first;
            context.read<ThemeController>().setMode(mode);
          },
        ),
      ],
    );
  }
}