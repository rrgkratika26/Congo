import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../Color/Colorclass.dart';
import '../../Login/ProfileSCreen.dart';
import '../DepartmentDashboard.dart';

import 'GraphTab.dart';
import 'HeaderView.dart';
import 'Marketingtab.dart';

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

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Header(ctrl: ctrl, isMobile: isMobile),

            Expanded(
              child: IndexedStack(
                index: _navIndex,
                children: [
                  NewAdminDashboard(),

                  ProductionTab(),

                  GraphTab(
                    unit: ctrl.unit.value,
                    department: department,
                    isMobile: isMobile,
                  ),

                  ProfileScreen(),
                ],
              ),
            ),
          ],
        ),
      ),

      // ─────────────────────────────────────────────
      // NORMAL FIXED BOTTOM NAVIGATION
      // ─────────────────────────────────────────────
      bottomNavigationBar: _BottomNav(
        selected: _navIndex,
        onTap: (i) {
          HapticFeedback.selectionClick();

          setState(() {
            _navIndex = i;
          });
        },
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
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: C.brand200),
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
              icon: Icons.all_inbox_outlined,
              label: 'Production',
              selected: selected == 1,
              onTap: () => onTap(1),
            ),

            _NavItem(
              icon: Icons.auto_graph,
              label: 'Analytics',
              selected: selected == 2,
              onTap: () => onTap(2),
            ),

            _NavItem(
              icon: Icons.person_rounded,
              label: 'User',
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

          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: selected ? 25 : 32,
                color: selected ? C.warning : C.textLow,
              ),

              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: C.warning,
                            fontSize: 12,
                            height: 1.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
