import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/health/health_connect_service.dart';
import '../../../../core/health/health_sync_service.dart';
import '../../domain/usecases/get_dashboard_snapshot.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._getSnapshot)
    : super(const DashboardState(loading: true)) {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => load(silent: true),
    );
  }

  final GetDashboardSnapshot _getSnapshot;
  Timer? _refreshTimer;
  int _tick = 0;
  bool _permissionsRequested = false;

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      emit(const DashboardState(loading: true));
    }

    if (!_permissionsRequested) {
      _permissionsRequested = true;
      try {
        final hc = getIt<HealthConnectService>();
        await hc.requestPermissions();
      } catch (e) {
        debugPrint('[DashboardCubit] Erro pedindo permissao: $e');
      }
    }

    // Sincroniza somente a leitura canônica do Health Connect para o período.
    unawaited(_syncHealthConnect());

    try {
      final snapshot = await _getSnapshot();
      _tick++;
      emit(DashboardState(snapshot: snapshot, tick: _tick));
    } catch (e) {
      // Loga o erro REAL (nao engole). Ajuda a diagnosticar.
      debugPrint('[DashboardCubit] Erro ao carregar: $e');

      // Se e refresh silencioso e ja temos dados na tela,
      // NAO sobrescreve com erro. Falha de rede em background nao
      // deve apagar a tela do usuario.
      if (silent && state.snapshot != null) {
        return;
      }

      // Se nao temos dados (primeira carga), mostra erro.
      emit(
        DashboardState(
          errorMessage: 'Sem conexão. Verifique sua internet e tente de novo.',
        ),
      );
    }
  }

  Future<void> _syncHealthConnect() async {
    try {
      if (!getIt.isRegistered<HealthSyncService>()) {
        return;
      }
      await getIt<HealthSyncService>().syncTodayData();
    } catch (e) {
      debugPrint('[DashboardCubit] Sync HC->backend falhou: $e');
    }
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
