import 'package:equatable/equatable.dart';

import '../../domain/entities/dashboard_snapshot.dart';

class DashboardState extends Equatable {
  const DashboardState({
    this.loading = false,
    this.snapshot,
    this.errorMessage,
    this.tick = 0,
  });

  final bool loading;
  final DashboardSnapshot? snapshot;
  final String? errorMessage;

  /// Incrementa a cada refresh bem-sucedido. Forca o Equatable a
  /// reconhecer o novo estado como diferente mesmo que snapshot seja igual.
  final int tick;

  @override
  List<Object?> get props => [loading, snapshot, errorMessage, tick];
}