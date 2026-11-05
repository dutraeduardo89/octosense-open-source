import '../entities/health_reading.dart';

abstract interface class ReadingsRepository {
  Future<List<HealthReading>> getByUser(String userId);

  Future<void> create({
    required String userId,
    required String deviceId,
    required String deviceSource,
    required DateTime recordedAt,
    double? heartRateBpm,
    int? steps,
    Duration? sleepDuration,
    double? oxygenSaturationPercent,
    double? totalCaloriesKcal,
    String? syncMode,
    int? batteryLevel,
    String? externalId,
  });
}
