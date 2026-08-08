import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../models/demo_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards.dart';
import '../../widgets/logo.dart';
import '../../services/ai_config.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text('More', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined, color: AppColors.secondary),
              title: const Text('Relatório'),
              trailing: const Icon(Icons.chevron_right, color: AppColors.tertiary),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportScreen())),
            ),
            const Divider(color: AppColors.border, height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.person_outline, color: AppColors.secondary),
              title: Text(context.watch<AppState>().currentUser?.name ?? 'Perfil'),
              subtitle: Text(
                context.watch<AppState>().isDemoMode
                    ? 'Modo demonstração'
                    : (context.watch<AppState>().currentUser?.email ?? 'Conta local'),
                style: const TextStyle(fontSize: 12, color: AppColors.tertiary),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppColors.tertiary),
              onTap: () {},
            ),
            const Divider(color: AppColors.border, height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.smart_toy_outlined, color: AppColors.secondary),
              title: const Text('API de IA'),
              subtitle: Text(
                context.watch<AppState>().hasLiveAi ? 'Chave configurada' : 'Usando motor local',
                style: const TextStyle(fontSize: 12, color: AppColors.tertiary),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppColors.tertiary),
              onTap: () {},
            ),
            const Divider(color: AppColors.border, height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Sair', style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.card,
                    title: const Text('Sair da conta'),
                    content: const Text('Deseja encerrar a sessão?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sair', style: TextStyle(color: Colors.redAccent))),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await context.read<AppState>().logout();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bio = context.watch<AppState>().biometrics;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('More'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const TesClinicLogo(fontSize: 22, center: false),
          const SizedBox(height: 8),
          const Text('AI Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.tertiary)),
          const SizedBox(height: 4),
          const Text('Relatório executivo da recomendação inteligente', style: TextStyle(fontSize: 13, color: AppColors.tertiary)),
          const SizedBox(height: 20),

          DarkCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Compatibilidade geral', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      SizedBox(height: 6),
                      Text('Leitura consolidada da IA com base em perfil, biometria e fórmula ativa', style: TextStyle(fontSize: 12, color: AppColors.tertiary, height: 1.35)),
                    ],
                  ),
                ),
                SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: const [
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: CircularProgressIndicator(
                          value: 0.94,
                          strokeWidth: 5,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                      Text('94', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _mini('Prontidão', '93%')),
              const SizedBox(width: 8),
              Expanded(child: _mini('Estímulo', 'Moderado a alto')),
              const SizedBox(width: 8),
              Expanded(child: _mini('Risco', 'Baixo')),
            ],
          ),
          const SizedBox(height: 20),

          const Text('Perfil analisado', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          DarkCard(
            child: Column(
              children: [
                _row('Nome', DemoProfile.name),
                _row('Objetivo', DemoProfile.goal),
                _row('Nível', DemoProfile.level),
                _row('Treino', '${DemoProfile.trainingDays} · ${DemoProfile.sessionMinutes} min'),
                _row('Horário', DemoProfile.trainingTime),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('Leitura biométrica', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          DarkCard(
            child: Column(
              children: [
                _row('Sono', '${bio.sleepHours} h · ${bio.sleepQuality}'),
                _row('FC repouso', '${bio.restingHr.toInt()} bpm'),
                _row('Recuperação', '${bio.recovery.toInt()}%'),
                _row('Energia percebida', '${bio.energy.toInt()}%'),
                _row('Estresse', bio.stress),
                _row('Fonte', 'Health Data Engine'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('Interpretação da IA', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          DarkCard(
            child: Column(
              children: [
                ScoreBar(label: 'Performance', value: DemoFormula.performance),
                ScoreBar(label: 'Tolerabilidade', value: DemoFormula.tolerability),
                ScoreBar(label: 'Equilíbrio', value: DemoFormula.balance),
                const SizedBox(height: 8),
                _row('Estímulo ideal', 'Moderado a alto'),
                _row('Risco de fadiga', 'Baixo'),
                _row('Compatibilidade geral', '94%'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('Fórmula recomendada', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          DarkCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DemoFormula.code, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                const SizedBox(height: 4),
                const Text(DemoFormula.title, style: TextStyle(fontSize: 14)),
                const SizedBox(height: 12),
                ...DemoFormula.ingredients.map((ing) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ing.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                Text(ing.role, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                              ],
                            ),
                          ),
                          Text(ing.dose, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DarkCard(
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Permissão para proposta de performance mais forte', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mini(String k, String v) {
    return DarkCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Text(k, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
          const SizedBox(height: 4),
          Text(v, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(k, style: const TextStyle(fontSize: 13, color: AppColors.tertiary)),
          const Spacer(),
          Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ],
      ),
    );
  }
}
