import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/logo.dart';
import '../../widgets/cards.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final bio = state.biometrics;

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
                  ? 'Dados de saúde · sincronização real'
                  : 'Dados de saúde · modo estimado',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.tertiary),
            ),
            const SizedBox(height: 20),

            const Text('Resumo biológico', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _bioCard('FC repouso', '${bio.restingHr.toInt()} bpm')),
                const SizedBox(width: 10),
                Expanded(child: _bioCard('Sono', '${bio.sleepHours} h')),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _bioCard('Recuperação', '${bio.recovery.toInt()} %')),
                const SizedBox(width: 10),
                Expanded(child: _bioCard('Energia', '${bio.energy.toInt()} %')),
              ],
            ),
            if (bio.hrvMs != null || bio.stepsToday != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  if (bio.hrvMs != null)
                    Expanded(child: _bioCard('HRV', '${bio.hrvMs!.toStringAsFixed(0)} ms')),
                  if (bio.hrvMs != null && bio.stepsToday != null) const SizedBox(width: 10),
                  if (bio.stepsToday != null)
                    Expanded(child: _bioCard('Passos', '${bio.stepsToday}')),
                ],
              ),
            ],
            const SizedBox(height: 20),

            DarkCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sincronização', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  _syncRow('Fonte', bio.sourceLabel),
                  const Divider(color: AppColors.border, height: 20),
                  _syncRow('Última sincronização', bio.lastSyncLabel),
                  const Divider(color: AppColors.border, height: 20),
                  _syncRow('Modo', bio.isRealData ? 'Dados reais' : 'Estimado / demo'),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    label: state.healthSyncing ? 'Sincronizando…' : 'Sincronizar agora',
                    onPressed: state.healthSyncing ? null : () => state.syncHealth(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (!bio.isRealData) ...[
              const Text('Ajuste manual (modo estimado)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              DarkCard(
                child: Column(
                  children: [
                    _adjustRow('FC repouso', '${bio.restingHr.toInt()} bpm', () {
                      state.updateBio(hr: (bio.restingHr - 1).clamp(40, 100));
                    }, () {
                      state.updateBio(hr: (bio.restingHr + 1).clamp(40, 100));
                    }),
                    const Divider(color: AppColors.border, height: 20),
                    _adjustRow('Horas de sono', '${bio.sleepHours} h', () {
                      state.updateBio(sleep: double.parse((bio.sleepHours - 0.1).clamp(4, 12).toStringAsFixed(1)));
                    }, () {
                      state.updateBio(sleep: double.parse((bio.sleepHours + 0.1).clamp(4, 12).toStringAsFixed(1)));
                    }),
                    const Divider(color: AppColors.border, height: 20),
                    _adjustRow('Recuperação', '${bio.recovery.toInt()} %', () {
                      state.updateBio(recovery: (bio.recovery - 1).clamp(0, 100));
                    }, () {
                      state.updateBio(recovery: (bio.recovery + 1).clamp(0, 100));
                    }),
                    const Divider(color: AppColors.border, height: 20),
                    _adjustRow('Energia', '${bio.energy.toInt()} %', () {
                      state.updateBio(energy: (bio.energy - 1).clamp(0, 100));
                    }, () {
                      state.updateBio(energy: (bio.energy + 1).clamp(0, 100));
                    }),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'O TesClinic não diagnostica doenças. Scores de prontidão e recuperação são estimativas para performance e formulação de pré-treino.',
              style: TextStyle(fontSize: 11, color: AppColors.tertiary, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bioCard(String label, String value) {
    return DarkCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.tertiary)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _syncRow(String k, String v) {
    return Row(
      children: [
        Text(k, style: const TextStyle(fontSize: 13)),
        const Spacer(),
        Flexible(
          child: Text(
            v,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _adjustRow(String label, String value, VoidCallback onMinus, VoidCallback onPlus) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
        IconButton(
          onPressed: onMinus,
          icon: const Icon(Icons.remove_circle_outline, color: AppColors.tertiary),
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          onPressed: onPlus,
          icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
