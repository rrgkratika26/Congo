import 'dart:async';
import 'package:flutter/material.dart';
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

  /// Callback jab date range change ho — parent isse listen kar sakta hai
  /// agar neeche wale department-grid ko bhi refresh karna ho.
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
        // "INQUIRY": DeptCountItem(
        //   title: "INQUIRY",
        //   icon: Icons.query_stats,
        //   color: Colors.amber.shade700,
        //   metrics: [
        //     MetricItem("Count", marketing["INQUIRY"]?.totalInquiryCount ?? 0),
        //
        //   ],
        // ),
      //   "Inquiry": DeptCountItem(
      //     title: "Quotation",
      //     icon: Icons.request_quote,
      //     color: Colors.teal,
      //     metrics: [
      //       MetricItem("Count", marketing["INQUIRY"]?.totalInquiryCount ?? 0),
      //       MetricItem("Net Wt", marketing["INQUIRY"]?.netWeight ?? 0),
      //       MetricItem("ROLL", marketing["INQUIRY"]?.noOfRoll ?? 0),
      //     ],
      //   ),
      };

      deptCounts = baseList.map((item) => overrides[item.title] ?? item).toList();

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
    final departments = ["INQUIRY", "Quotation", "WO", "BOM", "RMD", "LAMINATION"];
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

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isMobile = mq.size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dateFilterBar(isMobile),
        const SizedBox(height: 10),
        isLoading ? _loadingGrid(isMobile) : _metricsGrid(isMobile),
      ],
    );
  }

  // ── DATE FILTER BAR ────────────────────────
  Widget _dateFilterBar(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _dateChip(
              icon: Icons.calendar_today_rounded,
              label: DateFormat('dd MMM').format(fromDate),
              onTap: () => _pickDate(isFrom: true),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            _dateChip(
              icon: Icons.calendar_today_rounded,
              label: DateFormat('dd MMM').format(toDate),
              onTap: () => _pickDate(isFrom: false),
            ),
            const SizedBox(width: 12),
            _quickChip("Today", () => _quickRange(0)),
            _quickChip("7D", () => _quickRange(7)),
            _quickChip("30D", () => _quickRange(30)),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: C.primary),
              onPressed: loadDashboard,
              tooltip: "Refresh",
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateChip({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: C.primary.withOpacity(.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: C.primary),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _quickChip(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        backgroundColor: C.primary.withOpacity(.08),
        onPressed: onTap,
      ),
    );
  }

  // ── METRICS GRID ───────────────────────────
  Widget _metricsGrid(bool isMobile) {
    if (deptCounts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text("No Data", style: TextStyle(color: Colors.grey))),
      );
    }

    final crossCount = isMobile ? 2 : (MediaQuery.of(context).size.width < 1000 ? 3 : 4);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: isMobile ? 1 : 1.2,
      ),
      itemCount: deptCounts.length,
      itemBuilder: (_, i) => _metricCard(deptCounts[i], isMobile),
    );
  }

  Widget _loadingGrid(bool isMobile) {
    final crossCount = isMobile ? 2 : 4;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isMobile ? 1 : 1.2,
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
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.only(left: 8,right: 8, top: 10,bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: item.color, size: isMobile ? 18 : 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: isMobile ? 15 : 20,
                    color: C.textHigh,
                    letterSpacing: .3,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final m in item.metrics) _metricValue(m, isMobile),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricValue(MetricItem m, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            m.label,
            style: TextStyle(
              fontSize: isMobile ? 15 : 20,
              color: C.textHigh,
              fontWeight: FontWeight.w500,
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
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 15 : 20,
                  color: C.textHigh,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(num v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }
}