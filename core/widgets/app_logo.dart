import 'package:flutter/material.dart';

enum AppLogoSize { small, medium, large, custom }

class AppLogo extends StatelessWidget {
  final AppLogoSize size;
  final double? height; // استخدمه مع custom
  final String assetPath;

  const AppLogo({
    super.key,
    this.size = AppLogoSize.medium,
    this.height,
    this.assetPath = 'assets/se7en_logo.png',
  });

  double _resolveHeight() {
    switch (size) {
      case AppLogoSize.small:  return 64;
      case AppLogoSize.medium: return 96;
      case AppLogoSize.large:  return 132;
      case AppLogoSize.custom: return height ?? 96;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      height: _resolveHeight(),
      fit: BoxFit.contain,
    );
  }
}