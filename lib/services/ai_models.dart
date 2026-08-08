/// Resultado estruturado da análise de IA do TesClinic.
class AiAnalysisResult {
  final int readiness;
  final int energyScore;
  final int focusScore;
  final int resistanceScore;
  final int performance;
  final int tolerability;
  final int balance;
  final String sleepAssessment;
  final String stressAssessment;
  final String aiNote;
  final String stimulusLevel; // baixo | moderado | moderado a alto | alto
  final String fatigueRisk; // baixo | moderado | alto
  final List<AiIngredientSuggestion> ingredients;
  final String formulaCode;
  final String formulaTitle;
  final bool usedLiveApi;
  final String? rawSummary;

  const AiAnalysisResult({
    required this.readiness,
    required this.energyScore,
    required this.focusScore,
    required this.resistanceScore,
    required this.performance,
    required this.tolerability,
    required this.balance,
    required this.sleepAssessment,
    required this.stressAssessment,
    required this.aiNote,
    required this.stimulusLevel,
    required this.fatigueRisk,
    required this.ingredients,
    required this.formulaCode,
    required this.formulaTitle,
    required this.usedLiveApi,
    this.rawSummary,
  });

  factory AiAnalysisResult.fromJson(Map<String, dynamic> json, {bool live = true}) {
    final ings = <AiIngredientSuggestion>[];
    final list = json['ingredients'] as List<dynamic>? ?? [];
    for (final e in list) {
      if (e is Map<String, dynamic>) {
        ings.add(AiIngredientSuggestion(
          e['name']?.toString() ?? '',
          e['role']?.toString() ?? '',
          e['dose']?.toString() ?? '',
        ));
      }
    }
    return AiAnalysisResult(
      readiness: _int(json['readiness'], 85),
      energyScore: _int(json['energyScore'], 88),
      focusScore: _int(json['focusScore'], 80),
      resistanceScore: _int(json['resistanceScore'], 82),
      performance: _int(json['performance'], 90),
      tolerability: _int(json['tolerability'], 88),
      balance: _int(json['balance'], 90),
      sleepAssessment: json['sleepAssessment']?.toString() ?? 'Boa',
      stressAssessment: json['stressAssessment']?.toString() ?? 'Moderado',
      aiNote: json['aiNote']?.toString() ??
          'Análise gerada com base nos dados biométricos informados.',
      stimulusLevel: json['stimulusLevel']?.toString() ?? 'Moderado a alto',
      fatigueRisk: json['fatigueRisk']?.toString() ?? 'Baixo',
      ingredients: ings.isEmpty
          ? const [
              AiIngredientSuggestion('Cafeína', 'Energia e foco', '120 mg'),
              AiIngredientSuggestion('Beta-alanina', 'Resistência muscular', '1.8 g'),
              AiIngredientSuggestion('L-Citrulina', 'Pump e fluxo sanguíneo', '3.0 g'),
              AiIngredientSuggestion('Beterraba em pó', 'Suporte de fluxo e desempenho', '500 mg'),
            ]
          : ings,
      formulaCode: json['formulaCode']?.toString() ?? 'TES FORMULA // HYPER',
      formulaTitle: json['formulaTitle']?.toString() ??
          'Hipertrofia + força + resistência',
      usedLiveApi: live,
      rawSummary: json['rawSummary']?.toString(),
    );
  }

  static int _int(dynamic v, int fallback) {
    if (v is int) return v.clamp(0, 100);
    if (v is num) return v.toInt().clamp(0, 100);
    return int.tryParse(v?.toString() ?? '')?.clamp(0, 100) ?? fallback;
  }
}

class AiIngredientSuggestion {
  final String name;
  final String role;
  final String dose;
  const AiIngredientSuggestion(this.name, this.role, this.dose);
}
