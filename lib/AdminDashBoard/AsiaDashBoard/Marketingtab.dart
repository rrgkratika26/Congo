import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Color/Colorclass.dart';
import '../../Login/ProfileSCreen.dart';
import '../../ScannedItem/Cutting/CuttinIN/CuttingScreen.dart';
import '../../routes/app_routes.dart';
import '../../util/sharedpreference/shared_preference.dart';
import '../ActionButtonWidget.dart';
import '../DashBoard.dart';
import '../DepartmentDashboard.dart';

class _DeptItem {
  final String title;
  final IconData icon;
  final Color color;
  const _DeptItem({required this.title, required this.icon, required this.color});
}

// ─────────────────────────────────────────────
//  DESIGN TOKENS (kept local so Colorclass.dart doesn't need edits)
// ─────────────────────────────────────────────
class _Palette {
  // Neutral surface tones
  static const bg = Color(0xFFF5F7FB);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFEDF0F6);

  // Department accent colors — one distinct hue per department so the
  // grid reads as a color-coded map, not a wall of identical tiles.
  static const marketing = Color(0xFFFF7A59);
  static const planning = Color(0xFF6C5CE7);
  static const loom = Color(0xFF3D8EF7);
  static const rmd = Color(0xFF00B4A6);
  static const lamination = Color(0xFF9C6ADE);
  static const cutting = Color(0xFFEF6C6C);
  static const bag = Color(0xFFE8A33D);
  static const baling = Color(0xFF4C9F70);
  static const webbing = Color(0xFF2FB6C4);
  static const tapeline = Color(0xFF5C7CFA);
  static const dispatch = Color(0xFFFF9A3C);
  static const fallback = Color(0xFF6B7FD4);

  static Color forDept(String dept) {
    final d = dept.toUpperCase().replaceFirst('JBL ', '');
    switch (d) {
      case 'MARKETING':
        return marketing;
      case 'PLANNING':
        return planning;
      case 'LOOM':
        return loom;
      case 'RMD':
        return rmd;
      case 'LAMINATION':
        return lamination;
      case 'CUTTING':
        return cutting;
      case 'BAG':
        return bag;
      case 'BALING':
        return baling;
      case 'WEBBING':
        return webbing;
      case 'TAPELINE':
        return tapeline;
      case 'DISPATCH':
        return dispatch;
      default:
        return fallback;
    }
  }
}

List<MenuAction> getActionsForMenu(String dept) {
  switch (dept.toUpperCase()) {
    case 'INQUIRY':
      return [
        MenuAction.Inquirey_Report,
        MenuAction.Bom_Report,
        MenuAction.bomList,
        MenuAction.Issue_to_QC,
      ];
    case 'PLANNING':
      return [
        MenuAction.Order_Planning,
        MenuAction.Order_Composition,
        MenuAction.manual_Planning,
        MenuAction.combine_To_Loom,
      ];
    case 'LOOM':
      return [
        MenuAction.IN,
        MenuAction.saved_List,
        MenuAction.Out_Report,
        MenuAction.loom_forward_Report,
      ];
    case 'JBL LOOM':
      return [MenuAction.IN, MenuAction.report];
    case 'RMD':
      return [
        MenuAction.IN,
        MenuAction.OUT,
        MenuAction.In_Report,
        MenuAction.Out_Report,
        MenuAction.Roll_Entry,
        MenuAction.saved_List,
        MenuAction.stock,
        MenuAction.update_Location,
      ];
    case 'JBL RMD':
      return [MenuAction.IN, MenuAction.OUT, MenuAction.Stock_Report];
    case 'LAMINATION':
      return [
        MenuAction.IN,
        MenuAction.OUT,
        MenuAction.In_Report,
        MenuAction.Out_Report,
      ];
    case 'JBL LAMINATION':
      return [MenuAction.IN];
    case 'CUTTING':
      return [
        MenuAction.IN,
        MenuAction.OUT,
        MenuAction.In_Report,
        MenuAction.rollWise,
        MenuAction.component_Wise,
        MenuAction.cutting_Wise,
        MenuAction.stock,
        MenuAction.Approval,
        MenuAction.Pcs_Issue,
      ];
    case 'JBL CUTTING':
      return [MenuAction.IN];
    case 'BAG':
      return [MenuAction.entry, MenuAction.report];
    case 'JBL BAG':
      return [MenuAction.entry];
    case 'BALING':
      return [
        MenuAction.entry,
        MenuAction.bailing_Report,
        MenuAction.dispatch,
        MenuAction.stock,
      ];
    case 'JBL BALING':
      return [MenuAction.entry];
    case 'WEBBING':
      return [
        MenuAction.entry,
        MenuAction.saved_List,
        MenuAction.IN,
        MenuAction.OUT,
        MenuAction.report,
      ];
    case 'JBL WEBBING':
      return [MenuAction.IN];
    case 'TAPELINE':
      return [
        MenuAction.IN,
        MenuAction.recent_entries,
        MenuAction.OUT,
        MenuAction.In_Report,
        MenuAction.Out_Report,
        MenuAction.Stock_Report,
      ];
    case 'MARKETING':
      return [
        MenuAction.Inquirey_Report,
        MenuAction.Bom_Report,
        MenuAction.Issue_to_QC,
        MenuAction.Bom_List_remain,
      ];
    case 'JBL DISPATCH':
      return [MenuAction.entry];
    default:
      return [MenuAction.IN];
  }
}

// ─────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────
class ProductionTab extends StatelessWidget {
  final String? forceDepartment;
  const ProductionTab({super.key, this.forceDepartment});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(DashboardController());

    return Obx(() {
      if (!ctrl.isLoaded.value) {
        return Scaffold(
          backgroundColor: _Palette.bg,
          body: const Center(
            child: CircularProgressIndicator(color: _Palette.fallback),
          ),
        );
      }

      if (ctrl.isPAdmin) {
        return AdminDashboard(ctrl: ctrl);
      } else {
        final dept = forceDepartment ?? ctrl.department.value;
        return _DeptDashboard(ctrl: ctrl, department: dept);
      }
    });
  }
}

// ─────────────────────────────────────────────
//  PADMIN DASHBOARD
// ─────────────────────────────────────────────
class AdminDashboard extends StatelessWidget {
  final DashboardController ctrl;

  AdminDashboard({required this.ctrl});

  List<_DeptItem> get items => ctrl.isJBL ? _jblItems : _allItems;

  static final _jblItems = [
    _DeptItem(title: 'JBL LOOM', icon: Icons.looks, color: _Palette.loom),
    _DeptItem(title: 'JBL RMD', icon: Icons.inventory, color: _Palette.rmd),
    _DeptItem(title: 'JBL LAMINATION', icon: Icons.layers, color: _Palette.lamination),
    _DeptItem(title: 'JBL CUTTING', icon: Icons.cut, color: _Palette.cutting),
    _DeptItem(title: 'JBL BAG', icon: Icons.shopping_bag, color: _Palette.bag),
    _DeptItem(title: 'JBL BALING', icon: Icons.waves, color: _Palette.baling),
    _DeptItem(title: 'JBL DISPATCH', icon: Icons.local_shipping, color: _Palette.dispatch),
    _DeptItem(title: 'JBL WEBBING', icon: Icons.web, color: _Palette.webbing),
  ];

  static final _allItems = [
    _DeptItem(title: 'MARKETING', icon: Icons.bar_chart_rounded, color: _Palette.marketing),
    _DeptItem(title: 'PLANNING', icon: Icons.next_plan_rounded, color: _Palette.planning),
    _DeptItem(title: 'LOOM', icon: Icons.looks, color: _Palette.loom),
    _DeptItem(title: 'RMD', icon: Icons.inventory, color: _Palette.rmd),
    _DeptItem(title: 'LAMINATION', icon: Icons.layers, color: _Palette.lamination),
    _DeptItem(title: 'CUTTING', icon: Icons.cut, color: _Palette.cutting),
    _DeptItem(title: 'BAG', icon: Icons.shopping_bag, color: _Palette.bag),
    _DeptItem(title: 'BALING', icon: Icons.waves, color: _Palette.baling),
    _DeptItem(title: 'WEBBING', icon: Icons.web, color: _Palette.webbing),
    _DeptItem(title: 'TAPELINE', icon: Icons.dashboard_rounded, color: _Palette.tapeline),
  ];

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isMobile = mq.size.width < 600;
    final crossCount = isMobile ? 2 : (mq.size.width < 1000 ? 3 : 4);

    return Scaffold(
      backgroundColor: _Palette.bg,
      drawer: _AppDrawer(ctrl: ctrl, items: items),
      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 16 : 24,
                  isMobile ? 18 : 22,
                  isMobile ? 16 : 24,
                  isMobile ? 16 : 24,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.05,
                ),
                itemCount: items.length,
                itemBuilder: (ctx, i) => _DeptCard(
                  item: items[i],
                  ctrl: ctrl,
                  isMobile: isMobile,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _DeptDashboard extends StatelessWidget {
  final DashboardController ctrl;
  final String department;
  const _DeptDashboard({required this.ctrl, required this.department});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isMobile = mq.size.width < 600;
    final actions = getActionsForMenu(department);
    final crossCount = isMobile ? 2 : (mq.size.width < 1000 ? 3 : 4);
    final accent = _Palette.forDept(department);

    return Scaffold(
      backgroundColor: _Palette.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar ──────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 32,
                vertical: isMobile ? 18 : 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [C.appBar1, C.appBar1.withOpacity(.85)],
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Get.offAllNamed(AppRoutes.login);
                      Get.back();
                    },
                  ),
                  SizedBox(width: isMobile ? 8 : 16),
                  Expanded(
                    child: Obx(
                          () => Text(
                        ctrl.user.value,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 19 : 24,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Obx(
                        () => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.16),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(.3)),
                      ),
                      child: Text(
                        ctrl.unit.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Dept title ───────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 20 : 32,
                isMobile ? 20 : 26,
                isMobile ? 20 : 32,
                4,
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 30,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          department.toUpperCase(),
                          style: TextStyle(
                            fontSize: isMobile ? 22 : 28,
                            fontWeight: FontWeight.w800,
                            color: _Palette.textPrimary,
                            letterSpacing: .4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${actions.length} actions available',
                          style: TextStyle(
                            fontSize: isMobile ? 12.5 : 14,
                            color: _Palette.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Actions grid ─────────────────────────
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.05,
                ),
                itemCount: actions.length,
                itemBuilder: (ctx, i) => _ActionCard(
                  action: actions[i],
                  isMobile: isMobile,
                  accent: accent,
                  onTap: () => _navigate(ctx, department, actions[i]),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 4),
              child: Center(
                child: TextButton.icon(
                  onPressed: () async {
                    final confirm = await Get.dialog(
                      AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text(
                          "Logout",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        content: const Text("Are you sure you want to logout?"),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(result: false),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: C.textHigh),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => Get.back(result: true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: C.danger,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Logout"),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      ctrl.logout();
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, size: 18, color: C.danger),
                  label: Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: isMobile ? 15 : 17,
                      fontWeight: FontWeight.w700,
                      color: C.danger,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: C.danger.withOpacity(.08),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DEPT CARD (PADMIN grid)
// ─────────────────────────────────────────────
class _DeptCard extends StatelessWidget {
  final _DeptItem item;
  final DashboardController ctrl;
  final bool isMobile;
  const _DeptCard({
    required this.item,
    required this.ctrl,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Get.to(
              () => _DeptDashboard(ctrl: ctrl, department: item.title),
          transition: Transition.cupertino,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _Palette.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _Palette.border),
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(.14),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isMobile ? 54 : 64,
              height: isMobile ? 54 : 64,
              decoration: BoxDecoration(
                color: item.color.withOpacity(.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                item.icon,
                color: item.color,
                size: isMobile ? 28 : 32,
              ),
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: isMobile ? 12.5 : 15,
                  color: _Palette.textPrimary,
                  letterSpacing: .2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ACTION CARD (Dept grid)
// ─────────────────────────────────────────────
class _ActionCard extends StatelessWidget {
  final MenuAction action;
  final bool isMobile;
  final Color accent;
  final VoidCallback onTap;
  const _ActionCard({
    required this.action,
    required this.isMobile,
    required this.accent,
    required this.onTap,
  });

  // Icon chosen by the semantic *type* of action, so every department
  // still gets a recognizable glyph instead of a generic arrow.
  IconData get _icon {
    switch (action) {
      case MenuAction.IN:
        return Icons.login_rounded;
      case MenuAction.OUT:
        return Icons.logout_rounded;
      case MenuAction.report:
      case MenuAction.bailing_Report:
        return Icons.find_in_page_rounded;
      case MenuAction.In_Report:
      case MenuAction.Stock_Report:
      case MenuAction.loom_forward_Report:
      case MenuAction.Out_Report:
        return Icons.bar_chart_rounded;
      case MenuAction.stock:
      case MenuAction.bail_Stock:
        return Icons.inventory_2_rounded;
      case MenuAction.entry:
        return Icons.edit_note_rounded;
      case MenuAction.dispatch:
        return Icons.local_shipping_rounded;
      case MenuAction.scan:
        return Icons.qr_code_scanner_rounded;
      case MenuAction.Approval:
        return Icons.check_circle_outline_rounded;
      case MenuAction.Pcs_Issue:
        return Icons.assignment_rounded;
      case MenuAction.Inquirey_Report:
        return Icons.question_answer_rounded;
      case MenuAction.Order_Planning:
        return Icons.next_plan_rounded;
      case MenuAction.Order_Composition:
        return Icons.reorder_rounded;
      case MenuAction.combine_To_Loom:
        return Icons.merge_type_rounded;
      case MenuAction.manual_Planning:
        return Icons.queue_play_next_rounded;
      case MenuAction.Webbing_Ledger:
        return Icons.menu_book_rounded;
      case MenuAction.saved_List:
        return Icons.save_alt_rounded;
      case MenuAction.recent_entries:
        return Icons.history_rounded;
      case MenuAction.update_Location:
        return Icons.location_on_rounded;
      case MenuAction.Roll_Entry:
        return Icons.add_box_rounded;
      case MenuAction.rollWise:
        return Icons.view_agenda_rounded;
      case MenuAction.component_Wise:
        return Icons.category_rounded;
      case MenuAction.cutting_Wise:
        return Icons.content_cut_rounded;
      case MenuAction.Bom_Report:
        return Icons.description_rounded;
      case MenuAction.bomList:
      case MenuAction.Bom_List_remain:
        return Icons.list_alt_rounded;
      case MenuAction.Issue_to_QC:
        return Icons.fact_check_rounded;
      default:
        return Icons.arrow_forward_ios_rounded;
    }
  }

  // Color is grouped by the *function* of the action (inbound, outbound,
  // reporting, stock, workflow) rather than tied 1:1 to the icon, so a
  // user can tell at a glance "green = report" across every department,
  // while `accent` (the department color) still tints the tap ripple.
  Color get _color {
    switch (action) {
      case MenuAction.IN:
        return const Color(0xFF3D8EF7); // inbound — blue
      case MenuAction.OUT:
        return const Color(0xFFEF6C6C); // outbound — red
      case MenuAction.report:
      case MenuAction.In_Report:
      case MenuAction.Out_Report:
      case MenuAction.Stock_Report:
      case MenuAction.loom_forward_Report:
      case MenuAction.bailing_Report:
      case MenuAction.Inquirey_Report:
      case MenuAction.Bom_Report:
        return const Color(0xFF2FA88A); // reports — teal green
      case MenuAction.stock:
      case MenuAction.bail_Stock:
        return const Color(0xFFB47FD8); // stock — purple
      case MenuAction.dispatch:
        return const Color(0xFFFF9A3C); // dispatch — orange
      case MenuAction.Approval:
        return const Color(0xFF4CAF9A); // approval — green
      case MenuAction.entry:
      case MenuAction.Roll_Entry:
        return const Color(0xFF6C5CE7); // entry — indigo
      case MenuAction.saved_List:
      case MenuAction.recent_entries:
        return const Color(0xFF5C7CFA); // history/saved — soft blue
      case MenuAction.Pcs_Issue:
      case MenuAction.Issue_to_QC:
        return const Color(0xFFE8A33D); // issue — amber
      default:
        return accent; // fall back to department accent color
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        splashColor: _color.withOpacity(.12),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          decoration: BoxDecoration(
            color: _Palette.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _Palette.border),
            boxShadow: [
              BoxShadow(
                color: _color.withOpacity(.14),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isMobile ? 52 : 62,
                height: isMobile ? 52 : 62,
                decoration: BoxDecoration(
                  color: _color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_icon, color: _color, size: isMobile ? 26 : 30),
              ),
              SizedBox(height: isMobile ? 10 : 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  action.name.replaceAll('_', ' ').toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: isMobile ? 11 : 13,
                    color: _Palette.textPrimary,
                    letterSpacing: .3,
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

// ─────────────────────────────────────────────
//  DRAWER  (PADMIN only)
// ─────────────────────────────────────────────
class _AppDrawer extends StatelessWidget {
  final DashboardController ctrl;
  final List<_DeptItem> items;
  const _AppDrawer({required this.ctrl, required this.items});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Drawer(
      width: isMobile ? MediaQuery.of(context).size.width * .82 : 320,
      backgroundColor: _Palette.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [C.primary, C.primary.withOpacity(.85)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white24,
                        child: IconButton(
                          onPressed: () {
                            Get.to(() => ProfileScreen());
                          },
                          icon: const Icon(
                            Icons.person,
                            color: C.secondaryLight,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Obx(
                              () => Text(
                            ctrl.user.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(
                        () => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.factory, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              ctrl.unit.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Dept list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 2),
                itemBuilder: (ctx, i) {
                  final item = items[i];
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: item.color, size: 20),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _Palette.textPrimary,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      Get.to(
                            () => _DeptDashboard(ctrl: ctrl, department: item.title),
                        transition: Transition.cupertino,
                      );
                    },
                  );
                },
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: [
                  const Divider(),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: ctrl.logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  NAVIGATION HELPER
// ─────────────────────────────────────────────
void _navigate(BuildContext ctx, String dept, MenuAction action) {
  final isJBL = dept.toUpperCase().contains('JBL');

  if (isJBL) {
    switch (dept.toUpperCase()) {
      case 'JBL LOOM':
        if (action == MenuAction.IN)
          Get.toNamed(AppRoutes.loomList);
        else if (action == MenuAction.report)
          Get.toNamed(AppRoutes.loomIn);
        break;
      case 'JBL RMD':
        if (action == MenuAction.IN)
          Get.toNamed(AppRoutes.jblRmdIn);
        else if (action == MenuAction.OUT)
          Get.toNamed(AppRoutes.jblRmdOut);
        else if (action == MenuAction.Stock_Report)
          Get.toNamed(AppRoutes.jblRmdStockReports);
        break;
      case 'JBL LAMINATION':
        if (action == MenuAction.IN) Get.toNamed(AppRoutes.jblLamination);
        break;
      case 'JBL CUTTING':
        if (action == MenuAction.IN) Get.toNamed(AppRoutes.jblCuttingIn);
        break;
      case 'JBL BAG':
        if (action == MenuAction.entry) Get.toNamed(AppRoutes.jblBagStoreIssue);
        break;
      case 'JBL BALING':
        if (action == MenuAction.entry) Get.toNamed(AppRoutes.jblBailing);
        break;
      case 'JBL DISPATCH':
        if (action == MenuAction.entry) Get.toNamed(AppRoutes.jblScan);
        break;
      case 'JBL WEBBING':
        if (action == MenuAction.IN) Get.toNamed(AppRoutes.jblWebbIn);
        break;
    }
    return;
  }

  switch (dept.toUpperCase()) {
    case 'MARKETING':
      if (action == MenuAction.Inquirey_Report)
        Get.toNamed(AppRoutes.InquiryMarketingReport);
      if (action == MenuAction.Bom_Report) Get.toNamed(AppRoutes.bomReport);
      if (action == MenuAction.Bom_List_remain) {
        Get.toNamed(AppRoutes.bomList);
      }
      if (action == MenuAction.Issue_to_QC) Get.toNamed(AppRoutes.Issue_to_QC);
      break;
    case 'PLANNING':
      if (action == MenuAction.Order_Planning)
        Get.toNamed(AppRoutes.orderPlanning);
      else if (action == MenuAction.Order_Composition)
        Get.toNamed(AppRoutes.orderComposition);
      else if (action == MenuAction.combine_To_Loom)
        Get.toNamed(AppRoutes.toLoom);
      else if (action == MenuAction.manual_Planning)
        Get.toNamed(AppRoutes.manualToLoom);
      break;
    case 'LOOM':
      if (action == MenuAction.IN)
        Get.toNamed(AppRoutes.loomIn);
      else if (action == MenuAction.saved_List)
        Get.toNamed(AppRoutes.loomSaveList);
      else if (action == MenuAction.Out_Report)
        Get.toNamed(AppRoutes.loomReports);
      else if (action == MenuAction.loom_forward_Report)
        Get.toNamed(AppRoutes.manualPlanningReports);
      break;
    case 'RMD':
      if (action == MenuAction.IN)
        Get.toNamed(AppRoutes.rmdIn);
      else if (action == MenuAction.OUT)
        Get.toNamed(AppRoutes.rmdOut);
      else if (action == MenuAction.Roll_Entry)
        Get.toNamed(AppRoutes.rollEntry);
      else if (action == MenuAction.saved_List)
        Get.toNamed(AppRoutes.rmdRollSavedList);
      else if (action == MenuAction.In_Report)
        Get.toNamed(AppRoutes.rmdNardanaInReports);
      else if (action == MenuAction.Out_Report)
        Get.toNamed(AppRoutes.rmdNardanaOutReports);
      else if (action == MenuAction.stock)
        Get.toNamed(AppRoutes.rmdNardanaStock);
      else if (action == MenuAction.update_Location)
        Get.toNamed(AppRoutes.rmdUpdateLocation);
      break;
    case 'LAMINATION':
      if (action == MenuAction.IN)
        Get.toNamed(AppRoutes.lamination);
      else if (action == MenuAction.OUT)
        Get.toNamed(AppRoutes.laminationOutStock);
      else if (action == MenuAction.In_Report)
        Get.toNamed(AppRoutes.lamNaradanaInReport);
      else if (action == MenuAction.Out_Report)
        Get.toNamed(AppRoutes.lamNaradanaOutReport);
      break;
    case 'CUTTING':
      if (action == MenuAction.IN)
        Get.to(() => CuttingScreen());
      else if (action == MenuAction.In_Report)
        Get.toNamed(AppRoutes.nardanaInReport);
      else if (action == MenuAction.OUT)
        Get.toNamed(AppRoutes.nardanaCutOutList);
      else if (action == MenuAction.rollWise)
        Get.toNamed(AppRoutes.rollWiseReport);
      else if (action == MenuAction.component_Wise)
        Get.toNamed(AppRoutes.componentWiseReport);
      else if (action == MenuAction.cutting_Wise)
        Get.toNamed(AppRoutes.cuttingWiseReport);
      else if (action == MenuAction.stock)
        Get.toNamed(AppRoutes.cutGroupStock);
      else if (action == MenuAction.Approval)
        Get.toNamed(AppRoutes.cuttingnardana);
      else if (action == MenuAction.Pcs_Issue)
        Get.toNamed(AppRoutes.cuttingIssuenardana);
      break;
    case 'PRINTING':
      if (action == MenuAction.IN)
        Get.toNamed(AppRoutes.printingIn);
      else if (action == MenuAction.OUT)
        Get.toNamed(AppRoutes.printingOut);
      else if (action == MenuAction.In_Report)
        Get.toNamed(AppRoutes.printingInReport);
      else if (action == MenuAction.Out_Report)
        Get.toNamed(AppRoutes.printingOutReport);
      break;
    case 'BAG':
      if (action == MenuAction.entry)
        Get.toNamed(AppRoutes.bagEntry);
      else if (action == MenuAction.report)
        Get.toNamed(AppRoutes.bagReport);
      break;
    case 'BALING':
      if (action == MenuAction.entry)
        Get.toNamed(AppRoutes.baleEntry);
      else if (action == MenuAction.bail_Stock)
        Get.toNamed(AppRoutes.baleStockReport);
      else if (action == MenuAction.bailing_Report)
        Get.toNamed(AppRoutes.balingReport);
      else if (action == MenuAction.dispatch)
        Get.toNamed(AppRoutes.baleDispatch);
      else if (action == MenuAction.stock)
        Get.toNamed(AppRoutes.baleStockgroup);
      break;
    case 'WEBBING':
      if (action == MenuAction.entry)
        Get.toNamed(AppRoutes.webEntryScreen);
      else if (action == MenuAction.saved_List)
        Get.toNamed(AppRoutes.webSaveEntryScreen);
      else if (action == MenuAction.IN)
        Get.toNamed(AppRoutes.webbingIn);
      else if (action == MenuAction.OUT)
        Get.toNamed(AppRoutes.webbingOut);
      else if (action == MenuAction.report)
        Get.toNamed(AppRoutes.webbNardanaReport);
      break;
    case 'LEDGER':
      if (action == MenuAction.Webbing_Ledger)
        Get.toNamed(AppRoutes.stockLedger);
      break;
    case 'TAPELINE':
      if (action == MenuAction.IN)
        Get.toNamed(AppRoutes.tapelineIn);
      else if (action == MenuAction.recent_entries)
        Get.toNamed(AppRoutes.tapelineRecentEntries);
      else if (action == MenuAction.OUT)
        Get.toNamed(AppRoutes.tapelineOut);
      else if (action == MenuAction.In_Report)
        Get.toNamed(AppRoutes.tapeInReport);
      else if (action == MenuAction.Out_Report)
        Get.toNamed(AppRoutes.tapeOutReport);
      else if (action == MenuAction.Stock_Report)
        Get.toNamed(AppRoutes.tapeStockReport);
      break;
  }
}