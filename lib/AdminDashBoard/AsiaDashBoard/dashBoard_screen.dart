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
// import '../../Color/Colorclass.dart';
// import '../../JBL/JBLBailing/BaleReportScreen.dart';
// import '../../JBL/JBLDispatch/DispatchEntry.dart';
// import '../../JBL/JBLWebbing/ReportsScreen/ReportScreen.dart';
// import '../../JBL/JBLWebbing/ReportsScreen/StockScreen.dart';
// import '../../JBL/JBLWebbing/WebbingInStock.dart';
// import '../../JBL/JBL_BagProduction/ReportModel/ReortScreen.dart';
// import '../../JBL/JBL_Cutting/Cuttinf_Reports.dart';
// import '../../JBL/Lamination/LaminationReportscreen.dart';
// import '../../Login/LoginScreen.dart';
// import '../../Login/ProfileSCreen.dart';
// import '../../ScannedItem/Cutting/CuttinIN/CuttingScreen.dart';
// import '../../ScannedItem/Lamination/LaminationScreen.dart';
// import '../../ScannedItem/Loom/LoomScreen.dart';
// import '../../ScannedItem/Loom/LoomSliderScreen.dart';
// import '../../ScannedItem/RMDStock/RMDstockScreen.dart';
// import '../../ScannedItem/RmdIn/RMDscreen.dart';
// import '../../ScannedItem/RmdOut/RmdOutScreen.dart';
// import '../../ScannedItem/ScannedItemScreen.dart';
// import '../../ScannedItem/Webbing/WebbingScreen.dart';
// import '../../routes/app_routes.dart';
// import '../../screen/BagProduction/BagProduction/BagProductionEntryScreen.dart';
// import '../../screen/BagProduction/BagReport/BagReportScreen.dart';
// import '../../screen/Baling/BailingSliderScreen.dart';
// import '../../screen/Baling/BaleEntryForm.dart';
// import '../../screen/Baling/BaleInReportScreen.dart';
// import '../../screen/Baling/BaleSliderScreen.dart';
//
// import '../../screen/Baling/BailingDispatchScreen.dart';
// import '../../services/JBL_apis/jbl_api_bailing_reports.dart';
// import '../../services/LogoutServices.dart';
// import '../../util/sharedpreference/shared_preference.dart';
//
// import '../ActionButtonWidget.dart';
// import 'ActionButton.dart';
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
//   @override
//   void initState() {
//     super.initState();
//     _fadeCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
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
//   //
//   // Future<void> loadDepartment() async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   setState(() {
//   //     department = prefs.getString('department');
//   //   });
//   // }
//
//   // Future<void> _loadSession() async {
//   //   user = await AppSession.getUsername();
//   //   unit = await AppSession.getUnit();
//   //   department = await AppSession.getDepartment();
//   //   userType = await AppSession.getUserType();
//   //   if (!mounted) return;
//   //   setState(() {});
//   //   _fadeCtrl.forward();
//   // }
//
//   Future<void> _loadSession() async {
//     user = await AppSession.getUsername();
//     unit = await AppSession.getUnit();
//
//     // 🔥 IMPORTANT FIX
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
//     // ✅ JBL UNIT LOGIC
//     if (normalizedUnit != null &&
//         (normalizedUnit.contains('JBL') ||
//             normalizedUnit.contains('DINESH-POLYFAB'))) {
//       final jblItems = const [
//         _MenuItemData(
//           label: 'JBL LOOM',
//           departmentKey: 'LOOM',
//           icon: Icons.looks,
//         ),
//
//         _MenuItemData(
//           label: 'JBL RMD',
//           departmentKey: 'RMD',
//           icon: Icons.read_more_outlined,
//         ),
//         _MenuItemData(
//           label: 'JBL LAMINATION',
//           departmentKey: 'LAMINATION',
//           icon: Icons.label_important_rounded,
//         ),
//
//         _MenuItemData(
//           label: 'JBL Cutting',
//           departmentKey: 'CUTTING',
//           icon: Icons.cut,
//         ),
//         _MenuItemData(
//           label: 'JBL BAG',
//           departmentKey: 'BAG',
//           icon: Icons.shopping_bag,
//         ),
//         _MenuItemData(
//           label: 'JBL Baling',
//           departmentKey: 'BALING',
//           icon: Icons.waves,
//         ),
//         _MenuItemData(
//           label: 'JBL Dispatch',
//           departmentKey: 'BALING',
//           icon: Icons.local_shipping,
//         ),
//         _MenuItemData(
//           label: 'JBL Webbing',
//           departmentKey: 'WEBBING',
//           icon: Icons.web,
//         ),
//       ];
//
//       if (dept == 'PADMIN') return jblItems;
//
//       return jblItems.where((e) => e.departmentKey == dept).toList();
//     }
//
//     // ✅ NORMAL UNIT
//     const all = [
//       // _MenuItemData(label: 'LOOM', departmentKey: 'LOOM', icon: Icons.looks),
//
//       _MenuItemData(label: 'RMD', departmentKey: 'RMD', icon: Icons.settings),
//       _MenuItemData(
//         label: 'LAMINATION',
//         departmentKey: 'LAMINATION',
//         icon: Icons.layers,
//       ),
//       _MenuItemData(
//         label: 'CUTTING',
//         departmentKey: 'CUTTING',
//         icon: Icons.cut,
//       ),
//       // _MenuItemData(
//       //   label: 'BAG',
//       //   departmentKey: 'BAG',
//       //   icon: Icons.shopping_bag,
//       // ),
//       // _MenuItemData(
//       //   label: 'BALING',
//       //   departmentKey: 'BALING',
//       //   icon: Icons.inventory,
//       // ),
//       // _MenuItemData(
//       //   label: 'WEBBING',
//       //   departmentKey: 'WEBBING',
//       //   icon: Icons.grain,
//       // ),
//     ];
//
//     if (dept == 'PADMIN') return all;
//
//     return all.where((e) => e.departmentKey == dept).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isTablet = size.width > 600;
//     final isDesktop = size.width > 900;
//     final hPad = isDesktop ? 32.0 : (isTablet ? 24.0 : 16.0);
//     final menuItems = _getFilteredMenuItems();
//
//     return Scaffold(
//       backgroundColor: C.pageBg,
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildHeader(isTablet, hPad),
//             Expanded(
//               child: menuItems.isEmpty
//                   ? const _EmptyState()
//                   : FadeTransition(
//                 opacity: _fadeCtrl,
//                 child: ListView(
//                   padding: EdgeInsets.fromLTRB(hPad, 22, hPad, 32),
//                   children: [
//                     _buildSectionHeader(isTablet, isDesktop),
//                     const SizedBox(height: 18),
//                     ...List.generate(menuItems.length, (i) {
//                       return _DepartmentTile(
//                         key: ValueKey(menuItems[i].label),
//                         data: menuItems[i],
//                         isSelected: _selectedIndex == i,
//                         onTap: () {
//                           HapticFeedback.selectionClick();
//                           setState(() {
//                             _selectedIndex = _selectedIndex == i
//                                 ? null
//                                 : i;
//                           });
//                         },
//                         onAction: (action) => _navigateAction(
//                           context,
//                           // menuItems[i].departmentKey, // ✅ USE THIS
//                           menuItems[i].label, // ✅ FIX
//                           action,
//                         ),
//                       );
//                     }),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Header ──────────────────────────────────────────────────────────────────
//   Widget _buildHeader(bool isTablet, double hPad) {
//     return Container(
//       decoration: BoxDecoration(
//         color: C.cardBg,
//         border: Border(bottom: BorderSide(color: C.borderLight, width: 1)),
//         boxShadow: [
//           BoxShadow(
//             color: C.brandOp10,
//             blurRadius: 12,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 13),
//       child: Row(
//         children: [
//           // Avatar → profile
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
//               width: 44,
//               height: 44,
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [C.brand700, C.brand500],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: C.brandOp30,
//                     blurRadius: 10,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.person_rounded,
//                 color: Colors.white,
//                 size: 21,
//               ),
//             ),
//           ),
//
//           const SizedBox(width: 12),
//
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Welcome back',
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: C.textMid,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 Text(
//                   userType ?? '—',
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w800,
//                     color: C.textHigh,
//                     letterSpacing: 0.1,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//
//           // Unit pill
//           if (unit != null && unit!.isNotEmpty)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: C.pillBg,
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: C.brand300, width: 1),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(
//                     Icons.factory_rounded,
//                     size: 12,
//                     color: C.pillText,
//                   ),
//                   const SizedBox(width: 5),
//                   Text(
//                     unit!,
//                     style: const TextStyle(
//                       fontSize: 11,
//                       color: C.pillText,
//                       fontWeight: FontWeight.w800,
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
//   // ── Section header ───────────────────────────────────────────────────────────
//   Widget _buildSectionHeader(bool isTablet, bool isDesktop) {
//     final isAdmin =
//         department?.toUpperCase() == 'PADMIN' ||
//             userType?.toUpperCase() == 'PADMIN';
//     final subtitle = widget.forceDepartment != null
//         ? 'Welcome to ${widget.forceDepartment} department'
//         : (department == 'PADMIN'
//         ? 'All Departments Access'
//         : 'Welcome to $department department');
//
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Departments',
//                 style: TextStyle(
//                   fontSize: isDesktop ? 26 : (isTablet ? 22 : 20),
//                   fontWeight: FontWeight.w900,
//                   color: C.textHigh,
//                   letterSpacing: -0.4,
//                 ),
//               ),
//               const SizedBox(height: 3),
//               Text(
//                 subtitle,
//                 style: const TextStyle(fontSize: 13, color: C.textMid),
//               ),
//             ],
//           ),
//         ),
//         // Accent stripe
//         Container(
//           width: 36,
//           height: 4,
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(colors: [C.brand700, C.brand300]),
//             borderRadius: BorderRadius.circular(2),
//           ),
//         ),
//       ],
//     );
//   }
//
//   void _navigateAction(BuildContext context, String label, MenuAction action) {
//     final isJBL = unit?.toUpperCase().contains('JBL') ?? false;
//
//     // // ✅ JBL FLOW
//     // if (isJBL) {
//     //   switch (label) {
//     //     case 'JBL LOOM':
//     //       if (action == MenuAction.LOOM) {
//     //         Navigator.pushNamed(context, AppRoutes.loomList);
//     //       } else if (action == MenuAction.report) {
//     //         Navigator.pushNamed(context, AppRoutes.loomIn);
//     //       }
//     //
//     //     case 'JBL RMD':
//     //       if (action == MenuAction.IN) {
//     //         Navigator.pushNamed(context, AppRoutes.jblRmdIn);
//     //       } else if (action == MenuAction.OUT) {
//     //         Navigator.pushNamed(context, AppRoutes.jblRmdOut);
//     //       } else if (action == MenuAction.Stock_Report) {
//     //         Navigator.pushNamed(context, AppRoutes.jblRmdStockReports);
//     //       } else if (action == MenuAction.report) {
//     //         Get.toNamed(
//     //           AppRoutes.rmdInReport,
//     //           arguments: {
//     //             "title": "RMD Report",
//     //             "endpoint": "Rmd/GetRmdData",
//     //             "params": {
//     //               "plant": "JBL",
//     //               "type": "IN",
//     //               "fromDate": JblApiService.getApiDate(),
//     //               "toDate": JblApiService.getApiDate(),
//     //             },
//     //           },
//     //         );
//     //       } else if (action == MenuAction.report) {
//     //         Get.toNamed(
//     //           AppRoutes.rmdOutReport,
//     //           arguments: {
//     //             "title": "RMD Report",
//     //             "endpoint": "Rmd/GetRmdData",
//     //             "params": {
//     //               "plant": "JBL",
//     //               "type": "OUT",
//     //               "fromDate": JblApiService.getApiDate(),
//     //               "toDate": JblApiService.getApiDate(),
//     //             },
//     //           },
//     //         );
//     //       }
//     //       break;
//     //
//     //     case 'JBL LAMINATION':
//     //       if (action == MenuAction.IN) {
//     //         Navigator.pushNamed(context, AppRoutes.jblLamination);
//     //       } else if (action == MenuAction.report) {
//     //         Navigator.push(
//     //           context,
//     //           MaterialPageRoute(
//     //             builder: (_) => LaminationReportScreen(
//     //               title: 'Lamination Report',
//     //               endpoint:
//     //               'Lamination/LaminationReports', // ← swap in your actual endpoint
//     //               initialParams: {'plant': 'JBL'},
//     //             ),
//     //           ),
//     //         );
//     //       }
//     //
//     //       break;
//     //
//     //     case 'JBL Cutting':
//     //       if (action == MenuAction.Approval) {
//     //         Navigator.pushNamed(context, AppRoutes.reccutpcscutting);
//     //       } else if (action == MenuAction.Pcs_Issue) {
//     //         Navigator.pushNamed(context, AppRoutes.cuttingIssue);
//     //       } else if (action == MenuAction.Re_cut_Issue) {
//     //         Navigator.pushNamed(context, AppRoutes.reCutIssue);
//     //       } else if (action == MenuAction.IN) {
//     //         Navigator.pushNamed(context, AppRoutes.jblCuttingIn);
//     //       } else if (action == MenuAction.In_Report) {
//     //         Navigator.push(
//     //           context,
//     //           MaterialPageRoute(
//     //             builder: (_) => CuttingReportScreen(type: "IN"),
//     //           ),
//     //         );
//     //       } else if (action == MenuAction.Pcs_Report) {
//     //         Navigator.push(
//     //           context,
//     //           MaterialPageRoute(
//     //             builder: (_) => CuttingReportScreen(type: "CUTPCS"),
//     //           ),
//     //         );
//     //       } else if (action == MenuAction.Rollwise_Report) {
//     //         Navigator.push(
//     //           context,
//     //           MaterialPageRoute(
//     //             builder: (_) => CuttingReportScreen(type: "ROLLWISE"),
//     //           ),
//     //         );
//     //       }
//     //       break;
//     //
//     //     case 'JBL Webbing':
//     //       if (action == MenuAction.IN) {
//     //         Navigator.pushNamed(context, AppRoutes.jblWebbIn);
//     //       } else if (action == MenuAction.OUT) {
//     //         Navigator.pushNamed(context, AppRoutes.jblWebbOut);
//     //       } else if (action == MenuAction.stock) {
//     //         Navigator.pushNamed(context, AppRoutes.webbingStockReport);
//     //       } else if (action == MenuAction.In_Report) {
//     //         Navigator.push(
//     //           context,
//     //           MaterialPageRoute(
//     //             builder: (_) => WebbingReportScreen(type: "IN"),
//     //           ),
//     //         );
//     //       }
//     //       // else if (action == MenuAction.OUT__) {
//     //       //   Navigator.push(
//     //       //     context,
//     //       //     MaterialPageRoute(
//     //       //       builder: (_) => WebbingReportScreen(type: "OUT"),
//     //       //     ),
//     //       //   );
//     //       else if (action == MenuAction.Out_Report) {
//     //         Navigator.push(
//     //           context,
//     //           MaterialPageRoute(
//     //             builder: (_) => WebbingReportScreen(type: "OUTREPORT"),
//     //           ),
//     //         );
//     //       } else if (action == MenuAction.Stock_Report) {
//     //         Navigator.push(
//     //           context,
//     //           MaterialPageRoute(builder: (_) => WebbingStockScreen()),
//     //         );
//     //       }
//     //       break;
//     //
//     //     case 'JBL Baling':
//     //       if (action == MenuAction.entry) {
//     //         Navigator.pushNamed(context, AppRoutes.jblBailing);
//     //       } else if (action == MenuAction.report) {
//     //         Navigator.pushNamed(context, AppRoutes.jblBailingReport);
//     //       } else if (action == MenuAction.OverAll_Report) {
//     //         Navigator.push(
//     //           context,
//     //           MaterialPageRoute(
//     //             builder: (_) => BaleReportScreen(type: "OVERALL"),
//     //           ),
//     //         );
//     //       } else if (action == MenuAction.Stock_Report) {
//     //         Navigator.push(
//     //           context,
//     //           MaterialPageRoute(
//     //             builder: (_) => BaleReportScreen(type: "STOCK"),
//     //           ),
//     //         );
//     //       }
//     //       break;
//     //
//     //     case 'JBL Dispatch':
//     //       if (action == MenuAction.entry) {
//     //         Navigator.pushNamed(context, AppRoutes.jblScan);
//     //       } else if (action == MenuAction.report) {
//     //         Navigator.pushNamed(context, AppRoutes.jblDispatchReport);
//     //       }
//     //       break;
//     //
//     //     case 'JBL BAG':
//     //       if (action == MenuAction.FIBC_Store) {
//     //         Navigator.pushNamed(context, AppRoutes.jblBagStoreIssue);
//     //       } else if (action == MenuAction.Packing_Department) {
//     //         Navigator.pushNamed(context, AppRoutes.jblPackingReport);
//     //       } else if (action == MenuAction.Bag_Report) {
//     //         Navigator.push(
//     //           context,
//     //           MaterialPageRoute(
//     //             builder: (_) => BagProductionReportScreen(type: "BAGREPORT"),
//     //           ),
//     //         );
//     //       } else if (action == MenuAction.Packing_Report) {
//     //         Navigator.push(
//     //           context,
//     //           MaterialPageRoute(
//     //             builder: (_) => BagProductionReportScreen(type: "PACKAGING"),
//     //           ),
//     //         );
//     //       } else if (action == MenuAction.entry) {
//     //         Navigator.push(
//     //           context,
//     //           MaterialPageRoute(builder: (_) => JBLBagEntryScreen()),
//     //         );
//     //       }
//     //       break;
//     //   }
//     // }
//     // // ✅ NORMAL FLOW
//     // else {
//     //
//
//       switch (label) {
//         // case 'LOOM':
//         //   if (action == MenuAction.IN) {
//         //     // Navigator.pushNamed(context, AppRoutes.visaLoomList);
//         //
//         //     Navigator.pushNamed(context, AppRoutes.loomIn);
//         //   } else if (action == MenuAction.report) {
//         //     Navigator.pushNamed(context, AppRoutes.loomReports);
//         //   }
//         //
//         //   break;
//
//         case 'CUTTING':
//           if (action == MenuAction.IN) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => CuttingScreen()),
//             );
//           }
//           // else if (action == MenuAction.OUT) {
//           //   Navigator.pushNamed(context, AppRoutes.visaCutOutStock);
//           // }
//           else if (action == MenuAction.stock) {
//             Navigator.pushNamed(context, AppRoutes.cutGroupStock);
//           }
//           // else if (action == MenuAction.Approval) {
//           //   Navigator.pushNamed(context, AppRoutes.cuttingnardana);
//           // } else if (action == MenuAction.Pcs_Issue) {
//           //   Navigator.pushNamed(context, AppRoutes.cuttingIssuenardana);
//           // }
//           break;
//
//         case 'LAMINATION':
//           if (action == MenuAction.IN) {
//             Navigator.pushNamed(context, AppRoutes.lamination);
//           }
//           // else if (action == MenuAction.OUT) {
//           //   Navigator.pushNamed(context, AppRoutes.laminationOutStock);
//           // }
//           else if (action == MenuAction.report) {
//             Navigator.pushNamed(context, AppRoutes.lamNaradanaReports);
//           }
//           break;
//
//         case 'RMD':
//           if (action == MenuAction.IN) {
//             Navigator.pushNamed(context, AppRoutes.rmdIn);
//           }
//           else if (action == MenuAction.OUT) {
//             Navigator.pushNamed(context, AppRoutes.rmdOut);
//           }
//           // else if (action == MenuAction.report) {
//           //   Navigator.pushNamed(context, AppRoutes.rmdNardanaReports);
//           // }
//           // else if (action == MenuAction.stock) {
//           //   Navigator.pushNamed(context, AppRoutes.rmdNardanaStock);
//           // }
//           break;
//
//         // case 'BAG':
//         //   if (action == MenuAction.entry) {
//         //     Navigator.pushNamed(context, AppRoutes.bagEntry);
//         //   } else {
//         //     Navigator.pushNamed(context, AppRoutes.bagReport);
//         //   }
//         //   break;
//
//         // case 'WEBBING':
//         //   if (action == MenuAction.IN) {
//         //     Navigator.pushNamed(context, AppRoutes.webbingIn);
//         //   } else if (action == MenuAction.OUT) {
//         //     Navigator.pushNamed(context, AppRoutes.webbingOut);
//         //   }
//         //   // WebbingInReportScreen
//         //   else if (action == MenuAction.report) {
//         //     Navigator.pushNamed(context, AppRoutes.webbNardanaReport);
//         //   }
//         //   else if(action == MenuAction.stock){
//         //     Navigator.pushNamed(context, AppRoutes.webStockSlider);
//         //   }
//         //   break;
//         //
//         // case 'BALING':
//         //   if (action == MenuAction.entry) {
//         //     Navigator.pushNamed(context, AppRoutes.baleEntry);
//         //   }
//         //   //
//         //   else if(action == MenuAction.stock){
//         //     Navigator.pushNamed(context, AppRoutes.baleStockgroup);
//         //   }
//         //   else if (action == MenuAction.report) {
//         //     Navigator.pushNamed(context, AppRoutes.baleReport);
//         //   } else if (action == MenuAction.dispatch) {
//         //     Navigator.pushNamed(context, AppRoutes.baleDispatch);
//         //   }
//         //   break;
//       }
//     }
//   // }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // Department Tile
// // ─────────────────────────────────────────────────────────────────────────────
// class _DepartmentTile extends StatefulWidget {
//   final _MenuItemData data;
//   final bool isSelected;
//   final VoidCallback onTap;
//   final void Function(MenuAction) onAction;
//
//   const _DepartmentTile({
//     Key? key,
//     required this.data,
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
//       duration: const Duration(milliseconds: 280),
//     );
//     _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
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
//     final actions = getActionsForMenu(widget.data.label);
//
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 220),
//         decoration: BoxDecoration(
//           color: C.cardBg,
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(
//             color: widget.isSelected ? C.brand500 : C.borderLight,
//             width: widget.isSelected ? 1.5 : 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: widget.isSelected ? C.brandOp20 : C.brandOp10,
//               blurRadius: widget.isSelected ? 20 : 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(18),
//           child: Column(
//             children: [
//               // ── Header row ──────────────────────────────────────────────
//               Material(
//                 color: Colors.transparent,
//                 child: InkWell(
//                   onTap: widget.onTap,
//                   splashColor: C.brand200.withOpacity(0.4),
//                   highlightColor: C.brand100.withOpacity(0.3),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 14,
//                     ),
//                     child: Row(
//                       children: [
//                         // Icon badge
//                         AnimatedContainer(
//                           duration: const Duration(milliseconds: 220),
//                           width: 46,
//                           height: 46,
//                           decoration: BoxDecoration(
//                             color: widget.isSelected ? C.brand600 : C.brand100,
//                             borderRadius: BorderRadius.circular(13),
//                             boxShadow: widget.isSelected
//                                 ? [
//                               BoxShadow(
//                                 color: C.brandOp30,
//                                 blurRadius: 10,
//                                 offset: const Offset(0, 3),
//                               ),
//                             ]
//                                 : [],
//                           ),
//                           child: Icon(
//                             widget.data.icon,
//                             size: 21,
//                             color: widget.isSelected
//                                 ? Colors.white
//                                 : C.brand700,
//                           ),
//                         ),
//
//                         const SizedBox(width: 14),
//
//                         // Label + hint
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 widget.data.label,
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w800,
//                                   color: widget.isSelected
//                                       ? C.brand700
//                                       : C.textHigh,
//                                   letterSpacing: 0.1,
//                                 ),
//                               ),
//                               const SizedBox(height: 2),
//                               Text(
//                                 widget.isSelected
//                                     ? 'Select an action below'
//                                     : '${actions.length} action${actions.length != 1 ? 's' : ''} available',
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w500,
//                                   color: widget.isSelected
//                                       ? C.brand500
//                                       : C.textMid,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         // Chevron
//                         RotationTransition(
//                           turns: _rotateAnim,
//                           child: AnimatedContainer(
//                             duration: const Duration(milliseconds: 220),
//                             width: 30,
//                             height: 30,
//                             decoration: BoxDecoration(
//                               color: widget.isSelected
//                                   ? C.brand100
//                                   : C.pillLight,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Icon(
//                               Icons.keyboard_arrow_down_rounded,
//                               size: 19,
//                               color: widget.isSelected ? C.brand700 : C.textMid,
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
//                     Container(
//                       height: 1,
//                       margin: const EdgeInsets.symmetric(horizontal: 16),
//                       color: C.brand200,
//                     ),
//                     Container(
//                       color: C.brand50,
//                       padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
//                       child: Wrap(
//                         spacing: 10,
//                         runSpacing: 10,
//                         children: actions
//                             .map(
//                               (a) => _ActionButton(
//                             action: a,
//                             onTap: () => widget.onAction(a),
//                           ),
//                         )
//                             .toList(),
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
// // Action Button
// // ─────────────────────────────────────────────────────────────────────────────
// class _ActionButton extends StatefulWidget {
//   final MenuAction action;
//   final VoidCallback onTap;
//   const _ActionButton({required this.action, required this.onTap});
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
//       case MenuAction.IN:
//         return Icons.login_rounded;
//       case MenuAction.OUT:
//         return Icons.logout_rounded;
//       case MenuAction.stock:
//         return Icons.inventory_rounded;
//       case MenuAction.report:
//         return Icons.bar_chart_rounded;
//       case MenuAction.entry:
//         return Icons.edit_note_rounded;
//       case MenuAction.scan:
//         return Icons.qr_code_scanner_rounded;
//       case MenuAction.dispatch:
//         return Icons.local_shipping_rounded;
//       default:
//         return Icons.circle_outlined;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
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
//         duration: const Duration(milliseconds: 110),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//           color: _pressed ? C.brand700 : C.cardBg,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: _pressed ? C.brand700 : C.brand300,
//             width: 1.5,
//           ),
//           boxShadow: _pressed
//               ? [
//             BoxShadow(
//               color: C.brandOp30,
//               blurRadius: 10,
//               offset: const Offset(0, 3),
//             ),
//           ]
//               : [
//             BoxShadow(
//               color: C.brandOp10,
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               _iconFor(widget.action),
//               size: 14,
//               color: _pressed ? Colors.white : C.brand700,
//             ),
//             const SizedBox(width: 7),
//             Text(
//               widget.action.name.toUpperCase(),
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w800,
//                 color: _pressed ? Colors.white : C.brand700,
//                 letterSpacing: 0.8,
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
//               width: 84,
//               height: 84,
//               decoration: BoxDecoration(
//                 color: C.brand100,
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: C.brandOp20,
//                     blurRadius: 20,
//                     offset: const Offset(0, 6),
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.dashboard_customize_rounded,
//                 size: 38,
//                 color: C.brand600,
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'No Departments Available',
//               style: TextStyle(
//                 fontSize: 17,
//                 fontWeight: FontWeight.w800,
//                 color: C.textHigh,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Please contact your administrator\nto get access.',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 13, color: C.textMid, height: 1.6),
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
