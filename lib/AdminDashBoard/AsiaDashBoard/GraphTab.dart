import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection; // 👈 agar intl mein hai
import 'package:shared_preferences/shared_preferences.dart';
import '../../Color/Colorclass.dart' hide TextDirection; // 👈 add
import '../../services/DashboardApiServices.dart' hide TextDirection; // 👈 add
import '../ListMenuItems/DashboardTopBarAnimated.dart'
    hide TextDirection; // 👈 add
import '../ListMenuItems/dashBoardMapper.dart' hide TextDirection;
import 'BagTypesGraph.dart';
import 'TopCustomer.dart';

class GraphTab extends StatefulWidget {
  final String unit;
  final String department;
  final bool isMobile;

  const GraphTab({
    super.key,
    required this.unit,
    required this.department,
    required this.isMobile,
  });

  @override
  State<GraphTab> createState() => _GraphTabState();
}

class PolarDeptValue {
  final String title;
  final num value;
  final Color color;
  const PolarDeptValue({
    required this.title,
    required this.value,
    required this.color,
  });
}

class _GraphTabState extends State<GraphTab> {
  List<PolarDeptValue> _polarData = [];
  bool _polarLoading = true;
  bool _showDailyProduction = false; // collapsed by default

  bool _showProductionTrend = false;
  bool _showInventorySummary = false;
  static const Map<String, Color> _polarColors = {
    'LOOM': Color(0xFFEC407A),
    'RMD': Color(0xFF7C6CE8),
    'LAMINATION': Color(0xFFF5A623),
    'CUTTING': Color(0xFF2FA88A),
    'WEBBING': Color(0xFFEF5350),
  };
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 6));

  DateTime toDate = DateTime.now();

  bool _isLoading = true;
  String? _error;

  List<_ProductionPoint> _productionPoints = [];
  static const Color rmdColor = Color(0xFF06B6D4);
  static const Color cuttingColor = Color(0xFFEE7D00);
  static const Color textDark = Color(0xFF1A1A2E);
  String unitName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant GraphTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.unit != widget.unit ||
        oldWidget.department != widget.department) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();

    unitName = prefs.getString('unit') ?? 'UNIT';
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = DashboardService();

      final days = toDate.difference(fromDate).inDays.clamp(0, 30) + 1;

      final dateList = List.generate(
        days,
        (index) => fromDate.add(Duration(days: index)),
      );

      final results = await Future.wait(
        dateList.map((date) async {
          final dayStr = DateFormat('yyyy-MM-dd').format(date);

          try {
            final summary = await service.getDashboard(
              unit: unitName,
              fromDate: dayStr,
              toDate: dayStr,
            );

            final departments = createDepartments(summary);
            final rmdDepartment = _findDepartment(departments, 'RMD');
            final rmdKg = _getRmdValue(rmdDepartment);

            final cuttingDepartment = _findDepartment(departments, 'CUTTING');

            final cuttingKg = _getCuttingKg(cuttingDepartment);

            debugPrint(
              'GRAPH $dayStr | '
              'RMD: $rmdKg | '
              'CUTTING PCS: $cuttingKg',
            );

            return _ProductionPoint(
              date: date,
              rmdKg: rmdKg,
              cuttingKg: cuttingKg,
            );
          } catch (e) {
            debugPrint(
              'Production graph failed for '
              '$dayStr: $e',
            );

            return _ProductionPoint(date: date, rmdKg: 0, cuttingKg: 0);
          }
        }),
      );

      if (!mounted) return;

      setState(() {
        _productionPoints = results;
        _isLoading = false;
      });
      _loadPolarSummary();
    } catch (e, stack) {
      debugPrint('Production graph error: $e');

      debugPrintStack(stackTrace: stack);

      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  num _getDepartmentValue(DeptCountItem? department, String deptName) {
    if (department == null || department.metrics.isEmpty) {
      return 0;
    }

    final name = deptName.trim().toUpperCase();

    // RMD → Net Weight KG
    if (name == 'RMD') {
      for (final metric in department.metrics) {
        final label = metric.label.trim().toUpperCase();

        if (label.contains('NET WEIGHT') ||
            label.contains('NET WT') ||
            label.contains('NETWEIGHT')) {
          return metric.value;
        }
      }
    }

    // For other departments:
    // take KG metric
    for (final metric in department.metrics) {
      final label = metric.label.trim().toUpperCase();

      if (label.contains('KG') ||
          label.contains('KGS') ||
          label.contains('KILOGRAM')) {
        return metric.value;
      }
    }

    // fallback
    return department.metrics.first.value;
  }
  Future<void> _loadPolarSummary() async {
    if (!mounted) return;
    setState(() => _polarLoading = true);

    try {
      final service = DashboardService();
      final summary = await service.getDashboard(
        unit: unitName.isNotEmpty ? unitName : widget.unit,
        fromDate: DateFormat('yyyy-MM-dd').format(fromDate),
        toDate: DateFormat('yyyy-MM-dd').format(toDate),
      );

      final departments = createDepartments(summary);
      final result = <PolarDeptValue>[];

      for (final key in _polarColors.keys) {
        final dept = _findDepartment(departments, key);

        if (dept == null || dept.metrics.isEmpty) {
          continue;
        }

        final value = _getDepartmentValue(dept, key);

        result.add(
          PolarDeptValue(
            title: key[0] + key.substring(1).toLowerCase(),
            value: value,
            color: _polarColors[key]!,
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _polarData = result;
        _polarLoading = false;
      });
    } catch (e) {
      debugPrint('Polar summary load error: $e');
      if (!mounted) return;
      setState(() => _polarLoading = false);
    }
  }

  DeptCountItem? _findDepartment(List<DeptCountItem> departments, String name) {
    try {
      return departments.firstWhere(
        (department) =>
            department.title.trim().toUpperCase() == name.trim().toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  num _getRmdValue(DeptCountItem? department) {
    if (department == null || department.metrics.isEmpty) {
      return 0;
    }

    for (final metric in department.metrics) {
      final label = metric.label.trim().toUpperCase();

      if (label.contains('NET WEIGHT') ||
          label.contains('NET WT') ||
          label.contains('NETWEIGHT')) {
        return metric.value;
      }
    }

    return 0;
  }

  num _getCuttingKg(DeptCountItem? department) {
    if (department == null || department.metrics.isEmpty) {
      return 0;
    }

    for (final metric in department.metrics) {
      final label = metric.label.trim().toUpperCase();

      if (label.contains('KG') ||
          label.contains('KGS') ||
          label.contains('KILOGRAM')) {
        return metric.value;
      }
    }

    return 0;
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: fromDate, end: toDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: const ColorScheme.light(primary: C.primary)),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      fromDate = picked.start;
      toDate = picked.end;
    });

    _loadData();
  }

  String _fmt(num value) {
    if (value == value.roundToDouble()) {
      return NumberFormat('#,##0').format(value);
    }
    return NumberFormat('#,##0.##').format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.brand50,
      body: RefreshIndicator(
        onRefresh: _loadData,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: EdgeInsets.symmetric(vertical: widget.isMobile ? 16 : 24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isMobile ? 16 : 24,
                ),

                child: Row(
                  children: [
                    // TITLE
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text(
                            'Production Analytics',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: textDark,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '${widget.unit} • RMD & Cutting',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: C.rmdColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // DATE
                    _dateRangeChip(),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ─────────────────────────────────────
              // LOADING
              // ─────────────────────────────────────
              if (_isLoading) ...[
                _loadingCard(),
              ]
              // ─────────────────────────────────────
              // ERROR
              // ─────────────────────────────────────
              else if (_error != null) ...[
                _errorCard(),
              ]
              // ─────────────────────────────────────
              // DATA
              // ─────────────────────────────────────
              else ...[
                _summaryCards(),

                const SizedBox(height: 16),

                _productionLineChart(),

                const SizedBox(height: 16),

                _dailyProductionList(),
                const SizedBox(height: 16),
                _polarAreaSection(),
                const SizedBox(height: 16),
                TopCustomersChart(isMobile: widget.isMobile),
                  const SizedBox(height: 16),

                  TopBagTypesChart(isMobile: widget.isMobile),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateRangeChip() {
    return InkWell(
      onTap: _pickDateRange,

      borderRadius: BorderRadius.circular(14),

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),

        decoration: BoxDecoration(
          color: C.primary.withOpacity(.10),

          borderRadius: BorderRadius.circular(14),

          border: Border.all(color: C.primary.withOpacity(.12)),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(Icons.calendar_month_rounded, size: 16, color: C.primary),

            const SizedBox(width: 6),

            Text(
              '${DateFormat('dd MMM').format(fromDate)}'
              ' - '
              '${DateFormat('dd MMM').format(toDate)}',

              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: C.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCards() {
    final totalRmd = _productionPoints.fold<num>(
      0,
      (sum, item) => sum + item.rmdKg,
    );

    final totalCutting = _productionPoints.fold<num>(
      0,
      (sum, item) => sum + item.cuttingKg,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 24),

      child: Row(
        children: [
          Expanded(
            child: _summaryCard(
              icon: Icons.inventory_2_rounded,
              title: 'RMD Production',
              value: _fmt(totalRmd),
              color: rmdColor,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: _summaryCard(
              icon: Icons.content_cut_rounded,
              title: 'Cutting PCS',
              value: _fmt(totalCutting),
              color: cuttingColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),

            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(icon, size: 20, color: color),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.black45,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _productionLineChart() {
    if (_productionPoints.isEmpty) {
      return _emptyCard('No production data available');
    }

    final maxRmd = _productionPoints
        .map((e) => e.rmdKg)
        .fold<num>(0, (a, b) => a > b ? a : b);

    final maxCutting = _productionPoints
        .map((e) => e.cuttingKg)
        .fold<num>(0, (a, b) => a > b ? a : b);

    final maxValue = maxRmd > maxCutting ? maxRmd : maxCutting;
    final chartMax = maxValue <= 0 ? 10.0 : maxValue.toDouble() * 1.20;
    final interval = chartMax / 5;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 24),
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tappable header ──
          InkWell(
            onTap: () =>
                setState(() => _showProductionTrend = !_showProductionTrend),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: C.primary.withOpacity(.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.show_chart_rounded,
                      color: C.warning,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Production Trend',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'RMD KG vs Cutting KG',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Colors.black45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _showProductionTrend ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Collapsible content ──
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _showProductionTrend
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _legendItem(color: rmdColor, label: 'RMD KG'),
                            const SizedBox(width: 22),
                            _legendItem(
                              color: cuttingColor,
                              label: 'Cutting KG',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: widget.isMobile ? 280 : 350,
                          child: LineChart(
                            LineChartData(
                              minY: 0,
                              maxY: chartMax,
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: interval,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.black.withOpacity(.07),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: AxisTitles(
                                  axisNameWidget: const Text(
                                    'KG',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  axisNameSize: 22,
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 48,
                                    interval: interval,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        _formatKg(value),
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black54,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  axisNameWidget: const Text(
                                    'Date',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  axisNameSize: 22,
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 38,
                                    interval: _xAxisInterval(),
                                    getTitlesWidget: (value, meta) {
                                      final index = value.round();
                                      if (index < 0 ||
                                          index >= _productionPoints.length) {
                                        return const SizedBox.shrink();
                                      }
                                      final date =
                                          _productionPoints[index].date;
                                      return SideTitleWidget(
                                        meta: meta,
                                        child: Text(
                                          DateFormat('dd MMM').format(date),
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1A1A2E),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              lineTouchData: LineTouchData(
                                enabled: true,
                                handleBuiltInTouches: true,
                                touchSpotThreshold: 25,
                                touchTooltipData: LineTouchTooltipData(
                                  getTooltipColor: (_) =>
                                      const Color(0xFF1A1A2E),
                                  tooltipPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  getTooltipItems: (spots) {
                                    return spots.map((spot) {
                                      final index = spot.x.round();
                                      if (index < 0 ||
                                          index >= _productionPoints.length) {
                                        return null;
                                      }
                                      final point = _productionPoints[index];
                                      final isRmd = spot.barIndex == 0;
                                      final label = isRmd
                                          ? 'RMD KG'
                                          : 'Cutting KG';
                                      return LineTooltipItem(
                                        '${DateFormat('dd MMM yyyy').format(point.date)}\n'
                                        '$label: ${_formatKg(spot.y)} KG',
                                        const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          height: 1.5,
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: List.generate(
                                    _productionPoints.length,
                                    (index) {
                                      return FlSpot(
                                        index.toDouble(),
                                        _productionPoints[index].rmdKg
                                            .toDouble(),
                                      );
                                    },
                                  ),
                                  isCurved: true,
                                  curveSmoothness: .20,
                                  color: rmdColor,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, bar, index) {
                                      return FlDotCirclePainter(
                                        radius: 4,
                                        color: rmdColor,
                                        strokeWidth: 2,
                                        strokeColor: Colors.white,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        rmdColor.withOpacity(.15),
                                        rmdColor.withOpacity(.01),
                                      ],
                                    ),
                                  ),
                                ),
                                LineChartBarData(
                                  spots: List.generate(
                                    _productionPoints.length,
                                    (index) {
                                      return FlSpot(
                                        index.toDouble(),
                                        _productionPoints[index].cuttingKg
                                            .toDouble(),
                                      );
                                    },
                                  ),
                                  isCurved: true,
                                  curveSmoothness: .20,
                                  color: cuttingColor,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, bar, index) {
                                      return FlDotCirclePainter(
                                        radius: 4,
                                        color: cuttingColor,
                                        strokeWidth: 2,
                                        strokeColor: Colors.white,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        cuttingColor.withOpacity(.12),
                                        cuttingColor.withOpacity(.01),
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
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  String _formatKg(num value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return NumberFormat('#,##0').format(value);
  }

  Widget _legendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,

      children: [
        Container(
          width: 10,
          height: 10,

          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),

        const SizedBox(width: 6),

        Text(
          label,

          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
      ],
    );
  }

  Widget _dailyProductionList() {
    if (_productionPoints.isEmpty) {
      return const SizedBox.shrink();
    }

    final points = [..._productionPoints].reversed.toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () =>
                setState(() => _showDailyProduction = !_showDailyProduction),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.table_rows_rounded,
                    size: 19,
                    color: textDark,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Daily Production',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                  ),
                  Text(
                    '${points.length} days',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.black38,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: _showDailyProduction ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Collapsible content ──
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _showDailyProduction
                ? Column(
                    children: [
                      const SizedBox(height: 12),
                      ...points.map((point) => _dailyRow(point)),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _dailyRow(_ProductionPoint point) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),

      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),

      decoration: BoxDecoration(
        color: Colors.grey.shade50,

        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        children: [
          // DATE
          SizedBox(
            width: 65,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  DateFormat('dd MMM').format(point.date),

                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),

                Text(
                  DateFormat('EEE').format(point.date),

                  style: const TextStyle(fontSize: 9, color: Colors.black45),
                ),
              ],
            ),
          ),

          // RMD
          Expanded(
            child: _productionValue(
              color: rmdColor,
              title: 'RMD KG',
              value: '${_fmt(point.rmdKg)} KG',
            ),
          ),

          // CUTTING
          Expanded(
            child: _productionValue(
              color: cuttingColor,
              title: 'CUT PCS',
              value: _fmt(point.cuttingKg),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productionValue({
    required Color color,
    required String title,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,

      children: [
        Container(
          width: 7,
          height: 7,

          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),

        const SizedBox(width: 5),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,

          children: [
            Text(
              title,

              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: Colors.black45,
              ),
            ),

            const SizedBox(height: 1),

            Text(
              value,

              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _loadingCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 24),

      height: widget.isMobile ? 350 : 420,

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 12),
        ],
      ),

      child: const Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
    );
  }

  Widget _errorCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 24),

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: Colors.red.withOpacity(.08),

              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 30,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Unable to load production data',

            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            _error ?? 'Something went wrong',

            textAlign: TextAlign.center,

            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),

          const SizedBox(height: 14),

          ElevatedButton.icon(
            onPressed: _loadData,

            icon: const Icon(Icons.refresh_rounded, size: 17),

            label: const Text('Retry'),

            style: ElevatedButton.styleFrom(
              backgroundColor: C.primary,
              foregroundColor: Colors.white,

              elevation: 0,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(String message) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 24),

      padding: const EdgeInsets.all(28),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),
      ),

      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 34,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 10),

            Text(
              message,

              style: const TextStyle(
                fontSize: 12,
                color: Colors.black45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _xAxisInterval() {
    final count = _productionPoints.length;

    if (count <= 7) {
      return 1;
    }

    if (count <= 14) {
      return 2;
    }

    if (count <= 21) {
      return 3;
    }

    return 5;
  }

  Widget _polarAreaSection() {
    if (_polarLoading) return _loadingCard();
    if (_polarData.isEmpty) return _emptyCard('No inventory summary available');

    final maxValue = _polarData
        .map((e) => e.value)
        .fold<num>(0, (a, b) => a > b ? a : b);
    final niceMax = _niceMax(maxValue);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tappable header ──
          InkWell(
            onTap: () =>
                setState(() => _showInventorySummary = !_showInventorySummary),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.pie_chart_rounded,
                    size: 19,
                    color: textDark,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Inventory Summary',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: C.primary.withOpacity(.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Polar Area',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: C.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _showInventorySummary ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Collapsible content ──
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _showInventorySummary
                ? Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 420;

                        final legend = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (int i = 0; i < _polarData.length; i++) ...[
                              _polarLegendRow(_polarData[i]),
                              if (i != _polarData.length - 1)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Divider(
                                    height: 1,
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                            ],
                          ],
                        );

                        final chart = SizedBox(
                          height: widget.isMobile ? 220 : 260,
                          width: widget.isMobile ? 220 : 260,
                          child: CustomPaint(
                            painter: _PolarAreaPainter(
                              slices: _polarData
                                  .map(
                                    (d) => PolarSlice(
                                      label: d.title,
                                      value: d.value,
                                      color: d.color,
                                    ),
                                  )
                                  .toList(),
                              maxValue: niceMax,
                            ),
                            child: const SizedBox.expand(),
                          ),
                        );

                        if (isNarrow) {
                          return Column(
                            children: [
                              legend,
                              const SizedBox(height: 18),
                              Center(child: chart),
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(flex: 4, child: legend),
                            Expanded(flex: 5, child: Center(child: chart)),
                          ],
                        );
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _polarLegendRow(PolarDeptValue item) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            item.title,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
        ),
        Text(
          _fmt(item.value),
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          'Kg',
          style: TextStyle(
            fontSize: 10,
            color: Colors.black38,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  num _niceMax(num value) {
    if (value <= 0) return 10;
    final magnitude = pow(10, (log(value) / ln10).floor()).toDouble();
    final residual = value / magnitude;
    double niceResidual = residual <= 1
        ? 1
        : residual <= 2
        ? 2
        : residual <= 5
        ? 5
        : 10;
    return niceResidual * magnitude;
  }
}

class PolarSlice {
  final String label;
  final num value;
  final Color color;
  const PolarSlice({
    required this.label,
    required this.value,
    required this.color,
  });
}

class _PolarAreaPainter extends CustomPainter {
  final List<PolarSlice> slices;
  final num maxValue;
  _PolarAreaPainter({required this.slices, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (size.shortestSide / 2) - 24;
    final n = slices.length;
    if (n == 0 || maxRadius <= 0) return;

    final sweep = (2 * pi) / n;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const gridSteps = 3;
    for (int i = 1; i <= gridSteps; i++) {
      canvas.drawCircle(center, maxRadius * i / gridSteps, gridPaint);
    }

    for (int i = 0; i < n; i++) {
      final angle = -pi / 2 + sweep * i;
      final end = Offset(
        center.dx + maxRadius * cos(angle),
        center.dy + maxRadius * sin(angle),
      );
      canvas.drawLine(center, end, gridPaint);
    }

    var startAngle = -pi / 2;
    for (final slice in slices) {
      final radius = maxValue <= 0 ? 0.0 : (slice.value / maxValue) * maxRadius;
      final rect = Rect.fromCircle(center: center, radius: radius);
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(rect, startAngle, sweep, false)
        ..close();

      canvas.drawPath(
        path,
        Paint()
          ..color = slice.color.withOpacity(.55)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = slice.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );

      startAngle += sweep;
    }

    final textStyle = TextStyle(
      fontSize: 9,
      color: Colors.grey.shade600,
      fontWeight: FontWeight.w600,
    );
    for (int i = 1; i <= gridSteps; i++) {
      final val = maxValue * i / gridSteps;
      final r = maxRadius * i / gridSteps;
      final tp = TextPainter(
        text: TextSpan(
          text: NumberFormat('#,##0').format(val),
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(center.dx - tp.width / 2, center.dy - r - tp.height - 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PolarAreaPainter old) =>
      old.slices != slices || old.maxValue != maxValue;
}

class _ProductionPoint {
  final DateTime date;
  final num rmdKg;
  final num cuttingKg;

  const _ProductionPoint({
    required this.date,
    required this.rmdKg,
    required this.cuttingKg,
  });
}
