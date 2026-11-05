import '../entities/google_health_link.dart';
import '../repositories/google_health_repository.dart';

class GetGoogleHealthLinkStatus {
  const GetGoogleHealthLinkStatus(this._repository);

  final GoogleHealthRepository _repository;

  Future<GoogleHealthLink> call() => _repository.activeLink();
}
