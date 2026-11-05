import 'package:equatable/equatable.dart';

import '../../domain/entities/trends_snapshot.dart';

class TrendsState extends Equatable {
  const TrendsState({
    this.loading = false,
    this.period = TrendsPeriod.days7,
    this.snapshot,
    this.errorMessage,
  });

  final bool loading;
  final TrendsPeriod period;
  final TrendsSnapshot? snapshot;
  final String? errorMessage;

  @override
  List<Object?> get props => [loading, period, snapshot, errorMessage];
}
