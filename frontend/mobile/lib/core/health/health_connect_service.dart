import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

/// Lê dados de saúde locais do celular (Health Connect no Android).
///
/// Nota sobre deduplicação: o Health Connect recebe pontos de VÁRIOS apps
/// (Google Fit, sensor do celular, Mi Fitness, Samsung Health). Para
/// contagens (passos, calorias), usamos os métodos agregadores que já
/// deduplicam. Para dados pontuais (HR, SpO2), pegamos o mais recente.
class HealthConnectService {
  HealthConnectService();

  final Health _health = Health();

  /// IMPORTANTE: esta lista precisa conter TODOS os tipos que o app lê.
  /// Se um tipo não estiver aqui, o Android rejeita a leitura com
  /// SecurityException, mesmo que esteja no AndroidManifest.
  static const List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED,
    HealthDataType.BLOOD_OXYGEN, // ← FIX: faltava
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_SESSION, // ← FIX: sessão completa (Gadgetbridge)
  ];

  bool _configured = false;

  Future<void> configure() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  Future<bool> get isAvailable async {
    await configure();
    try {
      return await _health.isHealthConnectAvailable();
    } catch (e) {
      debugPrint('[HC] isAvailable ERROR: $e');
      return false;
    }
  }

  Future<bool> hasRequiredPermissions() async {
    await configure();
    try {
      final granted = await _health.hasPermissions(_types);
      return granted ?? false;
    } catch (e) {
      debugPrint('[HC] hasRequiredPermissions ERROR: $e');
      return false;
    }
  }

  /// Solicita autorização para TODOS os tipos. Após retornar, checa
  /// individualmente quais foram concedidos e loga os que faltaram.
  Future<bool> requestPermissions() async {
    await configure();
    try {
      final granted = await _health.requestAuthorization(_types);

      // Diagnóstico: checa individualmente quais foram concedidos
      for (final type in _types) {
        final has = await _health.hasPermissions([type]) ?? false;
        if (!has) {
          debugPrint('[HC] ❌ PERMISSÃO NEGADA: $type');
        }
      }
      return granted;
    } catch (e) {
      debugPrint('[HC] requestPermissions ERROR: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // PASSOS
  // ─────────────────────────────────────────────────────────────

  Future<int> getTodaySteps() async {
    await configure();
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    try {
      final total = await _health.getTotalStepsInInterval(startOfDay, now);
      debugPrint('[HC] getTodaySteps (agregado) = $total');
      return total ?? 0;
    } catch (e) {
      debugPrint('[HC] getTodaySteps ERROR: $e');
      return 0;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // CALORIAS
  // ─────────────────────────────────────────────────────────────

  Future<double?> getTodayCalories() async {
    await configure();
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    try {
      final points = await _health.getHealthDataFromTypes(
        startTime: startOfDay,
        endTime: now,
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
      );
      if (points.isEmpty) return null;

      final bySource = <String, double>{};
      for (final p in points) {
        final v = p.value;
        if (v is! NumericHealthValue) continue;
        final key = p.sourceName;
        bySource[key] = (bySource[key] ?? 0) + v.numericValue.toDouble();
      }
      if (bySource.isEmpty) return null;

      final maxValue = bySource.values.reduce((a, b) => a > b ? a : b);
      debugPrint('[HC] calories by source: $bySource -> using $maxValue');
      return maxValue > 0 ? maxValue : null;
    } catch (e) {
      debugPrint('[HC] getTodayCalories ERROR: $e');
      return null;
    }
  }

  Future<double?> getTodayTotalCalories() async {
    await configure();
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    try {
      final points = await _health.getHealthDataFromTypes(
        startTime: startOfDay,
        endTime: now,
        types: [HealthDataType.TOTAL_CALORIES_BURNED],
      );
      if (points.isNotEmpty) {
        final bySource = <String, double>{};
        for (final p in points) {
          final v = p.value;
          if (v is! NumericHealthValue) continue;
          final key = p.sourceName;
          bySource[key] = (bySource[key] ?? 0) + v.numericValue.toDouble();
        }
        if (bySource.isNotEmpty) {
          final maxValue = bySource.values.reduce((a, b) => a > b ? a : b);
          debugPrint(
            '[HC] totalCalories by source: $bySource -> using $maxValue',
          );
          if (maxValue > 0) return maxValue;
        }
      }

      // Fallback: alguns wearables não calculam TOTAL_CALORIES_BURNED.
      // Estimamos basal com Mifflin-St Jeor simplificado.
      final active = await getTodayCalories() ?? 0;
      if (active <= 0) return null;
      const basalKcalPerDay = 1620; // ~75kg * 24h * 0.9
      final estimated = active + basalKcalPerDay;
      debugPrint('[HC] totalCalories fallback (basal est.): $estimated');
      return estimated;
    } catch (e) {
      debugPrint('[HC] getTodayTotalCalories ERROR: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // SINAIS VITAIS
  // ─────────────────────────────────────────────────────────────

  Future<double?> getLatestHeartRate() async {
    await configure();
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    try {
      final points = await _health.getHealthDataFromTypes(
        startTime: startOfDay,
        endTime: now,
        types: [HealthDataType.HEART_RATE],
      );
      if (points.isEmpty) return null;
      points.sort((a, b) => b.dateTo.compareTo(a.dateTo));
      final v = points.first.value;
      return v is NumericHealthValue ? v.numericValue.toDouble() : null;
    } catch (e) {
      debugPrint('[HC] getLatestHeartRate ERROR: $e');
      return null;
    }
  }

  Future<double?> getLatestBloodOxygen() async {
    await configure();
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    try {
      final points = await _health.getHealthDataFromTypes(
        startTime: startOfDay,
        endTime: now,
        types: [HealthDataType.BLOOD_OXYGEN],
      );
      if (points.isEmpty) return null;
      points.sort((a, b) => b.dateTo.compareTo(a.dateTo));
      final v = points.first.value;
      return v is NumericHealthValue ? v.numericValue.toDouble() : null;
    } catch (e) {
      debugPrint('[HC] getLatestBloodOxygen ERROR: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // SONO
  // ─────────────────────────────────────────────────────────────

  /// Duração do sono da última noite (últimas 24h).
  /// Tenta SLEEP_SESSION primeiro (sessão completa do Gadgetbridge),
  /// depois cai pra SLEEP_ASLEEP se não achar.
  Future<Duration?> getLastSleepDuration() async {
    await configure();
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(hours: 24));

    // Tenta SLEEP_SESSION primeiro, com merge de intervalos sobrepostos
    // (Mi Fitness + Gadgetbridge escrevem a MESMA noite, então somar dá 2x)
    try {
      final sessions = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: [HealthDataType.SLEEP_SESSION],
      );
      if (sessions.isNotEmpty) {
        // Ordena por início
        final sorted = sessions.toList()
          ..sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

        // Merge de intervalos sobrepostos
        final merged = <({DateTime start, DateTime end})>[];
        for (final s in sorted) {
          if (merged.isEmpty) {
            merged.add((start: s.dateFrom, end: s.dateTo));
          } else {
            final last = merged.last;
            if (s.dateFrom.isBefore(last.end)) {
              // Sobreposto - estende o fim se necessário
              if (s.dateTo.isAfter(last.end)) {
                merged[merged.length - 1] = (start: last.start, end: s.dateTo);
              }
            } else {
              // Não sobreposto - novo intervalo
              merged.add((start: s.dateFrom, end: s.dateTo));
            }
          }
        }

        Duration total = Duration.zero;
        for (final m in merged) {
          total += m.end.difference(m.start);
        }
        debugPrint(
          '[HC] sleep merged = $total (${sessions.length} sessions -> ${merged.length} merged)',
        );
        if (total > Duration.zero) return total;
      }
    } catch (e) {
      debugPrint('[HC] getLastSleepDuration SLEEP_SESSION ERROR: $e');
    }

    // Fallback: SLEEP_ASLEEP (fases agregadas)
    try {
      final points = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: [HealthDataType.SLEEP_ASLEEP],
      );
      if (points.isEmpty) return null;
      Duration total = Duration.zero;
      for (final p in points) {
        total += p.dateTo.difference(p.dateFrom);
      }
      debugPrint('[HC] sleep SLEEP_ASLEEP (24h) = $total');
      return total > Duration.zero ? total : null;
    } catch (e) {
      debugPrint('[HC] getLastSleepDuration SLEEP_ASLEEP ERROR: $e');
      return null;
    }
  }

  /// Retorna todas as medições de HR de hoje (para o gráfico da home).
  /// Limita a ~60 pontos pra não poluir o gráfico.
  Future<List<({DateTime time, double bpm})>> getTodayHeartRateSeries() async {
    await configure();
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    try {
      final points = await _health.getHealthDataFromTypes(
        startTime: startOfDay,
        endTime: now,
        types: [HealthDataType.HEART_RATE],
      );
      final list = <({DateTime time, double bpm})>[];
      for (final p in points) {
        final v = p.value;
        if (v is NumericHealthValue) {
          list.add((time: p.dateFrom, bpm: v.numericValue.toDouble()));
        }
      }
      list.sort((a, b) => a.time.compareTo(b.time));

      if (list.length <= 60) return list;

      // Amostragem: pega a cada N pontos pra caber no gráfico
      final step = (list.length / 60).ceil();
      final sampled = <({DateTime time, double bpm})>[];
      for (var i = 0; i < list.length; i += step) {
        sampled.add(list[i]);
      }
      if (sampled.last != list.last) sampled.add(list.last);
      debugPrint('[HC] HR series: ${list.length} pontos -> ${sampled.length} amostrados');
      return sampled;
    } catch (e) {
      debugPrint('[HC] getTodayHeartRateSeries ERROR: $e');
      return [];
    }
  }
}
