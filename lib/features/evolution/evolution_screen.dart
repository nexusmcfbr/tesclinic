import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards.dart';

class EvolutionScreen extends StatelessWidget {
  const EvolutionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final values = [0.55, 0.7, 0.45, 0.85, 0.75, 0.9, 0.65];
    final labels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            // Chart
            DarkCard(
              child: Column(
                children: [
                  SizedBox(
                    height: 140,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (i) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: FractionallySizedBox(
                                      heightFactor: values[i],
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(labels[i], style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DarkCard(
                    child: Column(
                      children: [
                        const Text('Energia média', style: TextStyle(fontSize: 12, color: AppColors.tertiary)),
                        const SizedBox(height: 6),
                        const Text('8.6', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                        const Text('/10', style: TextStyle(fontSize: 12, color: AppColors.tertiary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DarkCard(
                    child: Column(
                      children: [
                        const Text('Consistência', style: TextStyle(fontSize: 12, color: AppColors.tertiary)),
                        const SizedBox(height: 6),
                        const Text('5', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                        const Text('treinos', style: TextStyle(fontSize: 12, color: AppColors.tertiary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Indicadores', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            DarkCard(
              child: Column(
                children: [
                  _row('Recuperação', '7.9/10'),
                  const Divider(color: AppColors.border, height: 20),
                  _row('Foco médio', '9.1/10'),
                  const Divider(color: AppColors.border, height: 20),
                  _row('Carga progressiva', '+12%'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Prontidão estimada', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            DarkCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Baseada na tendência semanal', style: TextStyle(fontSize: 13, color: AppColors.tertiary)),
                        SizedBox(height: 8),
                        Text('Alta consistência de treino e boa recuperação média.', style: TextStyle(fontSize: 13, height: 1.35)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const SizedBox(
                          width: 70,
                          height: 70,
                          child: CircularProgressIndicator(
                            value: 0.86,
                            strokeWidth: 5,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation(AppColors.primary),
                          ),
                        ),
                        const Text('86', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v) {
    return Row(
      children: [
        Text(k, style: const TextStyle(fontSize: 14)),
        const Spacer(),
        Text(v, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ],
    );
  }
}
