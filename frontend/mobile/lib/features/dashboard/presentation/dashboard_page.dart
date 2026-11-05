import 'package:flutter/material.dart';
import 'package:octosense/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/accessibility/app_preferences.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/widgets/octosense_logo.dart';
import '../../../core/di/injection.dart';
import '../../../core/health/health_sync_service.dart';
import '../../../core/network/octosense_api_client.dart';
import '../domain/entities/dashboard_snapshot.dart';
import 'bloc/dashboard_cubit.dart';
import 'bloc/dashboard_state.dart';
import 'widgets/heart_rate_chart.dart';
import 'widgets/metric_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DashboardCubit>()..load(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView>
    with WidgetsBindingObserver {
  bool _celebrationScheduled = false;
  final _feedbackKey = GlobalKey<_FeedbackCardState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Quando o app volta do background, recarrega em silencio.
    // Corrige o bug de "tela de erro" ao reabrir: o refresh silencioso
    // nao sobrescreve estado bom, e ao voltar forca um novo fetch.
    if (state == AppLifecycleState.resumed) {
      context.read<DashboardCubit>().load(silent: true);
    }
  }

  Future<void> _maybeCelebrateSteps(int? steps) async {
    if (_celebrationScheduled || steps == null || steps < 10000) return;
    _celebrationScheduled = true;
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final dayKey = '${now.year}-${now.month}-${now.day}';
    final key = 'ui.celebrated.10k.$dayKey';
    if (prefs.getBool(key) ?? false) return;
    await prefs.setBool(key, true);
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Confetti.launch(
        context,
        options: const ConfettiOptions(particleCount: 80, spread: 70, y: 0.55),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage != null) {
            return _ErrorState(
              message: state.errorMessage!,
              onRetry: () => context.read<DashboardCubit>().load(),
            );
          }

          final snapshot = state.snapshot;
          if (snapshot == null) {
            return const SizedBox.shrink();
          }

          _maybeCelebrateSteps(snapshot.steps);

          return RefreshIndicator(
            // Pull-to-refresh: sincroniza HC -> backend e recarrega.
            onRefresh: () async {
              try {
                if (getIt.isRegistered<HealthSyncService>()) {
                  await getIt<HealthSyncService>().syncTodayData();
                }
              } catch (_) {}
              if (context.mounted) {
                await context.read<DashboardCubit>().load(silent: true);
              }
              // Regenera o insight com dados frescos a cada swipe.
              await _feedbackKey.currentState?.reload();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => [
                        const _Header(),
                        const SizedBox(height: 22),
                        _MetricsGrid(snapshot: snapshot),
                        const SizedBox(height: 18),
                        HeartRateChart(series: snapshot.heartRateSeries)
                            .animate(delay: 150.ms)
                            .fadeIn(duration: 380.ms)
                            .slideY(begin: 0.03, end: 0),
                        const SizedBox(height: 18),
                        _FeedbackCard(key: _feedbackKey),
                        const SizedBox(height: 18),
                        const _EducationCard(),
                      ][index],
                      childCount: 7,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final accessibilityLayout =
            constraints.maxWidth < 600 && appPreferences.textScale > 1.0;
        final columns = constraints.maxWidth >= 1050
            ? 4
            : accessibilityLayout
            ? 1
            : 2;
        const gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        final cards = [
          MetricCard(
            label: AppLocalizations.of(context)!.frequency,
            value: snapshot.heartRateBpm?.round().toString() ?? '—',
            unit: 'bpm',
            icon: LucideIcons.heartPulse,
            accent: AppTokens.heart,
            caption: snapshot.heartRateBpm == null
                ? AppLocalizations.of(context)!.noMeasurement
                : AppLocalizations.of(context)!.now,
          ),
          MetricCard(
            label: AppLocalizations.of(context)!.steps,
            value: snapshot.steps?.toString() ?? '—',
            unit: '',
            icon: LucideIcons.footprints,
            accent: AppTokens.activity,
            caption: snapshot.steps == null
                ? AppLocalizations.of(context)!.noMeasurement
                : AppLocalizations.of(context)!.now,
          ),
          MetricCard(
            label: AppLocalizations.of(context)!.sleep,
            value: snapshot.sleepLabel ?? '—',
            unit: '',
            icon: LucideIcons.moon,
            accent: AppTokens.sleep,
            caption: snapshot.sleepLabel == null
                ? AppLocalizations.of(context)!.noRecord
                : AppLocalizations.of(context)!.now,
          ),
          MetricCard(
            label: AppLocalizations.of(context)!.activeCalories,
            value: snapshot.activeCaloriesLabel ?? '—',
            unit: snapshot.activeCaloriesLabel == null ? '' : 'kcal',
            icon: LucideIcons.flame,
            accent: AppTokens.recovery,
            caption: snapshot.activeCaloriesLabel == null
                ? AppLocalizations.of(context)!.noMeasurement
                : (snapshot.totalCaloriesLabel != null
                    ? 'Total ~${snapshot.totalCaloriesLabel} kcal'
                    : AppLocalizations.of(context)!.now),
          ),
          MetricCard(
            label: 'SpO₂',
            value: snapshot.oxygenLabel ?? '—',
            unit: snapshot.oxygenLabel == null ? '' : '%',
            icon: LucideIcons.droplets,
            accent: AppTokens.sleep,
            caption: snapshot.oxygenLabel == null
                ? AppLocalizations.of(context)!.noMeasurement
                : AppLocalizations.of(context)!.now,
          ),
        ];

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < cards.length; i++)
              SizedBox(
                width: width,
                child: cards[i]
                    .animate(
                      delay: (55 * i).ms,
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.04, end: 0)
                    .scaleXY(begin: 1, end: 1.012, duration: 1500.ms),
              ),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OCTOSENSE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.45,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                AppLocalizations.of(context)!.dashboardTitle,
                style: theme.textTheme.headlineMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeedbackCard extends StatefulWidget {
  const _FeedbackCard({super.key});

  @override
  State<_FeedbackCard> createState() => _FeedbackCardState();
}

class _FeedbackCardState extends State<_FeedbackCard> {
  static const _cacheKey = 'ai.feedback.7d';
  static const _timeKey = 'ai.feedback.7d.generatedAt';

  String? _insight;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  /// Forca regeneracao quando chamado pelo pull-to-refresh.
  Future<void> reload() async {
    if (_loading) return;
    await _loadFeedback(force: true);
  }

  Future<void> _loadFeedback({bool force = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    final generatedAt = prefs.getInt(_timeKey);
    final fresh =
        generatedAt != null &&
        DateTime.now().difference(
              DateTime.fromMillisecondsSinceEpoch(generatedAt),
            ) <
            const Duration(minutes: 10);

    if (!force && cached != null && cached.isNotEmpty && fresh) {
      if (!mounted) return;
      setState(() {
        _insight = cached;
        _loading = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final insight = await getIt<OctoSenseApiClient>().getWeeklyFeedback();
      if (!mounted) return;
      await prefs.setString(_cacheKey, insight);
      await prefs.setInt(_timeKey, DateTime.now().millisecondsSinceEpoch);
      setState(() {
        _insight = insight;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _insight = cached;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.sparkles,
                  color: theme.colorScheme.primary,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.weeklyInsight,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: l10n.refreshInsight,
                onPressed: _loading ? null : () => _loadFeedback(force: true),
                icon: const Icon(LucideIcons.refreshCw, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading)
            Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Container(
                      height: 14,
                      width: MediaQuery.sizeOf(context).width * 0.62,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(
                  duration: 1400.ms,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                )
          else
            Text(
              _insight ?? l10n.feedbackUnavailable,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          const SizedBox(height: 10),
          Text(
            l10n.feedbackDisclaimer,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _EducationCard extends StatelessWidget {
  const _EducationCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surfaceContainerLow,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.24),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OctoSenseLogo(size: 52, animate: true),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.aiInsightLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.whyHeartAccelerates,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.healthEstimateNote,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    color: theme.colorScheme.onSurfaceVariant,
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context)!.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
