import 'package:equatable/equatable.dart';

enum GoogleHealthStatus { idle, busy, error }

class GoogleHealthState extends Equatable {
  const GoogleHealthState({
    this.status = GoogleHealthStatus.idle,
    this.errorMessage,
  });

  final GoogleHealthStatus status;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, errorMessage];
}
