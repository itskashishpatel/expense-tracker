import 'dart:math';

import 'package:expenses_tracker/utils/formatters.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// One bar of the chart (a day or a month).
class ChartBucket {
  final String label; // text under the bar ('' hides it)
  final String tooltipLabel; // shown when the bar is tapped
  double total;

  ChartBucket({required this.label, required this.tooltipLabel, this.total = 0});
}

/// Bar chart driven entirely by the [buckets] it is given - the scale of the
/// Y axis, the labels and the bar heights all adapt to the user's data.
class MyChart extends StatelessWidget {
  final List<ChartBucket> buckets;
  final String currency;

  const MyChart({super.key, required this.buckets, required this.currency});

  /// Picks a "nice" axis step (1, 2, 5 x 10^n) so there are ~4 grid labels.
  static double niceInterval(double maxValue) {
    if (maxValue <= 0) return 25;
    final raw = maxValue / 4;
    final magnitude = pow(10, (log(raw) / ln10).floor()).toDouble();
    final n = raw / magnitude;
    final step = n <= 1 ? 1 : (n <= 2 ? 2 : (n <= 5 ? 5 : 10));
    return step * magnitude;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxValue = buckets.fold<double>(0, (m, b) => max(m, b.total));
    final interval = niceInterval(maxValue);
    // One step of headroom above the tallest bar.
    final maxY = maxValue <= 0
        ? interval * 4
        : (maxValue / interval).floor() * interval + interval;

    final barWidth = buckets.length > 20 ? 6.0 : (buckets.length > 8 ? 14.0 : 18.0);

    final labelStyle = TextStyle(
      color: scheme.outline,
      fontWeight: FontWeight.bold,
      fontSize: buckets.length > 8 ? 11 : 13,
    );

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final b = buckets[group.x];
              return BarTooltipItem(
                '${b.tooltipLabel}\n${formatMoney(b.total, currency)}',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= buckets.length) return const SizedBox.shrink();
                return SideTitleWidget(
                  meta: meta,
                  space: 8,
                  child: Text(buckets[i].label, style: labelStyle),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: interval,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                space: 4,
                child: Text(formatCompact(value), style: labelStyle),
              ),
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < buckets.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: buckets[i].total,
                  width: barWidth,
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [scheme.primary, scheme.secondary, scheme.tertiary],
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: scheme.outline.withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
