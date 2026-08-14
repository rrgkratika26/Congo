// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_navigation/src/extension_navigation.dart';
// import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
//
// import '../../Color/Colorclass.dart';
// import '../ActionButtonWidget.dart';
// import '../DepartmentDashboard.dart';
// import 'ActionCard.dart';
// import 'Navigate.dart';
//
// class DashboardTab extends StatelessWidget {
//   final DashboardController ctrl;
//   final String department;
//   final bool isMobile;
//   const DashboardTab({required this.ctrl, required this.department, required this.isMobile});
//
//   @override
//   Widget build(BuildContext context) {
//     final mq = MediaQuery.of(context);
//     final actions = getActionsForMenu(department);
//     final crossCount = isMobile ? 2 : (mq.size.width < 1000 ? 3 : 4);
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//
//           _Header(ctrl: ctrl, isMobile: isMobile),
//
//         Expanded(
//           child: GridView.builder(
//             padding: EdgeInsets.all(isMobile ? 16 : 24),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: crossCount,
//               crossAxisSpacing: 14,
//               mainAxisSpacing: 14,
//               childAspectRatio: 1.15,
//             ),
//             itemCount: actions.length,
//             itemBuilder: (ctx, i) => ActionCard(
//               action: actions[i],
//               isMobile: isMobile,
//               onTap: () => navigate(ctx, department, actions[i]),
//             ),
//           ),
//         ),
//         // Logout Button
//         Align(
//           alignment: Alignment.center,
//           child: TextButton(
//             onPressed: () async {
//               final confirm = await Get.dialog(
//                 AlertDialog(
//                   title: const Text("Logout"),
//                   content: const Text("Are you sure you want to logout?"),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Get.back(result: false),
//                       child: const Text(
//                         "Cancel",
//                         style: TextStyle(color: C.textHigh),
//                       ),
//                     ),
//                     ElevatedButton(
//                       onPressed: () => Get.back(result: true),
//                       child: const Text(
//                         "Logout",
//                         style: TextStyle(color: C.danger),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//
//               if (confirm == true) {
//                 ctrl.logout();
//               }
//             },
//             child: Text(
//               "Logout",
//               style: TextStyle(color: C.danger, fontSize: 14),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _Header extends StatelessWidget {
//   final DashboardController ctrl;
//   final bool isMobile;
//   const _Header({required this.ctrl, required this.isMobile});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(
//         horizontal: isMobile ? 16 : 28,
//         vertical: isMobile ? 14 : 18,
//       ),
//       decoration: const BoxDecoration(
//         color: C.appBar1,
//         borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           Builder(
//             builder: (ctx) => IconButton(
//               onPressed: () => Scaffold.of(ctx).openDrawer(),
//               icon: Icon(
//                 Icons.menu,
//                 color: Colors.white,
//                 size: isMobile ? 24 : 28,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               // crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Obx(
//                       () => ctrl.unit.value.isEmpty
//                       ? const SizedBox.shrink()
//                       : Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         ctrl.unit.value,
//                         style: TextStyle(
//                           color: C.bg,
//                           fontSize: isMobile ? 20 : 28,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 4),
//                 Text(
//                   'ERP',
//                   style: TextStyle(
//                     color: C.bg,
//                     fontSize: isMobile ? 20 : 28,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Logout Button
//           Align(
//             alignment: Alignment.center,
//             child: TextButton(
//               onPressed: () async {
//                 final confirm = await Get.dialog(
//                   AlertDialog(
//                     title: const Text("Logout"),
//                     content: const Text("Are you sure you want to logout?"),
//                     actions: [
//                       TextButton(
//                         onPressed: () => Get.back(result: false),
//                         child: const Text(
//                           "Cancel",
//                           style: TextStyle(color: C.textHigh),
//                         ),
//                       ),
//                       ElevatedButton(
//                         onPressed: () => Get.back(result: true),
//                         child: const Text(
//                           "Logout",
//                           style: TextStyle(color: C.danger),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//
//                 if (confirm == true) {
//                   ctrl.logout();
//                 }
//               },
//               child: Text(
//                 "Logout",
//                 style: TextStyle(color: C.danger, fontSize: 14),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//
//
// }
