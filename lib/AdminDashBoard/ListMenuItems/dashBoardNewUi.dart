// import 'package:IMS/JBL/JBL_BagProduction/JBLBagProductionEntry.dart';
// import 'package:IMS/screen/MachineDepartment/MachineDepartmment.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_navigation/src/extension_navigation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../JBL/JBLBailing/BaleReportScreen.dart';
// import '../../JBL/JBLWebbing/ReportsScreen/ReportScreen.dart';
// import '../../JBL/JBLWebbing/ReportsScreen/StockScreen.dart';
// import '../../JBL/JBL_BagProduction/ReportModel/ReortScreen.dart';
// import '../../JBL/JBL_Cutting/Cuttinf_Reports.dart';
// import '../../JBL/Lamination/LaminationReportscreen.dart';
// import '../../Login/ProfileSCreen.dart';
// import '../../ScannedItem/Cutting/CuttinIN/CuttingScreen.dart';
// import '../../ScannedItem/TAPELINE/OutStockList.dart';
// import '../../ScannedItem/TAPELINE/TApeline_IN.dart';
// import '../../routes/app_routes.dart';
// import '../../services/JBL_apis/jbl_api_bailing_reports.dart';
// import '../../util/sharedpreference/shared_preference.dart';
// import '../ActionButtonWidget.dart';
//
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Design Tokens
// // ─────────────────────────────────────────────────────────────────────────────
// class _DS {
//   // Brand palette — deep navy + electric blue accent
//   static const Color bgPage      = Color(0xFFF0F4FA);
//   static const Color bgCard      = Color(0xFFFFFFFF);
//   static const Color bgCardHover = Color(0xFFF7F9FF);
//   static const Color bgAccent    = Color(0xFF1A3A6B);   // deep navy
//   static const Color accent      = Color(0xFF2563EB);   // vivid blue
//   static const Color accentLight = Color(0xFFEFF4FF);
//   static const Color accentMid   = Color(0xFF93B4F5);
//   static const Color textHigh    = Color(0xFF0F1B35);
//   static const Color textMid     = Color(0xFF4A5878);
//   static const Color textLow     = Color(0xFF8A96B0);
//   static const Color border      = Color(0xFFDDE4F0);
//   static const Color borderFocus = Color(0xFF2563EB);
//   static const Color shadow      = Color(0x142563EB);
//   static const Color shadowDeep  = Color(0x282563EB);
//
//   // Gradient for header/accents
//   static const LinearGradient navyGradient = LinearGradient(
//     colors: [Color(0xFF1A3A6B), Color(0xFF2563EB)],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );
//
//   static const LinearGradient accentGrad = LinearGradient(
//     colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );
//
//   // Department icon colors — each dept gets a unique hue
//   static Color deptColor(String label) {
//     const map = {
//       'LOOM'        : Color(0xFF7C3AED),
//       'JBL LOOM'    : Color(0xFF7C3AED),
//       'RMD'         : Color(0xFF059669),
//       'JBL RMD'     : Color(0xFF059669),
//       'LAMINATION'  : Color(0xFFD97706),
//       'JBL LAMINATION': Color(0xFFD97706),
//       'CUTTING'     : Color(0xFFDC2626),
//       'JBL Cutting' : Color(0xFFDC2626),
//       'BAG'         : Color(0xFF2563EB),
//       'JBL BAG'     : Color(0xFF2563EB),
//       'BALING'      : Color(0xFF0891B2),
//       'JBL Baling'  : Color(0xFF0891B2),
//       'JBL Dispatch': Color(0xFFEA580C),
//       'WEBBING'     : Color(0xFF9333EA),
//       'JBL Webbing' : Color(0xFF9333EA),
//       'TAPELINE'    : Color(0xFF16A34A),
//       'FOLDING'     : Color(0xFFDB2777),
//       'LEDGER'      : Color(0xFF4F46E5),
//     };
//     return map[label] ?? const Color(0xFF2563EB);
//   }
//
//   static Color deptColorLight(String label) {
//     final c = deptColor(label);
//     return Color.fromARGB(18, c.red, c.green, c.blue);
//   }
// }
//
// class AdminDashboard extends StatefulWidget {
//   final String? forceDepartment;
//   const AdminDashboard({Key? key, this.forceDepartment}) : super(key: key);
//
//   @override
//   State<AdminDashboard> createState() => _AdminDashboardState();
// }
//
// class _AdminDashboardState extends State<AdminDashboard>
//     with SingleTickerProviderStateMixin {
//   String? unit;
//   String? user;
//   String? department;
//   String? userType;
//   late AnimationController _fadeCtrl;
//   int? _selectedIndex;
//
//   @override
//   void initState() {
//     super.initState();
//     _fadeCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );
//     _loadSession();
//   }
//
//   @override
//   void dispose() {
//     _fadeCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadSession() async {
//     user = await AppSession.getUsername();
//     unit = await AppSession.getUnit();
//
//     if (widget.forceDepartment != null) {
//       department = widget.forceDepartment;
//     } else {
//       department = await AppSession.getDepartment();
//     }
//
//     userType = await AppSession.getUserType();
//
//     if (!mounted) return;
//     setState(() {});
//     _fadeCtrl.forward();
//   }
//
//   List<_MenuItemData> _getFilteredMenuItems() {
//     final dept = department?.toUpperCase();
//     final normalizedUnit = unit?.toUpperCase().replaceAll(" ", "");
//
//     if (normalizedUnit != null &&
//         (normalizedUnit.contains('JBL') ||
//             normalizedUnit.contains('DINESH-POLYFAB'))) {
//       final jblItems = const [
//         _MenuItemData(label: 'JBL LOOM',       departmentKey: 'LOOM',      icon: Icons.looks),
//         _MenuItemData(label: 'JBL RMD',         departmentKey: 'RMD',       icon: Icons.read_more_outlined),
//         _MenuItemData(label: 'JBL LAMINATION',  departmentKey: 'LAMINATION',icon: Icons.label_important_rounded),
//         _MenuItemData(label: 'JBL Cutting',     departmentKey: 'CUTTING',   icon: Icons.cut),
//         _MenuItemData(label: 'JBL BAG',         departmentKey: 'BAG',       icon: Icons.shopping_bag),
//         _MenuItemData(label: 'JBL Baling',      departmentKey: 'BALING',    icon: Icons.waves),
//         _MenuItemData(label: 'JBL Dispatch',    departmentKey: 'BALING',    icon: Icons.local_shipping),
//         _MenuItemData(label: 'JBL Webbing',     departmentKey: 'WEBBING',   icon: Icons.web),
//       ];
//
//       if (dept == 'PADMIN') return jblItems;
//       return jblItems.where((e) => e.departmentKey == dept).toList();
//     }
//
//     const all = [
//       _MenuItemData(label: 'LOOM',      departmentKey: 'LOOM',      icon: Icons.looks),
//       _MenuItemData(label: 'RMD',       departmentKey: 'RMD',       icon: Icons.settings),
//       _MenuItemData(label: 'LAMINATION',departmentKey: 'LAMINATION',icon: Icons.layers),
//       _MenuItemData(label: 'CUTTING',   departmentKey: 'CUTTING',   icon: Icons.cut),
//       _MenuItemData(label: 'BAG',       departmentKey: 'BAG',       icon: Icons.shopping_bag),
//       _MenuItemData(label: 'BALING',    departmentKey: 'BALING',    icon: Icons.inventory),
//       _MenuItemData(label: 'WEBBING',   departmentKey: 'WEBBING',   icon: Icons.grain),
//       _MenuItemData(label: 'TAPELINE',  departmentKey: 'TAPELINE',  icon: Icons.straighten),
//     ];
//
//     if (dept == 'PADMIN') return all;
//     return all.where((e) => e.departmentKey == dept).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final menuItems = _getFilteredMenuItems();
//
//     return Scaffold(
//       backgroundColor: _DS.bgPage,
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildHeader(),
//             _buildStatsStrip(menuItems.length),
//             Expanded(
//               child: menuItems.isEmpty
//                   ? const _EmptyState()
//                   : FadeTransition(
//                 opacity: _fadeCtrl,
//                 child: ListView.builder(
//                   padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
//                   itemCount: menuItems.length + 1,
//                   itemBuilder: (ctx, i) {
//                     if (i == 0) return _buildListHeader();
//                     final idx = i - 1;
//                     return _DepartmentTile(
//                       key: ValueKey(menuItems[idx].label),
//                       data: menuItems[idx],
//                       index: idx,
//                       isSelected: _selectedIndex == idx,
//                       onTap: () {
//                         HapticFeedback.selectionClick();
//                         setState(() {
//                           _selectedIndex = _selectedIndex == idx ? null : idx;
//                         });
//                       },
//                       onAction: (action) => _navigateAction(
//                         context,
//                         menuItems[idx].label,
//                         action,
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── HEADER ────────────────────────────────────────────────────────────────
//   Widget _buildHeader() {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: _DS.navyGradient,
//       ),
//       padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
//       child: Row(
//         children: [
//           // Avatar
//           GestureDetector(
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => ProfileScreen(
//                   user: user,
//                   unit: unit,
//                   department: department,
//                   userType: userType,
//                 ),
//               ),
//             ),
//             child: Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.18),
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.white.withOpacity(0.35), width: 2),
//               ),
//               child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
//             ),
//           ),
//
//           const SizedBox(width: 14),
//
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Welcome back',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.white.withOpacity(0.65),
//                     fontWeight: FontWeight.w500,
//                     letterSpacing: 0.3,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   userType ?? '—',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w800,
//                     color: Colors.white,
//                     letterSpacing: -0.3,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//
//           // Unit badge
//           if (unit != null && unit!.isNotEmpty)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(24),
//                 border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(Icons.factory_rounded, size: 13, color: Colors.white),
//                   const SizedBox(width: 5),
//                   Text(
//                     unit!,
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   // ── STATS STRIP ──────────────────────────────────────────────────────────
//   Widget _buildStatsStrip(int deptCount) {
//     return Container(
//       color: _DS.bgAccent,
//       padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
//       child: Row(
//         children: [
//           _StatChip(
//             icon: Icons.domain_rounded,
//             label: 'Departments',
//             value: '$deptCount',
//           ),
//           const SizedBox(width: 12),
//           _StatChip(
//             icon: Icons.verified_user_rounded,
//             label: 'Role',
//             value: department ?? '—',
//           ),
//
//         ],
//       ),
//     );
//   }
//
//   // ── LIST HEADER ───────────────────────────────────────────────────────────
//   Widget _buildListHeader() {
//     final subtitle = widget.forceDepartment != null
//         ? 'Viewing ${widget.forceDepartment} department'
//         : (department == 'PADMIN'
//         ? 'Full admin access — all departments'
//         : 'Showing $department department');
//
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Departments',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.w900,
//                     color: _DS.textHigh,
//                     letterSpacing: -0.5,
//                   ),
//                 ),
//                 const SizedBox(height: 3),
//                 Text(
//                   subtitle,
//                   style: const TextStyle(
//                     fontSize: 12.5,
//                     color: _DS.textMid,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             decoration: BoxDecoration(
//               color: _DS.accentLight,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.touch_app_rounded, size: 13, color: _DS.accent),
//                 SizedBox(width: 4),
//                 Text(
//                   'Tap to expand',
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: _DS.accent,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── NAVIGATION (UNCHANGED LOGIC) ─────────────────────────────────────────
//   void _navigateAction(BuildContext context, String label, MenuAction action) {
//     final isJBL = unit?.toUpperCase().contains('JBL') ?? false;
//
//     if (isJBL) {
//       switch (label) {
//         case 'JBL LOOM':
//           if (action == MenuAction.LOOM) {
//             Navigator.pushNamed(context, AppRoutes.loomList);
//           } else if (action == MenuAction.report) {
//             Navigator.pushNamed(context, AppRoutes.loomIn);
//           }
//           break;
//
//         case 'JBL RMD':
//           if (action == MenuAction.IN) {
//             Navigator.pushNamed(context, AppRoutes.jblRmdIn);
//           } else if (action == MenuAction.OUT) {
//             Navigator.pushNamed(context, AppRoutes.jblRmdOut);
//           } else if (action == MenuAction.Stock_Report) {
//             Navigator.pushNamed(context, AppRoutes.jblRmdStockReports);
//           } else if (action == MenuAction.report) {
//             Get.toNamed(
//               AppRoutes.rmdInReport,
//               arguments: {
//                 "title": "RMD Report",
//                 "endpoint": "Rmd/GetRmdData",
//                 "params": {
//                   "plant": "JBL",
//                   "type": "IN",
//                   "fromDate": JblApiService.getApiDate(),
//                   "toDate": JblApiService.getApiDate(),
//                 },
//               },
//             );
//           } else if (action == MenuAction.report) {
//             Get.toNamed(
//               AppRoutes.rmdOutReport,
//               arguments: {
//                 "title": "RMD Report",
//                 "endpoint": "Rmd/GetRmdData",
//                 "params": {
//                   "plant": "JBL",
//                   "type": "OUT",
//                   "fromDate": JblApiService.getApiDate(),
//                   "toDate": JblApiService.getApiDate(),
//                 },
//               },
//             );
//           }
//           break;
//
//         case 'JBL LAMINATION':
//           if (action == MenuAction.IN) {
//             Navigator.pushNamed(context, AppRoutes.jblLamination);
//           } else if (action == MenuAction.report) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => LaminationReportScreen(
//                   title: 'Lamination Report',
//                   endpoint: 'Lamination/LaminationReports',
//                   initialParams: {'plant': 'JBL'},
//                 ),
//               ),
//             );
//           }
//           break;
//
//         case 'JBL Cutting':
//           if (action == MenuAction.Approval) {
//             Navigator.pushNamed(context, AppRoutes.reccutpcscutting);
//           } else if (action == MenuAction.Pcs_Issue) {
//             Navigator.pushNamed(context, AppRoutes.cuttingIssue);
//           } else if (action == MenuAction.Re_cut_Issue) {
//             Navigator.pushNamed(context, AppRoutes.reCutIssue);
//           } else if (action == MenuAction.IN) {
//             Navigator.pushNamed(context, AppRoutes.jblCuttingIn);
//           } else if (action == MenuAction.In_Report) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => CuttingReportScreen(type: "IN")),
//             );
//           } else if (action == MenuAction.Pcs_Report) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => CuttingReportScreen(type: "CUTPCS")),
//             );
//           } else if (action == MenuAction.Rollwise_Report) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => CuttingReportScreen(type: "ROLLWISE")),
//             );
//           }
//           break;
//
//         case 'JBL Webbing':
//           if (action == MenuAction.IN) {
//             Navigator.pushNamed(context, AppRoutes.jblWebbIn);
//           } else if (action == MenuAction.OUT) {
//             Navigator.pushNamed(context, AppRoutes.jblWebbOut);
//           } else if (action == MenuAction.stock) {
//             Navigator.pushNamed(context, AppRoutes.webbingStockReport);
//           } else if (action == MenuAction.In_Report) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => WebbingReportScreen(type: "IN")),
//             );
//           } else if (action == MenuAction.Out_Report) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => WebbingReportScreen(type: "OUTREPORT")),
//             );
//           } else if (action == MenuAction.Stock_Report) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => WebbingStockScreen()),
//             );
//           }
//           break;
//
//         case 'JBL Baling':
//           if (action == MenuAction.entry) {
//             Navigator.pushNamed(context, AppRoutes.jblBailing);
//           } else if (action == MenuAction.report) {
//             Navigator.pushNamed(context, AppRoutes.jblBailingReport);
//           } else if (action == MenuAction.OverAll_Report) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => BaleReportScreen(type: "OVERALL")),
//             );
//           } else if (action == MenuAction.Stock_Report) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => BaleReportScreen(type: "STOCK")),
//             );
//           }
//           break;
//
//         case 'JBL Dispatch':
//           if (action == MenuAction.entry) {
//             Navigator.pushNamed(context, AppRoutes.jblScan);
//           } else if (action == MenuAction.report) {
//             Navigator.pushNamed(context, AppRoutes.jblDispatchReport);
//           }
//           break;
//
//         case 'JBL BAG':
//           if (action == MenuAction.FIBC_Store) {
//             Navigator.pushNamed(context, AppRoutes.jblBagStoreIssue);
//           } else if (action == MenuAction.Packing_Department) {
//             Navigator.pushNamed(context, AppRoutes.jblPackingReport);
//           } else if (action == MenuAction.Bag_Report) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => BagProductionReportScreen(type: "BAGREPORT")),
//             );
//           } else if (action == MenuAction.Packing_Report) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => BagProductionReportScreen(type: "PACKAGING")),
//             );
//           } else if (action == MenuAction.entry) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => JBLBagEntryScreen()),
//             );
//           }
//           break;
//       }
//     } else {
//       switch (label) {
//         case 'LOOM':
//           if (action == MenuAction.IN) {
//             Navigator.pushNamed(context, AppRoutes.loomIn);
//           } else if (action == MenuAction.report) {
//             Navigator.pushNamed(context, AppRoutes.loomReports);
//           }
//           break;
//
//         case 'CUTTING':
//           if (action == MenuAction.IN) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => CuttingScreen()),
//             );
//           } else if (action == MenuAction.Approval) {
//             Navigator.pushNamed(context, AppRoutes.cuttingnardana);
//           } else if (action == MenuAction.Pcs_Issue) {
//             Navigator.pushNamed(context, AppRoutes.cuttingIssuenardana);
//           }
//           break;
//
//         case 'LAMINATION':
//           if (action == MenuAction.IN) {
//             Navigator.pushNamed(context, AppRoutes.lamination);
//           } else if (action == MenuAction.OUT) {
//             Navigator.pushNamed(context, AppRoutes.laminationOutStock);
//           } else if (action == MenuAction.report) {
//             Navigator.pushNamed(context, AppRoutes.lamNaradanaReports);
//           }
//           break;
//
//         case 'RMD':
//           if (action == MenuAction.IN) {
//             Navigator.pushNamed(context, AppRoutes.rmdIn);
//           } else if (action == MenuAction.OUT) {
//             Navigator.pushNamed(context, AppRoutes.rmdOut);
//           } else if (action == MenuAction.report) {
//             Navigator.pushNamed(context, AppRoutes.rmdNardanaReports);
//           } else if (action == MenuAction.stock) {
//             Navigator.pushNamed(context, AppRoutes.rmdNardanaStock);
//           }
//           break;
//
//         case 'BAG':
//           if (action == MenuAction.entry) {
//             Navigator.pushNamed(context, AppRoutes.bagEntry);
//           } else {
//             Navigator.pushNamed(context, AppRoutes.bagReport);
//           }
//           break;
//
//         case 'WEBBING':
//           if (action == MenuAction.IN) {
//             Navigator.pushNamed(context, AppRoutes.webbingIn);
//           } else if (action == MenuAction.OUT) {
//             Navigator.pushNamed(context, AppRoutes.webbingOut);
//           } else if (action == MenuAction.report) {
//             Navigator.pushNamed(context, AppRoutes.webbNardanaReport);
//           } else if (action == MenuAction.stock) {
//             Navigator.pushNamed(context, AppRoutes.webStockSlider);
//           }
//           break;
//
//         case 'BALING':
//           if (action == MenuAction.entry) {
//             Navigator.pushNamed(context, AppRoutes.baleEntry);
//           } else if (action == MenuAction.stock) {
//             Navigator.pushNamed(context, AppRoutes.baleStockgroup);
//           } else if (action == MenuAction.report) {
//             Navigator.pushNamed(context, AppRoutes.baleReport);
//           } else if (action == MenuAction.dispatch) {
//             Navigator.pushNamed(context, AppRoutes.baleDispatch);
//           }
//           break;
//
//         case 'FOLDING':
//           if (action == MenuAction.IN) {
//             Navigator.pushNamed(context, AppRoutes.foldingIn);
//           }
//           break;
//
//         case 'TAPELINE':
//           if (action == MenuAction.IN) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const TapeLineApp()),
//             );
//           } else if (action == MenuAction.OUT) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const TapelineOutStockScreen()),
//             );
//           }
//           break;
//
//         case 'LEDGER':
//           if (action == MenuAction.stock) {
//             Navigator.pushNamed(context, AppRoutes.stockLedger);
//           }
//           break;
//       }
//     }
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Stat Chip — in header strip
// // ─────────────────────────────────────────────────────────────────────────────
// class _StatChip extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color? valueColor;
//
//   const _StatChip({
//     required this.icon,
//     required this.label,
//     required this.value,
//     this.valueColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.10),
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 13, color: Colors.white.withOpacity(0.6)),
//             const SizedBox(width: 6),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     label,
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: Colors.white.withOpacity(0.55),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   Text(
//                     value,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: valueColor ?? Colors.white,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 0.2,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Department Tile — premium expandable card
// // ─────────────────────────────────────────────────────────────────────────────
// class _DepartmentTile extends StatefulWidget {
//   final _MenuItemData data;
//   final int index;
//   final bool isSelected;
//   final VoidCallback onTap;
//   final void Function(MenuAction) onAction;
//
//   const _DepartmentTile({
//     Key? key,
//     required this.data,
//     required this.index,
//     required this.isSelected,
//     required this.onTap,
//     required this.onAction,
//   }) : super(key: key);
//
//   @override
//   State<_DepartmentTile> createState() => _DepartmentTileState();
// }
//
// class _DepartmentTileState extends State<_DepartmentTile>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//   late Animation<double> _expandAnim;
//   late Animation<double> _rotateAnim;
//
//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);
//     _rotateAnim = Tween<double>(begin: 0.0, end: 0.5).animate(_expandAnim);
//   }
//
//   @override
//   void didUpdateWidget(_DepartmentTile old) {
//     super.didUpdateWidget(old);
//     if (widget.isSelected != old.isSelected) {
//       widget.isSelected ? _ctrl.forward() : _ctrl.reverse();
//     }
//   }
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final actions   = getActionsForMenu(widget.data.label);
//     final deptColor = _DS.deptColor(widget.data.label);
//     final deptLight = _DS.deptColorLight(widget.data.label);
//
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         decoration: BoxDecoration(
//           color: _DS.bgCard,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: widget.isSelected ? deptColor.withOpacity(0.6) : _DS.border,
//             width: widget.isSelected ? 1.5 : 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: widget.isSelected
//                   ? deptColor.withOpacity(0.16)
//                   : _DS.shadow,
//               blurRadius: widget.isSelected ? 24 : 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(20),
//           child: Column(
//             children: [
//               // ── Tile header ─────────────────────────────────────────────
//               Material(
//                 color: Colors.transparent,
//                 child: InkWell(
//                   onTap: widget.onTap,
//                   splashColor: deptColor.withOpacity(0.08),
//                   highlightColor: deptColor.withOpacity(0.05),
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                     child: Row(
//                       children: [
//                         // Numbered + icon badge
//                         Stack(
//                           clipBehavior: Clip.none,
//                           children: [
//                             AnimatedContainer(
//                               duration: const Duration(milliseconds: 250),
//                               width: 52,
//                               height: 52,
//                               decoration: BoxDecoration(
//                                 color: widget.isSelected ? deptColor : deptLight,
//                                 borderRadius: BorderRadius.circular(16),
//                                 boxShadow: widget.isSelected
//                                     ? [
//                                   BoxShadow(
//                                     color: deptColor.withOpacity(0.4),
//                                     blurRadius: 12,
//                                     offset: const Offset(0, 4),
//                                   )
//                                 ]
//                                     : [],
//                               ),
//                               child: Icon(
//                                 widget.data.icon,
//                                 size: 24,
//                                 color: widget.isSelected ? Colors.white : deptColor,
//                               ),
//                             ),
//                             // Index number badge
//                             Positioned(
//                               top: -4,
//                               right: -4,
//                               child: Container(
//                                 width: 18,
//                                 height: 18,
//                                 decoration: BoxDecoration(
//                                   color: widget.isSelected ? _DS.textHigh : _DS.textLow,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     '${widget.index + 1}',
//                                     style: const TextStyle(
//                                       fontSize: 9,
//                                       fontWeight: FontWeight.w800,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//
//                         const SizedBox(width: 14),
//
//                         // Label, subtitle
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 widget.data.label,
//                                 style: TextStyle(
//                                   fontSize: 14.5,
//                                   fontWeight: FontWeight.w800,
//                                   color: widget.isSelected ? deptColor : _DS.textHigh,
//                                   letterSpacing: 0.1,
//                                 ),
//                               ),
//                               const SizedBox(height: 3),
//                               Row(
//                                 children: [
//                                   Container(
//                                     width: 6,
//                                     height: 6,
//                                     decoration: BoxDecoration(
//                                       color: widget.isSelected
//                                           ? deptColor
//                                           : _DS.textLow,
//                                       shape: BoxShape.circle,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 5),
//                                   Text(
//                                     widget.isSelected
//                                         ? 'Choose an action below'
//                                         : '${actions.length} action${actions.length != 1 ? 's' : ''} available',
//                                     style: TextStyle(
//                                       fontSize: 11.5,
//                                       fontWeight: FontWeight.w500,
//                                       color: widget.isSelected
//                                           ? deptColor.withOpacity(0.8)
//                                           : _DS.textMid,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         // Expand chevron
//                         RotationTransition(
//                           turns: _rotateAnim,
//                           child: AnimatedContainer(
//                             duration: const Duration(milliseconds: 250),
//                             width: 34,
//                             height: 34,
//                             decoration: BoxDecoration(
//                               color: widget.isSelected ? deptLight : const Color(0xFFF3F6FB),
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(
//                                 color: widget.isSelected
//                                     ? deptColor.withOpacity(0.3)
//                                     : _DS.border,
//                                 width: 1,
//                               ),
//                             ),
//                             child: Icon(
//                               Icons.keyboard_arrow_down_rounded,
//                               size: 20,
//                               color: widget.isSelected ? deptColor : _DS.textMid,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//
//               // ── Expandable action panel ──────────────────────────────────
//               SizeTransition(
//                 sizeFactor: _expandAnim,
//                 axisAlignment: -1,
//                 child: Column(
//                   children: [
//                     // Divider with dept color
//                     Container(
//                       height: 1.5,
//                       margin: const EdgeInsets.symmetric(horizontal: 16),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             deptColor.withOpacity(0.15),
//                             deptColor.withOpacity(0.5),
//                             deptColor.withOpacity(0.15),
//                           ],
//                         ),
//                       ),
//                     ),
//
//                     // Action grid
//                     Container(
//                       color: deptLight.withOpacity(0.5),
//                       padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Section label
//                           Padding(
//                             padding: const EdgeInsets.only(bottom: 10),
//                             child: Text(
//                               'QUICK ACTIONS',
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w800,
//                                 color: deptColor.withOpacity(0.7),
//                                 letterSpacing: 1.5,
//                               ),
//                             ),
//                           ),
//                           Wrap(
//                             spacing: 8,
//                             runSpacing: 8,
//                             children: actions
//                                 .map((a) => _ActionButton(
//                               action: a,
//                               accentColor: deptColor,
//                               onTap: () => widget.onAction(a),
//                             ))
//                                 .toList(),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Action Button — colorized pill
// // ─────────────────────────────────────────────────────────────────────────────
// class _ActionButton extends StatefulWidget {
//   final MenuAction action;
//   final Color accentColor;
//   final VoidCallback onTap;
//
//   const _ActionButton({
//     required this.action,
//     required this.accentColor,
//     required this.onTap,
//   });
//
//   @override
//   State<_ActionButton> createState() => _ActionButtonState();
// }
//
// class _ActionButtonState extends State<_ActionButton> {
//   bool _pressed = false;
//
//   static IconData _iconFor(MenuAction a) {
//     switch (a) {
//       case MenuAction.IN:           return Icons.login_rounded;
//       case MenuAction.OUT:          return Icons.logout_rounded;
//       case MenuAction.stock:        return Icons.inventory_2_rounded;
//       case MenuAction.report:       return Icons.bar_chart_rounded;
//       case MenuAction.entry:        return Icons.edit_note_rounded;
//       case MenuAction.scan:         return Icons.qr_code_scanner_rounded;
//       case MenuAction.dispatch:     return Icons.local_shipping_rounded;
//       case MenuAction.Stock_Report: return Icons.assessment_rounded;
//       case MenuAction.In_Report:    return Icons.file_download_rounded;
//       case MenuAction.Out_Report:   return Icons.file_upload_rounded;
//       default:                      return Icons.chevron_right_rounded;
//     }
//   }
//
//   // Group actions by category for visual separation
//   static Color _actionTint(MenuAction a, Color accent) {
//     switch (a) {
//       case MenuAction.IN:
//         return const Color(0xFF059669);
//       case MenuAction.OUT:
//         return const Color(0xFFDC2626);
//       case MenuAction.report:
//       case MenuAction.In_Report:
//       case MenuAction.Out_Report:
//       case MenuAction.Stock_Report:
//       case MenuAction.OverAll_Report:
//       case MenuAction.Rollwise_Report:
//       case MenuAction.Pcs_Report:
//       case MenuAction.Bag_Report:
//       case MenuAction.Packing_Report:
//         return const Color(0xFF7C3AED);
//       case MenuAction.stock:
//         return const Color(0xFF0891B2);
//       default:
//         return accent;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final tint = _actionTint(widget.action, widget.accentColor);
//     final label = _labelFor(widget.action);
//
//     return GestureDetector(
//       onTapDown: (_) {
//         HapticFeedback.lightImpact();
//         setState(() => _pressed = true);
//       },
//       onTapUp: (_) {
//         setState(() => _pressed = false);
//         widget.onTap();
//       },
//       onTapCancel: () => setState(() => _pressed = false),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 120),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
//         decoration: BoxDecoration(
//           color: _pressed ? tint : Colors.white,
//           borderRadius: BorderRadius.circular(11),
//           border: Border.all(
//             color: _pressed ? tint : tint.withOpacity(0.35),
//             width: 1.5,
//           ),
//           boxShadow: _pressed
//               ? [BoxShadow(color: tint.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 3))]
//               : [BoxShadow(color: tint.withOpacity(0.10), blurRadius: 6, offset: const Offset(0, 2))],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 24,
//               height: 24,
//               decoration: BoxDecoration(
//                 color: _pressed ? Colors.white.withOpacity(0.25) : tint.withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(7),
//               ),
//               child: Icon(
//                 _iconFor(widget.action),
//                 size: 13,
//                 color: _pressed ? Colors.white : tint,
//               ),
//             ),
//             const SizedBox(width: 8),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 11.5,
//                 fontWeight: FontWeight.w700,
//                 color: _pressed ? Colors.white : tint,
//                 letterSpacing: 0.4,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String _labelFor(MenuAction a) {
//     switch (a) {
//       case MenuAction.IN:              return 'IN';
//       case MenuAction.OUT:             return 'OUT';
//       case MenuAction.stock:           return 'STOCK';
//       case MenuAction.report:          return 'REPORT';
//       case MenuAction.entry:           return 'ENTRY';
//       case MenuAction.scan:            return 'SCAN';
//       case MenuAction.dispatch:        return 'DISPATCH';
//       case MenuAction.LOOM:            return 'LOOM';
//       case MenuAction.Approval:        return 'APPROVAL';
//       case MenuAction.Pcs_Issue:       return 'PCS ISSUE';
//       case MenuAction.Re_cut_Issue:    return 'RECUT';
//       case MenuAction.In_Report:       return 'IN REPORT';
//       case MenuAction.Out_Report:      return 'OUT REPORT';
//       case MenuAction.Stock_Report:    return 'STOCK RPT';
//       case MenuAction.OverAll_Report:  return 'OVERALL';
//       case MenuAction.Rollwise_Report: return 'ROLLWISE';
//       case MenuAction.Pcs_Report:      return 'PCS REPORT';
//       case MenuAction.Bag_Report:      return 'BAG REPORT';
//       case MenuAction.Packing_Report:  return 'PACKING RPT';
//       case MenuAction.FIBC_Store:      return 'FIBC STORE';
//       case MenuAction.Packing_Department: return 'PACKING DEPT';
//       default:                         return a.name.toUpperCase();
//     }
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Empty State
// // ─────────────────────────────────────────────────────────────────────────────
// class _EmptyState extends StatelessWidget {
//   const _EmptyState();
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(48),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 90,
//               height: 90,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [_DS.accentLight, _DS.accentMid.withOpacity(0.3)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: _DS.accent.withOpacity(0.18),
//                     blurRadius: 24,
//                     offset: const Offset(0, 8),
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.domain_disabled_rounded,
//                 size: 38,
//                 color: _DS.accent,
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'No Departments',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w900,
//                 color: _DS.textHigh,
//                 letterSpacing: -0.3,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Please contact your administrator\nto get department access.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 13,
//                 color: _DS.textMid,
//                 height: 1.65,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Data Model
// // ─────────────────────────────────────────────────────────────────────────────
// class _MenuItemData {
//   final String label;
//   final String departmentKey;
//   final IconData icon;
//
//   const _MenuItemData({
//     required this.label,
//     required this.departmentKey,
//     required this.icon,
//   });
// }