// //
// // import 'dart:async';
// // import 'package:flutter/material.dart';
// //
// // import '../../Color/Colorclass.dart';
// // import '../../InquiryScreen/Marketing/MarketingModel.dart';
// // import '../../services/DashboardApiServices.dart';
// // import '../Dashboard Summary.dart';
// // import 'dashBoardMapper.dart';
// //
// // class MetricItem {
// //   final String label;
// //   final num value;
// //
// //   const MetricItem(this.label, this.value);
// // }
// //
// // class DeptCountItem {
// //   final String title;
// //   final IconData icon;
// //   final List<MetricItem> metrics; // 1..n values per dept
// //   final Color color;
// //
// //   const DeptCountItem({
// //     required this.title,
// //     required this.icon,
// //     required this.metrics,
// //     required this.color,
// //   });
// // }
// //
// // // ─────────────────────────────────────────────
// // //  TOP BAR WIDGET
// // // ─────────────────────────────────────────────
// // class DashboardTopBarAnimated extends StatefulWidget {
// //   final String unit;
// //   final String fromDate;
// //   final String toDate;
// //
// //   final VoidCallback? onMenuTap;
// //   final VoidCallback? onProfileTap;
// //
// //   const DashboardTopBarAnimated({
// //     super.key,
// //     required this.unit,
// //     required this.fromDate,
// //     required this.toDate,
// //     this.onMenuTap,
// //     this.onProfileTap,
// //   });
// //
// //   @override
// //   State<DashboardTopBarAnimated> createState() =>
// //       _DashboardTopBarAnimatedState();
// // }
// //
// // class _DashboardTopBarAnimatedState extends State<DashboardTopBarAnimated>
// //     with TickerProviderStateMixin {
// //   late final AnimationController _entranceCtrl;
// //   late final Animation<Offset> _slideAnim;
// //   late final Animation<double> _fadeAnim;
// //   bool _isPaused = false;
// //   int currentIndex = 0;
// //   DashboardSummary? dashboardSummary;
// //   List<DeptCountItem> deptCounts = [];
// //   bool isLoading = true;
// //
// //   final ScrollController _scrollCtrl = ScrollController();
// //   Timer? _tickerTimer;
// //   Timer? _refreshTimer;
// //   double _scrollPos = 0;
// //   static const double _scrollSpeed = 0.6;
// //   static const Duration _tickInterval = Duration(milliseconds: 16);
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //
// //     _entranceCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 600),
// //     );
// //
// //     _slideAnim = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
// //         .animate(
// //           CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic),
// //         );
// //
// //     _fadeAnim = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeIn);
// //
// //     _entranceCtrl.forward();
// //
// //     loadDashboard();
// //
// //     _refreshTimer = Timer.periodic(
// //       const Duration(seconds: 30),
// //       (_) => loadDashboard(),
// //     );
// //   }
// //
// //   void _startTicker() {
// //     _tickerTimer = Timer.periodic(_tickInterval, (_) {
// //       if (_isPaused) return;
// //       if (!_scrollCtrl.hasClients) return;
// //
// //       final maxExtent = _scrollCtrl.position.maxScrollExtent;
// //       if (maxExtent <= 0) return;
// //
// //       _scrollPos += _scrollSpeed;
// //
// //       if (_scrollPos >= maxExtent / 2) {
// //         _scrollPos = 0;
// //       }
// //
// //       _scrollCtrl.jumpTo(
// //         _scrollPos.clamp(0.0, _scrollCtrl.position.maxScrollExtent),
// //       );
// //     });
// //   }
// //
// //   @override
// //   void dispose() {
// //     _tickerTimer?.cancel();
// //     _refreshTimer?.cancel();
// //     _scrollCtrl.dispose();
// //     _entranceCtrl.dispose();
// //     super.dispose();
// //   }
// //
// //   // ── Responsive breakpoints ──
// //   // mobile < 600, tablet 600–1024, desktop > 1024
// //   _ScreenSize _sizeOf(double width) {
// //     if (width < 600) return _ScreenSize.mobile;
// //     if (width < 1024) return _ScreenSize.tablet;
// //     return _ScreenSize.desktop;
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final mq = MediaQuery.of(context);
// //     final screen = _sizeOf(mq.size.width);
// //
// //     return SlideTransition(
// //       position: _slideAnim,
// //       child: FadeTransition(
// //         opacity: _fadeAnim,
// //         child: SizedBox(
// //           width: double.infinity,
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               isLoading
// //                   ? SizedBox(
// //                       height: screen == _ScreenSize.mobile ? 110 : 140,
// //                       child: const Center(
// //                         child: CircularProgressIndicator(strokeWidth: 2.4),
// //                       ),
// //                     )
// //                   : _tickerRow(screen),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _tickerRow(_ScreenSize screen) {
// //     if (deptCounts.isEmpty) {
// //       return SizedBox(
// //         height: 110,
// //         child: Center(
// //           child: Text(
// //             "No Data",
// //             style: TextStyle(
// //               color: C.textHigh,
// //               fontSize: 14,
// //               fontWeight: FontWeight.w600,
// //             ),
// //           ),
// //         ),
// //       );
// //     }
// //
// //     final doubled = [...deptCounts, ...deptCounts];
// //     final cardHeight = switch (screen) {
// //       _ScreenSize.mobile => 138.0,
// //       _ScreenSize.tablet => 150.0,
// //       _ScreenSize.desktop => 162.0,
// //     };
// //
// //     return SizedBox(
// //       height: cardHeight,
// //       child: ListView.builder(
// //         controller: _scrollCtrl,
// //         scrollDirection: Axis.horizontal,
// //         physics: const NeverScrollableScrollPhysics(),
// //         padding: EdgeInsets.symmetric(
// //           horizontal: screen == _ScreenSize.mobile ? 14 : 24,
// //         ),
// //         itemCount: doubled.length,
// //         itemBuilder: (_, index) {
// //           return Padding(
// //             padding: const EdgeInsets.only(right: 14),
// //             child: Listener(
// //               onPointerDown: (_) => setState(() => _isPaused = true),
// //               onPointerUp: (_) => setState(() => _isPaused = false),
// //               onPointerCancel: (_) => setState(() => _isPaused = false),
// //               child: _tickerCard(doubled[index], screen),
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }
// //
// //   // ── Card: proper contrast, clear hierarchy, breathing room ──
// //   Widget _tickerCard(DeptCountItem item, _ScreenSize screen) {
// //     final bool active = deptCounts[currentIndex].title == item.title;
// //     final int metricCount = item.metrics.length;
// //     final bool useGrid = metricCount > 3;
// //     final bool isMobile = screen == _ScreenSize.mobile;
// //
// //     final double minW = switch (screen) {
// //       _ScreenSize.mobile => 210.0,
// //       _ScreenSize.tablet => 240.0,
// //       _ScreenSize.desktop => 260.0,
// //     };
// //     final double maxW = switch (screen) {
// //       _ScreenSize.mobile => 250.0,
// //       _ScreenSize.tablet => 280.0,
// //       _ScreenSize.desktop => 300.0,
// //     };
// //
// //     // Text/label colors now derive from card state instead of being
// //     // hardcoded white — fixes invisible text on the light inactive card.
// //     final Color titleColor = active ? item.color.darken(0.15) : C.textHigh;
// //     final Color valueColor = active ? item.color.darken(0.25) : C.textHigh;
// //     final Color labelColor = active
// //         ? item.color.darken(0.05)
// //         : (C.textLow ?? Colors.black54);
// //     final Color dividerColor = active ? item.color.withOpacity(.25) : C.border;
// //
// //     return AnimatedContainer(
// //       duration: const Duration(milliseconds: 350),
// //       curve: Curves.easeOut,
// //       constraints: BoxConstraints(minWidth: minW, maxWidth: maxW),
// //       decoration: BoxDecoration(
// //         gradient: active
// //             ? LinearGradient(
// //                 begin: Alignment.topLeft,
// //                 end: Alignment.bottomRight,
// //                 colors: [
// //                   item.color.withOpacity(.18),
// //                   item.color.withOpacity(.06),
// //                 ],
// //               )
// //             : null,
// //         color: active ? null : Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         border: Border(
// //           left: BorderSide(color: item.color, width: active ? 4 : 3),
// //           top: BorderSide(
// //             color: active ? item.color.withOpacity(.3) : C.border,
// //             width: .8,
// //           ),
// //           right: BorderSide(
// //             color: active ? item.color.withOpacity(.3) : C.border,
// //             width: .8,
// //           ),
// //           bottom: BorderSide(
// //             color: active ? item.color.withOpacity(.3) : C.border,
// //             width: .8,
// //           ),
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             color: active
// //                 ? item.color.withOpacity(.22)
// //                 : Colors.black.withOpacity(.05),
// //             blurRadius: active ? 14 : 6,
// //             offset: const Offset(0, 4),
// //           ),
// //         ],
// //       ),
// //       child: Padding(
// //         padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // ── Header: icon chip + title + active dot ──
// //             Row(
// //               children: [
// //                 Container(
// //                   padding: const EdgeInsets.all(6),
// //                   decoration: BoxDecoration(
// //                     color: item.color.withOpacity(.16),
// //                     borderRadius: BorderRadius.circular(10),
// //                   ),
// //                   child: Icon(
// //                     item.icon,
// //                     color: item.color,
// //                     size: isMobile ? 15 : 17,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 Expanded(
// //                   child: Text(
// //                     item.title.toUpperCase(),
// //                     overflow: TextOverflow.ellipsis,
// //                     maxLines: 1,
// //                     style: TextStyle(
// //                       color: titleColor,
// //                       fontWeight: FontWeight.w700,
// //                       fontSize: isMobile ? 12 : 13.5,
// //                       letterSpacing: 0.5,
// //                     ),
// //                   ),
// //                 ),
// //                 if (active)
// //                   Container(
// //                     width: 7,
// //                     height: 7,
// //                     margin: const EdgeInsets.only(left: 4),
// //                     decoration: BoxDecoration(
// //                       color: item.color,
// //                       shape: BoxShape.circle,
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: item.color.withOpacity(.6),
// //                           blurRadius: 4,
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //               ],
// //             ),
// //
// //             const SizedBox(height: 8),
// //             Container(height: 1, color: dividerColor),
// //             const SizedBox(height: 4),
// //
// //             // ── Metrics ──
// //             Expanded(
// //               child: useGrid
// //                   ? _metricGrid(item, isMobile, valueColor, labelColor)
// //                   : _metricRow(item, isMobile, valueColor, labelColor),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // Compact metric row with vertical dividers — for ≤3 metrics
// //   Widget _metricRow(
// //     DeptCountItem item,
// //     bool isMobile,
// //     Color valueColor,
// //     Color labelColor,
// //   ) {
// //     return Row(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         for (int i = 0; i < item.metrics.length; i++) ...[
// //           if (i > 0)
// //             Container(
// //               width: 1,
// //               height: isMobile ? 30 : 34,
// //               color: Colors.black.withOpacity(.08),
// //               margin: const EdgeInsets.symmetric(horizontal: 10),
// //             ),
// //           Expanded(
// //             child: _metricBlock(
// //               item.metrics[i],
// //               isMobile,
// //               valueColor,
// //               labelColor,
// //             ),
// //           ),
// //         ],
// //       ],
// //     );
// //   }
// //
// //   // Wrap-based grid — for 4+ metrics
// //   Widget _metricGrid(
// //     DeptCountItem item,
// //     bool isMobile,
// //     Color valueColor,
// //     Color labelColor,
// //   ) {
// //     return LayoutBuilder(
// //       builder: (context, constraints) {
// //         const double gap = 8;
// //         final double itemWidth = (constraints.maxWidth - gap) / 2;
// //
// //         return Wrap(
// //           spacing: gap,
// //           runSpacing: 6,
// //           children: item.metrics.map((m) {
// //             return SizedBox(
// //               width: itemWidth,
// //               child: _metricBlock(
// //                 m,
// //                 isMobile,
// //                 valueColor,
// //                 labelColor,
// //                 boxed: true,
// //               ),
// //             );
// //           }).toList(),
// //         );
// //       },
// //     );
// //   }
// //
// //   // Single metric — big value on top, subtle label below
// //   Widget _metricBlock(
// //     MetricItem m,
// //     bool isMobile,
// //     Color valueColor,
// //     Color labelColor, {
// //     bool boxed = false,
// //   }) {
// //     final content = Column(
// //       mainAxisSize: MainAxisSize.min,
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         FittedBox(
// //           fit: BoxFit.scaleDown,
// //           alignment: Alignment.centerLeft,
// //           child: Text(
// //             _fmt(m.value),
// //             maxLines: 1,
// //             style: TextStyle(
// //               color: valueColor,
// //               fontWeight: FontWeight.w800,
// //               fontSize: isMobile ? 17 : 19,
// //               height: 1.1,
// //             ),
// //           ),
// //         ),
// //         const SizedBox(height: 2),
// //         Text(
// //           m.label,
// //           overflow: TextOverflow.ellipsis,
// //           maxLines: 1,
// //           style: TextStyle(
// //             color: labelColor,
// //             fontSize: isMobile ? 10 : 11.5,
// //             fontWeight: FontWeight.w600,
// //             letterSpacing: 0.2,
// //           ),
// //         ),
// //       ],
// //     );
// //
// //     if (!boxed) return content;
// //
// //     return Container(
// //       padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 9),
// //       decoration: BoxDecoration(
// //         color: Colors.black.withOpacity(.03),
// //         borderRadius: BorderRadius.circular(10),
// //       ),
// //       child: content,
// //     );
// //   }
// //
// //   String _fmt(num value) {
// //     if (value >= 1000000000) {
// //       return "${(value / 1000000000).toStringAsFixed(1)}B";
// //     }
// //     if (value >= 1000000) {
// //       return "${(value / 1000000).toStringAsFixed(1)}M";
// //     }
// //     if (value >= 1000) {
// //       return "${(value / 1000).toStringAsFixed(1)}K";
// //     }
// //     if (value == value.roundToDouble()) {
// //       return value.toInt().toString();
// //     }
// //     return value.toStringAsFixed(2);
// //   }
// //
// //   Future loadDashboard() async {
// //     try {
// //       dashboardSummary = await DashboardService().getDashboard(
// //         unit: widget.unit,
// //         fromDate: widget.fromDate,
// //         toDate: widget.toDate,
// //       );
// //
// //       final marketing = await loadDepartmentCounts();
// //
// //       final rawList = createDepartments(dashboardSummary!);
// //
// //       final seen = <String>{};
// //       final baseList = rawList.where((e) => seen.add(e.title)).toList();
// //
// //       final Map<String, DeptCountItem> overrides = {
// //         // Inquiry -> ONLY TOTAL
// //         "INQUIRY": DeptCountItem(
// //           title: "INQUIRY",
// //           icon: Icons.query_stats,
// //           color: Colors.amber.shade700,
// //           metrics: [
// //             MetricItem(
// //               "Total",
// //               marketing["INQUIRY"]?.totalInquiryCount ??
// //                   dashboardSummary!.inquiryCount,
// //             ),
// //           ],
// //         ),
// //
// //         // Work Order -> ONLY TOTAL
// //         "Work Order": DeptCountItem(
// //           title: "Work Order",
// //           icon: Icons.assignment,
// //           color: Colors.blueGrey.shade600,
// //           metrics: [
// //             MetricItem(
// //               "Total",
// //               marketing["WO"]?.totalInquiryCount ?? dashboardSummary!.woCount,
// //             ),
// //           ],
// //         ),
// //
// //         // BOM -> ONLY TOTAL
// //         "BOM": DeptCountItem(
// //           title: "BOM",
// //           icon: Icons.assignment,
// //           color: Colors.blueGrey.shade600,
// //           metrics: [
// //             MetricItem(
// //               "Total",
// //               marketing["BOM"]?.totalInquiryCount ?? dashboardSummary!.bomCount,
// //             ),
// //           ],
// //         ),
// //
// //         // RMD -> KG / MTR / ROLL
// //         "RMD": DeptCountItem(
// //           title: "RMD",
// //           icon: Icons.settings,
// //           color: Colors.indigo.shade600,
// //           metrics: [
// //             MetricItem("KG", marketing["RMD"]?.netWeight ?? 0),
// //             MetricItem("MTR", marketing["RMD"]?.rollLength ?? 0),
// //             MetricItem("Roll", marketing["RMD"]?.noOfRoll ?? 0),
// //           ],
// //         ),
// //       };
// //
// //       deptCounts = baseList.map((e) => overrides[e.title] ?? e).toList();
// //
// //       if (mounted) {
// //         setState(() => isLoading = false);
// //
// //         _tickerTimer?.cancel();
// //
// //         WidgetsBinding.instance.addPostFrameCallback((_) {
// //           _startTicker();
// //         });
// //       }
// //     } catch (e, s) {
// //       debugPrint(e.toString());
// //       debugPrintStack(stackTrace: s);
// //     }
// //   }
// //
// //   Future<Map<String, MarketingCountModel>> loadDepartmentCounts() async {
// //     final service = DashboardService();
// //
// //     final departments = ["WO", "BOM", "INQUIRY", "RMD"];
// //
// //     final Map<String, MarketingCountModel> result = {};
// //
// //     await Future.wait(
// //       departments.map((dept) async {
// //         try {
// //           final value = await service.getMarketingCount(
// //             unit: widget.unit,
// //             type: dept,
// //             fromDate: widget.fromDate,
// //             toDate: widget.toDate,
// //           );
// //
// //           result[dept] = value;
// //
// //           debugPrint("$dept Loaded");
// //         } catch (e, s) {
// //           debugPrint("$dept Failed");
// //           debugPrint("$e");
// //           debugPrintStack(stackTrace: s);
// //         }
// //       }),
// //     );
// //
// //     return result;
// //   }
// // }
// //
// // enum _ScreenSize { mobile, tablet, desktop }
// //
// // // Small helper so item.color.darken(x) works without pulling in another
// // // package. Drop this in Colorclass.dart (or anywhere globally imported)
// // // if it's not already there.
// // extension _ColorShade on Color {
// //   Color darken([double amount = .1]) {
// //     final hsl = HSLColor.fromColor(this);
// //     final darker = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
// //     return darker.toColor();
// //   }
// // }
//
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../Color/Colorclass.dart';
import '../../InquiryScreen/Marketing/MarketingModel.dart';
import '../../services/DashboardApiServices.dart';
import '../Dashboard Summary.dart';
import 'dashBoardMapper.dart';

class MetricItem {
  final String label;
  final num value;

  const MetricItem(this.label, this.value);
}

class DeptCountItem {
  final String title;
  final IconData icon;
  final List<MetricItem> metrics; // 1..n values per dept
  final Color color;

  const DeptCountItem({
    required this.title,
    required this.icon,
    required this.metrics,
    required this.color,
  });
}

class DashboardTopBarAnimated extends StatefulWidget {
  final String unit;
  final String fromDate;
  final String toDate;
  final VoidCallback? onMenuTap;
  final VoidCallback? onProfileTap;
  final double shrinkFactor;

  const DashboardTopBarAnimated({
    super.key,
    required this.unit,
    required this.fromDate,
    required this.toDate,
    this.onMenuTap,
    this.onProfileTap,
    this.shrinkFactor = 0.0,
  });

  /// Expanded height a caller should reserve (e.g. for a SliverPersistentHeader).
  static const double maxHeaderExtent = 210;

  /// Collapsed height a caller should reserve.
  static const double minHeaderExtent = 96;

  @override
  State<DashboardTopBarAnimated> createState() =>
      _DashboardTopBarAnimatedState();
}

class _DashboardTopBarAnimatedState extends State<DashboardTopBarAnimated>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;
  bool _isPaused = false;
  int currentIndex = 0;
  DashboardSummary? dashboardSummary;
  List<DeptCountItem> deptCounts = [];
  bool isLoading = true;

  final ScrollController _scrollCtrl = ScrollController();
  Timer? _tickerTimer;
  Timer? _refreshTimer;
  double _scrollPos = 0;
  static const double _scrollSpeed = 0.6;
  static const Duration _tickInterval = Duration(milliseconds: 16);

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic),
        );

    _fadeAnim = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeIn);

    _entranceCtrl.forward();

    loadDashboard();

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => loadDashboard(),
    );
  }

  void _startTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(_tickInterval, (_) {
      if (_isPaused) return;
      if (!_scrollCtrl.hasClients) return;

      final maxExtent = _scrollCtrl.position.maxScrollExtent;
      if (maxExtent <= 0) return;

      _scrollPos += _scrollSpeed;

      if (_scrollPos >= maxExtent / 2) {
        _scrollPos = 0;
      }

      _scrollCtrl.jumpTo(
        _scrollPos.clamp(0.0, _scrollCtrl.position.maxScrollExtent),
      );
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _refreshTimer?.cancel();
    _scrollCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  // ── Responsive breakpoints ──
  // mobile < 600, tablet 600–1024, desktop > 1024
  _ScreenSize _sizeOf(double width) {
    if (width < 600) return _ScreenSize.mobile;
    if (width < 1024) return _ScreenSize.tablet;
    return _ScreenSize.desktop;
  }

  double get _t => widget.shrinkFactor.clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screen = _sizeOf(mq.size.width);

    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                C.appBar1.withOpacity(lerpDouble(0.10, 0.0, _t) ?? 0),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _headerRow(screen),
              isLoading
                  ? SizedBox(
                      height: screen == _ScreenSize.mobile ? 130 : 160,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      ),
                    )
                  : _tickerRow(screen),
            ],
          ),
        ),
      ),
    );
  }

  // Title + date range, fades & shrinks away as the header collapses.
  Widget _headerRow(_ScreenSize screen) {
    final opacity = (1 - _t * 2.2).clamp(0.0, 1.0);
    final height = lerpDouble(40, 0, _t.clamp(0.0, 0.6) / 0.6) ?? 0;

    return ClipRect(
      child: Align(
        heightFactor: 1,
        child: SizedBox(
          height: height,
          child: Opacity(
            opacity: opacity,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screen == _ScreenSize.mobile ? 16 : 26,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Overview",
                          style: TextStyle(
                            color: C.textHigh,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          "${widget.fromDate} – ${widget.toDate}  •  ${widget.unit}",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: C.textLow ?? Colors.black54,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: loadDashboard,
                    icon: Icon(Icons.refresh_rounded, color: C.primary),
                    tooltip: "Refresh",
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tickerRow(_ScreenSize screen) {
    if (deptCounts.isEmpty) {
      return SizedBox(
        height: 110,
        child: Center(
          child: Text(
            "No Data",
            style: TextStyle(
              color: C.textHigh,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final doubled = [...deptCounts, ...deptCounts];

    // Bigger base sizes than before, interpolated down to a compact
    // strip as `shrinkFactor` goes 0 -> 1.
    final expandedHeight = switch (screen) {
      _ScreenSize.mobile => 172.0,
      _ScreenSize.tablet => 188.0,
      _ScreenSize.desktop => 204.0,
    };
    final collapsedHeight = switch (screen) {
      _ScreenSize.mobile => 84.0,
      _ScreenSize.tablet => 90.0,
      _ScreenSize.desktop => 96.0,
    };
    final cardHeight = lerpDouble(expandedHeight, collapsedHeight, _t)!;

    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        controller: _scrollCtrl,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: screen == _ScreenSize.mobile ? 14 : 24,
        ),
        itemCount: doubled.length,
        itemBuilder: (_, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Listener(
              onPointerDown: (_) => setState(() => _isPaused = true),
              onPointerUp: (_) => setState(() => _isPaused = false),
              onPointerCancel: (_) => setState(() => _isPaused = false),
              child: _tickerCard(doubled[index], screen, cardHeight),
            ),
          );
        },
      ),
    );
  }

  // ── Card: bigger footprint, clearer hierarchy, shrinks smoothly ──
  Widget _tickerCard(
    DeptCountItem item,
    _ScreenSize screen,
    double cardHeight,
  ) {
    final bool active = deptCounts[currentIndex].title == item.title;
    final int metricCount = item.metrics.length;
    final bool useGrid = metricCount > 3;
    final bool isMobile = screen == _ScreenSize.mobile;
    final bool compact = _t > 0.55;

    final double expMinW = switch (screen) {
      _ScreenSize.mobile => 240.0,
      _ScreenSize.tablet => 270.0,
      _ScreenSize.desktop => 300.0,
    };
    final double expMaxW = switch (screen) {
      _ScreenSize.mobile => 288.0,
      _ScreenSize.tablet => 320.0,
      _ScreenSize.desktop => 350.0,
    };
    final double colMinW = expMinW * 0.72;
    final double colMaxW = expMaxW * 0.72;

    final double minW = lerpDouble(expMinW, colMinW, _t)!;
    final double maxW = lerpDouble(expMaxW, colMaxW, _t)!;

    final Color titleColor = active ? item.color.darken(0.15) : C.textHigh;
    final Color valueColor = active ? item.color.darken(0.25) : C.textHigh;
    final Color labelColor = active
        ? item.color.darken(0.05)
        : (C.textLow ?? Colors.black54);
    final Color dividerColor = active ? item.color.withOpacity(.25) : C.border;

    final double iconSize = lerpDouble(
      isMobile ? 16 : 18,
      isMobile ? 13 : 14,
      _t,
    )!;
    final double titleFont = lerpDouble(
      isMobile ? 12.5 : 14,
      isMobile ? 10.5 : 11.5,
      _t,
    )!;
    final double valueFont = lerpDouble(
      isMobile ? 19 : 21,
      isMobile ? 14 : 15,
      _t,
    )!;
    final double labelFont = lerpDouble(
      isMobile ? 10.5 : 12,
      isMobile ? 9 : 10,
      _t,
    )!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      height: cardHeight,
      constraints: BoxConstraints(minWidth: minW, maxWidth: maxW),
      decoration: BoxDecoration(
        gradient: active
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  item.color.withOpacity(.20),
                  item.color.withOpacity(.06),
                ],
              )
            : null,
        color: active ? null : Colors.white,
        borderRadius: BorderRadius.circular(18),
        // border: Border(
        //   left: BorderSide(color: item.color, width: active ? 4.5 : 3.5),
        //   top: BorderSide(
        //     color: active ? item.color.withOpacity(.3) : C.border,
        //     width: .8,
        //   ),
        //   right: BorderSide(
        //     color: active ? item.color.withOpacity(.3) : C.border,
        //     width: .8,
        //   ),
        //   bottom: BorderSide(
        //     color: active ? item.color.withOpacity(.3) : C.border,
        //     width: .8,
        //   ),
        // ),
        // boxShadow: [
        //   BoxShadow(
        //     color: active
        //         ? item.color.withOpacity(.24)
        //         : Colors.black.withOpacity(.06),
        //     blurRadius: active ? 16 : 8,
        //     offset: const Offset(0, 5),
        //   ),
        // ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          14,
          compact ? 8 : 12,
          14,
          compact ? 8 : 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: icon chip + title + active dot ──
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(compact ? 4 : 7),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(.16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.color, size: iconSize),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.title.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: titleColor,
                      fontWeight: FontWeight.w700,
                      fontSize: titleFont,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (active)
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: item.color.withOpacity(.6),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            if (!compact) ...[
              const SizedBox(height: 9),
              Container(height: 1, color: dividerColor),
              const SizedBox(height: 6),
            ] else
              const SizedBox(height: 4),

            // ── Metrics ──
            Expanded(
              child: useGrid
                  ? _metricGrid(
                      item,
                      isMobile,
                      valueColor,
                      labelColor,
                      valueFont,
                      labelFont,
                    )
                  : _metricRow(
                      item,
                      isMobile,
                      valueColor,
                      labelColor,
                      valueFont,
                      labelFont,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Compact metric row with vertical dividers — for ≤3 metrics
  Widget _metricRow(
    DeptCountItem item,
    bool isMobile,
    Color valueColor,
    Color labelColor,
    double valueFont,
    double labelFont,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < item.metrics.length; i++) ...[
          if (i > 0)
            Container(
              width: 1,
              height: isMobile ? 32 : 36,
              color: Colors.black.withOpacity(.08),
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),
          Expanded(
            child: _metricBlock(
              item.metrics[i],
              valueColor,
              labelColor,
              valueFont,
              labelFont,
            ),
          ),
        ],
      ],
    );
  }

  // Wrap-based grid — for 4+ metrics
  Widget _metricGrid(
    DeptCountItem item,
    bool isMobile,
    Color valueColor,
    Color labelColor,
    double valueFont,
    double labelFont,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double gap = 10;
        final double itemWidth = (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: 8,
          children: item.metrics.map((m) {
            return SizedBox(
              width: itemWidth,
              child: _metricBlock(
                m,
                valueColor,
                labelColor,
                valueFont,
                labelFont,
                boxed: true,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Single metric — big value on top, subtle label below
  Widget _metricBlock(
    MetricItem m,
    Color valueColor,
    Color labelColor,
    double valueFont,
    double labelFont, {
    bool boxed = false,
  }) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            _fmt(m.value),
            maxLines: 1,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w800,
              fontSize: valueFont,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          m.label,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
            color: labelColor,
            fontSize: labelFont,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );

    if (!boxed) return content;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.03),
        borderRadius: BorderRadius.circular(10),
      ),
      child: content,
    );
  }

  String _fmt(num value) {
    if (value >= 1000000000) {
      return "${(value / 1000000000).toStringAsFixed(1)}B";
    }
    if (value >= 1000000) {
      return "${(value / 1000000).toStringAsFixed(1)}M";
    }
    if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(1)}K";
    }
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  Future loadDashboard() async {
    try {
      dashboardSummary = await DashboardService().getDashboard(
        unit: widget.unit,
        fromDate: widget.fromDate,
        toDate: widget.toDate,
      );

      final marketing = await loadDepartmentCounts();

      final rawList = createDepartments(dashboardSummary!);

      final seen = <String>{};
      final baseList = rawList.where((e) => seen.add(e.title)).toList();

      final Map<String, DeptCountItem> overrides = {
        // Inquiry -> ONLY TOTAL
        "INQUIRY": DeptCountItem(
          title: "INQUIRY",
          icon: Icons.query_stats,
          color: Colors.amber.shade700,
          metrics: [
            MetricItem(
              "Total",
              marketing["INQUIRY"]?.totalInquiryCount ??
                  dashboardSummary!.inquiryCount,
            ),
          ],
        ),

        // Work Order -> ONLY TOTAL
        "Work Order": DeptCountItem(
          title: "Work Order",
          icon: Icons.assignment,
          color: Colors.blueGrey.shade600,
          metrics: [
            MetricItem(
              "Total",
              marketing["WO"]?.totalInquiryCount ?? dashboardSummary!.woCount,
            ),
          ],
        ),

        // BOM -> ONLY TOTAL
        "BOM": DeptCountItem(
          title: "BOM",
          icon: Icons.assignment,
          color: Colors.blueGrey.shade600,
          metrics: [
            MetricItem(
              "Total",
              marketing["BOM"]?.totalInquiryCount ?? dashboardSummary!.bomCount,
            ),
          ],
        ),

        // RMD -> KG / MTR / ROLL
        "RMD": DeptCountItem(
          title: "RMD",
          icon: Icons.settings,
          color: Colors.indigo.shade600,
          metrics: [
            MetricItem("KG", marketing["RMD"]?.netWeight ?? 0),
            MetricItem("MTR", marketing["RMD"]?.rollLength ?? 0),
            MetricItem("Roll", marketing["RMD"]?.noOfRoll ?? 0),
          ],
        ),
      };

      deptCounts = baseList.map((e) => overrides[e.title] ?? e).toList();

      if (mounted) {
        setState(() => isLoading = false);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _startTicker();
        });
      }
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: s);
    }
  }

  Future<Map<String, MarketingCountModel>> loadDepartmentCounts() async {
    final service = DashboardService();

    final departments = ["WO", "BOM", "INQUIRY", "RMD"];
    // final departments = ["RMD"];


    final Map<String, MarketingCountModel> result = {};

    await Future.wait(
      departments.map((dept) async {
        try {
          final value = await service.getMarketingCount(
            unit: widget.unit,
            type: dept,
            fromDate: widget.fromDate,
            toDate: widget.toDate,
          );

          result[dept] = value;

          debugPrint("$dept Loaded");
        } catch (e, s) {
          debugPrint("$dept Failed");
          debugPrint("$e");
          debugPrintStack(stackTrace: s);
        }
      }),
    );

    return result;
  }
}

enum _ScreenSize { mobile, tablet, desktop }

// Small helper so item.color.darken(x) works without pulling in another
// package. Drop this in Colorclass.dart (or anywhere globally imported)
// if it's not already there.
extension ColorShade on Color {
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final darker = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darker.toColor();
  }
}

// ─────────────────────────────────────────────
//  SLIVER DELEGATE — makes the top bar collapse as the page scrolls.
//  Wrap DashboardTopBarAnimated in a CustomScrollView like this:
//
//  CustomScrollView(
//    slivers: [
//      SliverPersistentHeader(
//        pinned: true,
//        delegate: DashboardCollapsingHeaderDelegate(
//          unit: unit, fromDate: from, toDate: to,
//        ),
//      ),
//      ...other slivers (chart, lists, etc.)
//    ],
//  )
// ─────────────────────────────────────────────
class DashboardCollapsingHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String unit;
  final String fromDate;
  final String toDate;

  DashboardCollapsingHeaderDelegate({
    required this.unit,
    required this.fromDate,
    required this.toDate,
  });

  @override
  double get maxExtent => DashboardTopBarAnimated.maxHeaderExtent;

  @override
  double get minExtent => DashboardTopBarAnimated.minHeaderExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = maxExtent - minExtent;
    final shrinkFactor = range <= 0
        ? 0.0
        : (shrinkOffset / range).clamp(0.0, 1.0);

    return Material(
      color: Colors.transparent,
      elevation: shrinkFactor > 0.05 ? 3 : 0,
      shadowColor: Colors.black.withOpacity(0.15),
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: DashboardTopBarAnimated(
          unit: unit,
          fromDate: fromDate,
          toDate: toDate,
          shrinkFactor: shrinkFactor,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant DashboardCollapsingHeaderDelegate oldDelegate) {
    return oldDelegate.unit != unit ||
        oldDelegate.fromDate != fromDate ||
        oldDelegate.toDate != toDate;
  }
}





//
// import 'dart:async';
// import 'dart:ui';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import '../../Color/Colorclass.dart';
// import '../../InquiryScreen/Marketing/MarketingModel.dart';
// import '../../services/DashboardApiServices.dart';
// import '../Dashboard Summary.dart';
// import 'dashBoardMapper.dart';
//
// class MetricItem {
//   final String label;
//   final num value;
//
//   const MetricItem(this.label, this.value);
// }
//
// class DeptCountItem {
//   final String title;
//   final IconData icon;
//   final List<MetricItem> metrics; // 1..n values per dept
//   final Color color;
//
//   const DeptCountItem({
//     required this.title,
//     required this.icon,
//     required this.metrics,
//     required this.color,
//   });
// }
//
// class DashboardTopBarAnimated extends StatefulWidget {
//   final String unit;
//   final String fromDate;
//   final String toDate;
//   final VoidCallback? onMenuTap;
//   final VoidCallback? onProfileTap;
//   final double shrinkFactor;
//
//   const DashboardTopBarAnimated({
//     super.key,
//     required this.unit,
//     required this.fromDate,
//     required this.toDate,
//     this.onMenuTap,
//     this.onProfileTap,
//     this.shrinkFactor = 0.0,
//   });
//
//   /// Expanded height a caller should reserve (e.g. for a SliverPersistentHeader).
//   static const double maxHeaderExtent = 210;
//
//   /// Collapsed height a caller should reserve.
//   static const double minHeaderExtent = 96;
//
//   @override
//   State<DashboardTopBarAnimated> createState() =>
//       _DashboardTopBarAnimatedState();
// }
//
// class _DashboardTopBarAnimatedState extends State<DashboardTopBarAnimated>
//     with TickerProviderStateMixin {
//   late final AnimationController _entranceCtrl;
//   late final Animation<Offset> _slideAnim;
//   late final Animation<double> _fadeAnim;
//   bool _isPaused = false;
//   int currentIndex = 0;
//   DashboardSummary? dashboardSummary;
//   List<DeptCountItem> deptCounts = [];
//   bool isLoading = true;
//
//   final ScrollController _scrollCtrl = ScrollController();
//   Timer? _tickerTimer;
//   Timer? _refreshTimer;
//   double _scrollPos = 0;
//   static const double _scrollSpeed = 0.6;
//   static const Duration _tickInterval = Duration(milliseconds: 16);
//
//   @override
//   void initState() {
//     super.initState();
//
//     _entranceCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//
//     _slideAnim = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
//         .animate(
//       CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic),
//     );
//
//     _fadeAnim = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeIn);
//
//     _entranceCtrl.forward();
//
//     loadDashboard();
//
//     _refreshTimer = Timer.periodic(
//       const Duration(seconds: 30),
//           (_) => loadDashboard(),
//     );
//   }
//
//   void _startTicker() {
//     _tickerTimer?.cancel();
//     _tickerTimer = Timer.periodic(_tickInterval, (_) {
//       if (_isPaused) return;
//       if (!_scrollCtrl.hasClients) return;
//
//       final maxExtent = _scrollCtrl.position.maxScrollExtent;
//       if (maxExtent <= 0) return;
//
//       _scrollPos += _scrollSpeed;
//
//       if (_scrollPos >= maxExtent / 2) {
//         _scrollPos = 0;
//       }
//
//       _scrollCtrl.jumpTo(
//         _scrollPos.clamp(0.0, _scrollCtrl.position.maxScrollExtent),
//       );
//     });
//   }
//
//   @override
//   void dispose() {
//     _tickerTimer?.cancel();
//     _refreshTimer?.cancel();
//     _scrollCtrl.dispose();
//     _entranceCtrl.dispose();
//     super.dispose();
//   }
//
//   // ── Responsive breakpoints ──
//   // mobile < 600, tablet 600–1024, desktop > 1024
//   _ScreenSize _sizeOf(double width) {
//     if (width < 600) return _ScreenSize.mobile;
//     if (width < 1024) return _ScreenSize.tablet;
//     return _ScreenSize.desktop;
//   }
//
//   double get _t => widget.shrinkFactor.clamp(0.0, 1.0);
//
//   @override
//   Widget build(BuildContext context) {
//     final mq = MediaQuery.of(context);
//     final screen = _sizeOf(mq.size.width);
//
//     return SlideTransition(
//       position: _slideAnim,
//       child: FadeTransition(
//         opacity: _fadeAnim,
//         child: Container(
//           width: double.infinity,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 C.appBar1.withOpacity(lerpDouble(0.12, 0.0, _t) ?? 0),
//                 Colors.transparent,
//               ],
//             ),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _headerRow(screen),
//               isLoading
//                   ? SizedBox(
//                 height: screen == _ScreenSize.mobile ? 130 : 160,
//                 child: const Center(
//                   child: CircularProgressIndicator(strokeWidth: 2.4),
//                 ),
//               )
//                   : _tickerRow(screen),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Title + date range, fades & shrinks away as the header collapses.
//   Widget _headerRow(_ScreenSize screen) {
//     final opacity = (1 - _t * 2.2).clamp(0.0, 1.0);
//     final height = lerpDouble(44, 0, _t.clamp(0.0, 0.6) / 0.6) ?? 0;
//
//     return ClipRect(
//       child: Align(
//         heightFactor: 1,
//         child: SizedBox(
//           height: height,
//           child: Opacity(
//             opacity: opacity,
//             child: Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: screen == _ScreenSize.mobile ? 16 : 26,
//                 vertical: 8,
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Overview",
//                           style: TextStyle(
//                             color: C.textHigh,
//                             fontWeight: FontWeight.w800,
//                             fontSize: 17,
//                             letterSpacing: 0.1,
//                           ),
//                         ),
//                         const SizedBox(height: 3),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 2,
//                           ),
//                           decoration: BoxDecoration(
//                             color: C.primary.withOpacity(.08),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             "${widget.fromDate} – ${widget.toDate}  •  ${widget.unit}",
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                               color: C.primary,
//                               fontSize: 11,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: C.primary.withOpacity(.08),
//                       shape: BoxShape.circle,
//                     ),
//                     child: IconButton(
//                       onPressed: loadDashboard,
//                       icon: Icon(
//                         Icons.refresh_rounded,
//                         color: C.primary,
//                         size: 20,
//                       ),
//                       tooltip: "Refresh",
//                       visualDensity: VisualDensity.compact,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _tickerRow(_ScreenSize screen) {
//     if (deptCounts.isEmpty) {
//       return SizedBox(
//         height: 110,
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 Icons.inbox_outlined,
//                 color: (C.textLow ?? Colors.black45),
//                 size: 26,
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 "No Data",
//                 style: TextStyle(
//                   color: C.textHigh,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     final doubled = [...deptCounts, ...deptCounts];
//
//     // Bigger base sizes than before, interpolated down to a compact
//     // strip as `shrinkFactor` goes 0 -> 1.
//     final expandedHeight = switch (screen) {
//       _ScreenSize.mobile => 172.0,
//       _ScreenSize.tablet => 188.0,
//       _ScreenSize.desktop => 204.0,
//     };
//     final collapsedHeight = switch (screen) {
//       _ScreenSize.mobile => 84.0,
//       _ScreenSize.tablet => 90.0,
//       _ScreenSize.desktop => 96.0,
//     };
//     final cardHeight = lerpDouble(expandedHeight, collapsedHeight, _t)!;
//
//     return SizedBox(
//       height: cardHeight,
//       child: ListView.builder(
//         controller: _scrollCtrl,
//         scrollDirection: Axis.horizontal,
//         physics: const NeverScrollableScrollPhysics(),
//         padding: EdgeInsets.symmetric(
//           horizontal: screen == _ScreenSize.mobile ? 14 : 24,
//         ),
//         itemCount: doubled.length,
//         itemBuilder: (_, index) {
//           return Padding(
//             padding: const EdgeInsets.only(right: 14),
//             child: Listener(
//               onPointerDown: (_) => setState(() => _isPaused = true),
//               onPointerUp: (_) => setState(() => _isPaused = false),
//               onPointerCancel: (_) => setState(() => _isPaused = false),
//               child: _tickerCard(doubled[index], screen, cardHeight),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // ── Card: flat surface + left-border accent (matches app design system) ──
//   Widget _tickerCard(
//       DeptCountItem item,
//       _ScreenSize screen,
//       double cardHeight,
//       ) {
//     final bool active = deptCounts[currentIndex].title == item.title;
//     final int metricCount = item.metrics.length;
//     final bool useGrid = metricCount > 3;
//     final bool isMobile = screen == _ScreenSize.mobile;
//     final bool compact = _t > 0.55;
//
//     final double expMinW = switch (screen) {
//       _ScreenSize.mobile => 240.0,
//       _ScreenSize.tablet => 270.0,
//       _ScreenSize.desktop => 300.0,
//     };
//     final double expMaxW = switch (screen) {
//       _ScreenSize.mobile => 288.0,
//       _ScreenSize.tablet => 320.0,
//       _ScreenSize.desktop => 350.0,
//     };
//     final double colMinW = expMinW * 0.72;
//     final double colMaxW = expMaxW * 0.72;
//
//     final double minW = lerpDouble(expMinW, colMinW, _t)!;
//     final double maxW = lerpDouble(expMaxW, colMaxW, _t)!;
//
//     final Color titleColor = active ? item.color.darken(0.15) : C.textHigh;
//     final Color valueColor = active ? item.color.darken(0.25) : C.textHigh;
//     final Color labelColor = active
//         ? item.color.darken(0.05)
//         : (C.textLow ?? Colors.black54);
//     final Color dividerColor = active ? item.color.withOpacity(.25) : C.border;
//
//     final double iconSize = lerpDouble(
//       isMobile ? 16 : 18,
//       isMobile ? 13 : 14,
//       _t,
//     )!;
//     final double titleFont = lerpDouble(
//       isMobile ? 12.5 : 14,
//       isMobile ? 10.5 : 11.5,
//       _t,
//     )!;
//     final double valueFont = lerpDouble(
//       isMobile ? 19 : 21,
//       isMobile ? 14 : 15,
//       _t,
//     )!;
//     final double labelFont = lerpDouble(
//       isMobile ? 10.5 : 12,
//       isMobile ? 9 : 10,
//       _t,
//     )!;
//
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       curve: Curves.easeOut,
//       height: cardHeight,
//       constraints: BoxConstraints(minWidth: minW, maxWidth: maxW),
//       decoration: BoxDecoration(
//         gradient: active
//             ? LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             item.color.withOpacity(.16),
//             item.color.withOpacity(.04),
//           ],
//         )
//             : null,
//         color: active ? null : Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border(
//           left: BorderSide(color: item.color, width: active ? 4 : 3),
//           top: BorderSide(
//             color: active ? item.color.withOpacity(.22) : C.border,
//             width: .8,
//           ),
//           right: BorderSide(
//             color: active ? item.color.withOpacity(.22) : C.border,
//             width: .8,
//           ),
//           bottom: BorderSide(
//             color: active ? item.color.withOpacity(.22) : C.border,
//             width: .8,
//           ),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: active
//                 ? item.color.withOpacity(.18)
//                 : Colors.black.withOpacity(.04),
//             blurRadius: active ? 14 : 6,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: EdgeInsets.fromLTRB(
//           14,
//           compact ? 8 : 12,
//           14,
//           compact ? 8 : 12,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Header: icon chip + title + active dot ──
//             Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(compact ? 4 : 7),
//                   decoration: BoxDecoration(
//                     color: item.color.withOpacity(.14),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(item.icon, color: item.color, size: iconSize),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     item.title.toUpperCase(),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                     style: TextStyle(
//                       color: titleColor,
//                       fontWeight: FontWeight.w700,
//                       fontSize: titleFont,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                 ),
//                 if (active)
//                   Container(
//                     width: 7,
//                     height: 7,
//                     margin: const EdgeInsets.only(left: 4),
//                     decoration: BoxDecoration(
//                       color: item.color,
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: item.color.withOpacity(.55),
//                           blurRadius: 5,
//                           spreadRadius: .5,
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//
//             if (!compact) ...[
//               const SizedBox(height: 9),
//               Container(height: 1, color: dividerColor),
//               const SizedBox(height: 6),
//             ] else
//               const SizedBox(height: 4),
//
//             // ── Metrics ──
//             Expanded(
//               child: useGrid
//                   ? _metricGrid(
//                 item,
//                 isMobile,
//                 valueColor,
//                 labelColor,
//                 valueFont,
//                 labelFont,
//               )
//                   : _metricRow(
//                 item,
//                 isMobile,
//                 valueColor,
//                 labelColor,
//                 valueFont,
//                 labelFont,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Compact metric row with vertical dividers — for ≤3 metrics
//   Widget _metricRow(
//       DeptCountItem item,
//       bool isMobile,
//       Color valueColor,
//       Color labelColor,
//       double valueFont,
//       double labelFont,
//       ) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         for (int i = 0; i < item.metrics.length; i++) ...[
//           if (i > 0)
//             Container(
//               width: 1,
//               height: isMobile ? 32 : 36,
//               color: item.color.withOpacity(.14),
//               margin: const EdgeInsets.symmetric(horizontal: 12),
//             ),
//           Expanded(
//             child: _metricBlock(
//               item.metrics[i],
//               valueColor,
//               labelColor,
//               valueFont,
//               labelFont,
//               accent: item.color,
//             ),
//           ),
//         ],
//       ],
//     );
//   }
//
//   // Wrap-based grid — for 4+ metrics
//   Widget _metricGrid(
//       DeptCountItem item,
//       bool isMobile,
//       Color valueColor,
//       Color labelColor,
//       double valueFont,
//       double labelFont,
//       ) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         const double gap = 10;
//         final double itemWidth = (constraints.maxWidth - gap) / 2;
//
//         return Wrap(
//           spacing: gap,
//           runSpacing: 8,
//           children: item.metrics.map((m) {
//             return SizedBox(
//               width: itemWidth,
//               child: _metricBlock(
//                 m,
//                 valueColor,
//                 labelColor,
//                 valueFont,
//                 labelFont,
//                 boxed: true,
//                 accent: item.color,
//               ),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }
//
//   // Single metric — big value on top, subtle label below
//   Widget _metricBlock(
//       MetricItem m,
//       Color valueColor,
//       Color labelColor,
//       double valueFont,
//       double labelFont, {
//         bool boxed = false,
//         Color? accent,
//       }) {
//     final content = Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         FittedBox(
//           fit: BoxFit.scaleDown,
//           alignment: Alignment.centerLeft,
//           child: Text(
//             _fmt(m.value),
//             maxLines: 1,
//             style: TextStyle(
//               color: valueColor,
//               fontWeight: FontWeight.w800,
//               fontSize: valueFont,
//               height: 1.1,
//             ),
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           m.label,
//           overflow: TextOverflow.ellipsis,
//           maxLines: 1,
//           style: TextStyle(
//             color: labelColor,
//             fontSize: labelFont,
//             fontWeight: FontWeight.w600,
//             letterSpacing: 0.2,
//           ),
//         ),
//       ],
//     );
//
//     if (!boxed) return content;
//
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
//       decoration: BoxDecoration(
//         color: (accent ?? Colors.black).withOpacity(.05),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: content,
//     );
//   }
//
//   String _fmt(num value) {
//     if (value >= 1000000000) {
//       return "${(value / 1000000000).toStringAsFixed(1)}B";
//     }
//     if (value >= 1000000) {
//       return "${(value / 1000000).toStringAsFixed(1)}M";
//     }
//     if (value >= 1000) {
//       return "${(value / 1000).toStringAsFixed(1)}K";
//     }
//     if (value == value.roundToDouble()) {
//       return value.toInt().toString();
//     }
//     return value.toStringAsFixed(2);
//   }
//
//   Future loadDashboard() async {
//     try {
//       dashboardSummary = await DashboardService().getDashboard(
//         unit: widget.unit,
//         fromDate: widget.fromDate,
//         toDate: widget.toDate,
//       );
//
//       final marketing = await loadDepartmentCounts();
//
//       final rawList = createDepartments(dashboardSummary!);
//
//       final seen = <String>{};
//       final baseList = rawList.where((e) => seen.add(e.title)).toList();
//
//       final Map<String, DeptCountItem> overrides = {
//         // Inquiry -> ONLY TOTAL
//         "INQUIRY": DeptCountItem(
//           title: "INQUIRY",
//           icon: Icons.query_stats,
//           color: Colors.amber.shade700,
//           metrics: [
//             MetricItem(
//               "Total",
//               marketing["INQUIRY"]?.totalInquiryCount ??
//                   dashboardSummary!.inquiryCount,
//             ),
//           ],
//         ),
//
//         // Work Order -> ONLY TOTAL
//         "Work Order": DeptCountItem(
//           title: "Work Order",
//           icon: Icons.assignment,
//           color: Colors.blueGrey.shade600,
//           metrics: [
//             MetricItem(
//               "Total",
//               marketing["WO"]?.totalInquiryCount ?? dashboardSummary!.woCount,
//             ),
//           ],
//         ),
//
//         // BOM -> ONLY TOTAL
//         "BOM": DeptCountItem(
//           title: "BOM",
//           icon: Icons.assignment,
//           color: Colors.blueGrey.shade600,
//           metrics: [
//             MetricItem(
//               "Total",
//               marketing["BOM"]?.totalInquiryCount ?? dashboardSummary!.bomCount,
//             ),
//           ],
//         ),
//
//         // RMD -> KG / MTR / ROLL
//         "RMD": DeptCountItem(
//           title: "RMD",
//           icon: Icons.settings,
//           color: Colors.indigo.shade600,
//           metrics: [
//             MetricItem("KG", marketing["RMD"]?.netWeight ?? 0),
//             MetricItem("MTR", marketing["RMD"]?.rollLength ?? 0),
//             MetricItem("Roll", marketing["RMD"]?.noOfRoll ?? 0),
//           ],
//         ),
//       };
//
//       deptCounts = baseList.map((e) => overrides[e.title] ?? e).toList();
//
//       if (mounted) {
//         setState(() => isLoading = false);
//
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _startTicker();
//         });
//       }
//     } catch (e, s) {
//       debugPrint(e.toString());
//       debugPrintStack(stackTrace: s);
//     }
//   }
//
//   Future<Map<String, MarketingCountModel>> loadDepartmentCounts() async {
//     final service = DashboardService();
//
//     final departments = ["WO", "BOM", "INQUIRY", "RMD"];
//
//     final Map<String, MarketingCountModel> result = {};
//
//     await Future.wait(
//       departments.map((dept) async {
//         try {
//           final value = await service.getMarketingCount(
//             unit: widget.unit,
//             type: dept,
//             fromDate: widget.fromDate,
//             toDate: widget.toDate,
//           );
//
//           result[dept] = value;
//
//           debugPrint("$dept Loaded");
//         } catch (e, s) {
//           debugPrint("$dept Failed");
//           debugPrint("$e");
//           debugPrintStack(stackTrace: s);
//         }
//       }),
//     );
//
//     return result;
//   }
// }
//
// enum _ScreenSize { mobile, tablet, desktop }
//
// // Small helper so item.color.darken(x) works without pulling in another
// // package. Drop this in Colorclass.dart (or anywhere globally imported)
// // if it's not already there.
// extension ColorShade on Color {
//   Color darken([double amount = .1]) {
//     final hsl = HSLColor.fromColor(this);
//     final darker = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
//     return darker.toColor();
//   }
// }
//
// // ─────────────────────────────────────────────
// //  SLIVER DELEGATE — makes the top bar collapse as the page scrolls.
// //  Wrap DashboardTopBarAnimated in a CustomScrollView like this:
// //
// //  CustomScrollView(
// //    slivers: [
// //      SliverPersistentHeader(
// //        pinned: true,
// //        delegate: DashboardCollapsingHeaderDelegate(
// //          unit: unit, fromDate: from, toDate: to,
// //        ),
// //      ),
// //      ...other slivers (chart, lists, etc.)
// //    ],
// //  )
// // ─────────────────────────────────────────────
// class DashboardCollapsingHeaderDelegate extends SliverPersistentHeaderDelegate {
//   final String unit;
//   final String fromDate;
//   final String toDate;
//
//   DashboardCollapsingHeaderDelegate({
//     required this.unit,
//     required this.fromDate,
//     required this.toDate,
//   });
//
//   @override
//   double get maxExtent => DashboardTopBarAnimated.maxHeaderExtent;
//
//   @override
//   double get minExtent => DashboardTopBarAnimated.minHeaderExtent;
//
//   @override
//   Widget build(
//       BuildContext context,
//       double shrinkOffset,
//       bool overlapsContent,
//       ) {
//     final range = maxExtent - minExtent;
//     final shrinkFactor = range <= 0
//         ? 0.0
//         : (shrinkOffset / range).clamp(0.0, 1.0);
//
//     return Material(
//       color: Colors.transparent,
//       elevation: shrinkFactor > 0.05 ? 3 : 0,
//       shadowColor: Colors.black.withOpacity(0.15),
//       child: Container(
//         color: Theme.of(context).scaffoldBackgroundColor,
//         child: DashboardTopBarAnimated(
//           unit: unit,
//           fromDate: fromDate,
//           toDate: toDate,
//           shrinkFactor: shrinkFactor,
//         ),
//       ),
//     );
//   }
//
//   @override
//   bool shouldRebuild(covariant DashboardCollapsingHeaderDelegate oldDelegate) {
//     return oldDelegate.unit != unit ||
//         oldDelegate.fromDate != fromDate ||
//         oldDelegate.toDate != toDate;
//   }
// }