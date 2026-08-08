import '../models/biometric_snapshot.dart';

/// Calcula prontidão, recuperação, energia e qualidade de sono
/// a partir de métricas brutas. Regras documentadas e auditáveis.
class ReadinessCalculator {
  /// [restingHr] FC de repouso (bpm)
  /// [sleepHours] horas de sono na última noite
  /// [hrvMs] HRV SDNN opcional
  /// [workoutsLast48h] treinos nas últimas 48h
  /// [baselineRestingHr] média recente (se null, usa 60)
  BiometricSnapshot compute({
    required double restingHr,
    required double sleepHours,
    double? hrvMs,
    int workoutsLast48h = 0,
    int weeklyTrainings = 0,
    double? baselineRestingHr,
    int? stepsToday,
    double? activeCalories,
    required String sourceLabel,
    required bool isRealData,
  }) {
    final baseline = baselineRestingHr ?? 60.0;

    // --- Sono (0-100) ---
    double sleepScore;
    String sleepQuality;
    if (sleepHours >= 7.5) {
      sleepScore = 95;
      sleepQuality = 'Boa';
    } else if (sleepHours >= 7.0) {
      sleepScore = 88;
      sleepQuality = 'Boa';
    } else if (sleepHours >= 6.0) {
      sleepScore = 72;
      sleepQuality = 'Regular';
    } else if (sleepHours >= 5.0) {
      sleepScore = 55;
      sleepQuality = 'Ruim';
    } else {
      sleepScore = 40;
      sleepQuality = 'Ruim';
    }

    // --- FC de repouso vs baseline ---
    final hrDelta = restingHr - baseline;
    double hrScore;
    if (hrDelta <= -2) {
      hrScore = 95; // melhor que baseline
    } else if (hrDelta <= 3) {
      hrScore = 85;
    } else if (hrDelta <= 8) {
      hrScore = 70;
    } else if (hrDelta <= 15) {
      hrScore = 55;
    } else {
      hrScore = 40;
    }

    // --- HRV (opcional) ---
    double hrvScore = 75;
    if (hrvMs != null) {
      if (hrvMs >= 60) {
        hrvScore = 95;
      } else if (hrvMs >= 40) {
        hrvScore = 80;
      } else if (hrvMs >= 25) {
        hrvScore = 65;
      } else {
        hrvScore = 50;
      }
    }

    // --- Carga de treino recente ---
    double loadPenalty = 0;
    if (workoutsLast48h >= 3) {
      loadPenalty = 12;
    } else if (workoutsLast48h == 2) {
      loadPenalty = 6;
    }

    // Recuperação
    final recovery = (sleepScore * 0.45 + hrScore * 0.35 + hrvScore * 0.20 - loadPenalty)
        .clamp(25.0, 99.0);

    // Energia percebida estimada
    final energy = (recovery * 0.7 + sleepScore * 0.3).clamp(30.0, 99.0);

    // Prontidão do dia
    final readiness = (recovery * 0.55 + sleepScore * 0.30 + hrScore * 0.15)
        .round()
        .clamp(30, 99);

    // Estresse estimado
    String stress;
    if (hrDelta > 10 || (hrvMs != null && hrvMs < 25) || sleepHours < 5.5) {
      stress = 'Alto';
    } else if (hrDelta > 4 || sleepHours < 6.5) {
      stress = 'Moderado';
    } else {
      stress = 'Baixo';
    }

    final now = DateTime.now();
    final label =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return BiometricSnapshot(
      restingHr: double.parse(restingHr.toStringAsFixed(0)),
      sleepHours: double.parse(sleepHours.toStringAsFixed(1)),
      recovery: double.parse(recovery.toStringAsFixed(0)),
      energy: double.parse(energy.toStringAsFixed(0)),
      sleepQuality: sleepQuality,
      stress: stress,
      readiness: readiness,
      weeklyTrainings: weeklyTrainings,
      lastSyncLabel: label,
      connected: isRealData,
      isRealData: isRealData,
      sourceLabel: sourceLabel,
      hrvMs: hrvMs,
      stepsToday: stepsToday,
      activeCalories: activeCalories,
    );
  }
}
