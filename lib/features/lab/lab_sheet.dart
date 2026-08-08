import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../models/demo_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards.dart';

class LabSheet extends StatefulWidget {
  const LabSheet({super.key});

  @override
  State<LabSheet> createState() => _LabSheetState();
}

class _LabSheetState extends State<LabSheet> {
  LabPartner? selected;
  bool ordered = false;
  int step = 0;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) {
        return Container(
          color: AppColors.background,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: AppColors.surfaceElevated,
                child: Row(
                  children: [
                    const Text('Fechar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: AppColors.tertiary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (!ordered) ...[
                      const Text('Laboratórios parceiros', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      const Text('Simulação de orçamento e fluxo de pedido integrado ao laboratório.', style: TextStyle(fontSize: 13, color: AppColors.tertiary)),
                      const SizedBox(height: 16),
                      ...DemoLabs.list.map((lab) {
                        final isSelected = selected?.name == lab.name;
                        return GestureDetector(
                          onTap: () => setState(() => selected = lab),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                                width: isSelected ? 1.5 : 0.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                  color: isSelected ? AppColors.primary : AppColors.tertiary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(lab.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                          const Spacer(),
                                          Text(lab.tag, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Preço estimado: R\$ ${lab.price}   ·   Prazo: ${lab.days} dias',
                                          style: const TextStyle(fontSize: 12, color: AppColors.tertiary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      const Text('Fórmula a ser manipulada', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'Solicitar Manipulação',
                        onPressed: selected == null
                            ? null
                            : () {
                                setState(() {
                                  ordered = true;
                                  step = 1;
                                });
                                Future.delayed(const Duration(seconds: 2), () {
                                  if (mounted) setState(() => step = 2);
                                });
                              },
                      ),
                    ] else ...[
                      // Tracking
                      const Text('Rastreamento do pedido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      _step('Pedido recebido', 'A fórmula foi enviada para o laboratório parceiro.', step >= 1),
                      _step('Laboratório confirmou', 'O laboratório validou a composição e iniciou o processo.', step >= 2),
                      _step('Seu pré-treino está sendo preparado', 'A manipulação está em andamento com controle interno.', step >= 3),
                      _step('Saiu para entrega', 'O pedido foi liberado e está a caminho.', step >= 4),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: step / 4,
                          minHeight: 4,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('${(step / 4 * 100).toInt()}%', style: const TextStyle(fontSize: 12, color: AppColors.tertiary)),
                      const SizedBox(height: 20),
                      DarkCard(
                        child: Column(
                          children: [
                            _sumRow('Laboratório', selected?.name ?? ''),
                            _sumRow('Preço estimado', 'R\$ ${selected?.price ?? 0}'),
                            _sumRow('Prazo estimado', '${selected?.days ?? 0} dias'),
                            _sumRow('Fórmula', DemoFormula.code),
                            _sumRow('Status atual', step >= 2 ? 'Laboratório confirmou' : 'Pedido recebido'),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _step(String title, String desc, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? AppColors.primary : Colors.transparent,
              border: Border.all(color: done ? AppColors.primary : AppColors.border, width: 1.5),
            ),
            child: done ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: done ? AppColors.secondary : AppColors.tertiary)),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.tertiary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sumRow(String k, String v) {
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
