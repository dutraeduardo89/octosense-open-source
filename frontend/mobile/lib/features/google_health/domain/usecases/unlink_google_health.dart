import '../repositories/google_health_repository.dart';

class UnlinkGoogleHealth {
	const UnlinkGoogleHealth(this._repository);

	final GoogleHealthRepository _repository;

	Future<void> call(String userId) => _repository.unlink(userId);
}
