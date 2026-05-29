// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'dart:async';
//
// // ---------------- MODEL ----------------
// class ItemRecord {
//   final String barcode;
//   final String itemName;
//   final String description;
//
//   ItemRecord({
//     required this.barcode,
//     required this.itemName,
//     required this.description,
//   });
// }
//
// // ---------------- SCREEN ----------------
// class ScanAndFetchScreen extends StatefulWidget {
//   const ScanAndFetchScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ScanAndFetchScreen> createState() => _ScanAndFetchScreenState();
// }
//
// class _ScanAndFetchScreenState extends State<ScanAndFetchScreen> {
//   final MobileScannerController _scannerController = MobileScannerController();
//   final List<ItemRecord> _records = [];
//
//   bool _isFetching = false;
//   String? _lastScanned;
//
//   // ---------------- MOCK API CALL ----------------
//   Future<ItemRecord> fetchItemDetails(String barcode) async {
//     await Future.delayed(const Duration(seconds: 1)); // simulate API delay
//
//     return ItemRecord(
//       barcode: barcode,
//       itemName: "Item $barcode",
//       description: "Fetched details for barcode $barcode",
//     );
//   }
//
//   // ---------------- HANDLE SCAN ----------------
//   Future<void> _onBarcodeScanned(String code) async {
//     if (_isFetching || _lastScanned == code) return;
//
//     setState(() {
//       _isFetching = true;
//       _lastScanned = code;
//     });
//
//     final item = await fetchItemDetails(code);
//
//     setState(() {
//       _records.insert(0, item);
//       _isFetching = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Scan & Fetch Items"),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           // ---------------- SCANNER ----------------
//           SizedBox(
//             height: 220,
//             child: MobileScanner(
//               controller: _scannerController,
//               onDetect: (barcode, args) {
//                 final String? code = barcode.rawValue;
//                 if (code != null) {
//                   _onBarcodeScanned(code);
//                 }
//               },
//             ),
//           ),
//
//           if (_isFetching)
//             const Padding(
//               padding: EdgeInsets.all(8.0),
//               child: LinearProgressIndicator(),
//             ),
//
//           const SizedBox(height: 8),
//           const Divider(),
//
//           // ---------------- RECORDS ----------------
//           Expanded(
//             child: _records.isEmpty
//                 ? const Center(
//               child: Text("No records scanned yet"),
//             )
//                 : ListView.builder(
//               itemCount: _records.length,
//               itemBuilder: (context, index) {
//                 final item = _records[index];
//                 return Card(
//                   margin: const EdgeInsets.symmetric(
//                       horizontal: 12, vertical: 6),
//                   child: ListTile(
//                     leading: const Icon(Icons.qr_code),
//                     title: Text(item.itemName),
//                     subtitle: Text(item.description),
//                     trailing: Text(item.barcode),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// /*
// PUBSPEC DEPENDENCY:
//
// mobile_scanner: ^5.0.0
//
// ANDROID:
// - minSdkVersion 21
//
// IOS:
// - Add camera permission in Info.plist
// */
