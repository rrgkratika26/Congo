import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../Color/Colorclass.dart';
import '../../Login/ProfileSCreen.dart';
import '../DepartmentDashboard.dart';

import 'GraphTab.dart';
import 'HeaderView.dart';
import 'Marketingtab.dart';

class DeptDashboard extends StatefulWidget {
  const DeptDashboard({super.key});

  @override
  State<DeptDashboard> createState() => _DeptDashboardState();
}

class _DeptDashboardState extends State<DeptDashboard> {
  int _navIndex = 0;
  late final DashboardController ctrl;
  late final String department;

  @override
  void initState() {
    super.initState();
    ctrl = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    department = (Get.arguments != null && Get.arguments['department'] != null)
        ? Get.arguments['department'] as String
        : ctrl.department.value;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isMobile = mq.size.width < 600;

    final pages = [
      NewAdminDashboard(),
      ProductionTab(),
      GraphTab(
        unit: ctrl.unit.value,
        department: department,
        isMobile: isMobile,
      ),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: C.bg,

      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Header(ctrl: ctrl, isMobile: isMobile),

                Expanded(
                  child: IndexedStack(
                    index: _navIndex,
                    children: [
                      // Dashboard
                      NewAdminDashboard(),

                      // Production
                      ProductionTab(),

                      // Analytics
                      GraphTab(
                        unit: ctrl.unit.value,
                        department: department,
                        isMobile: isMobile,
                      ),

                      // Profile
                      ProfileScreen(),
                    ],
                  ),
                ),
              ],
            ),

            Positioned(
              left: isMobile ? 16 : 80,
              right: isMobile ? 16 : 80,
              bottom: isMobile ? 16 : 24,
              child: _BottomNav(
                selected: _navIndex,
                onTap: (i) {
                  HapticFeedback.selectionClick();

                  setState(() {
                    _navIndex = i;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      shadowColor: Colors.black.withOpacity(.18),
      borderRadius: BorderRadius.circular(28),
      color: Colors.white,
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.grey.withOpacity(.08)),
        ),
        child: Row(
          children: [
            _NavItem(
              icon: Icons.dashboard_rounded,
              label: 'Home',
              selected: selected == 0,
              onTap: () => onTap(0),
            ),

            _NavItem(
              icon: Icons.precision_manufacturing_rounded,
              label: 'Production',
              selected: selected == 1,
              onTap: () => onTap(1),
            ),

            _NavItem(
              icon: Icons.analytics_rounded,
              label: 'Analytics',
              selected: selected == 2,
              onTap: () => onTap(2),
            ),

            _NavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              selected: selected == 3,
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: selected
                ? LinearGradient(
                    colors: [C.bg, C.bg.withOpacity(0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: selected ? 1.05 : 1,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  size: 22,
                  color: selected ? C.warning : C.appBar4,
                ),
              ),

              if (selected) ...[
                const SizedBox(height: 7),

                Flexible(
                  child: AnimatedOpacity(
                    opacity: selected ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: C.warning,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
