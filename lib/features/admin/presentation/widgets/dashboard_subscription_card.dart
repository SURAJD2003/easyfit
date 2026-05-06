import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/analytics_entity.dart';

class DashboardSubscriptionCard extends StatelessWidget {
  final AnalyticsEntity analytics;

  const DashboardSubscriptionCard({
    super.key,
    required this.analytics,
  });

  static const Color _accent = Color(0xFFFF6B00);
  static const Color _cardColor = Color(0xFF1A1A1A);
  static const Color _mutedColor = Color(0xFF3A3A3A);

  @override
  Widget build(BuildContext context) {
    final total = analytics.totalSubscriptions;
    final freePercent =
        total == 0 ? 0.0 : (analytics.freeUsers / total) * 100;
    final premiumPercent =
        total == 0 ? 0.0 : (analytics.premiumUsers / total) * 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Subscription Breakdown',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF252525),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: const Row(
                  children: [
                    Text(
                      'All Time',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: _accent,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 45,
                        startDegreeOffset: -90,
                        sections: [
                          PieChartSectionData(
                            value: analytics.freeUsers.toDouble(),
                            color: _accent,
                            radius: 16,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: analytics.premiumUsers == 0
                                ? 0.0001
                                : analytics.premiumUsers.toDouble(),
                            color: _mutedColor,
                            radius: 16,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$total',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Total\nSubscriptions',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _LegendRow(
                      color: _accent,
                      label: 'Free Users',
                      count: analytics.freeUsers,
                      percent: freePercent,
                      percentColor: _accent,
                    ),
                    const SizedBox(height: 20),
                    _LegendRow(
                      color: _mutedColor,
                      label: 'Premium Users',
                      count: analytics.premiumUsers,
                      percent: premiumPercent,
                      percentColor: Colors.white54,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  final double percent;
  final Color percentColor;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.count,
    required this.percent,
    required this.percentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${percent.toStringAsFixed(0)}%',
              style: TextStyle(
                color: percentColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}