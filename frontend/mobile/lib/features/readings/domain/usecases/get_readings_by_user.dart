import '../entities/health_reading.dart';
import '../repositories/readings_repository.dart';

class GetReadingsByUser {
	const GetReadingsByUser(this._repository);

	final ReadingsRepository _repository;

	Future<List<HealthReading>> call(String userId) => _repository.getByUser(userId);
}
