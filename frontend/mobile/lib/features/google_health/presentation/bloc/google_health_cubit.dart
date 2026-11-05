import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/session/user_session.dart';
import '../../domain/entities/google_health_link.dart';
import '../../domain/usecases/get_google_health_link_status.dart';
import '../../domain/usecases/start_google_health_link.dart';
import '../../domain/usecases/unlink_google_health.dart';
import 'google_health_state.dart';

class GoogleHealthCubit extends Cubit<GoogleHealthState> {
  GoogleHealthCubit(
    this._startLink,
    this._activeLink,
    this._unlink,
    this._session,
  ) : super(const GoogleHealthState());

  final StartGoogleHealthLink _startLink;
  final GetGoogleHealthLinkStatus _activeLink;
  final UnlinkGoogleHealth _unlink;
  final UserSession _session;

  Future<Uri?> startLink() async {
    emit(const GoogleHealthState(status: GoogleHealthStatus.busy));
    try {
      final uri = await _startLink();
      emit(const GoogleHealthState());
      return uri;
    } catch (_) {
      emit(
        const GoogleHealthState(
          status: GoogleHealthStatus.error,
          errorMessage:
              'Não foi possível iniciar o vínculo com o Google Health.',
        ),
      );
      return null;
    }
  }

  Future<GoogleHealthLink?> confirmLink({bool quiet = false}) async {
    if (!quiet) {
      emit(const GoogleHealthState(status: GoogleHealthStatus.busy));
    }
    try {
      final link = await _activeLink();
      await _session.setUserId(link.userId);
      emit(const GoogleHealthState());
      return link;
    } catch (_) {
      if (quiet) {
        emit(const GoogleHealthState());
        return null;
      }
      emit(
        const GoogleHealthState(
          status: GoogleHealthStatus.error,
          errorMessage:
              'Não encontramos a conta Google. Conclua o consentimento e tente de novo.',
        ),
      );
      return null;
    }
  }

  Future<bool> unlink() async {
    final userId = _session.userId;
    if (userId == null || userId.isEmpty) {
      return true;
    }

    emit(const GoogleHealthState(status: GoogleHealthStatus.busy));
    try {
      await _unlink(userId);
      await _session.clear();
      emit(const GoogleHealthState());
      return true;
    } catch (_) {
      emit(
        const GoogleHealthState(
          status: GoogleHealthStatus.error,
          errorMessage: 'Não foi possível desvincular o Google Health.',
        ),
      );
      return false;
    }
  }
}
