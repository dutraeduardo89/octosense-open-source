import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../../features/dashboard/data/repositories/api_dashboard_repository.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_snapshot.dart';
import '../../features/dashboard/presentation/bloc/dashboard_cubit.dart';
import '../../features/google_health/data/repositories/api_google_health_repository.dart';
import '../../features/google_health/domain/repositories/google_health_repository.dart';
import '../../features/google_health/domain/usecases/get_google_health_link_status.dart';
import '../../features/google_health/domain/usecases/start_google_health_link.dart';
import '../../features/google_health/domain/usecases/unlink_google_health.dart';
import '../../features/google_health/presentation/bloc/google_health_cubit.dart';
import '../../features/readings/data/repositories/api_readings_repository.dart';
import '../../features/readings/domain/repositories/readings_repository.dart';
import '../../features/readings/domain/usecases/get_readings_by_user.dart';
import '../../features/trends/presentation/bloc/trends_cubit.dart';
import '../auth/auth_service.dart';
import '../config/api_config.dart';
import '../health/health_connect_service.dart';
import '../health/health_sync_service.dart';
import '../network/octosense_api_client.dart';
import '../session/user_session.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  debugPrint('�� [BOOT OCTOSENSE] URL EFETIVA DO BACKEND: ${ApiConfig.baseUrl}');
  if (getIt.isRegistered<OctoSenseApiClient>()) {
    return;
  }

  getIt.registerLazySingleton(() => UserSession());

  // IMPORTANTE: passa ApiConfig.baseUrl (que respeita --dart-define=API_BASE).
  // Sem isso, o client usa o default 10.0.2.2 (emulador) e falha em device físico.
  getIt.registerLazySingleton(
    () => OctoSenseApiClient(baseUrl: ApiConfig.baseUrl),
  );

  getIt.registerLazySingleton(() => HealthConnectService());

  // Autenticação Google Sign-In + troca de idToken por JWT do OctoSense.
  getIt.registerLazySingleton(() => AuthService(getIt(), getIt()));

  // Sincronização Health Connect -> backend (usa Bearer injetado pelo client).
  getIt.registerLazySingleton(() => HealthSyncService(getIt(), getIt()));

  getIt.registerLazySingleton<ReadingsRepository>(
    () => ApiReadingsRepository(getIt()),
  );
  getIt.registerLazySingleton<DashboardRepository>(
    () => ApiDashboardRepository(getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton<GoogleHealthRepository>(
    () => ApiGoogleHealthRepository(getIt()),
  );

  getIt.registerLazySingleton(() => GetReadingsByUser(getIt()));
  getIt.registerLazySingleton(() => GetDashboardSnapshot(getIt()));
  getIt.registerLazySingleton(() => StartGoogleHealthLink(getIt()));
  getIt.registerLazySingleton(() => GetGoogleHealthLinkStatus(getIt()));
  getIt.registerLazySingleton(() => UnlinkGoogleHealth(getIt()));

  getIt.registerFactory(() => DashboardCubit(getIt()));
  getIt.registerFactory(() => TrendsCubit(getIt(), getIt(), getIt()));
  getIt.registerFactory(
    () => GoogleHealthCubit(getIt(), getIt(), getIt(), getIt()),
  );
}
