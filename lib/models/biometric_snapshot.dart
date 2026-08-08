/// Snapshot unificado de biometria (demo ou HealthKit/Health Connect).
class BiometricSnapshot {
  final double restingHr;
  final double sleepHours;
  final double recovery;
  final double energy;
  final String sleepQuality;
  final String stress;
  final int readiness;
  final int weeklyTrainings;
  final String lastSyncLabel;
  final bool connected;
  final bool isRealData;
  final String sourceLabel;
  final double? hrvMs;
  final int? stepsToday;
  final double? activeCalories;

  const BiometricSnapshot({
    required this.restingHr,
    required this.sleepHours,
    required this.recovery,
    required this.energy,
    required this.sleepQuality,
    required this.stress,
    required this.readiness,
    required this.weeklyTrainings,
    required this.lastSyncLabel,
    required this.connected,
    required this.isRealData,
    required this.sourceLabel,
    this.hrvMs,
    this.stepsToday,
    this.activeCalories,
  });

  BiometricSnapshot copyWith({
    double? restingHr,
    double? sleepHours,
    double? recovery,
    double? energy,
    String? sleepQuality,
    String? stress,
    int? readiness,
    int? weeklyTrainings,
    String? lastSyncLabel,
    bool? connected,
    bool? isRealData,
    String? sourceLabel,
    double? hrvMs,
    int? stepsToday,
    double? activeCalories,
  }) {
    return BiometricSnapshot(
      restingHr: restingHr ?? this.restingHr,
      sleepHours: sleepHours ?? this.sleepHours,
      recovery: recovery ?? this.recovery,
      energy: energy ?? this.energy,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      stress: stress ?? this.stress,
      readiness: readiness ?? this.readiness,
      weeklyTrainings: weeklyTrainings ?? this.weeklyTrainings,
      lastSyncLabel: lastSyncLabel ?? this.lastSyncLabel,
      connected: connected ?? this.connected,
      isRealData: isRealData ?? this.isRealData,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      hrvMs: hrvMs ?? this.hrvMs,
      stepsToday: stepsToday ?? this.stepsToday,
      activeCalories: activeCalories ?? this.activeCalories,
    );
  }

  /// Valores iniciais no estilo da demo (fallback).
  factory BiometricSnapshot.demoFallback() {
    return const BiometricSnapshot(
      restingHr: 58,
      sleepHours: 7.2,
      recovery: 82,
      energy: 84,
      sleepQuality: 'Boa',
      stress: 'Moderado',
      readiness: 93,
      weeklyTrainings: 5,
      lastSyncLabel: 'Modo estimado',
      connected: false,
      isRealData: false,
      sourceLabel: 'Motor estimado TesClinic',
    );
  }
}
