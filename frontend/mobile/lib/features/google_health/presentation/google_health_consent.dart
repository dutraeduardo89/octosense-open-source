import 'dart:async';

import 'package:flutter/material.dart';
import 'package:octosense/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injection.dart';
import '../domain/entities/google_health_link.dart';
import 'bloc/google_health_cubit.dart';

Future<GoogleHealthLink?> requestGoogleHealthConsent(BuildContext context) async {
  final cubit = getIt<GoogleHealthCubit>();
  final uri = await cubit.startLink();
  if (!context.mounted) {
    return null;
  }

  if (uri == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.googleConsentError),
      ),
    );
    return null;
  }

  var launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched) {
    launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
  }
  if (!context.mounted) {
    return null;
  }
  if (!launched) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.googleBrowserError),
      ),
    );
    return null;
  }

  final link = await showDialog<GoogleHealthLink>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _WaitingForGoogleDialog(cubit: cubit),
  );

  if (!context.mounted || link == null) {
    return null;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Vinculado como ${link.userId}. O worker importa as leituras.',
      ),
    ),
  );
  return link;
}

class _WaitingForGoogleDialog extends StatefulWidget {
  const _WaitingForGoogleDialog({required this.cubit});

  final GoogleHealthCubit cubit;

  @override
  State<_WaitingForGoogleDialog> createState() => _WaitingForGoogleDialogState();
}

class _WaitingForGoogleDialogState extends State<_WaitingForGoogleDialog>
    with WidgetsBindingObserver {
  Timer? _timer;
  var _closing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_tryConfirm());
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _tryConfirm());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _tryConfirm();
    }
  }

  Future<void> _tryConfirm() async {
    if (_closing) {
      return;
    }
    final link = await widget.cubit.confirmLink(quiet: true);
    if (link == null || !mounted || _closing) {
      return;
    }
    _closing = true;
    _timer?.cancel();
    Navigator.pop(context, link);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.waitingGoogle),
      content: const Text(
        'Conclua a autorização no navegador. O app volta sozinho quando o vínculo terminar.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
      ],
    );
  }
}
