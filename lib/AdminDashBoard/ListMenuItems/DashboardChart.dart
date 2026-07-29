import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../Color/Colorclass.dart';
import 'DashboardTopBarAnimated.dart';


/// Bar chart card comparing each department's primary metric.
/// Add `fl_chart: ^0.68.0` to pubspec.yaml to use this.
///
/// Usage:
///   DashboardChartCard(deptCounts: deptCounts)
class DashboardChartCard extends StatefulWidget {
  final List<DeptCountItem> deptCounts;
  final String title;

  const DashboardChartCard({
    super.key,
    required this.deptCounts,
    this.title = "Department Overview",
  });

  @override
  State<DashboardChartCard> createState() => _DashboardChartCardState();
}

class _DashboardChartCardState extends State<DashboardChartCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _grow;
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _grow = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // Use the first metric of each department as the bar value.
  List<_Bar> get _bars => widget.deptCounts
      .where((d) => d.metrics.isNotEmpty)
      .map((d) => _Bar(d.title, d.metrics.first.value.toDouble(), d.color))
      .toList();

  @override
  Widget build(BuildContext context) {
    final bars = _bars;
    if (bars.isEmpty) return const SizedBox.shrink();

    final maxVal = bars.map((b) => b.value).fold<double>(0, (a, b) => a > b ? a : b);
    final safeMax = maxVal <= 0 ? 1.0 : maxVal * 1.25;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: C.primary, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: C.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: TextStyle(
                  color: C.textHigh,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 220,
            child: AnimatedBuilder(
              animation: _grow,
              builder: (context, _) {
                return BarChart(
                  BarChartData(
                    maxY: safeMax,
                    alignment: BarChartAlignment.spaceAround,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: safeMax / 4,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: Colors.black.withOpacity(.06),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 38,
                          interval: safeMax / 4,
                          getTitlesWidget: (value, meta) => Text(
                            _fmt(value),
                            style: TextStyle(
                              color: C.textLow ?? Colors.black45,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= bars.length) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                bars[i].label,
                                style: TextStyle(
                                  color: C.textHigh,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => Colors.black87,
                        getTooltipItem: (group, groupIdx, rod, rodIdx) => BarTooltipItem(
                          "${bars[group.x.toInt()].label}\n",
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
                          children: [
                            TextSpan(
                              text: _fmt(rod.toY),
                              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      touchCallback: (event, response) {
                        setState(() {
                          _touchedIndex = response?.spot?.touchedBarGroupIndex;
                        });
                      },
                    ),
                    barGroups: [
                      for (int i = 0; i < bars.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: bars[i].value * _grow.value,
                              color: _touchedIndex == i
                                  ? bars[i].color
                                  : bars[i].color.withOpacity(.85),
                              width: 22,
                              borderRadius: BorderRadius.circular(6),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: safeMax,
                                color: Colors.black.withOpacity(.03),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  String _fmt(num value) {
    if (value >= 1000000) return "${(value / 1000000).toStringAsFixed(1)}M";
    if (value >= 1000) return "${(value / 1000).toStringAsFixed(1)}K";
    return value.toInt().toString();
  }
}

class _Bar {
  final String label;
  final double value;
  final Color color;
  _Bar(this.label, this.value, this.color);
}