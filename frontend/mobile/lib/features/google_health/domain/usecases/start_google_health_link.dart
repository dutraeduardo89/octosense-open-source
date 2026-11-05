import '../repositories/google_health_repository.dart';

class StartGoogleHealthLink {
  const StartGoogleHealthLink(this._repository);

  final GoogleHealthRepository _repository;

  Future<Uri> call() => _repository.authorizationUri();
}
