import 'package:shared_preferences/shared_preferences.dart';

/// Guarda o estado de sessão local: userId (email Google), tokens JWT e
/// preferências de onboarding.
class UserSession {
  static const _keyUserId = 'octosense.googleUserId';
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyHcUserDeclined = 'octosense.hcUserDeclined';
  static const _keyFreshAfterDelete = 'octosense.freshAfterDelete';

  String? userId;
  String? accessToken;
  String? refreshToken;
  bool _hcUserDeclined = false;
  bool _freshAfterDelete = false;

  bool get isLinked => userId != null && userId!.isNotEmpty;
  bool get isAuthenticated => accessToken != null && accessToken!.isNotEmpty;

  /// Indica que o usuário tocou "Agora não" na tela de permissão do
  /// Health Connect. NÃO significa "já mostramos a tela" — significa
  /// "usuário recusou explicitamente". O app respeita essa decisão.
  ///
  /// Resetado no logout. Se o usuário autorizou mas revogou depois,
  /// essa flag continua false e a tela aparece de novo.
  bool get hcUserDeclined => _hcUserDeclined;

  /// true quando a conta acabou de ser excluída. Faz a PermissionsPage
  /// mostrar de novo (mesmo com HC autorizado no Android) uma única vez.
  bool get freshAfterDelete => _freshAfterDelete;

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString(_keyUserId);
    accessToken = prefs.getString(_keyAccessToken);
    refreshToken = prefs.getString(_keyRefreshToken);
    _hcUserDeclined = prefs.getBool(_keyHcUserDeclined) ?? false;
    _freshAfterDelete = prefs.getBool(_keyFreshAfterDelete) ?? false;
  }

  Future<void> setUserId(String value) async {
    userId = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, value);
  }

  Future<void> saveTokens({
    required String userId,
    required String accessToken,
    String? refreshToken,
  }) async {
    this.userId = userId;
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyAccessToken, accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(_keyRefreshToken, refreshToken);
    } else {
      await prefs.remove(_keyRefreshToken);
    }
  }

  Future<void> markHcUserDeclined() async {
    _hcUserDeclined = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHcUserDeclined, true);
  }

  Future<void> markFreshAfterDelete() async {
    _freshAfterDelete = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFreshAfterDelete, true);
  }

  Future<void> clearFreshAfterDelete() async {
    _freshAfterDelete = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFreshAfterDelete);
  }

  Future<void> clear() async {
    userId = null;
    accessToken = null;
    refreshToken = null;
    _hcUserDeclined = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyHcUserDeclined);
  }
}
