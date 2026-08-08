import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../models/demo_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/logo.dart';
import '../../widgets/cards.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final bio = state.biometrics;
    final analysis = state.lastAnalysis;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            const TesClinicLogo(fontSize: 22),
            const SizedBox(height: 6),
            Text(
              bio.isRealData
                  ? 'Dados reais · ${bio.sourceLabel}'
                  : 'Performance personalizada para cada treino',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.tertiary),
            ),
            if (bio.isRealData) ...[
              const SizedBox(height: 8),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    'FC ${bio.restingHr.toInt()} bpm · ao vivo do relógio',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 10),
              Center(
                child: TextButton.icon(
                  onPressed: () => state.goTo(AppScreen.healthConnect),
                  icon: const Icon(Icons.watch, size: 18, color: AppColors.primary),
                  label: const Text('Sincronizar relógio / Health Connect', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Prontidão do dia
            DarkCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Prontidão do dia', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        const Text('Alta prontidão', style: TextStyle(fontSize: 13, color: AppColors.tertiary)),
                        const SizedBox(height: 8),
                        Text(
                          'Manter fórmula\nadaptativa padrão',
                          style: TextStyle(fontSize: 12, color: AppColors.tertiary.withValues(alpha: 0.9), height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 84,
                    height: 84,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 84,
                          height: 84,
                          child: CircularProgressIndicator(
                            value: bio.readiness / 100,
                            strokeWidth: 6,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                          ),
                        ),
                        Text(
                          '${bio.readiness}',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Sono + FC
            Row(
              children: [
                Expanded(child: _miniStat(Icons.nightlight_round, 'Sono', '${bio.sleepHours}h')),
                const SizedBox(width: 10),
                Expanded(child: _miniStat(Icons.favorite, 'FC repouso', '${bio.restingHr.toInt()} bpm')),
              ],
            ),
            const SizedBox(height: 20),

            const Text('Resumo do dia', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _dayStat(Icons.bolt, 'Energia', '${bio.energy.toInt()} %')),
                const SizedBox(width: 8),
                Expanded(child: _dayStat(Icons.monitor_heart, 'Recuperação', '${bio.recovery.toInt()} %')),
                const SizedBox(width: 8),
                Expanded(child: _dayStat(Icons.fitness_center, 'Treinos', '${bio.weeklyTrainings} sem')),
              ],
            ),
            const SizedBox(height: 20),

            // Fórmula ativa
            const Text('Fórmula ativa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            DarkCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DemoFormula.code, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.3)),
                            const SizedBox(height: 4),
                            const Text(DemoFormula.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Icon(Icons.science, color: AppColors.primary.withValues(alpha: 0.8), size: 28),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: DemoFormula.ingredients.map((ing) {
                      return Container(
                        width: (MediaQuery.of(context).size.width - 72) / 2,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ing.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text(ing.dose, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  ScoreBar(label: 'Energia', value: DemoFormula.energyScore),
                  ScoreBar(label: 'Foco', value: DemoFormula.focusScore),
                  ScoreBar(label: 'Resistência', value: DemoFormula.resistanceScore),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Análise da IA
            const Text('Análise da IA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            DarkCard(
              child: Column(
                children: [
                  _aiRow('Sono', bio.sleepQuality),
                  const Divider(color: AppColors.border, height: 20),
                  _aiRow('Estresse', bio.stress),
                  const Divider(color: AppColors.border, height: 20),
                  _aiRow('Horário de treino', DemoProfile.trainingTime),
                  const Divider(color: AppColors.border, height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ajuste aplicado', style: TextStyle(fontSize: 13, color: AppColors.tertiary)),
                      const SizedBox(height: 4),
                      Text(analysis?.aiNote ?? DemoFormula.aiNote, style: const TextStyle(fontSize: 13, height: 1.35)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sinais recentes
            const Text('Sinais recentes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            DarkCard(
              child: Column(
                children: [
                  _signalRow('Sincronização biométrica', '${bio.sourceLabel} · ${bio.lastSyncLabel}', bio.isRealData ? 'Conectado' : 'Estimado'),
                  const Divider(color: AppColors.border, height: 20),
                  _signalRow('Qualidade do sono', 'Última noite · ${bio.sleepHours}h', bio.sleepQuality),
                  const Divider(color: AppColors.border, height: 20),
                  _signalRow('Leitura de recuperação', 'Estado fisiológico estimado pela IA', '${bio.recovery.toInt()}%'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, String label, String value) {
    return DarkCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dayStat(IconData icon, String label, String value) {
    return DarkCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
        ],
      ),
    );
  }

  Widget _aiRow(String k, String v) {
    return Row(
      children: [
        Text(k, style: const TextStyle(fontSize: 13, color: AppColors.tertiary)),
        const Spacer(),
        Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _signalRow(String title, String subtitle, String trailing) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.tertiary)),
            ],
          ),
        ),
        Text(trailing, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
      ],
    );
  }
}
