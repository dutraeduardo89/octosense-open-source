import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/app_tokens.dart';
import '../../domain/entities/dashboard_snapshot.dart';

/// Gráfico de frequência cardíaca do dia.
class HeartRateChart extends StatelessWidget {
  const HeartRateChart({super.key, required this.series});

  final List<HeartRateSample> series;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spots = <FlSpot>[
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
          Text('Frequência cardíaca', style: theme.textTheme.titleMedium),
          const SizedBox(height: 3),
          Text(
            spots.length < 2 ? 'Sem medições hoje' : 'Ao longo do dia',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: spots.length < 2
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.heartPulse,
                          size: 32,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nenhuma medição ainda hoje',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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
