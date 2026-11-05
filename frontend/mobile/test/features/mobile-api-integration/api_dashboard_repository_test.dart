import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:octosense/core/health/health_connect_service.dart';
import 'package:octosense/core/network/octosense_api_client.dart';
import 'package:octosense/core/session/user_session.dart';
import 'package:octosense/features/dashboard/data/repositories/api_dashboard_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fake que simula Health Connect indisponivel para forcar o uso do backend.
class _UnavailableHealthConnect extends HealthConnectService {
  @override
  Future<bool> get isAvailable async => false;
}

void main() {
  // OBRIGATORIO: inicializa o binding do Flutter ANTES de qualquer teste.
  // Sem isso, SharedPreferences.getInstance() (chamado dentro de
  // OctoSenseApiClient._getHeaders) lanca "Binding has not yet been
  // initialized." porque o plugin nativo nao existe no test runner (VM).
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock in-memory do SharedPreferences. Roda ANTES de cada teste.
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'getSnapshot_ShouldNotUseBackend_WhenHealthConnectUnavailable',
    () async {
      final client = OctoSenseApiClient(
        client: MockClient((request) async {
          fail('Dashboard should not read a second source.');
        }),
      );
      final session = UserSession()..userId = 'owner@gmail.com';

      final snapshot = await ApiDashboardRepository(
        client,
        session,
        _UnavailableHealthConnect(),
      ).getSnapshot();

      expect(snapshot.hasAnyMetric, isFalse);
      expect(snapshot.sourceCaption, contains('Health Connect'));
    },
  );

  test('getSnapshot_ShouldAskToLink_WhenSessionHasNoUser', () async {
    final client = OctoSenseApiClient(
      client: MockClient((request) async {
        fail('API should not be called before Google link');
      }),
    );

    final snapshot = await ApiDashboardRepository(
      client,
      UserSession(),
      _UnavailableHealthConnect(),
    ).getSnapshot();

    expect(snapshot.hasAnyMetric, isFalse);
    expect(snapshot.sourceCaption, 'Entre para acompanhar suas métricas');
  });
}
