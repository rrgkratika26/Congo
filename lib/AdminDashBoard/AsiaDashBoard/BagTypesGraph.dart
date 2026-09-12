import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Color/Colorclass.dart';
import '../../services/DashboardApiServices.dart';


class TopBagType {
  final String type;
  final num count;

  const TopBagType({
    required this.type,
    required this.count,
  });

  factory TopBagType.fromJson(Map<String, dynamic> json) {
    return TopBagType(
      type: (
          json['typee'] ??
              json['type'] ??
              json['bagType'] ??
              json['bag_type'] ??
              ''
      ).toString(),

      count: num.tryParse(
        (
            json['count'] ??
                json['Count'] ??
                0
        ).toString(),
      ) ?? 0,
    );
  }
}


// ============================================================
// CHART
// ============================================================

class TopBagTypesChart extends StatefulWidget {
  final bool isMobile;

  const TopBagTypesChart({
    super.key,
    required this.isMobile,
  });

  @override
  State<TopBagTypesChart> createState() => _TopBagTypesChartState();
}


class _TopBagTypesChartState extends State<TopBagTypesChart> {
  bool _expanded = true;
  String unitName = '';
  bool _loading = true;
  String? _error;

  List<TopBagType> _bagTypes = [];

  static const List<Color> _pieColors = [
    Color(0xFF6C5CE7), // Vibrant Purple
    Color(0xFFFF5A5F), // Coral Red
    Color(0xFFFFA726), // Bright Orange
    Color(0xFF26C281), // Emerald Green
    Color(0xFF00B8D9), // Cyan
    Color(0xFF2979FF), // Bright Blue
    Color(0xFFD946EF), // Magenta
    Color(0xFFFDD835), // Golden Yellow
    Color(0xFF00C853), // Green
    Color(0xFFFF4081), // Pink
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }


  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    unitName = prefs.getString('unit') ?? 'UNIT';
    setState(() {
      _loading = true;
      _error = null;
    });
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = DashboardService();

      final data = await service.getTopBagTypes(unit:unitName, fromDate: '2026-08-01', toDate: '2026-09-01',);

      // Sort highest count first
      final sorted = [...data]
        ..sort(
              (a, b) => b.count.compareTo(a.count),
        );

      // Top 5 only
      final top5 = sorted.take(5).toList();

      if (!mounted) return;

      setState(() {
        _bagTypes = top5;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Top bag types load error: $e');

      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }


  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: widget.isMobile ? 16 : 24,
      ),

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

          // ======================================================
          // HEADER
          // ======================================================

          InkWell(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },

            borderRadius: BorderRadius.circular(12),

            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4,
              ),

              child: Row(
                children: [

                  const Icon(
                    Icons.account_tree_rounded,
                    size: 19,
                    color: Color(0xFF6C63FF),
                  ),

                  const SizedBox(width: 8),

                  const Expanded(
                    child: Text(
                      'Popular Bag Types',

                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),


                  // Chart type badge

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
                      'Pie Chart',

                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: C.primary,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),


                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,

                    duration: const Duration(
                      milliseconds: 220,
                    ),

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


          // ======================================================
          // CONTENT
          // ======================================================

          AnimatedSize(
            duration: const Duration(
              milliseconds: 220,
            ),

            curve: Curves.easeInOut,

            child: _expanded
                ? _content()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }


  // ============================================================
  // CONTENT
  // ============================================================

  Widget _content() {

    // ----------------------------------------------------------
    // LOADING
    // ----------------------------------------------------------

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(
          vertical: 50,
        ),

        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
          ),
        ),
      );
    }


    // ----------------------------------------------------------
    // ERROR
    // ----------------------------------------------------------

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 30,
        ),

        child: Column(
          children: [

            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 28,
            ),

            const SizedBox(height: 8),

            const Text(
              'Unable to load bag types',

              style: TextStyle(
                fontSize: 12,
                color: Colors.black45,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            TextButton.icon(
              onPressed: _load,

              icon: const Icon(
                Icons.refresh_rounded,
                size: 16,
              ),

              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }


    // ----------------------------------------------------------
    // EMPTY
    // ----------------------------------------------------------

    if (_bagTypes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(
          vertical: 30,
        ),

        child: Center(
          child: Text(
            'No bag type data available',

            style: TextStyle(
              fontSize: 12,
              color: Colors.black45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }


    // ----------------------------------------------------------
    // TOTAL
    // ----------------------------------------------------------

    final total = _bagTypes.fold<num>(
      0,
          (sum, item) => sum + item.count,
    );


    return Padding(
      padding: const EdgeInsets.only(
        top: 16,
      ),

      child: Column(
        children: [

          // ======================================================
          // PIE CHART
          // ======================================================

          SizedBox(
            height: widget.isMobile ? 250 : 280,

            child: PieChart(
              PieChartData(

                centerSpaceRadius: 0,

                sectionsSpace: 1.5,

                startDegreeOffset: -90,

                sections: List.generate(
                  _bagTypes.length,

                      (index) {
                    final item = _bagTypes[index];

                    final percentage = total <= 0
                        ? 0
                        : (item.count / total) * 100;

                    return PieChartSectionData(

                      value: item.count.toDouble(),

                      color: _pieColors[
                      index % _pieColors.length
                      ],

                      radius: widget.isMobile
                          ? 90
                          : 110,

                      showTitle: false,

                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    );
                  },
                ),

                borderData: FlBorderData(
                  show: false,
                ),

                pieTouchData: PieTouchData(
                  enabled: true,

                  touchCallback: (
                      FlTouchEvent event,
                      PieTouchResponse? response,
                      ) {
                    // Optional touch handling
                  },
                ),
              ),
            ),
          ),


          const SizedBox(height: 12),


          // ======================================================
          // LEGEND
          // ======================================================

          _legend(),
        ],
      ),
    );
  }


  // ============================================================
  // LEGEND
  // ============================================================

  Widget _legend() {

    return Wrap(
      alignment: WrapAlignment.center,

      spacing: 12,

      runSpacing: 8,

      children: List.generate(
        _bagTypes.length,

            (index) {
          final item = _bagTypes[index];

          final color = _pieColors[
          index % _pieColors.length
          ];

          return Row(
            mainAxisSize: MainAxisSize.min,

            children: [

              Container(
                width: 18,
                height: 18,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),

              const SizedBox(width: 5),

              Text(
                item.type,

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}