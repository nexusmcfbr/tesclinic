import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../models/demo_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards.dart';
import '../lab/lab_sheet.dart';

class FormulaScreen extends StatelessWidget {
  const FormulaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            const Text(DemoFormula.code, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const SizedBox(height: 4),
            const Text(DemoFormula.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),

            // Leitura da IA
            DarkCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Leitura da IA', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),
                  ScoreBar(label: 'Energia', value: DemoFormula.energyScore),
                  ScoreBar(label: 'Foco', value: DemoFormula.focusScore),
                  ScoreBar(label: 'Resistência', value: DemoFormula.resistanceScore),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Score de otimização
            DarkCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Score de otimização da fórmula', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),
                  ScoreBar(label: 'Performance', value: DemoFormula.performance),
                  const Text('Compatibilidade com objetivo e intensidade do treino', style: TextStyle(fontSize: 11, color: AppColors.tertiary)),
                  const SizedBox(height: 12),
                  ScoreBar(label: 'Tolerabilidade', value: DemoFormula.tolerability),
                  const Text('Adequação ao sono, estresse e sensibilidade do usuário', style: TextStyle(fontSize: 11, color: AppColors.tertiary)),
                  const SizedBox(height: 12),
                  ScoreBar(label: 'Equilíbrio', value: DemoFormula.balance),
                  const Text('Distribuição entre energia, foco e resistência', style: TextStyle(fontSize: 11, color: AppColors.tertiary)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Otimização
            DarkCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Otimização inteligente', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text(
                    'A IA pode revisar a fórmula atual e aplicar substituições mais toleráveis com base no sono, estresse, recuperação e horário do treino.',
                    style: TextStyle(fontSize: 13, color: AppColors.tertiary, height: 1.4),
                  ),
                  if (state.formulaOptimized) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.check, size: 14, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Fórmula otimizada com sucesso', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              Text(
                                state.lastAnalysis?.aiNote ??
                                    'A composição foi recalibrada para melhorar a tolerabilidade.',
                                style: const TextStyle(fontSize: 12, color: AppColors.tertiary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Otimizar Fórmula com IA',
                    onPressed: state.aiLoading
                        ? null
                        : () async {
                            await state.runAnalysis(optimize: true);
                          },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Lab
            DarkCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Manipulação com laboratório parceiro', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text(
                    'Solicite orçamento e acompanhe o fluxo do pedido em uma simulação completa de laboratório parceiro.',
                    style: TextStyle(fontSize: 13, color: AppColors.tertiary, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      _Chip('4 parceiros'),
                      SizedBox(width: 8),
                      _Chip('orçamento instantâneo'),
                      SizedBox(width: 8),
                      _Chip('fluxo integrado'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Manipular com Laboratório Parceiro',
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: AppColors.surface,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => const LabSheet(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ingredientes ativos
            DarkCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ingredientes ativos', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  ...DemoFormula.ingredients.map((ing) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ing.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                  Text(ing.role, style: const TextStyle(fontSize: 12, color: AppColors.tertiary)),
                                ],
                              ),
                            ),
                            Text(ing.dose, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () async {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Re-sincronizando dados de saúde e recalculando...'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                await state.syncHealth();
                                await state.runAnalysis(optimize: true);
                              },
                              child: const Icon(Icons.refresh, size: 18, color: AppColors.primary),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Ajuste fino de ${ing.name}: em breve você poderá editar a dose.'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: const Icon(Icons.add_circle_outline, size: 18, color: AppColors.primary),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
    );
  }
}
