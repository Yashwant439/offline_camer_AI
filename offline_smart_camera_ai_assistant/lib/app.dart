import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'features/camera_screen.dart';
import 'features/chat_screen.dart';
import 'features/history_screen.dart';
import 'features/home_screen.dart';
import 'features/result_screen.dart';
import 'features/settings_screen.dart';
import 'features/splash_screen.dart';

class OfflineSmartCameraApp extends ConsumerWidget {
  const OfflineSmartCameraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Offline Smart Camera AI Assistant',
      theme: AppTheme.light(),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.camera: (_) => const CameraScreen(),
        AppRoutes.result: (_) => const ResultScreen(),
        AppRoutes.chat: (_) => const ChatScreen(),
        AppRoutes.history: (_) => const HistoryScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
      },
    );
  }
}
