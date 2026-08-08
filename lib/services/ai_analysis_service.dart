import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/demo_data.dart';
import 'ai_config.dart';
import 'ai_models.dart';

/// Serviço de análise de IA do TesClinic.
///
/// - Usa API OpenAI-compatible quando [AiConfig.isConfigured]
/// - Caso contrário (ou em erro de rede), usa motor local (regras + demo)
/// - Nunca envia dados sem chave configurada
class AiAnalysisService {
  AiAnalysisService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<AiAnalysisResult> analyze({
    required DemoBiometrics bio,
    String goal = DemoProfile.goal,
    String level = DemoProfile.level,
    String trainingTime = DemoProfile.trainingTime,
    int trainingDaysPerWeek = 5,
    int sessionMinutes = DemoProfile.sessionMinutes,
    bool optimizeExisting = false,
  }) async {
    if (!AiConfig.isConfigured) {
      return _localFallback(bio, goal: goal, optimize: optimizeExisting);
    }

    try {
      return await _callLiveApi(
        bio: bio,
        goal: goal,
        level: level,
        trainingTime: trainingTime,
        trainingDaysPerWeek: trainingDaysPerWeek,
        sessionMinutes: sessionMinutes,
        optimizeExisting: optimizeExisting,
      );
    } catch (_) {
      // Rede / timeout / JSON inválido → fallback offline
      return _localFallback(bio, goal: goal, optimize: optimizeExisting);
    }
  }

  Future<AiAnalysisResult> _callLiveApi({
    required DemoBiometrics bio,
    required String goal,
    required String level,
    required String trainingTime,
    required int trainingDaysPerWeek,
    required int sessionMinutes,
    required bool optimizeExisting,
  }) async {
    final system = '''
Você é o motor clínico de performance do TesClinic (app brasileiro de pré-treino manipulado).
Responda APENAS com JSON válido, sem markdown, sem texto fora do JSON.
Objetivo: analisar biometria e sugerir fórmula de pré-treino personalizada (não vende suplemento; só estratégia).
Respeite contraindicações implícitas: cafeína alta se sono ruim ou FC de repouso elevada; reduzir estímulo se recuperação baixa.
Campos obrigatórios do JSON:
{
  "readiness": 0-100,
  "energyScore": 0-100,
  "focusScore": 0-100,
  "resistanceScore": 0-100,
  "performance": 0-100,
  "tolerability": 0-100,
  "balance": 0-100,
  "sleepAssessment": "Boa|Regular|Ruim",
  "stressAssessment": "Baixo|Moderado|Alto",
  "aiNote": "frase curta em português explicando o ajuste",
  "stimulusLevel": "Baixo|Moderado|Moderado a alto|Alto",
  "fatigueRisk": "Baixo|Moderado|Alto",
  "formulaCode": "TES FORMULA // XXX",
  "formulaTitle": "descrição curta",
  "ingredients": [
    {"name": "...", "role": "...", "dose": "..."}
  ],
  "rawSummary": "1-2 frases em português"
}
Máximo 5 ingredientes. Doses realistas de pré-treino.
''';

    final user = '''
Perfil:
- Objetivo: $goal
- Nível: $level
- Treinos/semana: $trainingDaysPerWeek
- Duração sessão: $sessionMinutes min
- Horário preferido: $trainingTime

Biometria atual:
- FC repouso: ${bio.restingHr} bpm
- Sono: ${bio.sleepHours} h (${bio.sleepQuality})
- Recuperação: ${bio.recovery}%
- Energia percebida: ${bio.energy}%
- Estresse: ${bio.stress}
- Prontidão atual (app): ${bio.readiness}

Modo: ${optimizeExisting ? "OTIMIZAR fórmula existente para melhor tolerabilidade" : "GERAR análise completa e fórmula"}
''';

    final uri = Uri.parse('${AiConfig.baseUrl}/chat/completions');
    final body = jsonEncode({
      'model': AiConfig.model,
      'temperature': 0.4,
      'response_format': {'type': 'json_object'},
      'messages': [
        {'role': 'system', 'content': system},
        {'role': 'user', 'content': user},
      ],
    });

    final response = await _client
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AiConfig.apiKey}',
          },
          body: body,
        )
        .timeout(Duration(seconds: AiConfig.timeoutSeconds));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API status ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = decoded['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw Exception('Resposta vazia da API');
    }
    final content = choices.first['message']?['content']?.toString() ?? '';
    final map = jsonDecode(_stripMarkdownFence(content)) as Map<String, dynamic>;
    return AiAnalysisResult.fromJson(map, live: true);
  }

  String _stripMarkdownFence(String content) {
    var c = content.trim();
    if (c.startsWith('```')) {
      c = c.replaceFirst(RegExp(r'^```(?:json)?\s*', caseSensitive: false), '');
      c = c.replaceFirst(RegExp(r'\s*```$'), '');
    }
    return c.trim();
  }

  /// Motor local (mesma lógica da demo do vídeo + pequenos ajustes por biometria)
  AiAnalysisResult _localFallback(
    DemoBiometrics bio, {
    required String goal,
    required bool optimize,
  }) {
    final recovery = bio.recovery;
    final sleep = bio.sleepHours;
    final hr = bio.restingHr;

    var caffeine = 120;
    var beta = 1.8;
    var citrulline = 3.0;
    var beet = 500;

    // Ajustes de segurança / performance
    if (sleep < 6.0 || bio.sleepQuality == 'Ruim') {
      caffeine = 80;
    } else if (sleep >= 7.5 && recovery >= 80) {
      caffeine = 150;
    }
    if (hr > 72) caffeine = (caffeine * 0.75).round();
    if (recovery < 60) {
      beta = 1.2;
      caffeine = caffeine.clamp(0, 100);
    }
    if (optimize) {
      caffeine = (caffeine * 0.85).round();
      beta = double.parse((beta * 0.9).toStringAsFixed(1));
    }

    final readiness = bio.readiness.clamp(50, 99);
    final energy = bio.energy.round().clamp(60, 98);
    final focus = (energy - 6 + (sleep >= 7 ? 4 : 0)).clamp(60, 95);
    final resistance = (recovery.round() + 3).clamp(60, 95);

    String note;
    if (optimize) {
      note =
          'A IA recalibrou a composição para melhorar a tolerabilidade com base no sono e na recuperação.';
    } else if (recovery >= 80 && sleep >= 7) {
      note =
          'A IA manteve uma proposta mais forte por causa da boa recuperação.';
    } else if (recovery < 65) {
      note =
          'Estímulo reduzido para proteger a recuperação e o sono.';
    } else {
      note =
          'Fórmula equilibrada para o objetivo de $goal e o estado fisiológico atual.';
    }

    return AiAnalysisResult(
      readiness: readiness,
      energyScore: energy,
      focusScore: focus,
      resistanceScore: resistance,
      performance: ((energy + focus + resistance) / 3).round().clamp(70, 99),
      tolerability: optimize ? 92 : (sleep >= 7 ? 89 : 78),
      balance: 94,
      sleepAssessment: bio.sleepQuality,
      stressAssessment: bio.stress,
      aiNote: note,
      stimulusLevel: caffeine >= 140
          ? 'Alto'
          : caffeine >= 100
              ? 'Moderado a alto'
              : 'Moderado',
      fatigueRisk: recovery < 60 ? 'Moderado' : 'Baixo',
      ingredients: [
        AiIngredientSuggestion('Cafeína', 'Energia e foco', '$caffeine mg'),
        AiIngredientSuggestion(
            'Beta-alanina', 'Resistência muscular', '${beta.toStringAsFixed(1)} g'),
        AiIngredientSuggestion(
            'L-Citrulina', 'Pump e fluxo sanguíneo', '${citrulline.toStringAsFixed(1)} g'),
        AiIngredientSuggestion(
            'Beterraba em pó', 'Suporte de fluxo e desempenho', '$beet mg'),
      ],
      formulaCode: 'TES FORMULA // HYPER',
      formulaTitle: 'Hipertrofia + força + resistência',
      usedLiveApi: false,
      rawSummary: note,
    );
  }

  void dispose() {
    _client.close();
  }
}
