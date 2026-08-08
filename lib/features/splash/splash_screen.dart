import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _progress = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeInOut),
    );
    _c.forward();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final state = context.read<AppState>();
    // Inicializa de verdade + mantém animação visual
    await Future.wait([
      state.initialize(),
      Future.delayed(const Duration(milliseconds: 2200)),
    ]);
    // initialize() já define a tela correta (login ou main)
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            const TesClinicLogo(fontSize: 36),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: AnimatedBuilder(
                animation: _progress,
                builder: (_, __) => ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: _progress.value,
                    minHeight: 3,
                    backgroundColor: AppColors.border,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Carregando motor inteligente...',
              style: TextStyle(fontSize: 13, color: AppColors.tertiary),
            ),
            const Spacer(flex: 4),
            const Text(
              'Criado e desenvolvido por',
              style: TextStyle(fontSize: 12, color: AppColors.tertiary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Magno Fagundes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
