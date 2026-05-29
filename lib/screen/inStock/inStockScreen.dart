// import 'package:flutter/material.dart';
// import '../../QRScan/QrScanScreen.dart';
// import 'inStockController.dart';
//
//
// class InStockScreen extends StatefulWidget {
//   const InStockScreen({Key? key}) : super(key: key);
//
//   @override
//   State<InStockScreen> createState() => _InStockScreenState();
// }
//
// class _InStockScreenState extends State<InStockScreen> {
//   final controller = InStockController();
//
//   @override
//   void initState() {
//     super.initState();
//     controller.loadSupervisors().then((_) => setState(() {}));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: controller.isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _buildBody(),
//     );
//   }
//
//   Widget _buildBody() {
//     return Column(
//       children: [
//         DropdownButton<String>(
//           value: controller.selectedSupervisor,
//           items: controller.supervisors
//               .map(
//                 (e) => DropdownMenuItem(
//               value: e.label,
//               child: Text(e.label),
//             ),
//           )
//               .toList(),
//           onChanged: (value) {
//             setState(() => controller.selectedSupervisor = value);
//           },
//         ),
//       ],
//     );
//   }
// }
