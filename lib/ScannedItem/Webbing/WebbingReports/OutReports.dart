// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// //
// // class WebbOutReportDetailsScreen extends StatefulWidget {
// //   const WebbOutReportDetailsScreen({super.key});
// //
// //   @override
// //   State<WebbOutReportDetailsScreen> createState() => _WebbingInReportsState();
// // }
// //
// // class _WebbingInReportsState extends State<WebbOutReportDetailsScreen> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(body: Column(
// //       children: [
// //         Padding(
// //           padding: const EdgeInsets.all(28.0),
// //           child: Text("Webbing Out Reports"),
// //         ),
// //       ],
// //     ));
// //   }
// // }
//
//
//
//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../services/getSupervisors/getSupervisors.dart';
//
//
// class WebbOutReportDetailsScreen extends StatelessWidget {
//   final String date;
//
//   WebbOutReportDetailsScreen({Key? key, required this.date}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Webbing Out Stock Reports"),
//         centerTitle: true,
//       ),
//       body: FutureBuilder<WebbingOutReportModel?>(
//         future: InStockService.fetchWebbingScannedOutItems(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }
//
//           if (!snapshot.hasData || snapshot.data == null) {
//             return const Center(child: Text("No Data Found"));
//           }
//
//           final items = snapshot.data!.data;
//
//           if (items.isEmpty) {
//             return const Center(child: Text("No Items Found"));
//           }
//
//           return LayoutBuilder(
//             builder: (context, constraints) {
//               return SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.vertical,
//                   child: Column(
//                     children: [
//                       /// 🔹 HEADER
//                       Container(
//                         color: Colors.grey.shade200,
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             children: const [
//                               _HeaderCell("SR No", 70),
//                               _HeaderCell("Barcode", 120),
//                               _HeaderCell("Roll Code", 120),
//                               _HeaderCell("Lot No", 100),
//                               _HeaderCell("Fabric Code", 120),
//                               _HeaderCell("Weight", 90),
//                               _HeaderCell("Party", 140),
//                               _HeaderCell("PO No", 100),
//                               _HeaderCell("Article", 120),
//                               _HeaderCell("Supervisor", 140),
//                               _HeaderCell("Shift", 80),
//                               _HeaderCell("Machine", 100),
//                               _HeaderCell("Width", 80),
//                               _HeaderCell("Date", 110),
//                               _HeaderCell("Time", 90),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       /// 🔹 DATA
//                       SizedBox(
//                         height: constraints.maxHeight - 50,
//                         child: SingleChildScrollView(
//                           child: Column(
//                             children: items.map((item) {
//                               return Container(
//                                 decoration: const BoxDecoration(
//                                   border: Border(
//                                     bottom: BorderSide(color: Colors.black12),
//                                   ),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     _DataCell(item.srNo.toString(), 70),
//                                     _DataCell(item.barcode, 120),
//                                     _DataCell(item.rollCode, 120),
//                                     _DataCell(item.lotNo, 100),
//                                     _DataCell(item.fabricCode, 120),
//                                     _DataCell(item.rollWeightKg.toString(), 90),
//                                     _DataCell(item.partyName, 140),
//                                     _DataCell(item.poNo, 100),
//                                     _DataCell(item.articleNo, 120),
//                                     _DataCell(item.supervisorName, 140),
//                                     _DataCell(item.shift, 80),
//                                     _DataCell(item.machineNo, 100),
//                                     _DataCell(item.beltWidthCm.toString(), 80),
//                                     _DataCell(
//                                       DateFormat(
//                                         'dd-MM-yyyy',
//                                       ).format(item.date),
//                                       110,
//                                     ),
//                                     _DataCell(item.time, 90),
//                                   ],
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
//
// class _DataCell extends StatelessWidget {
//   final String text;
//   final double width;
//
//   const _DataCell(this.text, this.width);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: width,
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//       child: Text(
//         text.isEmpty ? "-" : text,
//         overflow: TextOverflow.ellipsis,
//         style: const TextStyle(fontSize: 13),
//       ),
//     );
//   }
// }
//
// class _HeaderCell extends StatelessWidget {
//   final String text;
//   final double width;
//
//   const _HeaderCell(this.text, this.width);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: width,
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       child: Text(
//         text,
//         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
//       ),
//     );
//   }
// }
