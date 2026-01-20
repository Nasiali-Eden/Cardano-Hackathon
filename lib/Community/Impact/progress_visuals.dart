import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../Models/contribution.dart';

class ProgressVisuals extends StatelessWidget {
  final List<Contribution> contributions;
  final int days;

  const ProgressVisuals({
    super.key,
    required this.contributions,
    this.days = 14,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final series = _dailySeries(contributions, days: days);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress (last $days days)',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 190,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 3,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= series.length)
                            return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${idx + 1}',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  minX: 0,
                  maxX: (series.length - 1).toDouble(),
                  minY: 0,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < series.length; i++)
                          FlSpot(i.toDouble(), series[i].toDouble()),
                      ],
                      isCurved: true,
                      barWidth: 3,
                      color: colorScheme.primary,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color:
                            colorScheme.primary.withAlpha((0.12 * 255).toInt()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Day 1 is the oldest day in the window. Values show points logged per day.',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  List<int> _dailySeries(List<Contribution> contributions,
      {required int days}) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));

    final buckets = List<int>.filled(days, 0);

    for (final c in contributions) {
      final dt = c.createdAt;
      if (dt == null) continue;
      final day = DateTime(dt.year, dt.month, dt.day);
      if (day.isBefore(start)) continue;
      final index = day.difference(start).inDays;
      if (index < 0 || index >= days) continue;
      buckets[index] += c.estimatedImpactPoints;
    }

    return buckets;
  }
}
