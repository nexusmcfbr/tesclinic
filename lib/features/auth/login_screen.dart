import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../models/demo_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/logo.dart';
import '../../widgets/cards.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _showPasswordLogin = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await context.read<AppState>().login(
            email: _emailCtrl.text,
            password: _passwordCtrl.text,
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const TesClinicLogo(fontSize: 28),
              const SizedBox(height: 10),
              const Text(
                'Plataforma adaptativa de performance e formulação inteligente',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: AppColors.tertiary, height: 1.4),
              ),
              const SizedBox(height: 28),

              // ===== MODO REAL =====
              DarkCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Modo real',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Icon(Icons.watch,
                            color: AppColors.primary.withValues(alpha: 0.9),
                            size: 22),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Entre com sua conta ou crie uma nova. Depois conecte Health Connect / Apple Health para dados reais do seu relógio.',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.tertiary, height: 1.4),
                    ),
                    const SizedBox(height: 16),

                    if (!_showPasswordLogin) ...[
                      PrimaryButton(
                        label: 'Entrar com conta',
                        onPressed: () =>
                            setState(() => _showPasswordLogin = true),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RegisterScreen()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.secondary,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('CRIAR CONTA',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3)),
                        ),
                      ),
                    ] else ...[
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppColors.secondary),
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          labelStyle:
                              const TextStyle(color: AppColors.tertiary),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        style: const TextStyle(color: AppColors.secondary),
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          labelStyle:
                              const TextStyle(color: AppColors.tertiary),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(_error!,
                            style: const TextStyle(
                                color: Colors.redAccent, fontSize: 13)),
                      ],
                      const SizedBox(height: 14),
                      PrimaryButton(
                        label: _loading ? 'Entrando...' : 'Entrar',
                        onPressed: _loading ? null : _doLogin,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () =>
                            setState(() => _showPasswordLogin = false),
                        child: const Text('Voltar',
                            style: TextStyle(
                                color: AppColors.tertiary, fontSize: 13)),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ===== MODO DEMO =====
              DarkCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Acesso demonstrativo',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Icon(Icons.psychology,
                            color: AppColors.primary.withValues(alpha: 0.9),
                            size: 22),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ambiente de apresentação: biometria simulada e fórmula em tempo real — sem precisar de relógio ou conta.',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.tertiary, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.surfaceElevated,
                            child: Icon(Icons.person,
                                color: AppColors.tertiary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Perfil demo',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.tertiary)),
                                SizedBox(height: 2),
                                Text(
                                  '${DemoProfile.name} · ${DemoProfile.goal}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            'DEMO',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Entrar na Demo',
                      onPressed: () => state.enterDemoMode(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Não substitui avaliação médica ou farmacêutica. Dados de saúde permanecem sob o seu controle.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11, color: AppColors.tertiary, height: 1.35),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
