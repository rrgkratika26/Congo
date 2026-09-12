import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Color/Colorclass.dart';
import '../../services/DashboardApiServices.dart';

class TopCustomer {
  final String name;
  final num rmdKg;

  const TopCustomer({
    required this.name,
    required this.rmdKg,
  });

  factory TopCustomer.fromJson(Map<String, dynamic> json) {
    return TopCustomer(
      name: (json['customeR_NAME'] ??
          json['customerName'] ??
          '')
          .toString(),

      rmdKg: num.tryParse(
        (json['rmdKg'] ??
            json['rmdKG'] ??
            json['totalRmdKg'] ??
            0)
            .toString(),
      ) ??
          0,
    );
  }
}

class TopCustomersChart extends StatefulWidget {
  final bool isMobile;
  const TopCustomersChart({super.key, required this.isMobile});

  @override
  State<TopCustomersChart> createState() => _TopCustomersChartState();
}

class _TopCustomersChartState extends State<TopCustomersChart> {
  bool _expanded = false;
  bool _loading = true;
  bool _isLoading = true;

  String? _error;
  List<TopCustomer> _customers = [];
  String unitName = '';

  static const List<Color> _barColors = [
    Color(0xFF7C6CE8), // indigo/purple
    Color(0xFF9C6ADE), // purple
    Color(0xFF2FA88A), // teal green
    Color(0xFFE8A33D), // orange
    Color(0xFFEC407A), // pink
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
      _isLoading = true;
      _error = null;
    });
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = DashboardService();
      final data = await service.getTopCustomers(unit:unitName, fromDate: '2026-08-01', toDate: '2026-09-01',);

      // top 5 only, sorted descending
      final sorted = [...data]..sort((a, b) => b.rmdKg.compareTo(a.rmdKg));
      final top5 = sorted.take(5).toList();

      if (!mounted) return;
      setState(() {
        _customers = top5;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Top customers load error: $e');
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 16, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tappable header ──
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_rounded, size: 19, color: Color(0xFFE8A33D)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Top Customers',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: C.primary.withOpacity(.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Horizontal Bar',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: C.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: Colors.black45),
                  ),
                ],
              ),
            ),
          ),

          // ── Collapsible content ──
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _expanded ? _content() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 26),
            const SizedBox(height: 8),
            Text(
              'Unable to load top customers',
              style: const TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_customers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Text('No customer data available',
              style: TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w600)),
        ),
      );
    }

    final maxVal = _customers.map((e) => e.rmdKg).fold<num>(0, (a, b) => a > b ? a : b);
    final axisMax = maxVal <= 0 ? 10.0 : (maxVal * 1.15);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < _customers.length; i++) ...[
            _barRow(_customers[i], _barColors[i % _barColors.length], axisMax),
            if (i != _customers.length - 1) const SizedBox(height: 14),
          ],
          const SizedBox(height: 12),
          _axisLine(axisMax),
        ],
      ),
    );
  }

  Widget _barRow(TopCustomer customer, Color color, double axisMax) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const labelWidth = 92.0;
        final trackWidth = constraints.maxWidth - labelWidth;
        final fraction = axisMax <= 0 ? 0.0 : (customer.rmdKg / axisMax).clamp(0.0, 1.0);
        final barWidth = trackWidth * fraction;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: labelWidth,
              child: Text(
                customer.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  width: barWidth < 28 && customer.rmdKg > 0 ? 28 : barWidth,
                  height: 26,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    NumberFormat('#,##0').format(customer.rmdKg),
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _axisLine(double axisMax) {
    const labelWidth = 92.0;
    const steps = 7;
    final stepVal = axisMax / steps;

    return Padding(
      padding: const EdgeInsets.only(left: labelWidth + 6),
      child: Row(
        children: List.generate(steps + 1, (i) {
          return Expanded(
            child: Text(
              NumberFormat('#,##0').format(stepVal * i),
              textAlign: i == 0 ? TextAlign.left : TextAlign.center,
              style: const TextStyle(fontSize: 9, color: Colors.black38, fontWeight: FontWeight.w600),
            ),
          );
        }),
      ),
    );
  }
}