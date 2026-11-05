import '../entities/dashboard_snapshot.dart';

/// Port for dashboard metrics loaded from the OctoSense API.
abstract class DashboardRepository {
  Future<DashboardSnapshot> getSnapshot();
}
