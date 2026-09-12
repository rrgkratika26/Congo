import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Color/Colorclass.dart';

class BomGraphSheet extends StatefulWidget {
  final List<Map<String, dynamic>> reports;
  const BomGraphSheet({required this.reports});

  @override
  State<BomGraphSheet> createState() => BomGraphSheetState();
}

class BomGraphSheetState extends State<BomGraphSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<String, int> _countByParty() {
    final map = <String, int>{};
    for (final item in widget.reports) {
      final party = (item["customer_name"] ?? "Unknown").toString();
      map[party] = (map[party] ?? 0) + 1;
    }
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(10)); // top 10 parties
  }

  Map<String, int> _countByDate() {
    final map = <String, int>{};
    for (final item in widget.reports) {
      final raw = item["todaY_DATE"]?.toString();
      if (raw == null) continue;
      final date = raw.split("T")[0];
      map[date] = (map[date] ?? 0) + 1;
    }
    final sorted = map.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key)); // chronological
    return Map.fromEntries(sorted);
  }

  String _shortDate(String isoDate) {
    final p = isoDate.split("-");
    return p.length == 3 ? "${p[2]}-${p[1]}" : isoDate;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "BOM Report Analytics",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TabBar(
              controller: _tabController,
              labelColor: C.warning,
              unselectedLabelColor: Colors.grey,
              indicatorColor: C.teal,
              tabs: const [
                Tab(text: "By Party"),
                Tab(text: "By Date"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildChart(_countByParty(), Colors.purple, byDate: false),
                  _buildChart(_countByDate(), const Color(0xFFEE7D00), byDate: true)],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChart(Map<String, int> data, Color barColor, {required bool byDate}) {
    if (data.isEmpty) return const Center(child: Text("No data"));

    final entries = data.entries.toList();
    final maxY = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
      child: BarChart(
        BarChartData(
          maxY: maxY + 1,
          barGroups: [
            for (int i = 0; i < entries.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: entries[i].value.toDouble(),
                    color: barColor,
                    width: 18,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 28),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: byDate ? 50 : 70,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= entries.length) return const SizedBox();
                  final label = byDate ? _shortDate(entries[idx].key) : entries[idx].key;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: byDate
                        ? Text(label, style: const TextStyle(fontSize: 9))
                        : Transform.rotate(
                      angle: -0.6,
                      child: Text(label, style: const TextStyle(fontSize: 9),
                          overflow: TextOverflow.ellipsis),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}