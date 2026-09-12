import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:intl/intl.dart';

import '../../Color/Colorclass.dart';
import '../../InquiryScreen/Marketing/MarketingModel.dart';
import '../../services/DashboardApiServices.dart';
import '../ScannedItem/Cutting/CuttinIN/CuttingScreen.dart';
import '../routes/app_routes.dart';
import 'AsiaDashBoard/DepartmentdashboardBottom.dart';
import 'Dashboard Summary.dart';
import 'DepartmentDashboard.dart';
import 'ListMenuItems/DashboardTopBarAnimated.dart';
import 'ListMenuItems/dashBoardMapper.dart';

class DashboardMetricsGrid extends StatefulWidget {
  final String unit;

  final void Function(DateTime from, DateTime to)? onDateRangeChanged;

  const DashboardMetricsGrid({
    super.key,
    required this.unit,
    this.onDateRangeChanged,
  });

  @override
  State<DashboardMetricsGrid> createState() => _DashboardMetricsGridState();
}

class _DashboardMetricsGridState extends State<DashboardMetricsGrid> {
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 6));
  DateTime toDate = DateTime.now();

  DashboardSummary? dashboardSummary;
  List<DeptCountItem> deptCounts = [];
  bool isLoading = true;

  int? _touchedBarIndex;

  // Only these departments show up in the chart.
  static const List<String> _chartDepts = [
    "LOOM",
    "RMD",
    "LAMINATION",
    "CUTTING",
  ];

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  @override
  void didUpdateWidget(covariant DashboardMetricsGrid old) {
    super.didUpdateWidget(old);
    if (old.unit != widget.unit) loadDashboard();
  }

  String get _fromStr => DateFormat('yyyy-MM-dd').format(fromDate);
  String get _toStr => DateFormat('yyyy-MM-dd').format(toDate);

  // ── DATA LOAD ─────────────────────────────
  Future<void> loadDashboard() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      dashboardSummary = await DashboardService().getDashboard(
        unit: widget.unit,
        fromDate: _fromStr,
        toDate: _toStr,
      );

      final marketing = await loadDepartmentCounts();
      final rawList = createDepartments(dashboardSummary!);

      final seenTitles = <String>{};
      final baseList = rawList.where((item) {
        if (seenTitles.contains(item.title)) return false;
        seenTitles.add(item.title);
        return true;
      }).toList();

      final Map<String, DeptCountItem> overrides = {
        "RMD": DeptCountItem(
          title: "RMD",
          icon: Icons.settings,
          color: Colors.indigo.shade300,
          metrics: [
            MetricItem("KG", marketing["RMD"]?.netWeight ?? 0),
            MetricItem("MTR", marketing["RMD"]?.rollLength ?? 0),
            MetricItem("Roll", marketing["RMD"]?.noOfRoll ?? 0),
          ],
        ),
        "INQUIRY": DeptCountItem(
          title: "INQUIRY",
          icon: Icons.query_stats,
          color: Colors.amber.shade700,
          metrics: [
            MetricItem("Total", marketing["INQUIRY"]?.totalInquiryCount ?? 0),
          ],
        ),
        "Inquiry": DeptCountItem(
          title: "Quotation",
          icon: Icons.request_quote,
          color: Colors.teal,
          metrics: [
            MetricItem("Count", marketing["INQUIRY"]?.totalInquiryCount ?? 0),
            MetricItem("Net Wt", marketing["INQUIRY"]?.netWeight ?? 0),
            MetricItem("ROLL", marketing["INQUIRY"]?.noOfRoll ?? 0),
          ],
        ),
      };

      deptCounts = baseList
          .map((item) => overrides[item.title] ?? item)
          .toList();

      widget.onDateRangeChanged?.call(fromDate, toDate);
    } catch (e, s) {
      debugPrint("DashboardMetricsGrid load error: $e");
      debugPrintStack(stackTrace: s);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<Map<String, MarketingCountModel>> loadDepartmentCounts() async {
    final service = DashboardService();
    final departments = [
      "PLANNING",
      "INQUIRY",
      "QUOTATION",
      "WO",
      "BOM",
      "RMD",
      "LAMINATION",
    ];
    final Map<String, MarketingCountModel> result = {};

    await Future.wait(
      departments.map((dept) async {
        try {
          result[dept] = await service.getMarketingCount(
            unit: widget.unit,
            type: dept,
            fromDate: _fromStr,
            toDate: _toStr,
          );
        } catch (e) {
          debugPrint("$dept Failed: $e");
        }
      }),
    );
    return result;
  }

  void _quickRange(int days) {
    setState(() {
      toDate = DateTime.now();
      fromDate = days == 0
          ? DateTime(toDate.year, toDate.month, toDate.day)
          : toDate.subtract(Duration(days: days));
    });
    loadDashboard();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: fromDate, end: toDate),
    );

    if (picked != null) {
      setState(() {
        fromDate = picked.start;
        toDate = picked.end;
      });

      loadDashboard();
    }
  }

  // Primary value per department used for the bar chart —
  // first metric of each dept (e.g. "Total", "KG") represents its headline number.
  num _primaryValue(DeptCountItem item) =>
      item.metrics.isEmpty ? 0 : item.metrics.first.value;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isMobile = mq.size.width < 600;
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _dateFilterBar(isMobile),
          const SizedBox(height: 10),
          _dashboardContent(isMobile),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── DATE FILTER BAR ─────────────────────────
  Widget _dateFilterBar(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 25 : 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _pickDateRange,
              icon: Icon(
                Icons.calendar_month_rounded,
                size: 18,
                color: C.primary,
              ),
              label: Text(
                "${DateFormat('dd MMM yyyy').format(fromDate)}"
                    " - "
                    "${DateFormat('dd MMM yyyy').format(toDate)}",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: C.primary,
                backgroundColor: C.primary.withOpacity(.05),
                side: BorderSide(color: C.primary.withOpacity(.25)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(width: 5),

          _quickChip("Today", () => _quickRange(0)),
        ],
      ),
    );
  }

  // ── QUICK DATE CHIP ─────────────────────────
  Widget _quickChip(String label, VoidCallback onTap) {
    return ActionChip(
      onPressed: onTap,
      label: Text(
        label,
        style: TextStyle(
          color: C.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      backgroundColor: C.primary.withOpacity(.05),
      side: BorderSide(color: C.primary.withOpacity(.25)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // ── BAR CHART: one bar per department, headline metric ──
  Widget _barChartSection(bool isMobile) {
    final chartItems = deptCounts
        .where((e) => _chartDepts.contains(e.title.toUpperCase()))
        .toList();

    if (chartItems.isEmpty) return const SizedBox.shrink();

    final maxVal = chartItems
        .map(_primaryValue)
        .fold<num>(0, (a, b) => a > b ? a : b);
    final chartMax = (maxVal <= 0 ? 10 : maxVal * 1.25).toDouble();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Text(
                "Department Totals",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: C.textHigh,
                  letterSpacing: .2,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                "${DateFormat('dd MMM yyyy').format(fromDate)} – ${DateFormat('dd MMM yyyy').format(toDate)}",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: C.textLow ?? Colors.black45,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: isMobile ? 190 : 230,
            child: BarChart(
              BarChartData(
                maxY: chartMax,
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: chartMax / 4 == 0 ? 1 : chartMax / 4,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.black.withOpacity(.06),
                    strokeWidth: 1,
                  ),
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
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      interval: chartMax / 4 == 0 ? 1 : chartMax / 4,
                      getTitlesWidget: (value, meta) => Text(
                        _fmt(value),
                        style: TextStyle(fontSize: 9.2, color: C.textHigh),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= chartItems.length) {
                          return const SizedBox.shrink();
                        }
                        final title = chartItems[i].title;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Transform.rotate(
                            angle: 0.0,
                            child: Text(
                              title.length > 8
                                  ? "${title.substring(0, 8)}…"
                                  : title,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: C.textHigh,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.black,
                    getTooltipItem: (group, groupIdx, rod, rodIdx) {
                      final item = chartItems[group.x.toInt()];
                      return BarTooltipItem(
                        "${item.title}\n${_fmt(rod.toY)}",
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                  touchCallback: (event, response) {
                    setState(() {
                      _touchedBarIndex = response?.spot?.touchedBarGroupIndex;
                    });
                  },
                ),
                barGroups: List.generate(chartItems.length, (i) {
                  final item = chartItems[i];
                  final val = _primaryValue(item).toDouble();
                  final touched = _touchedBarIndex == i;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: val,
                        color: touched ? item.color : item.color,
                        width: isMobile ? 16 : 20,
                        borderRadius: BorderRadius.circular(6),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: chartMax,
                          color: Colors.black.withOpacity(.03),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashboardContent(bool isMobile) {
    if (isLoading) {
      return _loadingDashboard(isMobile);
    }

    if (deptCounts.isEmpty) {
      return _emptyDashboard();
    }

    return Column(
      children: [
        _departmentList(isMobile),

        const SizedBox(height: 14),

        _barChartSection(isMobile),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _loadingDashboard(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      child: Column(
        children: [
          Container(
            height: 82,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(18),
            ),
          ),

          const SizedBox(height: 14),

          ...List.generate(
            5,
                (index) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Container(
                height: isMobile ? 65 : 70,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyDashboard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: C.primary.withOpacity(.07),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.analytics_outlined, color: C.primary, size: 30),
          ),

          const SizedBox(height: 12),

          Text(
            "No Dashboard Data",
            style: TextStyle(
              color: C.textHigh,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            "Try selecting a different date range.",
            style: TextStyle(color: C.textLow ?? Colors.black45, fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _fmt(num v) {
    if (v == v.roundToDouble()) {
      return NumberFormat('#,##0').format(v);
    }
    return NumberFormat('#,##0.##').format(v);
  }

  void _openDepartment(String department) {
    final dept = department.trim().toUpperCase();

    debugPrint('======================================');
    debugPrint('Dashboard Department Clicked: $department');
    debugPrint('Normalized Department: $dept');
    debugPrint('======================================');

    HapticFeedback.lightImpact();

    try {
      final ctrl = Get.find<DashboardController>();

      Get.to(
            () => DeptDashboard(ctrl: ctrl, department: dept),
        transition: Transition.cupertino,
      );
    } catch (e, s) {
      debugPrint('❌ Department navigation error: $e');
      debugPrintStack(stackTrace: s);

      _showNotAvailable(dept);
    }
  }

  Widget _departmentList(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: C.primary,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),

              const SizedBox(width: 8),

              Text(
                "Department Activity",
                style: TextStyle(
                  color: C.textHigh,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const Spacer(),

              Text(
                "${deptCounts.length} Departments",
                style: TextStyle(
                  color: C.textLow ?? Colors.black45,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          ...List.generate(deptCounts.length, (index) {
            final item = deptCounts[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: _departmentRow(item, isMobile, index),
            );
          }),
        ],
      ),
    );
  }

  Widget _departmentRow(DeptCountItem item, bool isMobile, int index) {
    final primary = _primaryValue(item);

    final chartItems = deptCounts
        .where((e) => _chartDepts.contains(e.title.toUpperCase()))
        .toList();

    num maxValue = 0;

    for (final element in chartItems) {
      final value = _primaryValue(element);

      if (value > maxValue) {
        maxValue = value;
      }
    }

    final progress = maxValue <= 0
        ? 0.0
        : (primary / maxValue).clamp(0.0, 1.0).toDouble();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDepartment(item.title),
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(.10),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(item.icon, color: item.color, size: 18),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: C.textHigh,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 6),

                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: item.color.withOpacity(.07),
                        valueColor: AlwaysStoppedAnimation<Color>(item.color),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                Text(
                  _fmt(primary),
                  style: TextStyle(
                    color: item.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(width: 4),

                Icon(Icons.chevron_right_rounded, size: 20, color: item.color),
              ],
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerLeft,
              child: _mobileMetrics(item.metrics, item.color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mobileMetrics(List<MetricItem> metrics, Color accent) {
    return Wrap(
      spacing: 5,
      runSpacing: 4,
      children: metrics.map((metric) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: accent.withOpacity(.05),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "${metric.label}: ",
                  style: TextStyle(
                    color: C.textMid ?? Colors.black54,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: _fmt(metric.value),
                  style: TextStyle(
                    color: accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _navigateFromMetricsDashboard(String department) {
    final dept = department.trim().toUpperCase();

    debugPrint('>>> Navigating Department: $dept');

    switch (dept) {

      case 'MARKETING':
        Get.to(
              () => DeptDashboard(
            ctrl: Get.find<DashboardController>(),
            department: department,
          ),
          transition: Transition.cupertino,
        );
        break;

      case 'INQUIRY':
        Get.to(
              () => DeptDashboard(
            ctrl: Get.find<DashboardController>(),
            department: department,
          ),
          transition: Transition.cupertino,
        );
        break;

      case 'PLANNING':
        Get.to(
              () => DeptDashboard(
            ctrl: Get.find<DashboardController>(),
            department: department,
          ),
          transition: Transition.cupertino,
        );
        break;

      case 'LOOM':
        Get.toNamed(AppRoutes.loomIn);
        break;

      case 'RMD':
        Get.toNamed(AppRoutes.rmdIn);
        break;

      case 'LAMINATION':
        Get.toNamed(AppRoutes.lamination);
        break;

      case 'CUTTING':
        Get.to(() => CuttingScreen(), transition: Transition.cupertino);
        break;

      case 'BAG':
        Get.toNamed(AppRoutes.bagEntry);
        break;

      case 'BALING':
        Get.toNamed(AppRoutes.baleEntry);
        break;

      case 'WEBBING':
        Get.toNamed(AppRoutes.webEntryScreen);
        break;

      case 'TAPELINE':
        Get.toNamed(AppRoutes.tapelineIn);
        break;

      case 'JBL LOOM':
        Get.toNamed(AppRoutes.loomList);
        break;

      case 'JBL RMD':
        Get.toNamed(AppRoutes.jblRmdIn);
        break;

      case 'JBL LAMINATION':
        Get.toNamed(AppRoutes.jblLamination);
        break;

      case 'JBL CUTTING':
        Get.toNamed(AppRoutes.jblCuttingIn);
        break;

      case 'JBL BAG':
        Get.toNamed(AppRoutes.jblBagStoreIssue);
        break;

      case 'JBL BALING':
        Get.toNamed(AppRoutes.jblBailing);
        break;

      case 'JBL DISPATCH':
        Get.toNamed(AppRoutes.jblScan);
        break;

      case 'JBL WEBBING':
        Get.toNamed(AppRoutes.jblWebbIn);
        break;

      default:
        _showNotAvailable(dept);
        break;
    }
  }

  void _showNotAvailable(String department) {
    Get.snackbar(
      'Not available',
      '$department is not available for navigation',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
    );
  }
}

extension _ColorShade on Color {
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final darker = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darker.toColor();
  }
}
