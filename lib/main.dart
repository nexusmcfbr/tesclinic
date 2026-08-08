import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/app_state.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/health/health_connect_screen.dart';
import 'features/ai_analysis/ai_analysis_screen.dart';
import 'features/home/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.background,
  ));
  runApp(const TesClinicApp());
}

class TesClinicApp extends StatelessWidget {
  const TesClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'TesClinic',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const RootView(),
      ),
    );
  }
}

class RootView extends StatelessWidget {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = context.watch<AppState>().screen;
    switch (screen) {
      case AppScreen.splash:
        return const SplashScreen();
      case AppScreen.login:
        return const LoginScreen();
      case AppScreen.healthConnect:
        return const HealthConnectScreen();
      case AppScreen.aiAnalysis:
        return const AiAnalysisScreen();
      case AppScreen.main:
        return const MainShell();
    }
  }
}
