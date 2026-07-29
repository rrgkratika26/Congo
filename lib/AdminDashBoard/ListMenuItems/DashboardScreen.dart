import 'package:flutter/material.dart';

import '../../Color/Colorclass.dart';
import 'DashboardBottomNavigation.dart';
import 'DashboardTopBarAnimated.dart';



class DashboardScreenExample extends StatefulWidget {
  final String unit;
  final String fromDate;
  final String toDate;

  const DashboardScreenExample({
    super.key,
    required this.unit,
    required this.fromDate,
    required this.toDate,
  });

  @override
  State<DashboardScreenExample> createState() => _DashboardScreenExampleState();
}

class _DashboardScreenExampleState extends State<DashboardScreenExample> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.pageBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: DashboardCollapsingHeaderDelegate(
                unit: widget.unit,
                fromDate: widget.fromDate,
                toDate: widget.toDate,
              ),
            ),

            // Chart — needs the same deptCounts your top bar loaded.
            // Simplest wiring: lift deptCounts state up one level (e.g. via
            // a GetX controller) instead of re-fetching here. Placeholder
            // below assumes a `controller.deptCounts` Rx list.
            //
            // SliverToBoxAdapter(
            //   child: Obx(() => DashboardChartCard(
            //     deptCounts: controller.deptCounts,
            //   )),
            // ),

            SliverToBoxAdapter(child: const SizedBox(height: 12)),

            // ...rest of your dashboard content (recent activity, lists, etc.)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Rest of dashboard content goes here",
                  style: TextStyle(color: C.textLow ?? Colors.black45),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: DashboardBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        items: const [
          NavItemData(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: "Dashboard",
          ),
          NavItemData(
            icon: Icons.insert_chart_outlined_rounded,
            activeIcon: Icons.insert_chart_rounded,
            label: "Reports",
          ),
          NavItemData(
            icon: Icons.apps_outlined,
            activeIcon: Icons.apps_rounded,
            label: "Departments",
          ),
          NavItemData(icon: Icons.more_horiz_rounded, label: "More"),
        ],
      ),
    );
  }
}