import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards.dart';
import '../../widgets/logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  String? _sex;
  String? _goal;
  DateTime? _birthDate;
  bool _loading = false;
  String? _error;

  final _goals = [
    'Hipertrofia',
    'Emagrecimento',
    'Performance',
    'Saúde geral',
    'Força',
  ];

  final _sexes = ['Masculino', 'Feminino', 'Outro'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
    });
    if (!_formKey.currentState!.validate()) return;

    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'As senhas não coincidem.');
      return;
    }

    setState(() => _loading = true);
    try {
      final weight = double.tryParse(_weightCtrl.text.replaceAll(',', '.'));
      final height = double.tryParse(_heightCtrl.text.replaceAll(',', '.'));

      await context.read<AppState>().register(
            name: _nameCtrl.text,
            email: _emailCtrl.text,
            password: _passwordCtrl.text,
            birthDate: _birthDate,
            sex: _sex,
            weight: weight,
            height: height,
            goal: _goal,
          );
      if (!mounted) return;
      // Fecha a tela de cadastro e vai para Health Connect
      Navigator.of(context).pop();
      context.read<AppState>().goToHealthAfterRegister();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 10),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.card,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.tertiary, fontSize: 13),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.secondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: TesClinicLogo(fontSize: 22, center: false),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Criar conta',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Seus dados ficam apenas neste dispositivo por enquanto.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.tertiary),
                ),
                const SizedBox(height: 24),

                DarkCard(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        style: const TextStyle(color: AppColors.secondary),
                        decoration: _decoration('Nome completo *'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppColors.secondary),
                        decoration: _decoration('E-mail *'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
                          if (!v.contains('@')) return 'E-mail inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        style: const TextStyle(color: AppColors.secondary),
                        decoration: _decoration('Senha * (mín. 6 caracteres)'),
                        validator: (v) {
                          if (v == null || v.length < 6) {
                            return 'Mínimo 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmCtrl,
                        obscureText: true,
                        style: const TextStyle(color: AppColors.secondary),
                        decoration: _decoration('Confirmar senha *'),
                        validator: (v) {
                          if (v != _passwordCtrl.text) return 'Senhas diferentes';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                DarkCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dados biométricos (opcional)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _pickBirthDate,
                        child: InputDecorator(
                          decoration: _decoration('Data de nascimento'),
                          child: Text(
                            _birthDate == null
                                ? 'Selecionar'
                                : '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}',
                            style: TextStyle(
                              color: _birthDate == null
                                  ? AppColors.tertiary
                                  : AppColors.secondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _sex,
                        decoration: _decoration('Sexo'),
                        dropdownColor: AppColors.card,
                        style: const TextStyle(color: AppColors.secondary),
                        items: _sexes
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) => setState(() => _sex = v),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _weightCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: AppColors.secondary),
                              decoration: _decoration('Peso (kg)'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _heightCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: AppColors.secondary),
                              decoration: _decoration('Altura (cm)'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _goal,
                        decoration: _decoration('Objetivo'),
                        dropdownColor: AppColors.card,
                        style: const TextStyle(color: AppColors.secondary),
                        items: _goals
                            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        onChanged: (v) => setState(() => _goal = v),
                      ),
                    ],
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 24),
                PrimaryButton(
                  label: _loading ? 'Criando conta...' : 'Criar conta',
                  onPressed: _loading ? null : _submit,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Já tenho conta · Fazer login',
                    style: TextStyle(color: AppColors.primary, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
