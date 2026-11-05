import '../entities/google_health_link.dart';

abstract interface class GoogleHealthRepository {
  Future<Uri> authorizationUri();

  Future<GoogleHealthLink> activeLink();

  Future<void> unlink(String userId);
}
