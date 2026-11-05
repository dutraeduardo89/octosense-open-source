import '../../../readings/domain/entities/daily_summary.dart';

enum TrendsPeriod { days7, days30, days90 }

class TrendHeartRatePoint {
  const TrendHeartRatePoint({required this.recordedAt, required this.bpm});

  final DateTime recordedAt;
  final double bpm;
}

/// Agregado de métricas em um período (7/30/90 dias).
///
/// Mostra MÉDIA DIÁRIA e TOTAL ACUMULADO. As duas coisas são úteis:
/// média dá noção de hábito, total dá noção de volume.
class TrendsSnapshot {
  const TrendsSnapshot({
    required this.period,
    this.averageHeartRateBpm,
    this.averageSteps,
    this.totalSteps,
    this.averageSleepLabel,
    this.totalSleepLabel,
    this.averageCalories,
    this.totalActiveCalories,
    this.totalCalories,
    this.heartRateSeries = const [],
    this.daysWithData = 0,
    required this.sourceCaption,
  });

  final TrendsPeriod period;

  /// Média diária de FC no período.
  final double? averageHeartRateBpm;

  /// Média diária de passos.
  final double? averageSteps;

  /// Soma de passos no período.
  final double? totalSteps;

  /// Média diária de sono (formatada).
  final String? averageSleepLabel;

  /// Soma de sono no período (formatada).
  final String? totalSleepLabel;

  /// Média diária de calorias ativas.
  final double? averageCalories;

  /// Soma de calorias ativas no período (exercício).
  final double? totalActiveCalories;

  /// Soma de calorias totais no período (ativas + basal).
  final double? totalCalories;

  final List<TrendHeartRatePoint> heartRateSeries;
  final int daysWithData;
  final String sourceCaption;

  static TrendsSnapshot fromSummaries({
    required TrendsPeriod period,
    required List<DailySummary> summaries,
  }) {
    // Aceita qualquer dia com pelo menos 1 leitura.
    final daysWithData = summaries.where((s) => s.readingCount >= 1).toList();

    if (daysWithData.isEmpty) {
      return TrendsSnapshot(
        period: period,
        sourceCaption: 'Sem medições neste período',
      );
    }

    final steps = daysWithData.map((s) => s.totalSteps.toDouble()).toList();
    final activeCalories =
        daysWithData.map((s) => s.activeCaloriesKcal).toList();
    final totalCalories =
        daysWithData.map((s) => s.totalCaloriesKcal).toList();

    final heartRates = daysWithData
        .where((s) => s.avgHeartRateBpm != null)
        .map((s) => s.avgHeartRateBpm!)
        .toList();

    final sleeps = daysWithData
        .where((s) => s.totalSleepDuration != null)
        .map((s) => s.totalSleepDuration!)
        .toList();

    final totalSleep = sleeps.isEmpty
        ? null
        : sleeps.fold<Duration>(Duration.zero, (acc, d) => acc + d);

    return TrendsSnapshot(
      period: period,
      averageHeartRateBpm: _average(heartRates),
      averageSteps: _average(steps),
      totalSteps: steps.fold<double>(0, (a, b) => a + b),
      averageSleepLabel: sleeps.isEmpty
          ? null
          : _formatDuration(_averageDuration(sleeps)),
      totalSleepLabel: totalSleep == null ? null : _formatDuration(totalSleep),
      averageCalories: _average(totalCalories),
      totalActiveCalories: activeCalories.fold<double>(0, (a, b) => a + b),
      totalCalories: totalCalories.fold<double>(0, (a, b) => a + b),
      heartRateSeries: [
        for (final summary in daysWithData)
          if (summary.avgHeartRateBpm != null)
            TrendHeartRatePoint(
              recordedAt: summary.date,
              bpm: summary.avgHeartRateBpm!,
            ),
      ],
      daysWithData: daysWithData.length,
      sourceCaption: '${daysWithData.length} dia(s) com dados no período',
    );
  }

  static double? _average(List<double> values) {
    if (values.isEmpty) {
      return null;
    }
    return values.reduce((a, b) => a + b) / values.length;
  }

  static Duration _averageDuration(List<Duration> values) {
    final totalMs = values.fold<int>(
      0,
      (sum, item) => sum + item.inMilliseconds,
    );
    return Duration(milliseconds: totalMs ~/ values.length);
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '${hours}h $minutes';
  }
}
