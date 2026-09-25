import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../Color/Colorclass.dart';
import '../../Login/ProfileSCreen.dart';
import '../DepartmentDashboard.dart';

import '../Status_Tracker/StatusTrackerListScreen.dart';
import 'GraphTab.dart';
import 'HeaderView.dart';
import 'Marketingtab.dart';

class DeptBottomNavDashboard extends StatefulWidget {
  final String? forceDepartment;

  const DeptBottomNavDashboard({super.key, this.forceDepartment});

  @override
  State<DeptBottomNavDashboard> createState() => _DeptBottomNavDashboardState();
}

class _DeptBottomNavDashboardState extends State<DeptBottomNavDashboard> {
  // ------------------------------------------------------------
  // SCREEN INDEX
  // 0 = Home
  // 1 = Production
  // 2 = Status Tracker
  // 3 = Analytics
  // 4 = User
  // ------------------------------------------------------------
  int _navIndex = 0;

  late final DashboardController ctrl;
  late String department;
  late bool isDepartmentUser;

  @override
  void initState() {
    super.initState();

    ctrl = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    final args = Get.arguments;

    // Priority:
    // 1. forceDepartment
    // 2. Get.arguments['department']
    // 3. Logged-in user's department
    department =
        widget.forceDepartment?.trim().toUpperCase() ??
        (args is Map && args['department'] != null
            ? args['department'].toString().trim().toUpperCase()
            : ctrl.department.value.trim().toUpperCase());

    isDepartmentUser = args is Map && args['isDepartmentUser'] == true;

    debugPrint('======================================');
    debugPrint('DeptBottomNavDashboard');
    debugPrint('Department: $department');
    debugPrint('Is Department User: $isDepartmentUser');
    debugPrint('Unit: ${ctrl.unit.value}');
    debugPrint('Initial Bottom Index: $_navIndex');
    debugPrint('======================================');
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
            // ====================================================
            // HEADER
            // ====================================================
            Header(ctrl: ctrl, isMobile: isMobile),

            // ====================================================
            // CONTENT
            // ====================================================
            Expanded(
              child: IndexedStack(
                index: _navIndex,

                children: [
                  // ==================================================
                  // INDEX 0 - HOME
                  // ==================================================
                  NewAdminDashboard(),

                  // ==================================================
                  // INDEX 1 - PRODUCTION
                  // ==================================================
                  ProductionTab(forceDepartment: department),
                  StatusTrackerListScreen(),
                  // ==================================================
                  // INDEX 2 - STATUS TRACKER
                  // ==================================================


                  // ==================================================
                  // INDEX 3 - ANALYTICS
                  // ==================================================
                  GraphTab(
                    unit: ctrl.unit.value,
                    department: department,
                    isMobile: isMobile,
                  ),

                  // ==================================================
                  // INDEX 4 - USER
                  // ==================================================
                  ProfileScreen(),
                ],
              ),
            ),
          ],
        ),
      ),

      // ==========================================================
      // BOTTOM NAVIGATION
      // ==========================================================
      bottomNavigationBar: _BottomNav(
        selected: _navIndex,

        onTap: (index) {
          HapticFeedback.selectionClick();

          if (!mounted) return;

          setState(() {
            _navIndex = index;
          });
        },
      ),
    );
  }
}

// =================================================================
// RESPONSIVE BOTTOM NAVIGATION
// =================================================================

class _BottomNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // Responsive values
    final bool isSmallPhone = size.height < 700;
    final bool isTablet = size.width >= 600;

    final double navHeight = isSmallPhone
        ? 58
        : isTablet
        ? 74
        : 68;

    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,

      child: SizedBox(
        height: navHeight,

        child: Material(
          color: Colors.white,
          elevation: 8,

          child: Container(
            width: double.infinity,

            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 6,
              vertical: isSmallPhone ? 3 : 5,
            ),

            decoration: BoxDecoration(
              color: Colors.white,

              border: Border(
                top: BorderSide(
                  color: C.brand200,
                  width: 1,
                ),
              ),
            ),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                // ==================================================
                // PRODUCTION
                // ==================================================
                _NavItem(
                  icon: Icons.all_inbox_outlined,
                  label: 'Production',
                  selected: selected == 1,
                  smallScreen: isSmallPhone,
                  tablet: isTablet,
                  onTap: () => onTap(1),
                ),

                // ==================================================
                // STATUS
                // ==================================================
                _NavItem(
                  icon: Icons.list_alt_outlined,
                  label: 'Status',
                  selected: selected == 2,
                  smallScreen: isSmallPhone,
                  tablet: isTablet,
                  onTap: () => onTap(2),
                ),

                // ==================================================
                // HOME - CENTER
                // ==================================================
                _CenterHomeItem(
                  selected: selected == 0,
                  smallScreen: isSmallPhone,
                  tablet: isTablet,
                  onTap: () => onTap(0),
                ),

                // ==================================================
                // ANALYTICS
                // ==================================================
                _NavItem(
                  icon: Icons.auto_graph,
                  label: 'Analytics',
                  selected: selected == 3,
                  smallScreen: isSmallPhone,
                  tablet: isTablet,
                  onTap: () => onTap(3),
                ),

                // ==================================================
                // USER
                // ==================================================
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'User',
                  selected: selected == 4,
                  smallScreen: isSmallPhone,
                  tablet: isTablet,
                  onTap: () => onTap(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =================================================================
// NORMAL NAV ITEM
// =================================================================

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool smallScreen;
  final bool tablet;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.smallScreen,
    required this.tablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double iconSize = smallScreen
        ? (selected ? 21 : 24)
        : tablet
        ? (selected ? 27 : 30)
        : (selected ? 24 : 28);

    final double fontSize = smallScreen
        ? 9.5
        : tablet
        ? 12
        : 11;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),

          margin: EdgeInsets.symmetric(
            horizontal: tablet ? 4 : 2,
            vertical: smallScreen ? 1 : 2,
          ),

          padding: EdgeInsets.symmetric(
            horizontal: 2,
            vertical: smallScreen ? 1 : 2,
          ),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),

            gradient: selected
                ? LinearGradient(
              colors: [
                C.bg,
                C.bg.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,

            children: [
              Icon(
                icon,
                size: iconSize,
                color: selected
                    ? C.warning
                    : C.textLow,
              ),

              // Show label only when selected
              if (selected)
                Padding(
                  padding: EdgeInsets.only(
                    top: smallScreen ? 0 : 1,
                  ),

                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      color: C.warning,
                      fontSize: fontSize,
                      height: 1.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================================================================
// CENTER HOME ITEM
// =================================================================

class _CenterHomeItem extends StatelessWidget {
  final bool selected;
  final bool smallScreen;
  final bool tablet;
  final VoidCallback onTap;

  const _CenterHomeItem({
    required this.selected,
    required this.smallScreen,
    required this.tablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive Home circle
    final double circleSize = smallScreen
        ? (selected ? 38 : 34)
        : tablet
        ? (selected ? 52 : 46)
        : (selected ? 44 : 40);

    final double iconSize = smallScreen
        ? 21
        : tablet
        ? 28
        : 24;

    final double labelSize = smallScreen
        ? 9.5
        : tablet
        ? 12
        : 11;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),

        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: smallScreen ? 0 : 1,
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,

            children: [
              // ==================================================
              // HOME CIRCLE
              // ==================================================
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),

                width: circleSize,
                height: circleSize,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  gradient: selected
                      ? LinearGradient(
                    colors: [
                      C.primary,
                      C.primaryDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : null,

                  border: selected
                      ? null
                      : Border.all(
                    color: C.brand200,
                    width: 1,
                  ),

                  boxShadow: selected
                      ? [
                    BoxShadow(
                      color: C.primary.withOpacity(0.20),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),

                child: Icon(
                  Icons.home_rounded,
                  size: iconSize,
                  color: selected
                      ? Colors.white
                      : C.textLow,
                ),
              ),

              // ==================================================
              // HOME LABEL
              // ==================================================
              if (selected)
                Padding(
                  padding: EdgeInsets.only(
                    top: smallScreen ? 0 : 1,
                  ),

                  child: Text(
                    'Home',
                    maxLines: 1,

                    style: TextStyle(
                      color: C.warning,
                      fontSize: labelSize,
                      height: 1.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

