/// Dados de demonstração 100% fiéis ao vídeo do TesClinic.
class DemoProfile {
  static const name = 'Magno';
  static const fullName = 'Magno Fagundes';
  static const email = 'demo@tesclinic.com';
  static const goal = 'Hipertrofia';
  static const level = 'Intermediário';
  static const trainingDays = '5x/semana';
  static const sessionMinutes = 52;
  static const trainingTime = '07:00';
}

class DemoBiometrics {
  double restingHr = 58;
  double sleepHours = 7.2;
  double recovery = 82;
  double energy = 84;
  String sleepQuality = 'Boa';
  String stress = 'Moderado';
  int readiness = 93;
  int weeklyTrainings = 5;
  String lastSync = 'Hoje, 21:14';
  bool connected = true;
}

class FormulaIngredient {
  final String name;
  final String role;
  final String dose;
  FormulaIngredient(this.name, this.role, this.dose);
}

class DemoFormula {
  static const code = 'TES FORMULA // HYPER';
  static const title = 'Hipertrofia + força + resistência';
  static final ingredients = [
    FormulaIngredient('Cafeína', 'Energia e foco', '120 mg'),
    FormulaIngredient('Beta-alanina', 'Resistência muscular', '1.8 g'),
    FormulaIngredient('L-Citrulina', 'Pump e fluxo sanguíneo', '3.0 g'),
    FormulaIngredient('Beterraba em pó', 'Suporte de fluxo e desempenho', '500 mg'),
  ];
  static const energyScore = 90;
  static const focusScore = 82;
  static const resistanceScore = 85;
  static const performance = 99;
  static const tolerability = 89;
  static const balance = 94;
  static const aiNote =
      'A IA manteve uma proposta mais forte por causa da boa recuperação.';
}

class LabPartner {
  final String name;
  final String tag;
  final int price;
  final int days;
  LabPartner(this.name, this.tag, this.price, this.days);
}

class DemoLabs {
  static final list = [
    LabPartner('Alpha Manipulação', 'Mais rápido', 68, 3),
    LabPartner('BioComp Pharma', 'Premium', 75, 2),
    LabPartner('Performance Labs', 'Melhor custo', 59, 4),
    LabPartner('NutriLab Partner', 'Mais escolhido', 72, 3),
  ];
}
