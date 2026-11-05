import 'dart:async';

import 'package:flutter/material.dart';
import 'package:octosense/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/app_tokens.dart';
import '../../../core/di/injection.dart';
import '../../../core/health/health_connect_service.dart';
import '../../../core/session/user_session.dart';

/// Tela de consentimento do Health Connect.
///
/// Lógica de entrada (initState):
///   1. HC não disponível → home direto
///   2. HC já autorizado → home direto
///   3. Usuário já tocou "Agora não" → home direto (respeita)
///   4. Senão → mostra a tela
///
/// Se o usuário revogar permissão no Android depois, o passo 2 falha e a
/// tela reaparece — comportamento correto.
class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key, this.force = false});

  /// Quando true, mostra a tela mesmo se o usuário já tocou "Agora não".
  /// Usado pra reabrir a tela via Ajustes > Dispositivos.
  final bool force;

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  bool _checking = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decideRoute());
  }

  Future<void> _decideRoute() async {
    // Quando force=true (vindo de Ajustes > Dispositivos), mostra a tela
    // sem checar flags. O usuário quer autorizar deliberadamente.
    if (widget.force) {
      if (mounted) setState(() => _checking = false);
      return;
    }

    final hc = getIt<HealthConnectService>();
    final session = getIt<UserSession>();

    // 0. Conta acabou de ser excluída? Mostra a tela uma vez e consome a flag.
    // Necessário porque o HC no Android continua autorizado a nível de sistema,
    // então o passo 2 abaixo pularia a tela sem essa checagem.
    if (session.freshAfterDelete) {
      await session.clearFreshAfterDelete();
      if (mounted) setState(() => _checking = false);
      return;
    }

    // 1. HC não disponível neste aparelho?
    final available = await hc.isAvailable;
    if (!mounted) return;
    if (!available) {
      context.go('/');
      return;
    }

    // 2. HC já autorizado?
    final hasPerms = await hc.hasRequiredPermissions();
    if (!mounted) return;
    if (hasPerms) {
      context.go('/');
      return;
    }

    // 3. Usuário já tocou "Agora não"? Respeita.
    if (session.hcUserDeclined) {
      context.go('/');
      return;
    }

    // 4. Mostra a tela
    if (mounted) setState(() => _checking = false);
  }

  Future<void> _requestPermissions() async {
    if (_busy) return;
    setState(() => _busy = true);

    final hc = getIt<HealthConnectService>();

    try {
      final granted = await hc.requestPermissions();
      if (!mounted) return;

      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Permissão negada. Você pode conceder depois em '
              'Ajustes do Android → Health Connect.',
            ),
            duration: Duration(seconds: 6),
          ),
        );
      }
      if (widget.force) {
        if (mounted) context.pop();
      } else {
        context.go('/');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorRequestPermission(e))),
      );
      if (widget.force) {
        if (mounted) context.pop();
      } else {
        context.go('/');
      }
    }
  }

  Future<void> _skip() async {
    await getIt<UserSession>().markHcUserDeclined();
    if (!mounted) return;
    if (widget.force) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTokens.brandDeep, AppTokens.brand],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(21),
                      ),
                      child: const Icon(
                        LucideIcons.activity,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Conectar seus dados',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'O OctoSense lê passos, frequência cardíaca e calorias '
                    'do Health Connect do seu celular. É local e instantâneo.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 26),

                  const _Bullet(
                    icon: LucideIcons.smartphone,
                    title: 'Os dados ficam no aparelho',
                    text: 'Health Connect é local. Nada é enviado antes '
                        'de você escolher o que sincronizar.',
                  ),
                  const _Bullet(
                    icon: LucideIcons.refreshCw,
                    title: 'Você no controle',
                    text: 'Pode revogar a qualquer momento nas configurações '
                        'do Android ou em Ajustes → Dispositivos.',
                  ),
                  const _Bullet(
                    icon: LucideIcons.heartPulse,
                    title: 'Sem Health Connect?',
                    text: 'O app funciona só com dados do backend. '
                        'Você verá o histórico sincronizado, mas não leituras de hoje.',
                  ),

                  const SizedBox(height: 30),

                  FilledButton(
                    onPressed: _busy ? null : _requestPermissions,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          )
                        : Text(AppLocalizations.of(context)!.authorizeNow),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: _busy ? null : _skip,
                    child: Text(AppLocalizations.of(context)!.notNow),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTokens.brand.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTokens.brand, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
