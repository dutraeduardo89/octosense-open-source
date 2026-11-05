import '../../../../core/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence for Google Health link flags.
abstract class GoogleHealthLocalDataSource {
  Future<bool> isLinked();

  Future<String> userId();

  Future<void> markLinked({required String userId});

  Future<void> markUnlinked();

  Uri buildAuthorizationUri(String userId);
}

class GoogleHealthLocalDataSourceImpl implements GoogleHealthLocalDataSource {
  GoogleHealthLocalDataSourceImpl(this._prefs);

  static const _linkedKey = 'google_health_linked';
  static const _userIdKey = 'google_health_user_id';
  static const defaultUserId = 'usr_local_demo';
  // Usa a configuração centralizada para evitar divergência de URLs

  final SharedPreferences _prefs;

  @override
  Future<bool> isLinked() async => _prefs.getBool(_linkedKey) ?? false;

  @override
  Future<String> userId() async =>
      _prefs.getString(_userIdKey) ?? defaultUserId;

  @override
  Future<void> markLinked({required String userId}) async {
    await _prefs.setBool(_linkedKey, true);
    await _prefs.setString(_userIdKey, userId);
  }

  @override
  Future<void> markUnlinked() async {
    await _prefs.setBool(_linkedKey, false);
  }

  @override
  Uri buildAuthorizationUri(String userId) {
    return Uri.parse('${ApiConfig.baseUrl}/auth/google/health').replace(
      queryParameters: {'userId': userId},
    );
  }
}
