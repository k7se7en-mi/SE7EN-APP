// Dart & Flutter
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// State management
import 'package:provider/provider.dart';

// App imports
import 'services/firebase_options.dart';
import 'features/splash/splash_page.dart';
import 'features/auth/login_page.dart';
import 'features/main_home/main_home_page.dart';
import 'core/widgets/glass_config.dart';
import 'core/localization/locale_controller.dart';

// الثيم
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // اللغة + زجاج الواجهة
  await LocaleController.instance.loadSaved();
  await GlassConfig.init();

  // تحميل وضع الثيم المحفوظ
  final themeCtrl = ThemeController();
  await themeCtrl.load(); // يقرأ من التخزين (SharedPreferences مثلاً)

  runApp(
    ChangeNotifierProvider.value(
      value: themeCtrl,
      child: const Se7enApp(),
    ),
  );
}

class Se7enApp extends StatelessWidget {
  const Se7enApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = context.watch<ThemeController>();

    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleController.instance.locale,
      builder: (_, loc, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Se7en',

          // الثيم (ألوان: برتقالي + أزرق مضي + أسود)
          theme: AppTheme.light,       // ThemeData الفاتح
          darkTheme: AppTheme.dark,    // ThemeData الداكن
          themeMode: themeCtrl.materialMode, // ThemeMode من الكنترولر

          // اللغة
          locale: loc,
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // البداية والروتس
          home: const SplashPage(),
          routes: {
            LoginPage.route: (_) => const LoginPage(),
            MainHomePage.route: (_) => const MainHomePage(),
          },
        );
      },
    );
  }
}