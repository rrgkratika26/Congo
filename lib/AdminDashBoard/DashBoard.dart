// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// import '../../Color/Colorclass.dart';
// import '../../InquiryScreen/Marketing/MarketingModel.dart';
// import '../../services/DashboardApiServices.dart';
// import 'Dashboard Summary.dart';
// import 'ListMenuItems/DashboardTopBarAnimated.dart';
// import 'ListMenuItems/dashBoardMapper.dart';
//
// // ─────────────────────────────────────────────
// //  MAIN GRID WIDGET (replaces DashboardTopBarAnimated)
// // ─────────────────────────────────────────────
// class DashboardMetricsGrid extends StatefulWidget {
//   final String unit;
//
//   final void Function(DateTime from, DateTime to)? onDateRangeChanged;
//
//   const DashboardMetricsGrid({
//     super.key,
//     required this.unit,
//     this.onDateRangeChanged,
//   });
//
//   @override
//   State<DashboardMetricsGrid> createState() => _DashboardMetricsGridState();
// }
//
// class _DashboardMetricsGridState extends State<DashboardMetricsGrid> {
//   DateTime fromDate = DateTime.now().subtract(const Duration(days: 6));
//   DateTime toDate = DateTime.now();
//
//   DashboardSummary? dashboardSummary;
//   List<DeptCountItem> deptCounts = [];
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     loadDashboard();
//   }
//
//   @override
//   void didUpdateWidget(covariant DashboardMetricsGrid old) {
//     super.didUpdateWidget(old);
//     if (old.unit != widget.unit) loadDashboard();
//   }
//
//   String get _fromStr => DateFormat('yyyy-MM-dd').format(fromDate);
//   String get _toStr => DateFormat('yyyy-MM-dd').format(toDate);
//
//   // ── DATA LOAD ─────────────────────────────
//   Future<void> loadDashboard() async {
//     if (!mounted) return;
//     setState(() => isLoading = true);
//
//     try {
//       dashboardSummary = await DashboardService().getDashboard(
//         unit: widget.unit,
//         fromDate: _fromStr,
//         toDate: _toStr,
//       );
//
//       final marketing = await loadDepartmentCounts();
//       final rawList = createDepartments(dashboardSummary!);
//
//       final seenTitles = <String>{};
//       final baseList = rawList.where((item) {
//         if (seenTitles.contains(item.title)) return false;
//         seenTitles.add(item.title);
//         return true;
//       }).toList();
//
//       final Map<String, DeptCountItem> overrides = {
//         "RMD": DeptCountItem(
//           title: "RMD",
//           icon: Icons.settings,
//           color: Colors.indigo.shade300,
//           metrics: [
//             MetricItem("KG", marketing["RMD"]?.netWeight ?? 0),
//             MetricItem("MTR", marketing["RMD"]?.rollLength ?? 0),
//             MetricItem("Roll", marketing["RMD"]?.noOfRoll ?? 0),
//           ],
//         ),
//         "INQUIRY": DeptCountItem(
//           title: "INQUIRY",
//           icon: Icons.query_stats,
//           color: Colors.amber.shade700,
//           metrics: [
//             MetricItem("Total", marketing["INQUIRY"]?.totalInquiryCount ?? 0),
//           ],
//         ),
//         "Inquiry": DeptCountItem(
//           title: "Quotation",
//           icon: Icons.request_quote,
//           color: Colors.teal,
//           metrics: [
//             MetricItem("Count", marketing["INQUIRY"]?.totalInquiryCount ?? 0),
//             MetricItem("Net Wt", marketing["INQUIRY"]?.netWeight ?? 0),
//             MetricItem("ROLL", marketing["INQUIRY"]?.noOfRoll ?? 0),
//           ],
//         ),
//       };
//
//       deptCounts = baseList
//           .map((item) => overrides[item.title] ?? item)
//           .toList();
//
//       widget.onDateRangeChanged?.call(fromDate, toDate);
//     } catch (e, s) {
//       debugPrint("DashboardMetricsGrid load error: $e");
//       debugPrintStack(stackTrace: s);
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }
//
//   Future<Map<String, MarketingCountModel>> loadDepartmentCounts() async {
//     final service = DashboardService();
//     final departments = [
//       "PLANNING",
//       "INQUIRY",
//       "QUOTATION",
//       "WO",
//       "BOM",
//       "RMD",
//       "LAMINATION",
//     ];
//     final Map<String, MarketingCountModel> result = {};
//
//     await Future.wait(
//       departments.map((dept) async {
//         try {
//           result[dept] = await service.getMarketingCount(
//             unit: widget.unit,
//             type: dept,
//             fromDate: _fromStr,
//             toDate: _toStr,
//           );
//         } catch (e) {
//           debugPrint("$dept Failed: $e");
//         }
//       }),
//     );
//     return result;
//   }
//
//   // ── DATE FILTER ACTIONS ───────────────────
//   Future<void> _pickDate({required bool isFrom}) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: isFrom ? fromDate : toDate,
//       firstDate: DateTime(2022),
//       lastDate: DateTime.now(),
//     );
//     if (picked == null) return;
//
//     setState(() {
//       if (isFrom) {
//         fromDate = picked;
//         if (fromDate.isAfter(toDate)) toDate = fromDate;
//       } else {
//         toDate = picked;
//         if (toDate.isBefore(fromDate)) fromDate = toDate;
//       }
//     });
//     loadDashboard();
//   }
//
//   void _quickRange(int days) {
//     setState(() {
//       toDate = DateTime.now();
//       fromDate = days == 0
//           ? DateTime(toDate.year, toDate.month, toDate.day)
//           : toDate.subtract(Duration(days: days));
//     });
//     loadDashboard();
//   }
//
//   Future<void> _pickDateRange() async {
//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2022),
//       lastDate: DateTime.now(),
//       initialDateRange: DateTimeRange(start: fromDate, end: toDate),
//     );
//
//     if (picked != null) {
//       setState(() {
//         fromDate = picked.start;
//         toDate = picked.end;
//       });
//
//       loadDashboard();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final mq = MediaQuery.of(context);
//     final isMobile = mq.size.width < 600;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Text(
//           "Dashboard",
//           style: TextStyle(
//             color: C.primary,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(width: 5),
//         _dateFilterBar(isMobile),
//         const SizedBox(height: 10),
//         isLoading ? _loadingGrid(isMobile) : _metricsGrid(isMobile),
//       ],
//     );
//   }
//
//   // ── DATE FILTER BAR ────────────────────────
//   Widget _dateFilterBar(bool isMobile) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 24),
//       child: Row(
//         children: [
//           Expanded(
//             child: OutlinedButton.icon(
//               onPressed: _pickDateRange,
//               icon: const Icon(Icons.calendar_month_rounded),
//               label: Text(
//                 "${DateFormat('dd MMM yyyy').format(fromDate)}"
//                 " - "
//                 "${DateFormat('dd MMM yyyy').format(toDate)}",
//                 overflow: TextOverflow.ellipsis,
//               ),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: C.primary,
//                 side: BorderSide(color: C.primary.withOpacity(.3)),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 5),
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           _quickChip("Today", () => _quickRange(0)),
//         ],
//       ),
//     );
//   }
//
//   Widget _quickChip(String label, VoidCallback onTap) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 6),
//       child: ActionChip(
//         label: Text(
//           label,
//           style: const TextStyle(
//             color: C.primary,
//             fontSize: 11,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: C.bg,
//         onPressed: onTap,
//       ),
//     );
//   }
//
//   // ── METRICS GRID ───────────────────────────
//   Widget _metricsGrid(bool isMobile) {
//     if (deptCounts.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.symmetric(vertical: 24),
//         child: Center(
//           child: Text("No Data", style: TextStyle(color: Colors.grey)),
//         ),
//       );
//     }
//
//     final crossCount = isMobile
//         ? 2
//         : (MediaQuery.of(context).size.width < 1000 ? 3 : 4);
//
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 24),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: crossCount,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 12,
//         childAspectRatio: isMobile ? 1 : 1.2,
//       ),
//       itemCount: deptCounts.length,
//       itemBuilder: (_, i) => _metricCard(deptCounts[i], isMobile),
//     );
//   }
//
//   Widget _loadingGrid(bool isMobile) {
//     final crossCount = isMobile ? 2 : 4;
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: crossCount,
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//         childAspectRatio: isMobile ? 1 : 1.2,
//       ),
//       itemCount: crossCount * 2,
//       itemBuilder: (_, __) => Container(
//         decoration: BoxDecoration(
//           color: Colors.grey.shade200,
//           borderRadius: BorderRadius.circular(14),
//         ),
//       ),
//     );
//   }
//
//   Widget _metricCard(DeptCountItem item, bool isMobile) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border(left: BorderSide(color: item.color, width: 4)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(.05),
//             blurRadius: 8,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.only(left: 5, right: 5, top: 8, bottom: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           Icon(item.icon, color: item.color, size: isMobile ? 28 : 38),
//           const SizedBox(height: 4),
//           Expanded(
//             child: Text(
//               item.title.toUpperCase(),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 fontWeight: FontWeight.w700,
//                 fontSize: isMobile ? 15 : 20,
//                 color: C.textHigh,
//                 letterSpacing: .3,
//               ),
//             ),
//           ),
//           // const SizedBox(height: 2),
//           for (final m in item.metrics) _metricValue(m, isMobile),
//         ],
//       ),
//     );
//   }
//
//   Widget _metricValue(MetricItem m, bool isMobile) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       // crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Text(
//           m.label,
//           style: TextStyle(
//             fontSize: isMobile ? 15 : 20,
//             color: C.textHigh,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Flexible(
//           child: FittedBox(
//             fit: BoxFit.scaleDown,
//             alignment: Alignment.centerRight,
//             child: Text(
//               _fmt(m.value),
//               maxLines: 1,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: isMobile ? 15 : 20,
//                 color: C.textHigh,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   String _fmt(num v) {
//     if (v == v.roundToDouble()) return v.toInt().toString();
//     return v.toStringAsFixed(2);
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../Color/Colorclass.dart';
import '../../InquiryScreen/Marketing/MarketingModel.dart';
import '../../services/DashboardApiServices.dart';
import 'Dashboard Summary.dart';
import 'ListMenuItems/DashboardTopBarAnimated.dart';
import 'ListMenuItems/dashBoardMapper.dart';

// ─────────────────────────────────────────────
//  MAIN GRID WIDGET (replaces DashboardTopBarAnimated)
// ─────────────────────────────────────────────
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

  // ── DATE FILTER ACTIONS ───────────────────
  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? fromDate : toDate,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;

    setState(() {
      if (isFrom) {
        fromDate = picked;
        if (fromDate.isAfter(toDate)) toDate = fromDate;
      } else {
        toDate = picked;
        if (toDate.isBefore(fromDate)) fromDate = toDate;
      }
    });
    loadDashboard();
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Dashboard",
            style: TextStyle(
              color: C.primary,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: .2,
            ),
          ),
          const SizedBox(height: 10),
          _dateFilterBar(isMobile),
          const SizedBox(height: 16),
          isLoading ? _loadingGrid(isMobile) : _metricsGrid(isMobile),
          const SizedBox(height: 18),
          isLoading ? _loadingChart(isMobile) : _barChartSection(isMobile),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── DATE FILTER BAR ────────────────────────
  Widget _dateFilterBar(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 24),
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
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: C.primary,
                backgroundColor: C.primary.withOpacity(.05),
                side: BorderSide(color: C.primary.withOpacity(.25)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _quickChip("Today", () => _quickRange(0)),
        ],
      ),
    );
  }

  Widget _quickChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          color: C.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      backgroundColor: C.primary.withOpacity(.08),
      side: BorderSide(color: C.primary.withOpacity(.25)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onPressed: onTap,
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
          const SizedBox(height: 14),
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
                        style: TextStyle(
                          fontSize: 9.2,
                          color: C.textHigh ?? C.brand600,
                        ),
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

  Widget _loadingChart(bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      height: isMobile ? 230 : 270,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  // ── METRICS GRID — vertical scroll, fully responsive ──
  Widget _metricsGrid(bool isMobile) {
    if (deptCounts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 50),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined, color: Colors.black26, size: 30),
              const SizedBox(height: 8),
              Text(
                "No Data",
                style: TextStyle(
                  color: C.textHigh,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final horizontalPad = isMobile ? 16.0 : 24.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - horizontalPad * 2;

        const crossCount = 2; // always 2 cards per row, any screen size

        const crossSpacing = 12.0;
        const mainSpacing = 12.0;

        final cardWidth =
            (availableWidth - crossSpacing * (crossCount - 1)) / crossCount;

        // Tallest card in the current data set (most metric rows) sets the
        // cell height, so every card — regardless of metric count — fits
        // without overflowing.
        final maxMetrics = deptCounts
            .map((e) => e.metrics.length)
            .fold<int>(1, (a, b) => a > b ? a : b);
        final metricRowH = isMobile ? 26.0 : 29.0; // row height + spacing
        const headerH = 40.0; // icon chip + title row
        const dividerH = 19.0; // divider + surrounding spacing
        const verticalPad = 26.0; // card top+bottom padding
        final cardHeight =
            headerH + dividerH + verticalPad + maxMetrics * metricRowH;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: horizontalPad),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: crossSpacing,
            mainAxisSpacing: mainSpacing,
            childAspectRatio: cardWidth / cardHeight,
          ),
          itemCount: deptCounts.length,
          itemBuilder: (_, i) => _metricCard(deptCounts[i], isMobile),
        );
      },
    );
  }

  Widget _loadingGrid(bool isMobile) {
    const crossCount = 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isMobile ? 0.95 : 1.15,
      ),
      itemCount: crossCount * 2,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ── CARD: icon chip + title tight together, then metric rows ──
  Widget _metricCard(DeptCountItem item, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: item.color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: isMobile ? 18 : 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: isMobile ? 11.5 : 12.5,
                    color: C.textHigh,
                    letterSpacing: .4,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Container(height: 1, color: item.color.withOpacity(.14)),
          const SizedBox(height: 8),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < item.metrics.length; i++) ...[
                if (i > 0) const SizedBox(height: 6),
                _metricValue(item.metrics[i], item.color, isMobile),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricValue(MetricItem m, Color accent, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          m.label,
          style: TextStyle(
            fontSize: isMobile ? 11.5 : 12.5,
            color: C.textMid ?? Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              _fmt(m.value),
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: isMobile ? 14.5 : 16,
                color: ColorShade(accent).darken(0.1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _fmt(num v) {
    if (v == v.roundToDouble()) {
      return NumberFormat('#,##0').format(v);
    }
    return NumberFormat('#,##0.##').format(v);
  }
}

// helper — matches item.color.darken() used earlier in DashboardTopBarAnimated.
// Skip this if a ColorShade extension already exists somewhere globally imported.
extension _ColorShade on Color {
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final darker = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darker.toColor();
  }
}
