import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class GlassConfig {
  /// يحدد هل نفعل الـ blur الثقيل أم لا
  static bool enableHeavyEffects = true;

  /// استدعها في main() مرة وحدة
  static Future<void> init() async {
    if (kIsWeb) {
      enableHeavyEffects = false; // الويب غالبًا أبطأ مع BackdropFilter
      return;
    }

    final info = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final android = await info.androidInfo;
      final sdk = android.version.sdkInt;
      // أقل من Android 9 قد يتعب مع Blur + BackdropFilter
      enableHeavyEffects = sdk >= 28;
    } else if (Platform.isIOS) {
      final ios = await info.iosInfo;
      // أجهزة قديمة جدًا: طفي التأثير الثقيل
      final isOld = (ios.systemVersion).split('.').firstOrNull == '12';
      enableHeavyEffects = !isOld;
    } else {
      // منصات أخرى (macOS/Windows/Linux): فعّل، وعدّل لاحقًا حسب تجربتك
      enableHeavyEffects = true;
    }
  }
}

extension on List<String> {
  String? get firstOrNull => isEmpty ? null : first;
}