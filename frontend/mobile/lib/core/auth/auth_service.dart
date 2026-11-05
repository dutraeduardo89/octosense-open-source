import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:google_sign_in/google_sign_in.dart';

import '../config/api_config.dart';
import '../network/octosense_api_client.dart';
import '../session/user_session.dart';

/// Orquestra o login via Google Sign-In e troca o idToken por JWTs do OctoSense.
///
/// Fluxo:
/// 1. Abre o fluxo nativo do Google Sign-In.
/// 2. Obtém o `idToken` (JWT assinado pelo Google).
/// 3. Extrai o `email` do idToken (claim padrão do Google) — vira o userId do app.
/// 4. POST /auth/google { idToken } no backend OctoSense.
/// 5. Recebe { accessToken, refreshToken } (AuthTokens).
/// 6. Persiste em SharedPreferences via UserSession.
///
/// Depois disso, OctoSenseApiClient._getHeaders() injeta o Bearer automaticamente
/// em toda request, pois já lê `access_token` do SharedPreferences.
class AuthService {
  AuthService(this._client, this._session);

  final OctoSenseApiClient _client;
  final UserSession _session;

  GoogleSignIn? _googleSignIn;
  bool _initialized = false;

  Future<GoogleSignIn> _ensureInitialized() async {
    if (_initialized && _googleSignIn != null) {
      return _googleSignIn!;
    }

    final instance = GoogleSignIn.instance;

    // serverClientId: OBRIGATÓRIO no Android com google_sign_in 7.x.
    // É o Client ID do tipo "Aplicativo da Web" (não Android) do projeto
    // Octosense no Google Cloud Console.
    await instance.initialize(
      serverClientId: ApiConfig.googleServerClientId,
    );

    _googleSignIn = instance;
    _initialized = true;
    return instance;
  }

  /// Resultado de um login bem-sucedido.
  ///
  /// Retorna `null` se o usuário cancelou a tela do Google.
  /// Lança [AuthException] em erros de rede/backend.
  Future<AuthResult?> signInWithGoogle() async {
    debugPrint('[Auth] Iniciando authenticate()...');
    final googleSignIn = await _ensureInitialized();

    final GoogleSignInAccount googleUser;
    try {
      googleUser = await googleSignIn.authenticate();
      debugPrint('[Auth] authenticate() OK. email=${googleUser.email}');
    } on GoogleSignInException catch (e) {
      debugPrint('[Auth] GoogleSignInException: code=${e.code} desc=${e.description}');
      // Cancelamento não é erro — é escolha do usuário.
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      throw AuthException(
        'Google Sign-In falhou: ${e.code} ${e.description ?? ''}',
      );
    } catch (e, st) {
      debugPrint('[Auth] Exceção inesperada em authenticate: $e\n$st');
      rethrow;
    }

    final idToken = googleUser.authentication.idToken;
    debugPrint('[Auth] idToken length=${idToken?.length ?? 0}');
    if (idToken == null || idToken.isEmpty) {
      throw const AuthException(
        'Google Sign-In não retornou idToken. Verifique se o OAuth Client '
        'Android está configurado no Google Cloud Console com o SHA-1 correto.',
      );
    }

    // O backend valida este idToken e cria/atualiza o User com o mesmo email.
    // Extraímos o email do próprio idToken (fonte da verdade) para usá-lo
    // como userId do app — evita ter que alterar o Domain AuthTokens.
    final userId = _extractEmailFromIdToken(idToken);
    if (userId == null || userId.isEmpty) {
      throw const AuthException(
        'Não foi possível extrair email do idToken do Google.',
      );
    }

    debugPrint('[Auth] POST /auth/google...');
    final response = await _client.postRaw(
      '/auth/google',
      <String, dynamic>{'idToken': idToken},
    );
    debugPrint('[Auth] /auth/google -> ${response.statusCode} body=${response.body}');

    if (response.statusCode != 200) {
      throw AuthException(
        'Backend recusou o login (${response.statusCode}): ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    // O backend retorna AuthTokens direto (sem wrapper, sem userId).
    // Campos possíveis conforme JwtTokenService.IssueAsync:
    final accessToken = (body['accessToken'] ?? body['AccessToken']) as String?;
    final refreshToken =
        (body['refreshToken'] ?? body['RefreshToken']) as String?;

    if (accessToken == null || accessToken.isEmpty) {
      throw AuthException(
        'Backend não retornou accessToken. Body: ${response.body}',
      );
    }

    debugPrint('[Auth] Salvando tokens...');
    await _session.saveTokens(
      userId: userId,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    debugPrint('[Auth] Tokens salvos. userId=$userId');

    return AuthResult(
      userId: userId,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  /// Encerra sessão do Google e limpa tokens locais.
  Future<void> signOut() async {
    if (_initialized && _googleSignIn != null) {
      try {
        await _googleSignIn!.signOut();
      } catch (_) {
        // Ignora erros do Google: o importante é limpar o estado local.
      }
    }
    await _session.clear();
  }

  /// Decodifica o payload do JWT do Google (sem validar assinatura).
  ///
  /// A validação criptográfica é responsabilidade do backend
  /// (GoogleTokenValidator.ValidateAsync). Aqui só queremos ler o email.
  static String? _extractEmailFromIdToken(String idToken) {
    try {
      final parts = idToken.split('.');
      if (parts.length != 3) return null;

      // Base64url -> base64 padrão
      var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      // Re-pad para múltiplo de 4
      while (payload.length % 4 != 0) {
        payload = '$payload=';
      }

      final decoded = utf8.decode(base64.decode(payload));
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      return json['email'] as String?;
    } catch (_) {
      return null;
    }
  }
}

/// Resultado do login bem-sucedido.
class AuthResult {
  const AuthResult({
    required this.userId,
    required this.accessToken,
    this.refreshToken,
  });

  final String userId;
  final String accessToken;
  final String? refreshToken;
}

/// Erro de autenticação com mensagem amigável.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
