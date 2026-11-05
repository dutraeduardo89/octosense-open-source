import '../../../../core/network/octosense_api_client.dart';
import '../../domain/entities/health_reading.dart';
import '../../domain/repositories/readings_repository.dart';

class ApiReadingsRepository implements ReadingsRepository {
  ApiReadingsRepository(this._client);

  final OctoSenseApiClient _client;

  @override
  Future<List<HealthReading>> getByUser(String userId) =>
      _client.getReadings(userId);

  @override
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
  }) async {
    await _client.createReading(
      userId: userId,
      deviceId: deviceId,
      deviceSource: deviceSource,
      recordedAt: recordedAt,
      heartRateBpm: heartRateBpm,
      steps: steps,
      sleepDuration: sleepDuration,
      oxygenSaturationPercent: oxygenSaturationPercent,
      totalCaloriesKcal: totalCaloriesKcal,
      syncMode: syncMode,
      batteryLevel: batteryLevel,
      externalId: externalId,
    );
  }
}
