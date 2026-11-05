import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:octosense/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/app_tokens.dart';
import '../../../core/di/injection.dart';
import '../../../core/health/health_sync_service.dart';
import '../domain/entities/trends_snapshot.dart';
import 'bloc/trends_cubit.dart';
import 'bloc/trends_state.dart';

class TrendsPage extends StatelessWidget {
  const TrendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TrendsCubit>()..load(),
      child: const _TrendsView(),
    );
  }
}

class _TrendsView extends StatelessWidget {
  const _TrendsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: BlocBuilder<TrendsCubit, TrendsState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.read<TrendsCubit>().load(
                        period: state.period,
                      ),
                      child: Text(AppLocalizations.of(context)!.tryAgain),
                    ),
                  ],
                ),
              ),
            );
          }

          final snapshot = state.snapshot;
          if (snapshot == null) {
            return const SizedBox.shrink();
          }

          return RefreshIndicator(
            onRefresh: () async {
              try {
                if (getIt.isRegistered<HealthSyncService>()) {
                  await getIt<HealthSyncService>().syncTodayData();
                }
              } catch (_) {}
              if (context.mounted) {
                await context.read<TrendsCubit>().load(period: state.period);
              }
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(
                        AppLocalizations.of(context)!.trends,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.45,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        AppLocalizations.of(context)!.seeWhatChanged,
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.daysWithDataLabel(snapshot.daysWithData),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _PeriodSelector(
                        period: state.period,
                        onSelected: context.read<TrendsCubit>().selectPeriod,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _TrendMetric(
                              icon: LucideIcons.heartPulse,
                              label: 'FC',
                              primaryValue:
                                  snapshot.averageHeartRateBpm
                                      ?.round()
                                      .toString() ??
                                  '—',
                              primaryUnit: 'bpm',
                              secondaryLabel: AppLocalizations.of(
                                context,
                              )!.averagePerDay,
                              accent: AppTokens.heart,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TrendMetric(
                              icon: LucideIcons.footprints,
                              label: AppLocalizations.of(context)!.steps,
                              primaryValue: snapshot.totalSteps == null
                                  ? '—'
                                  : _fmtInt(
                                      context,
                                      snapshot.totalSteps!.round(),
                                    ),
                              primaryUnit: AppLocalizations.of(
                                context,
                              )!.periodTotal,
                              secondaryLabel: snapshot.averageSteps == null
                                  ? null
                                  : '${_fmtInt(context, snapshot.averageSteps!.round())} ${AppLocalizations.of(context)!.averagePerDay}',
                              accent: AppTokens.activity,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _TrendMetric(
                              icon: LucideIcons.moon,
                              label: AppLocalizations.of(context)!.sleep,
                              primaryValue: snapshot.totalSleepLabel ?? '—',
                              primaryUnit: AppLocalizations.of(
                                context,
                              )!.periodTotal,
                              secondaryLabel: snapshot.averageSleepLabel == null
                                  ? null
                                  : '${snapshot.averageSleepLabel} ${AppLocalizations.of(context)!.averagePerDay}',
                              accent: AppTokens.sleep,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TrendMetric(
                              icon: LucideIcons.flame,
                              label: AppLocalizations.of(context)!.calories,
                              primaryValue: snapshot.totalCalories == null
                                  ? '—'
                                  : _fmtInt(
                                      context,
                                      snapshot.totalCalories!.round(),
                                    ),
                              primaryUnit: 'kcal',
                              secondaryLabel: snapshot.averageCalories == null
                                  ? null
                                  : '${_fmtInt(context, snapshot.averageCalories!.round())} ${AppLocalizations.of(context)!.averagePerDay}',
                              accent: AppTokens.recovery,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _TrendChart(snapshot: snapshot)
                          .animate()
                          .fadeIn(duration: 350.ms)
                          .slideY(begin: 0.03, end: 0),
                      const SizedBox(height: 18),
                      _InsightCard(caption: snapshot.sourceCaption),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _fmtInt(BuildContext context, int value) {
    return value.toString();
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.period, required this.onSelected});

  final TrendsPeriod period;
  final ValueChanged<TrendsPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Row(
        children: [
          for (final item in TrendsPeriod.values)
            Expanded(
              child: InkWell(
                onTap: () => onSelected(item),
                borderRadius: BorderRadius.circular(12),
                child: _PeriodButton(
                  label: switch (item) {
                    TrendsPeriod.days7 => AppLocalizations.of(context)!.days7,
                    TrendsPeriod.days30 => AppLocalizations.of(context)!.days30,
                    TrendsPeriod.days90 => AppLocalizations.of(context)!.days90,
                  },
                  selected: period == item,
                  textColor: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  const _PeriodButton({
    required this.label,
    required this.selected,
    this.textColor,
  });

  final String label;
  final bool selected;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.11)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: selected ? Theme.of(context).colorScheme.primary : textColor,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _TrendMetric extends StatelessWidget {
  const _TrendMetric({
    required this.icon,
    required this.label,
    required this.primaryValue,
    required this.primaryUnit,
    required this.accent,
    this.secondaryLabel,
  });

  final IconData icon;
  final String label;
  final String primaryValue;
  final String primaryUnit;
  final String? secondaryLabel;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 148,
      padding: const EdgeInsets.all(14),
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
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 16),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: primaryValue,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                if (primaryUnit.isNotEmpty)
                  TextSpan(
                    text: ' $primaryUnit',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (secondaryLabel != null) ...[
            const SizedBox(height: 3),
            Text(
              secondaryLabel!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.snapshot});

  final TrendsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final series = snapshot.heartRateSeries;
    final spots = [
      for (var i = 0; i < series.length; i++)
        FlSpot(i.toDouble(), series[i].bpm),
    ];

    return Container(
      height: 280,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.heartRateChartTitle,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 3),
          Text(
            snapshot.sourceCaption,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: spots.length < 2
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.noHeartRateMeasurements,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: (spots.length - 1).toDouble(),
                      minY: 50,
                      maxY: 140,
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval: 20,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: theme.colorScheme.outlineVariant.withValues(
                            alpha: 0.35,
                          ),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: const FlTitlesData(
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.25,
                          color: AppTokens.brand,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTokens.brand.withValues(alpha: 0.15),
                                AppTokens.brand.withValues(alpha: 0.01),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.caption});

  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTokens.brand.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTokens.brand.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.sparkles,
              color: AppTokens.brand,
              size: 19,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.periodAnalysis,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  caption,
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
