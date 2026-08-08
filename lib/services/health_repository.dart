import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

import '../models/biometric_snapshot.dart';
import 'readiness_calculator.dart';

enum HealthConnectionStatus {
  unsupported,
  notDetermined,
  denied,
  authorized,
  partial,
  error,
}

/// Lê dados de HealthKit (iOS) e Health Connect (Android)
/// e devolve [BiometricSnapshot] no mesmo formato da demo.
class HealthRepository {
  HealthRepository({Health? health}) : _health = health ?? Health();

  final Health _health;
  final _calculator = ReadinessCalculator();

  static final List<HealthDataType> _types = [
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
    HealthDataType.HEART_RATE_VARIABILITY_SDNN,
  ];

  static final List<HealthDataAccess> _permissions =
      _types.map((_) => HealthDataAccess.READ).toList();

  bool get isMobilePlatform {
    if (kIsWeb) return false;
    try {
      return Platform.isIOS || Platform.isAndroid;
    } catch (_) {
      return false;
    }
  }

  String get platformSourceLabel {
    if (kIsWeb) return 'Web (sem HealthKit)';
    try {
      if (Platform.isIOS) return 'Apple Health / Apple Watch';
      if (Platform.isAndroid) return 'Health Connect';
    } catch (_) {}
    return 'Plataforma sem sensores de saúde';
  }

  /// Solicita autorização de leitura.
  Future<HealthConnectionStatus> requestAuthorization() async {
    if (!isMobilePlatform) return HealthConnectionStatus.unsupported;
    try {
      await _health.configure();
      final ok = await _health.requestAuthorization(
        _types,
        permissions: _permissions,
      );
      if (ok == true) return HealthConnectionStatus.authorized;
      return HealthConnectionStatus.denied;
    } catch (e) {
      debugPrint('Health auth error: $e');
      return HealthConnectionStatus.error;
    }
  }

  /// Sincroniza biometria das últimas 24–48h e calcula prontidão.
  Future<BiometricSnapshot> sync({bool preferReal = true}) async {
    if (!preferReal || !isMobilePlatform) {
      return BiometricSnapshot.demoFallback();
    }

    try {
      await _health.configure();

      final now = DateTime.now();
      final from24h = now.subtract(const Duration(hours: 36));
      final from7d = now.subtract(const Duration(days: 7));

      // Tipos principais (nem todos existem em todos os devices)
      final points = await _safeFetch(_types, from24h, now);
      final weekPoints = await _safeFetch(
        [
          HealthDataType.RESTING_HEART_RATE,
          HealthDataType.WORKOUT,
          HealthDataType.STEPS,
        ],
        from7d,
        now,
      );

      final restingHr = _latestNumeric(points, [
            HealthDataType.RESTING_HEART_RATE,
          ]) ??
          _averageNumeric(points, [HealthDataType.HEART_RATE]) ??
          _averageNumeric(weekPoints, [HealthDataType.RESTING_HEART_RATE]);

      final sleepHours = _sleepHours(points);
      final hrv = _averageNumeric(points, [
        HealthDataType.HEART_RATE_VARIABILITY_SDNN,
      ]);
      final steps = _sumNumeric(points, [HealthDataType.STEPS])?.round();
      final calories = _sumNumeric(points, [HealthDataType.ACTIVE_ENERGY_BURNED]);
      final workouts48h = _countWorkouts(points);
      final weeklyTrainings = _countWorkouts(weekPoints);
      final baselineHr = _averageNumeric(weekPoints, [
            HealthDataType.RESTING_HEART_RATE,
          ]) ??
          restingHr;

      // Se quase nada veio do dispositivo, fallback
      final hasSignal = restingHr != null || sleepHours != null || steps != null;
      if (!hasSignal) {
        return BiometricSnapshot.demoFallback().copyWith(
          lastSyncLabel: 'Sem dados no ${platformSourceLabel.split(' ').first}',
          sourceLabel: platformSourceLabel,
          connected: false,
          isRealData: false,
        );
      }

      return _calculator.compute(
        restingHr: restingHr ?? 62,
        sleepHours: sleepHours ?? 6.5,
        hrvMs: hrv,
        workoutsLast48h: workouts48h,
        weeklyTrainings: weeklyTrainings,
        baselineRestingHr: baselineHr,
        stepsToday: steps,
        activeCalories: calories,
        sourceLabel: platformSourceLabel,
        isRealData: true,
      );
    } catch (e) {
      debugPrint('Health sync error: $e');
      return BiometricSnapshot.demoFallback().copyWith(
        lastSyncLabel: 'Erro na sincronização',
        sourceLabel: platformSourceLabel,
      );
    }
  }

  Future<List<HealthDataPoint>> _safeFetch(
    List<HealthDataType> types,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        types: types,
        startTime: start,
        endTime: end,
      );
      return _health.removeDuplicates(data);
    } catch (e) {
      debugPrint('Fetch partial error: $e');
      return [];
    }
  }

  double? _latestNumeric(List<HealthDataPoint> data, List<HealthDataType> types) {
    final filtered = data.where((p) => types.contains(p.type)).toList()
      ..sort((a, b) => b.dateTo.compareTo(a.dateTo));
    if (filtered.isEmpty) return null;
    final v = filtered.first.value;
    if (v is NumericHealthValue) return v.numericValue.toDouble();
    return null;
  }

  double? _averageNumeric(List<HealthDataPoint> data, List<HealthDataType> types) {
    final vals = <double>[];
    for (final p in data) {
      if (!types.contains(p.type)) continue;
      final v = p.value;
      if (v is NumericHealthValue) vals.add(v.numericValue.toDouble());
    }
    if (vals.isEmpty) return null;
    return vals.reduce((a, b) => a + b) / vals.length;
  }

  double? _sumNumeric(List<HealthDataPoint> data, List<HealthDataType> types) {
    double sum = 0;
    var any = false;
    for (final p in data) {
      if (!types.contains(p.type)) continue;
      final v = p.value;
      if (v is NumericHealthValue) {
        sum += v.numericValue.toDouble();
        any = true;
      }
    }
    return any ? sum : null;
  }

  /// Soma duração de sono (horas). Prefer SLEEP_ASLEEP / SESSION.
  double? _sleepHours(List<HealthDataPoint> data) {
    Duration total = Duration.zero;
    var any = false;
    for (final p in data) {
      if (p.type == HealthDataType.SLEEP_ASLEEP ||
          p.type == HealthDataType.SLEEP_SESSION ||
          p.type == HealthDataType.SLEEP_IN_BED) {
        final d = p.dateTo.difference(p.dateFrom);
        if (d.inMinutes > 0 && d.inHours < 16) {
          total += d;
          any = true;
        }
      }
    }
    if (!any) return null;
    // Se veio IN_BED + ASLEEP duplicado, limita a 12h
    final hours = total.inMinutes / 60.0;
    return hours.clamp(0.5, 12.0);
  }

  int _countWorkouts(List<HealthDataPoint> data) {
    return data.where((p) => p.type == HealthDataType.WORKOUT).length;
  }
}
