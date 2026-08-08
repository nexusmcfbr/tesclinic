import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../services/health_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards.dart';
import '../../widgets/logo.dart';

/// Tela pós-login no modo real: permissões + primeira sincronização.
class HealthConnectScreen extends StatefulWidget {
  const HealthConnectScreen({super.key});

  @override
  State<HealthConnectScreen> createState() => _HealthConnectScreenState();
}

class _HealthConnectScreenState extends State<HealthConnectScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().requestHealthAndSync();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final bio = state.biometrics;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              const TesClinicLogo(fontSize: 24),
              const SizedBox(height: 8),
              const Text(
                'Conectar dados de saúde',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              const Text(
                'O TesClinic lê sono, FC, treinos e atividade do Apple Health ou Health Connect para calcular prontidão e personalizar a fórmula. Nada é vendido nem compartilhado sem o seu consentimento.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.tertiary, height: 1.4),
              ),
              const SizedBox(height: 24),
              DarkCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          state.healthSyncing
                              ? Icons.sync
                              : bio.isRealData
                                  ? Icons.check_circle
                                  : Icons.watch,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            state.healthSyncing
                                ? 'Sincronizando…'
                                : bio.isRealData
                                    ? 'Dados reais conectados'
                                    : 'Aguardando permissão / dados',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _row('Fonte', bio.sourceLabel),
                    _row('Status', _statusLabel(state.healthStatus)),
                    _row('Última sync', bio.lastSyncLabel),
                    if (state.healthMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        state.healthMessage!,
                        style: const TextStyle(fontSize: 12, color: AppColors.tertiary, height: 1.35),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (bio.isRealData || !state.healthSyncing)
                DarkCard(
                  child: Column(
                    children: [
                      _metric('FC repouso', '${bio.restingHr.toInt()} bpm'),
                      const Divider(color: AppColors.border, height: 18),
                      _metric('Sono', '${bio.sleepHours} h · ${bio.sleepQuality}'),
                      const Divider(color: AppColors.border, height: 18),
                      _metric('Recuperação', '${bio.recovery.toInt()}%'),
                      const Divider(color: AppColors.border, height: 18),
                      _metric('Prontidão', '${bio.readiness}'),
                    ],
                  ),
                ),
              const Spacer(),
              if (!bio.isRealData && !state.healthSyncing)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Os números acima podem ser estimados. Conecte o Health Connect e autorize o acesso para ler dados reais do seu relógio.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.tertiary, height: 1.35),
                  ),
                ),
              PrimaryButton(
                label: state.healthSyncing
                    ? 'Aguarde…'
                    : (bio.isRealData ? 'Continuar com dados reais' : 'Continuar mesmo assim'),
                onPressed: state.healthSyncing
                    ? null
                    : () => state.goTo(AppScreen.aiAnalysis),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: state.healthSyncing
                      ? null
                      : () => state.requestHealthAndSync(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Tentar sincronizar de novo'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: state.healthSyncing
                    ? null
                    : () async {
                        await state.enterDemoMode();
                      },
                child: const Text(
                  'Usar modo estimado (sem relógio)',
                  style: TextStyle(color: AppColors.tertiary, fontSize: 13),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(HealthConnectionStatus s) {
    switch (s) {
      case HealthConnectionStatus.authorized:
        return 'Autorizado';
      case HealthConnectionStatus.partial:
        return 'Parcial';
      case HealthConnectionStatus.denied:
        return 'Negado';
      case HealthConnectionStatus.unsupported:
        return 'Não suportado';
      case HealthConnectionStatus.error:
        return 'Erro';
      case HealthConnectionStatus.notDetermined:
        return 'Pendente';
    }
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(k, style: const TextStyle(fontSize: 13, color: AppColors.tertiary)),
          const Spacer(),
          Flexible(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String k, String v) {
    return Row(
      children: [
        Text(k, style: const TextStyle(fontSize: 13, color: AppColors.tertiary)),
        const Spacer(),
        Text(v, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ],
    );
  }
}
