// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import 'JBL/JBL_RMD/AllReportScreen.dart';
//
// class DynamicReportScreenWrapper extends StatelessWidget {
//   const DynamicReportScreenWrapper({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final args = ModalRoute.of(context)?.settings.arguments;
//
//     if (args == null || args is! Map<String, dynamic>) {
//       return const Scaffold(
//         body: Center(child: Text("Invalid arguments passed")),
//       );
//     }
//
//     return DynamicReportScreen(
//       title: args['title'] ?? 'Report',
//       endpoint: args['endpoint'] ?? '',
//       initialParams: Map<String, String>.from(args['params'] ?? {}),
//     );
//   }
// }
