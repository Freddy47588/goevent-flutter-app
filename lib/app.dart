import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'auth_gate.dart';
import 'routes/app_routes.dart';

class GoEventApp extends StatefulWidget {
  const GoEventApp({super.key});

  @override
  State<GoEventApp> createState() => _GoEventAppState();
}

class _GoEventAppState extends State<GoEventApp> {
  @override
  void initState() {
    super.initState();
    ThemeController.instance.init(); // ✅ init sekali
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.notifier,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          home: const AuthGate(), // ✅ inilah kuncinya
          // ✅ tambahkan ini biar pushNamed jalan
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
