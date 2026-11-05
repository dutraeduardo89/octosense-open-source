class HeartRateSample {
  const HeartRateSample({required this.recordedAt, required this.bpm});

  final DateTime recordedAt;
  final double bpm;
}

class DashboardSnapshot {
  const DashboardSnapshot({
    this.heartRateBpm,
    this.steps,
    this.sleepLabel,
    this.oxygenLabel,
    this.activeCaloriesLabel,
    this.totalCaloriesLabel,
    this.heartRateSeries = const [],
    required this.sourceCaption,
  });

  final double? heartRateBpm;
  final int? steps;
  final String? sleepLabel;
  final String? oxygenLabel;
  final String? activeCaloriesLabel;
  final String? totalCaloriesLabel;
  final List<HeartRateSample> heartRateSeries;
  final String sourceCaption;

  bool get hasAnyMetric =>
      heartRateBpm != null ||
      steps != null ||
      sleepLabel != null ||
      oxygenLabel != null ||
      activeCaloriesLabel != null ||
      totalCaloriesLabel != null;
}
