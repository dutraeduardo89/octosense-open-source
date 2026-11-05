abstract final class ApiConfig {
  /// Backend base URL. Override with `--dart-define=API_BASE=...`.
  /// Padrão seguro para desenvolvimento local.
  static const baseUrl = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://localhost:5137',
  );

  /// Demo user used by dashboard, trends, and Google Health link.
  static const demoUserId = String.fromEnvironment(
    'OCTOSENSE_USER_ID',
    defaultValue: 'usr_local_demo',
  );

  /// OAuth 2.0 Web Client ID.
  /// No repositório público, o valor padrão é vazio.
  /// Cada desenvolvedor deve criar o próprio Client ID no Google Cloud Console.
  static const googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );
}
