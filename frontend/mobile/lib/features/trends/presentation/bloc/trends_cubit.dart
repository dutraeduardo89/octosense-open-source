import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/health/health_sync_service.dart';
import '../../../../core/network/octosense_api_client.dart';
import '../../../../core/session/user_session.dart';
import '../../domain/entities/trends_snapshot.dart';
import 'trends_state.dart';

class TrendsCubit extends Cubit<TrendsState> {
  TrendsCubit(this._client, this._session, this._healthSync)
    : super(const TrendsState(loading: true));

  final OctoSenseApiClient _client;
  final UserSession _session;
  final HealthSyncService _healthSync;

  Future<void> load({TrendsPeriod period = TrendsPeriod.days7}) async {
    emit(TrendsState(loading: true, period: period));
    try {
      final userId = _session.userId;
      if (userId == null || userId.isEmpty) {
        emit(
          TrendsState(
            period: period,
            snapshot: TrendsSnapshot.fromSummaries(
              period: period,
              summaries: const [],
            ),
          ),
        );
        return;
      }

      final days = switch (period) {
        TrendsPeriod.days7 => 7,
        TrendsPeriod.days30 => 30,
        TrendsPeriod.days90 => 90,
      };
      final now = DateTime.now().toUtc();
      final today = DateTime.utc(now.year, now.month, now.day);
      final from = today.subtract(Duration(days: days - 1));

      await _healthSync.syncTodayData();

      final summaries = await _client.getDailySummary(
        userId: userId,
        from: from,
        to: today,
      );

      emit(
        TrendsState(
          period: period,
          snapshot: TrendsSnapshot.fromSummaries(
            period: period,
            summaries: summaries,
          ),
        ),
      );
    } catch (_) {
      emit(
        TrendsState(
          period: period,
          errorMessage: 'Não foi possível atualizar as tendências agora.',
        ),
      );
    }
  }

  void selectPeriod(TrendsPeriod period) {
    load(period: period);
  }
}
