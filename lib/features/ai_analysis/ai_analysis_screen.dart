import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/logo.dart';
import '../../widgets/cards.dart';

class AiAnalysisScreen extends StatefulWidget {
  const AiAnalysisScreen({super.key});

  @override
  State<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends State<AiAnalysisScreen> {
  final steps = const [
    'Sono analisado',
    'Frequência cardíaca processada',
    'Recuperação estimada',
    'Objetivo de treino validado',
    'Gerando fórmula personalizada',
  ];
  int done = 0;
  double progress = 0;
  String statusLine = 'Motor adaptativo de formulação em execução';
  bool finished = false;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final state = context.read<AppState>();
    final analysisFuture = state.runAnalysis(optimize: false);

    for (var i = 0; i < steps.length - 1; i++) {
      await Future.delayed(const Duration(milliseconds: 550));
      if (!mounted) return;
      setState(() {
        done = i + 1;
        progress = (i + 1) / steps.length;
      });
    }

    setState(() {
      statusLine = state.hasLiveAi
          ? 'Consultando motor de IA na nuvem...'
          : 'Motor local (offline) em execução...';
    });

    try {
      final result = await analysisFuture;
      if (!mounted) return;
      setState(() {
        done = steps.length;
        progress = 1;
        statusLine = result.usedLiveApi
            ? 'Análise concluída via API de IA'
            : 'Análise concluída (motor local)';
        finished = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        done = steps.length;
        progress = 1;
        statusLine = 'Análise concluída com fallback local';
        finished = true;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final bio = state.biometrics;

    if (finished) {
      return _ResultView(
        isReal: bio.isRealData,
        restingHr: bio.restingHr,
        sleepHours: bio.sleepHours,
        readiness: bio.readiness,
        sourceLabel: bio.sourceLabel,
        onContinue: () => state.goTo(AppScreen.main),
        onSyncHealth: () => state.goTo(AppScreen.healthConnect),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const TesClinicLogo(fontSize: 26, suffix: 'AI'),
              const SizedBox(height: 12),
              const Text(
                'Analisando seus dados biométricos',
                style: TextStyle(fontSize: 14, color: AppColors.tertiary),
              ),
              const SizedBox(height: 36),
              ...List.generate(steps.length, (i) {
                final complete = i < done;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: complete ? AppColors.primary : Colors.transparent,
                          border: Border.all(
                            color: complete ? AppColors.primary : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: complete
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Text(
                        steps[i],
                        style: TextStyle(
                          fontSize: 15,
                          color: complete ? AppColors.secondary : AppColors.tertiary,
                          fontWeight: complete ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 28),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${(progress * 100).toInt()}% concluído',
                style: const TextStyle(fontSize: 12, color: AppColors.tertiary),
              ),
              const Spacer(flex: 3),
              Text(
                statusLine,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.tertiary),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final bool isReal;
  final double restingHr;
  final double sleepHours;
  final int readiness;
  final String sourceLabel;
  final VoidCallback onContinue;
  final VoidCallback onSyncHealth;

  const _ResultView({
    required this.isReal,
    required this.restingHr,
    required this.sleepHours,
    required this.readiness,
    required this.sourceLabel,
    required this.onContinue,
    required this.onSyncHealth,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              const TesClinicLogo(fontSize: 24, suffix: 'AI'),
              const SizedBox(height: 8),
              Text(
                isReal ? 'Análise concluída com dados reais' : 'Análise concluída',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                isReal
                    ? 'Fonte: $sourceLabel'
                    : 'Alguns valores ainda estão estimados. Conecte seu relógio para precisão máxima.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.tertiary, height: 1.35),
              ),
              const SizedBox(height: 24),
              DarkCard(
                child: Column(
                  children: [
                    _metric('FC repouso', '${restingHr.toInt()} bpm'),
                    const Divider(color: AppColors.border, height: 20),
                    _metric('Sono', '${sleepHours}h'),
                    const Divider(color: AppColors.border, height: 20),
                    _metric('Prontidão', '$readiness'),
                    const Divider(color: AppColors.border, height: 20),
                    _metric(
                      'Periodização sugerida',
                      readiness >= 80
                          ? 'Carga moderada-alta'
                          : readiness >= 60
                              ? 'Carga moderada'
                              : 'Recuperação prioritária',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (!isReal) ...[
                PrimaryButton(
                  label: 'Conectar relógio / Health Connect',
                  onPressed: onSyncHealth,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: onContinue,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Continuar com dados estimados'),
                  ),
                ),
              ] else ...[
                PrimaryButton(
                  label: 'Ver minha fórmula personalizada',
                  onPressed: onContinue,
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(String k, String v) {
    return Row(
      children: [
        Text(k, style: const TextStyle(fontSize: 13, color: AppColors.tertiary)),
        const Spacer(),
        Text(v,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ],
    );
  }
}
