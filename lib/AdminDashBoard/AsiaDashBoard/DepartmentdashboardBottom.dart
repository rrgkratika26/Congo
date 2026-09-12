// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import '../../Color/Colorclass.dart';
// import '../../Login/ProfileSCreen.dart';
// import '../DepartmentDashboard.dart';
//
// import 'GraphTab.dart';
// import 'HeaderView.dart';
// import 'Marketingtab.dart';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
//
// import '../../Color/Colorclass.dart';
// import '../../Login/ProfileSCreen.dart';
// import '../DepartmentDashboard.dart';
//
// import 'GraphTab.dart';
// import 'HeaderView.dart';
// import 'Marketingtab.dart';
//
// class DeptBottomNavDashboard extends StatefulWidget {
//   const DeptBottomNavDashboard({super.key});
//
//   @override
//   State<DeptBottomNavDashboard> createState() => _DeptBottomNavDashboardState();
// }
//
// class _DeptBottomNavDashboardState extends State<DeptBottomNavDashboard> {
//   int _navIndex = 0;
//
//   late final DashboardController ctrl;
//   late final String department;
//   late final bool isDepartmentUser;
//   @override
//
//   @override
//   void initState() {
//     super.initState();
//
//     ctrl = Get.isRegistered<DashboardController>()
//         ? Get.find<DashboardController>()
//         : Get.put(DashboardController());
//
//     final args = Get.arguments;
//
//     department = args is Map && args['department'] != null
//         ? args['department'].toString()
//         : ctrl.department.value;
//
//     isDepartmentUser =
//         args is Map && args['isDepartmentUser'] == true;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final mq = MediaQuery.of(context);
//     final isMobile = mq.size.width < 600;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//
//       body: SafeArea(
//         bottom: false,
//         child: Column(
//           children: [
//             Header(ctrl: ctrl, isMobile: isMobile),
//
//             Expanded(
//               child: IndexedStack(
//                 index: _navIndex,
//                 children: isDepartmentUser
//                     ? [
//                   ProductionTab(),
//
//                   GraphTab(
//                     unit: ctrl.unit.value,
//                     department: department,
//                     isMobile: isMobile,
//                   ),
//
//                   ProfileScreen(),
//                 ]
//                     : [
//                   NewAdminDashboard(),
//
//                   ProductionTab(),
//
//                   GraphTab(
//                     unit: ctrl.unit.value,
//                     department: department,
//                     isMobile: isMobile,
//                   ),
//
//                   ProfileScreen(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//
//       bottomNavigationBar: _BottomNav(
//         selected: _navIndex,
//         showHome: !isDepartmentUser,
//         onTap: (i) {
//           HapticFeedback.selectionClick();
//
//           setState(() {
//             _navIndex = i;
//           });
//         },
//       ),
//     );
//   }
// }
//
// class _BottomNav extends StatelessWidget {
//   final int selected;
//   final bool showHome;
//   final ValueChanged<int> onTap;
//
//   const _BottomNav({
//     required this.selected,
//     required this.showHome,
//     required this.onTap,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       child: Container(
//         height: 68,
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: C.brand200),
//         ),
//         child: Row(
//           children: [
//             if (showHome)
//               _NavItem(
//                 icon: Icons.dashboard_rounded,
//                 label: 'Home',
//                 selected: selected == 0,
//                 onTap: () => onTap(0),
//               ),
//
//             _NavItem(
//               icon: Icons.all_inbox_outlined,
//               label: 'Production',
//               selected: selected == (showHome ? 1 : 0),
//               onTap: () => onTap(showHome ? 1 : 0),
//             ),
//
//             _NavItem(
//               icon: Icons.auto_graph,
//               label: 'Analytics',
//               selected: selected == (showHome ? 2 : 1),
//               onTap: () => onTap(showHome ? 2 : 1),
//             ),
//
//             _NavItem(
//               icon: Icons.person_rounded,
//               label: 'User',
//               selected: selected == (showHome ? 3 : 2),
//               onTap: () => onTap(showHome ? 3 : 2),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _NavItem extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final bool selected;
//   final VoidCallback onTap;
//
//   const _NavItem({
//     required this.icon,
//     required this.label,
//     required this.selected,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         behavior: HitTestBehavior.opaque,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 250),
//
//           padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(18),
//             gradient: selected
//                 ? LinearGradient(
//                     colors: [C.bg, C.bg.withOpacity(0.85)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   )
//                 : null,
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 icon,
//                 size: selected ? 25 : 32,
//                 color: selected ? C.warning : C.textLow,
//               ),
//
//               AnimatedSize(
//                 duration: const Duration(milliseconds: 200),
//                 curve: Curves.easeOutCubic,
//                 child: selected
//                     ? Padding(
//                         padding: const EdgeInsets.only(top: 2),
//                         child: Text(
//                           label,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             color: C.warning,
//                             fontSize: 12,
//                             height: 1.0,
//                             fontWeight: FontWeight.w700,
//                             letterSpacing: 0.1,
//                           ),
//                         ),
//                       )
//                     : const SizedBox.shrink(),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../Color/Colorclass.dart';
import '../../Login/ProfileSCreen.dart';
import '../DepartmentDashboard.dart';

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
    // 1. forceDepartment passed directly
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
    debugPrint('======================================');
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isMobile = mq.size.width < 600;

    final bool showHome = !isDepartmentUser;

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ─────────────────────────────────────
            // SAME HEADER
            // ─────────────────────────────────────
            Header(ctrl: ctrl, isMobile: isMobile),

            // ─────────────────────────────────────
            // CONTENT
            // ─────────────────────────────────────
            Expanded(
              child: IndexedStack(
                index: _navIndex,

                children: showHome
                    ? [
                        // HOME
                        NewAdminDashboard(),

                        // PRODUCTION
                        ProductionTab(forceDepartment: department),

                        // ANALYTICS
                        GraphTab(
                          unit: ctrl.unit.value,
                          department: department,
                          isMobile: isMobile,
                        ),

                        // PROFILE
                        ProfileScreen(),
                      ]
                    : [
                        // PRODUCTION
                        ProductionTab(forceDepartment: department),

                        // ANALYTICS
                        GraphTab(
                          unit: ctrl.unit.value,
                          department: department,
                          isMobile: isMobile,
                        ),

                        // PROFILE
                        ProfileScreen(),
                      ],
              ),
            ),
          ],
        ),
      ),

      // ─────────────────────────────────────────
      // SAME BOTTOM NAVIGATION
      // ─────────────────────────────────────────
      bottomNavigationBar: _BottomNav(
        selected: _navIndex,
        showHome: showHome,
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

// ═══════════════════════════════════════════════
// BOTTOM NAVIGATION
// ═══════════════════════════════════════════════

class _BottomNav extends StatelessWidget {
  final int selected;
  final bool showHome;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.selected,
    required this.showHome,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: C.brand200),
        ),
        child: Row(
          children: [
            // HOME
            if (showHome)
              _NavItem(
                icon: Icons.dashboard_rounded,
                label: 'Home',
                selected: selected == 0,
                onTap: () => onTap(0),
              ),

            // PRODUCTION
            _NavItem(
              icon: Icons.all_inbox_outlined,
              label: 'Production',
              selected: selected == (showHome ? 1 : 0),
              onTap: () => onTap(showHome ? 1 : 0),
            ),

            // ANALYTICS
            _NavItem(
              icon: Icons.auto_graph,
              label: 'Analytics',
              selected: selected == (showHome ? 2 : 1),
              onTap: () => onTap(showHome ? 2 : 1),
            ),

            // USER
            _NavItem(
              icon: Icons.person_rounded,
              label: 'User',
              selected: selected == (showHome ? 3 : 2),
              onTap: () => onTap(showHome ? 3 : 2),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// NAV ITEM
// ═══════════════════════════════════════════════

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
