import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/accessibility/app_preferences.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/widgets/octosense_logo.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/di/injection.dart';
import '../../../core/health/health_connect_service.dart';
import '../../../core/network/octosense_api_client.dart';
import '../../../core/session/user_session.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.surfaceContainerLow,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
              ),
            ),
            child: Row(
              children: [
                const OctoSenseLogo(size: 62, animate: true),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.settingsPremiumTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.settingsPremiumSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AppLocalizations.of(context)!.yourOctoSense,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 5),
          Text(
            AppLocalizations.of(context)!.settingsSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),

          _SettingsItem(
            icon: LucideIcons.user,
            title: AppLocalizations.of(context)!.account,
            subtitle: AppLocalizations.of(context)!.accountSubtitle,
            onTap: () => context.push('/settings/account'),
          ),
          _SettingsItem(
            icon: LucideIcons.accessibility,
            title: AppLocalizations.of(context)!.accessibility,
            subtitle: AppLocalizations.of(context)!.accessibilitySubtitle,
            onTap: () => context.push('/settings/accessibility'),
          ),
          _SettingsItem(
            icon: LucideIcons.shield,
            title: AppLocalizations.of(context)!.privacy,
            subtitle: AppLocalizations.of(context)!.privacySubtitle,
            onTap: () => context.push('/settings/privacy'),
          ),
          _SettingsItem(
            icon: LucideIcons.circleHelp,
            title: AppLocalizations.of(context)!.help,
            subtitle: AppLocalizations.of(context)!.helpSubtitle,
            onTap: () => context.push('/settings/help'),
          ),
          _SettingsItem(
            icon: LucideIcons.info,
            title: AppLocalizations.of(context)!.about,
            subtitle: AppLocalizations.of(context)!.aboutSubtitle,
            onTap: () => context.push('/settings/about'),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: title,
      hint: subtitle,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.65,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTokens.brand.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: AppTokens.brand, size: 20),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 19,
                    color: theme.colorScheme.onSurfaceVariant,
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

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  bool _signingOut = false;
  bool _deleting = false;

  Future<void> _confirmDeleteAccount() async {
    if (_deleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteAccountQuestion),
        content: const Text(
          'Isso apaga sua conta, todas as suas leituras e desconecta você '
          'de todos os aparelhos. Não tem como desfazer.\n\n'
          'Tem certeza?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTokens.heart),
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.deleteEverything),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);

    try {
      // 1. Apaga no backend
      await getIt<OctoSenseApiClient>().deleteAccount();

      // 2. Limpa sessão local (tokens, userId, flags)
      await getIt<AuthService>().signOut();

      // 3. Marca flag: próximo login deve mostrar PermissionsPage
      //    (mesmo se HC já estiver autorizado no Android).
      await getIt<UserSession>().markFreshAfterDelete();

      if (!mounted) return;
      // 4. Vai pro welcome
      context.go('/welcome');
    } catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorDeleteAccount(e)),
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  Future<void> _confirmSignOut() async {
    if (_signingOut) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.signOutQuestion),
        content: const Text(
          'Você voltará para a tela de entrada. Os tokens serão apagados '
          'deste aparelho.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.signOut),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _signingOut = true);
    try {
      await getIt<AuthService>().signOut();
    } catch (_) {
      // Ignora falhas de rede — o importante é limpar o estado local.
    }
    if (mounted) context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userSession = getIt<UserSession>();
    final email = userSession.userId;
    final isAuthenticated = userSession.isAuthenticated;

    return _SettingsDetailScaffold(
      title: AppLocalizations.of(context)!.account,
      subtitle: 'Gerencie sua conta OctoSense.',
      icon: LucideIcons.user,
      children: [
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTokens.brand.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(LucideIcons.user, color: AppTokens.brand),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAuthenticated ? 'Sessão ativa' : 'Sem sessão',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email ?? 'Nenhuma conta vinculada',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Material(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _signingOut ? null : _confirmSignOut,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _signingOut
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        )
                      : const Icon(LucideIcons.logOut, color: AppTokens.brand),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.signOut,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Voltar para a tela de entrada.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.chevronRight, size: 19),
                ],
              ),
            ),
          ),
        ),

        Material(
          color: AppTokens.heart.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _deleting ? null : _confirmDeleteAccount,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _deleting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        )
                      : const Icon(LucideIcons.trash2, color: AppTokens.heart),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.deleteAccount,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Apaga permanentemente sua conta e todos os dados. '
                          'Esta ação não pode ser desfeita.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.chevronRight, size: 19),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DevicesSettingsPage extends StatelessWidget {
  const DevicesSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _SettingsDetailScaffold(
      title: l10n.devicesSources,
      subtitle: l10n.healthConnectTodaySource,
      icon: LucideIcons.watch,
      children: [
        const _HealthConnectCard(),
        const SizedBox(height: 14),
        _ProductInfoCard(
          icon: LucideIcons.radioTower,
          title: l10n.dashboardSourceTitle,
          text: l10n.connectHealthConnect,
        ),
        const SizedBox(height: 14),
        _ProductInfoCard(
          icon: LucideIcons.fingerprint,
          title: l10n.privacy,
          text: l10n.premiumSecurityNote,
        ),
      ],
    );
  }
}

class _ProductInfoCard extends StatelessWidget {
  const _ProductInfoCard({
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
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

class AccessibilitySettingsPage extends StatelessWidget {
  const AccessibilitySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appPreferences,
      builder: (context, _) {
        final theme = Theme.of(context);

        return _SettingsDetailScaffold(
          title: AppLocalizations.of(context)!.accessibility,
          subtitle: 'Adapte o OctoSense às suas necessidades.',
          icon: LucideIcons.accessibility,
          children: [
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.appearance,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Escolha como o OctoSense deve aparecer.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppThemeMode.values.map((mode) {
                      return ChoiceChip(
                        avatar: Icon(mode.icon, size: 18),
                        label: Text(switch (mode) {
                          AppThemeMode.system => AppLocalizations.of(
                            context,
                          )!.system,
                          AppThemeMode.light => AppLocalizations.of(
                            context,
                          )!.light,
                          AppThemeMode.dark => AppLocalizations.of(
                            context,
                          )!.dark,
                        }),
                        selected: appPreferences.themeMode == mode,
                        onSelected: (_) {
                          appPreferences.setThemeMode(mode);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.textSize,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'O tamanho escolhido é aplicado em todo o OctoSense.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppTextSize.values.map((size) {
                      return ChoiceChip(
                        label: Text(switch (size) {
                          AppTextSize.standard => AppLocalizations.of(
                            context,
                          )!.standard,
                          AppTextSize.large => AppLocalizations.of(
                            context,
                          )!.large,
                          AppTextSize.extraLarge => AppLocalizations.of(
                            context,
                          )!.extraLarge,
                        }),
                        selected: appPreferences.textSize == size,
                        onSelected: (_) {
                          appPreferences.setTextSize(size);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),


            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.colorVision,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppLocalizations.of(context)!.colorVisionDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    AppLocalizations.of(context)!.colorVisionAccessibleHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        [
                          (
                            AppColorVisionMode.standard,
                            AppLocalizations.of(context)!.colorVisionStandard,
                          ),
                          (
                            AppColorVisionMode.protanopia,
                            AppLocalizations.of(context)!.colorVisionProtanopia,
                          ),
                          (
                            AppColorVisionMode.deuteranopia,
                            AppLocalizations.of(
                              context,
                            )!.colorVisionDeuteranopia,
                          ),
                          (
                            AppColorVisionMode.tritanopia,
                            AppLocalizations.of(context)!.colorVisionTritanopia,
                          ),
                          (
                            AppColorVisionMode.achromatopsia,
                            AppLocalizations.of(
                              context,
                            )!.colorVisionAchromatopsia,
                          ),
                        ].map((entry) {
                          return ChoiceChip(
                            label: Text(entry.$2),
                            selected:
                                appPreferences.colorVisionMode == entry.$1,
                            onSelected: (_) =>
                                appPreferences.setColorVisionMode(entry.$1),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),

            SwitchListTile(
              value: appPreferences.highContrast,
              onChanged: appPreferences.setHighContrast,
              secondary: const Icon(LucideIcons.eye),
              title: Text(AppLocalizations.of(context)!.highContrast),
              subtitle: const Text(
                'Aumenta a separação visual entre elementos da interface.',
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              tileColor: theme.colorScheme.surfaceContainerLow,
            ),

            SwitchListTile(
              value: appPreferences.reduceMotion,
              onChanged: appPreferences.setReduceMotion,
              secondary: const Icon(LucideIcons.activity),
              title: Text(AppLocalizations.of(context)!.reduceMotion),
              subtitle: const Text(
                'Informa ao aplicativo que movimentos não essenciais '
                'devem ser reduzidos.',
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              tileColor: theme.colorScheme.surfaceContainerLow,
            ),


          ],
        );
      },
    );
  }
}

class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SettingsDetailScaffold(
      title: l10n.privacy,
      subtitle: l10n.privacyDescription,
      icon: LucideIcons.shield,
      children: [
        _InfoBlock(
          title: l10n.privacyWhatWeCollect,
          text: l10n.privacyWhatWeCollectText,
        ),
        _InfoBlock(
          title: l10n.privacyWhereItStays,
          text: l10n.privacyWhereItStaysText,
        ),
        _InfoBlock(
          title: l10n.privacyWhoCanSee,
          text: l10n.privacyWhoCanSeeText,
        ),
        _InfoBlock(
          title: l10n.privacyHowLong,
          text: l10n.privacyHowLongText,
        ),
        _InfoBlock(
          title: l10n.privacyYourRights,
          text: l10n.privacyYourRightsText,
        ),
        _InfoBlock(
          title: l10n.privacyDelete,
          text: l10n.privacyDeleteText,
        ),
        _InfoBlock(
          title: l10n.privacyContact,
          text: l10n.privacyContactText,
        ),
      ],
    );
  }
}

class HelpSettingsPage extends StatelessWidget {
  const HelpSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _SettingsDetailScaffold(
      title: AppLocalizations.of(context)!.help,
      subtitle: AppLocalizations.of(context)!.helpDescription,
      icon: LucideIcons.circleHelp,
      children: [
        _HelpTopic(
          title: AppLocalizations.of(context)!.howToStart,
          text: AppLocalizations.of(context)!.howToStartText,
        ),
        _HelpTopic(
          title: AppLocalizations.of(context)!.howToConnectWatch,
          text: AppLocalizations.of(context)!.howToConnectWatchText,
        ),
        _HelpTopic(
          title: AppLocalizations.of(context)!.whereNumbersComeFrom,
          text: AppLocalizations.of(context)!.whereNumbersComeFromText,
        ),
        _HelpTopic(
          title: AppLocalizations.of(context)!.diagnosisQuestion,
          text: AppLocalizations.of(context)!.diagnosisText,
        ),
      ],
    );
  }
}

class AboutSettingsPage extends StatelessWidget {
  const AboutSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _SettingsDetailScaffold(
      title: AppLocalizations.of(context)!.aboutTitle,
      subtitle: AppLocalizations.of(context)!.aboutSubtitle,
      icon: LucideIcons.info,
      children: [
        _InfoBlock(
          title: 'OctoSense',
          text: AppLocalizations.of(context)!.projectInfo,
        ),
        _InfoBlock(
          title: AppLocalizations.of(context)!.currentVersion,
          text: AppLocalizations.of(context)!.versionText,
        ),
        _InfoBlock(
          title: AppLocalizations.of(context)!.important,
          text: AppLocalizations.of(context)!.diagnosisText,
        ),
      ],
    );
  }
}

class _SettingsDetailScaffold extends StatelessWidget {
  const _SettingsDetailScaffold({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: AppLocalizations.of(context)!.back,
              onPressed: () => context.pop(),
              icon: const Icon(LucideIcons.arrowLeft),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTokens.brand.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTokens.brand),
          ),
          const SizedBox(height: 14),
          Text(title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ...children.expand((widget) => [widget, const SizedBox(height: 12)]),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.4,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpTopic extends StatelessWidget {
  const _HelpTopic({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      collapsedBackgroundColor: theme.colorScheme.surfaceContainerLow,
      title: Text(title, style: theme.textTheme.titleMedium),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.4,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// HEALTH CONNECT — autorizar / status / reautorizar
// ============================================================

/// Card em Ajustes > Dispositivos que mostra o estado REAL do Health Connect
/// e permite autorizar/reautorizar a qualquer momento.
///
/// Resolve 3 cenários do produto:
///   - Usuário tocou "Agora não" no onboarding e quer habilitar depois.
///   - Usuário revogou permissão nas configurações do Android.
///   - Usuário trocou de celular.
class _HealthConnectCard extends StatefulWidget {
  const _HealthConnectCard();

  @override
  State<_HealthConnectCard> createState() => _HealthConnectCardState();
}

class _HealthConnectCardState extends State<_HealthConnectCard> {
  bool _loading = true;
  bool _available = false;
  bool _granted = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
    });
    final hc = getIt<HealthConnectService>();
    final available = await hc.isAvailable;
    final granted = available ? await hc.hasRequiredPermissions() : false;
    if (!mounted) return;
    setState(() {
      _available = available;
      _granted = granted;
      _loading = false;
    });
  }

  Future<void> _toggleHealthConnect() async {
    if (_busy) return;
    setState(() => _busy = true);

    final hc = getIt<HealthConnectService>();

    if (!_granted) {
      final granted = await hc.requestPermissions();
      if (!mounted) return;
      await _refresh();
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted
                ? AppLocalizations.of(context)!.healthConnectAuthorized
                : 'Não foi possível autorizar o Health Connect.',
          ),
        ),
      );
      return;
    }

    setState(() => _busy = false);
    await _showDisableDialog();
  }

  Future<void> _showDisableDialog() async {
    final openSettings = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.disableHealthConnectQuestion),
        content: const Text(
          'Para desativar o Health Connect, revogue a permissão do OctoSense '
          'nas configurações do Android. Isso impede novas leituras locais.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(AppLocalizations.of(context)!.openSettings),
          ),
        ],
      ),
    );

    if (openSettings != true || !mounted) return;

    final uri = Uri(
      scheme: 'package',
      path: 'com.google.android.apps.healthdata',
    );
    final opened = await launchUrl(uri);

    if (!mounted) return;
    if (opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.healthConnectDisableInstruction,
          ),
        ),
      );
      await _refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.healthConnectSettingsError,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Textos por estado
    final (
      String title,
      String subtitle,
      IconData icon,
      Color color,
    ) = switch ((_available, _granted, _loading)) {
      (_, _, true) => (
        'Health Connect',
        'Verificando...',
        LucideIcons.loader,
        AppTokens.brand,
      ),
      (false, _, _) => (
        'Health Connect indisponível',
        'Este aparelho não suporta Health Connect. '
            'O app funciona só com dados do backend.',
        LucideIcons.wifiOff,
        theme.colorScheme.onSurfaceVariant,
      ),
      (true, true, _) => (
        AppLocalizations.of(context)!.disableHealthConnect,
        'Toque para revogar a permissão nas configurações do Android.',
        LucideIcons.checkCircle2,
        AppTokens.brand,
      ),
      (true, false, _) => (
        AppLocalizations.of(context)!.authorizeHealthConnect,
        'Permita que o OctoSense leia seus dados locais de saúde.',
        LucideIcons.heartPulse,
        AppTokens.heart,
      ),
    };

    final canTap = _available && !_loading && !_busy;

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: canTap ? _toggleHealthConnect : null,
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: _loading || _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (canTap)
                const Icon(LucideIcons.chevronRight, size: 19)
              else
                const SizedBox(width: 19),
            ],
          ),
        ),
      ),
    );
  }
}
