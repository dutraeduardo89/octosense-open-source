class DailySummary {
  const DailySummary({
    required this.date,
    required this.totalSteps,
    required this.activeCaloriesKcal,
    required this.totalCaloriesKcal,
    this.avgHeartRateBpm,
    this.totalSleepDuration,
    this.avgOxygenSaturation,
    required this.readingCount,
  });

  final DateTime date;
  final int totalSteps;
  final double activeCaloriesKcal;
  final double totalCaloriesKcal;
  final double? avgHeartRateBpm;
  final Duration? totalSleepDuration;
  final double? avgOxygenSaturation;
  final int readingCount;

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      date: DateTime.parse('${json['date']}T00:00:00Z'),
      totalSteps: (json['totalSteps'] as num).toInt(),
      activeCaloriesKcal:
          (json['activeCaloriesKcal'] as num?)?.toDouble() ?? 0.0,
      totalCaloriesKcal: (json['totalCaloriesKcal'] as num).toDouble(),
      avgHeartRateBpm: (json['avgHeartRateBpm'] as num?)?.toDouble(),
      totalSleepDuration: _parseTimeSpan(json['totalSleepDuration'] as String?),
      avgOxygenSaturation: (json['avgOxygenSaturation'] as num?)?.toDouble(),
      readingCount: (json['readingCount'] as num).toInt(),
    );
  }

  static Duration? _parseTimeSpan(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    var cleaned = raw.replaceAll(RegExp(r'\.\d+$'), '');
    var days = 0;
    if (cleaned.contains('.')) {
      final parts = cleaned.split('.');
      days = int.tryParse(parts[0]) ?? 0;
      cleaned = parts[1];
    }
    final hms = cleaned.split(':');
    if (hms.length != 3) {
      return null;
    }
    return Duration(
      days: days,
      hours: int.tryParse(hms[0]) ?? 0,
      minutes: int.tryParse(hms[1]) ?? 0,
      seconds: int.tryParse(hms[2]) ?? 0,
    );
  }
}