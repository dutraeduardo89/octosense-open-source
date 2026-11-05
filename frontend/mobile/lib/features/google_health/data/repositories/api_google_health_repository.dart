import '../../../../core/network/octosense_api_client.dart';
import '../../domain/entities/google_health_link.dart';
import '../../domain/repositories/google_health_repository.dart';

class ApiGoogleHealthRepository implements GoogleHealthRepository {
  ApiGoogleHealthRepository(this._client);

  final OctoSenseApiClient _client;

  @override
  Future<Uri> authorizationUri() => _client.fetchGoogleHealthAuthorizationUri();

  @override
  Future<GoogleHealthLink> activeLink() => _client.fetchActiveGoogleHealthLink();

  @override
  Future<void> unlink(String userId) => _client.unlinkGoogleHealth(userId);
}
