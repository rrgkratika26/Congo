import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Color/Colorclass.dart';
import '../../services/DashboardApiServices.dart';
import '../ListMenuItems/DashboardTopBarAnimated.dart';
import '../ListMenuItems/dashBoardMapper.dart';

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

class _GraphTabState extends State<GraphTab> {
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 6));

  DateTime toDate = DateTime.now();

  bool _isLoading = true;
  String? _error;

  List<_ProductionPoint> _productionPoints = [];

  static const Color rmdColor = Color(0xFF06B6D4);
  static const Color cuttingColor = Color(0xFFEE7D00);

  static const Color textDark = Color(0xFF1A1A2E);
  String unitName = '';

  String get _fromStr => DateFormat('yyyy-MM-dd').format(fromDate);

  String get _toStr => DateFormat('yyyy-MM-dd').format(toDate);

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

      // Limit graph to 31 days.
      //
      // This prevents too many API calls while still allowing
      // monthly production analysis.

      final days = toDate.difference(fromDate).inDays.clamp(0, 30) + 1;

      final dateList = List.generate(
        days,
        (index) => fromDate.add(Duration(days: index)),
      );

      final results = await Future.wait(
        dateList.map((date) async {
          final dayStr = DateFormat('yyyy-MM-dd').format(date);

          try {
            // ───────────────────────────────────────────
            // API CALL
            // ───────────────────────────────────────────

            final summary = await service.getDashboard(
              unit:unitName,
              fromDate: dayStr,
              toDate: dayStr,
            );

            // ───────────────────────────────────────────
            // CONVERT API DATA
            // ───────────────────────────────────────────

            final departments = createDepartments(summary);

            // ───────────────────────────────────────────
            // FIND RMD
            // ───────────────────────────────────────────

            final rmdDepartment = _findDepartment(departments, 'RMD');

            final rmdKg = _getRmdValue(rmdDepartment);

            // ───────────────────────────────────────────
            // FIND CUTTING
            // ───────────────────────────────────────────

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

  // ─────────────────────────────────────────────────────────
  // FIND DEPARTMENT
  // ─────────────────────────────────────────────────────────

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

  // ─────────────────────────────────────────────────────────
  // GET RMD VALUE
  // ─────────────────────────────────────────────────────────

  num _getRmdValue(DeptCountItem? department) {
    if (department == null || department.metrics.isEmpty) {
      return 0;
    }

    return department.metrics.last.value;
  }

  num _getCuttingKg(DeptCountItem? department) {
    if (department == null || department.metrics.isEmpty) {
      return 0;
    }

    // Look specifically for KG metric
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

  // ─────────────────────────────────────────────────────────
  // NUMBER FORMAT
  // ─────────────────────────────────────────────────────────

  String _fmt(num value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    if (value == value.roundToDouble()) {
      return NumberFormat('#,##0').format(value);
    }

    return NumberFormat('#,##0.##').format(value);
  }

  // ─────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,

      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: EdgeInsets.symmetric(vertical: widget.isMobile ? 16 : 24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ─────────────────────────────────────
            // HEADER
            // ─────────────────────────────────────
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
                            color: Colors.black45,
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
            ],
          ],
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

      padding: const EdgeInsets.fromLTRB(12, 18, 16, 12),

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: C.primary.withOpacity(.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.show_chart_rounded,
                  color: C.primary,
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
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              _legendItem(color: rmdColor, label: 'RMD KG'),

              const SizedBox(width: 22),

              _legendItem(color: cuttingColor, label: 'Cutting KG'),
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
                  // TOP
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),

                  // RIGHT
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

                        if (index < 0 || index >= _productionPoints.length) {
                          return const SizedBox.shrink();
                        }

                        final date = _productionPoints[index].date;

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
                    getTooltipColor: (_) => const Color(0xFF1A1A2E),

                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),

                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        final index = spot.x.round();

                        if (index < 0 || index >= _productionPoints.length) {
                          return null;
                        }

                        final point = _productionPoints[index];

                        final isRmd = spot.barIndex == 0;

                        final label = isRmd ? 'RMD KG' : 'Cutting KG';

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
                    spots: List.generate(_productionPoints.length, (index) {
                      return FlSpot(
                        index.toDouble(),

                        _productionPoints[index].rmdKg.toDouble(),
                      );
                    }),

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
                    spots: List.generate(_productionPoints.length, (index) {
                      return FlSpot(
                        index.toDouble(),

                        _productionPoints[index].cuttingKg.toDouble(),
                      );
                    }),

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
          const Row(
            children: [
              Icon(Icons.table_rows_rounded, size: 19, color: textDark),

              SizedBox(width: 8),

              Text(
                'Daily Production',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ...points.map((point) {
            return _dailyRow(point);
          }),
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
              title: 'RMD',
              value: _fmt(point.rmdKg),
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

  // ─────────────────────────────────────────────────────────
  // LOADING CARD
  // ─────────────────────────────────────────────────────────

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

  // ─────────────────────────────────────────────────────────
  // ERROR CARD
  // ─────────────────────────────────────────────────────────

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

  // ─────────────────────────────────────────────────────────
  // EMPTY CARD
  // ─────────────────────────────────────────────────────────

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
}

// ─────────────────────────────────────────────────────────────
// PRODUCTION POINT MODEL
// ─────────────────────────────────────────────────────────────

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
