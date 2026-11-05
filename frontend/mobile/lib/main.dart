import 'dart:async';

import 'package:flutter/material.dart';

import 'app/accessibility/app_preferences.dart';
import 'app/octosense_app.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/app_tokens.dart';
import 'app/widgets/octosense_logo.dart';
import 'core/di/injection.dart';
import 'core/session/user_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  await getIt<UserSession>().restore();
  await appPreferences.load();
  runApp(const _BootstrapApp());
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp();

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return const OctoSenseApp();

    final theme = AppTheme.dark();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Scaffold(
        backgroundColor: AppTokens.brandDeep,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTokens.brandDeep,
                AppTokens.brandDeep.withValues(alpha: 0.94),
                AppTokens.brand,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Semantics(
              label: 'OctoSense',
              image: true,
              child: const OctoSenseLogo(
                size: 235,
                showWordmark: true,
                animate: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
