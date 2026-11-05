import '../../../../core/health/health_connect_service.dart';
import '../../../../core/network/octosense_api_client.dart';
import '../../../../core/session/user_session.dart';
import '../../domain/entities/dashboard_snapshot.dart';
import '../../domain/repositories/dashboard_repository.dart';

class ApiDashboardRepository implements DashboardRepository {
  ApiDashboardRepository(
    OctoSenseApiClient _,
    this._session,
    this._healthConnect,
  );

  final UserSession _session;
  final HealthConnectService _healthConnect;

  @override
  Future<DashboardSnapshot> getSnapshot() async {
    final userId = _session.userId;
    if (userId == null || userId.isEmpty) {
      return const DashboardSnapshot(
        sourceCaption: 'Entre para acompanhar suas métricas',
      );
    }

    // O dashboard usa o Health Connect como fonte de verdade para o "agora".
    // O backend continua recebendo o mesmo resumo para Trends, mas não é
    // usado como segunda fonte da tela inicial.
    return await _readFromHealthConnect() ??
        const DashboardSnapshot(
          sourceCaption: 'Conecte o Health Connect para ver suas métricas',
        );
  }

  Future<DashboardSnapshot?> _readFromHealthConnect() async {
    final available = await _healthConnect.isAvailable;
    if (!available) return null;

    try {
      final steps = await _healthConnect.getTodaySteps();
      final calories = await _healthConnect.getTodayCalories();
      final totalCalories = await _healthConnect.getTodayTotalCalories();
      final heartRate = await _healthConnect.getLatestHeartRate();
      final sleep = await _healthConnect.getLastSleepDuration();
      final oxygen = await _healthConnect.getLatestBloodOxygen();
      final heartRateSeries = await _healthConnect.getTodayHeartRateSeries();

      final hasAny =
          steps > 0 ||
          calories != null ||
          totalCalories != null ||
          heartRate != null ||
          sleep != null ||
          oxygen != null;
      if (!hasAny) return null;

      return DashboardSnapshot(
        heartRateBpm: heartRate,
        steps: steps,
        sleepLabel: _formatDuration(sleep),
        oxygenLabel: _formatOxygen(oxygen),
        activeCaloriesLabel: calories?.round().toString(),
        totalCaloriesLabel: totalCalories?.round().toString(),
        heartRateSeries: heartRateSeries
            .map((e) => HeartRateSample(recordedAt: e.time, bpm: e.bpm))
            .toList(),
        sourceCaption: 'Health Connect · hoje',
      );
    } catch (_) {
      return null;
    }
  }

  static String? _formatDuration(Duration? duration) {
    if (duration == null) return null;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '${hours}h $minutes';
  }

  static String? _formatOxygen(double? value) {
    if (value == null || value <= 0) return null;
    return '${value.round()}%';
  }
}
