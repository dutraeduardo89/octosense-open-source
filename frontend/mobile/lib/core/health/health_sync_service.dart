import 'package:flutter/foundation.dart';

import '../di/injection.dart';
import '../network/octosense_api_client.dart';
import '../session/user_session.dart';
import 'health_connect_service.dart';

/// Envia dados locais do Health Connect para o backend OctoSense.
///
/// Idempotência: cada leitura diária tem um ExternalId determinístico no
/// formato `hc:{email}:{YYYY-MM-DD}:daily`. Isso garante que syncs
/// subsequentes no mesmo dia atualizem o mesmo documento no Mongo
/// em vez de inserir cópias duplicadas.
class HealthSyncService {
  HealthSyncService(this._healthConnect, this._apiClient);

  final HealthConnectService _healthConnect;
  final OctoSenseApiClient _apiClient;

  Future<bool> syncTodayData() async {
    try {
      final session = getIt<UserSession>();
      final userId = session.userId;

      if (userId == null || userId.isEmpty) {
        debugPrint('[Sync] Sem usuário autenticado. Pulando sync.');
        return false;
      }

      final steps = await _healthConnect.getTodaySteps();
      final calories = await _healthConnect.getTodayCalories();
      final totalCalories = await _healthConnect.getTodayTotalCalories();
      final heartRate = await _healthConnect.getLatestHeartRate();
      final oxygen = await _healthConnect.getLatestBloodOxygen();
      final sleep = await _healthConnect.getLastSleepDuration();

      if (steps == 0 &&
          heartRate == null &&
          calories == null &&
          oxygen == null &&
          sleep == null) {
        debugPrint('[Sync] Sem dados novos para sincronizar hoje.');
        return true;
      }

      final now = DateTime.now();
      final dateKey = _dateKey(now);
      final externalId = 'hc:$userId:$dateKey:daily';

      debugPrint(
        '[Sync] Enviando: steps=$steps, hr=$heartRate, activeCal=$calories, totalCal=$totalCalories, spo2=$oxygen, sleep=$sleep, extId=$externalId',
      );

      await _apiClient.createReading(
        userId: userId,
        deviceId: 'health_connect_android',
        deviceSource: 'health_connect_android',
        recordedAt: now,
        heartRateBpm: heartRate,
        steps: steps,
        sleepDuration: sleep,
        oxygenSaturationPercent: oxygen,
        activeCaloriesKcal: calories,
        totalCaloriesKcal: totalCalories,
        externalId: externalId,
      );

      debugPrint('[Sync] OK.');
      return true;
    } catch (e) {
      debugPrint('[Sync] Exceção: $e');
      return false;
    }
  }

  static String _dateKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
}
