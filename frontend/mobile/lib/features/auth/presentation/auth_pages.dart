import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:octosense/l10n/app_localizations.dart';

import '../../../app/theme/app_tokens.dart';
import '../../../app/widgets/octosense_logo.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/di/injection.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _signingIn = false;

  Future<void> _signInWithGoogle() async {
    if (_signingIn) return;
    setState(() => _signingIn = true);

    try {
      final result = await getIt<AuthService>().signInWithGoogle();
      if (!mounted) return;

      if (result == null) {
        setState(() => _signingIn = false);
        return;
      }

      context.go('/onboarding');
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _signingIn = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _signingIn = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.unexpectedError(e)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.primaryContainer.withValues(alpha: 0.28),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 30),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  children: [
                    Semantics(
                      header: true,
                      child: OctoSenseLogo(
                        size: 190,
                        showWordmark: true,
                        animate: !MediaQuery.of(context).disableAnimations,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      l10n.signInTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.4,
                        height: 1.02,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Text(
                      l10n.signInSubtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            LucideIcons.heartPulse,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              l10n.healthEstimateNote,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    FilledButton(
                      onPressed: _signingIn ? null : _signInWithGoogle,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      child: _signingIn
                          ? const SizedBox(
                              width: 23,
                              height: 23,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const _GoogleMark(),
                                const SizedBox(width: 12),
                                Text(l10n.signInGoogle),
                              ],
                            ),
                    ),
                    const SizedBox(height: 13),
                    Text(
                      l10n.accountAccessNote,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        shape: BoxShape.circle,
      ),
      child: Text(
        'G',
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: AppTokens.brandDeep,
        ),
      ),
    );
  }
}
