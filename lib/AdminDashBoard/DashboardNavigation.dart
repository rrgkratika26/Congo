// import 'package:flutter/material.dart';
//
// import 'ActionBottomSheet.dart';
// import 'ActionButtonWidget.dart';
// import 'dashboardMenuItem.dart';
// import 'package:flutter/material.dart';
//
// import '../screen/BagProduction/BagProduction/BagProductionEntryScreen.dart';
// import '../screen/BagProduction/BagProduction/BagReportScreen.dart';
// import '../ScannedItem/RmdIn/RMDscreen.dart';
// import '../ScannedItem/RmdOut/RmdOutScreen.dart';
// import '../ScannedItem/RMDStock/RMDstockScreen.dart';
// import '../ScannedItem/Cutting/CuttinIN/CuttingScreen.dart';
// import '../ScannedItem/Lamination/LaminationScreen.dart';
//
//
// final List<DashboardMenuItem> menuItems = [
//   DashboardMenuItem(
//     icon: Icons.settings,
//     label: 'RMD',
//     color: Colors.blue,
//     gradient: [Colors.blue, Colors.blueAccent],
//     inScreen: const RmdScreen(),
//     outScreen: const RmdOutScreen(),
//     stockScreen: const RMDStockReportScreen(),
//   ),
//
//   DashboardMenuItem(
//     icon: Icons.layers,
//     label: 'Lamination',
//     color: Colors.orange,
//     gradient: [Colors.orange, Colors.deepOrange],
//     inScreen: const LaminationScreen(),
//   ),
//
//   DashboardMenuItem(
//     icon: Icons.cut,
//     label: 'Cutting',
//     color: Colors.green,
//     gradient: [Colors.green, Colors.greenAccent],
//     inScreen: const CuttingScreen(),
//   ),
//
//   DashboardMenuItem(
//     icon: Icons.shopping_bag,
//     label: 'Bag Production',
//     color: Colors.indigo,
//     gradient: [Colors.indigo, Colors.indigoAccent],
//     inScreen:  BagEntryScreen(),
//     reportScreen:  Bagreportscreen(),
//   ),
// ];
//
// void handleMenuTap(
//     BuildContext context,
//     DashboardMenuItem data,
//     ) {
//   final actions = getActionsForMenu(data.label);
//
//   if (actions.isEmpty) {
//     _showMessage(context, '${data.label} screens are not available yet');
//     return;
//   }
//
//   showModalBottomSheet(
//     context: context,
//     backgroundColor: Colors.transparent,
//     builder: (_) {
//       return ActionBottomSheet(
//         data: data,
//         actions: actions,
//       );
//     },
//   );
// }
//
//
//
// void _showMessage(BuildContext context, String msg) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text(msg),
//       behavior: SnackBarBehavior.floating,
//       duration: const Duration(seconds: 2),
//     ),
//   );
// }