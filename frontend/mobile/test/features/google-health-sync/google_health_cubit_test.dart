import 'package:flutter_test/flutter_test.dart';
import 'package:octosense/core/session/user_session.dart';
import 'package:octosense/features/google_health/domain/entities/google_health_link.dart';
import 'package:octosense/features/google_health/domain/repositories/google_health_repository.dart';
import 'package:octosense/features/google_health/domain/usecases/get_google_health_link_status.dart';
import 'package:octosense/features/google_health/domain/usecases/start_google_health_link.dart';
import 'package:octosense/features/google_health/domain/usecases/unlink_google_health.dart';
import 'package:octosense/features/google_health/presentation/bloc/google_health_cubit.dart';
import 'package:octosense/features/google_health/presentation/bloc/google_health_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeGoogleHealthRepository implements GoogleHealthRepository {
  _FakeGoogleHealthRepository({this.fail = false});

  final bool fail;

  @override
  Future<Uri> authorizationUri() async {
    if (fail) {
      throw Exception('boom');
    }
    return Uri.parse(
      'https://accounts.google.com/o/oauth2/v2/auth?client_id=test',
    );
  }

  @override
  Future<GoogleHealthLink> activeLink() async {
    if (fail) {
      throw Exception('boom');
    }
    return const GoogleHealthLink(userId: 'owner@gmail.com', linked: true);
  }

  @override
  Future<void> unlink(String userId) async {
    if (fail) {
      throw Exception('boom');
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('startLink_ShouldReturnGoogleAuthorizationUri_WhenApiSucceeds', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = _FakeGoogleHealthRepository();
    final cubit = GoogleHealthCubit(
      StartGoogleHealthLink(repository),
      GetGoogleHealthLinkStatus(repository),
      UnlinkGoogleHealth(repository),
      UserSession(),
    );

    final uri = await cubit.startLink();

    expect(uri?.host, 'accounts.google.com');
    expect(cubit.state.status, GoogleHealthStatus.idle);
    await cubit.close();
  });

  test('startLink_ShouldEmitError_WhenRepositoryFails', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = _FakeGoogleHealthRepository(fail: true);
    final cubit = GoogleHealthCubit(
      StartGoogleHealthLink(repository),
      GetGoogleHealthLinkStatus(repository),
      UnlinkGoogleHealth(repository),
      UserSession(),
    );

    final uri = await cubit.startLink();

    expect(uri, isNull);
    expect(cubit.state.status, GoogleHealthStatus.error);
    await cubit.close();
  });

  test('confirmLink_ShouldStoreGoogleEmail_WhenActiveLinkExists', () async {
    SharedPreferences.setMockInitialValues({});
    final session = UserSession();
    final repository = _FakeGoogleHealthRepository();
    final cubit = GoogleHealthCubit(
      StartGoogleHealthLink(repository),
      GetGoogleHealthLinkStatus(repository),
      UnlinkGoogleHealth(repository),
      session,
    );

    final link = await cubit.confirmLink();

    expect(link?.userId, 'owner@gmail.com');
    expect(session.userId, 'owner@gmail.com');
    await cubit.close();
  });

  test('confirmLink_ShouldReturnNullWithoutError_WhenQuietAndActiveLinkMissing', () async {
    SharedPreferences.setMockInitialValues({});
    final cubit = GoogleHealthCubit(
      StartGoogleHealthLink(_FakeGoogleHealthRepository()),
      GetGoogleHealthLinkStatus(_FakeGoogleHealthRepository(fail: true)),
      UnlinkGoogleHealth(_FakeGoogleHealthRepository()),
      UserSession(),
    );

    final link = await cubit.confirmLink(quiet: true);

    expect(link, isNull);
    expect(cubit.state.status, GoogleHealthStatus.idle);
    await cubit.close();
  });
}
