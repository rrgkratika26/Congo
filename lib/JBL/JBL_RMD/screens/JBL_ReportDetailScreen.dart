// // import 'package:flutter/material.dart';
// //
// // class Jbl_ReportDetailScreen extends StatelessWidget {
// //   final String title;
// //   final String date;
// //   final List<dynamic> data;
// //
// //   const Jbl_ReportDetailScreen({
// //     Key? key,
// //     required this.title,
// //     required this.date,
// //     required this.data,
// //   }) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text(title), // ✅ dynamic title
// //       ),
// //       body: data.isEmpty
// //           ? const Center(child: Text("No Data Found"))
// //           : ListView.builder(
// //         itemCount: data.length,
// //         itemBuilder: (context, index) {
// //           final item = data[index];
// //
// //           return Card(
// //             margin: const EdgeInsets.all(10),
// //             child: Padding(
// //               padding: const EdgeInsets.all(12),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: item.entries.map<Widget>((entry) {
// //                   return _row(entry.key, entry.value);
// //                 }).toList(),
// //               ),
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }
// //
// //   Widget _row(String key, dynamic value) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 2),
// //       child: Row(
// //         children: [
// //           SizedBox(
// //             width: 140,
// //             child: Text(
// //               "$key:",
// //               style: const TextStyle(fontWeight: FontWeight.bold),
// //             ),
// //           ),
// //           Expanded(
// //             child: Text(value?.toString() ?? "-"),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import '../../../Color/Colorclass.dart';
//
// class Jbl_ReportDetailScreen extends StatelessWidget {
//   final String title;
//   final String date;
//   final List<dynamic> data;
//
//   const Jbl_ReportDetailScreen({
//     Key? key,
//     required this.title,
//     required this.date,
//     required this.data,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: C.pageBg,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: C.headerBlue,
//         iconTheme: const IconThemeData(color: Colors.white),
//
//         title: Text(title, style: TextStyle(color: C.primaryLight)),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(20),
//           child: Padding(
//             padding: const EdgeInsets.only(bottom: 8),
//             child: Text(date, style: const TextStyle(color: Colors.white70)),
//           ),
//         ),
//       ),
//
//       body: data.isEmpty
//           ? _emptyState()
//           : ListView.builder(
//               padding: const EdgeInsets.all(12),
//               itemCount: data.length,
//               itemBuilder: (context, index) {
//                 final item = Map<String, dynamic>.from(data[index]);
//
//                 return _reportCard(item, index);
//               },
//             ),
//     );
//   }
//
//   // ================= CARD =================
//
//   Widget _reportCard(Map<String, dynamic> item, int index) {
//     final barcode = item['BARCODE'] ?? '-';
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: C.brandOp10,
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // 🔷 HEADER (Barcode Highlight)
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: C.lightBlue,
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(16),
//               ),
//             ),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 16,
//                   backgroundColor: C.primaryBlue,
//                   child: Text(
//                     "${index + 1}",
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//
//                 // ✅ BARCODE (MAIN)
//                 Expanded(
//                   child: Text(
//                     barcode.toString(),
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: C.text,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // 🔽 ALL DETAILS FROM API
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               children: item.entries.map((e) {
//                 return _detailRow(e.key, e.value);
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ================= ROW =================
//
//   Widget _detailRow(String key, dynamic value) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//       decoration: BoxDecoration(
//         color: C.pillLight,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           // KEY
//           Expanded(
//             flex: 5,
//             child: Text(
//               key,
//               style: const TextStyle(color: C.textSub, fontSize: 13),
//             ),
//           ),
//
//           // VALUE
//           Expanded(
//             flex: 5,
//             child: Text(
//               value?.toString() ?? "-",
//               textAlign: TextAlign.right,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: C.text,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ================= EMPTY =================
//
//   Widget _emptyState() {
//     return Center(
//       child: Text(
//         "No Report Data",
//         style: TextStyle(color: C.textSub, fontSize: 16),
//       ),
//     );
//   }
// }
