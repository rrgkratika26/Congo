// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
//
// import '../../Color/Colorclass.dart';
// import '../../services/JBL_apis/jbl_api_bailing_reports.dart';
// import '../../services/getSupervisors/getSupervisors.dart';
// import '../../util/sharedpreference/shared_preference.dart';
//
// class PackingEntryScreen extends StatefulWidget {
//   const PackingEntryScreen({Key? key}) : super(key: key);
//
//   @override
//   State<PackingEntryScreen> createState() => _PackingEntryScreenState();
// }
//
// class _PackingEntryScreenState extends State<PackingEntryScreen> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   final _dispatchNoController = TextEditingController();
//   bool isDispatchLoading = false;
//   QRViewController? controller;
//   bool isSheetOpen = false;
//   // Header field controllers
//
//   final _partyNameController = TextEditingController();
//   final _transportNameController = TextEditingController();
//   final _poNoController = TextEditingController();
//   final _vehicleNoController = TextEditingController();
//   final _invoiceNoController = TextEditingController();
//   final _barcodeController = TextEditingController();
//   List<String> partyList = [];
//   String? selectedParty;
//   bool isPartyLoading = false;
//
//   List<Map<String, dynamic>> entries = [];
//   bool isProcessing = false;
//   bool isFetching = false;
//   Timer? _scanTimer;
//   // ─── Theme ───────────────────────────────────────────────────────────────
//
//   // ─── API endpoint ────────────────────────────────────────────────────────
//   static final String _apiBase =
//       '${JblApiService.baseUrlJBL}/BaleDepartment/dispatch';
//
//   // ─── Totals ───────────────────────────────────────────────────────────────
//   double get totalGross =>
//       entries.fold(0.0, (s, e) => s + _toDouble(e['grossWt']));
//   double get totalTare =>
//       entries.fold(0.0, (s, e) => s + _toDouble(e['tareWt']));
//   double get totalNet => entries.fold(0.0, (s, e) => s + _toDouble(e['netWt']));
//   int get totalPcs =>
//       entries.fold(0, (s, e) => s + (_toDouble(e['pcs']).toInt()));
//
//   // ─── API call ─────────────────────────────────────────────────────────────
//   Future<void> fetchPartyList() async {
//     setState(() => isPartyLoading = true);
//
//     try {
//       final token = await AppSession.getToken();
//
//       if (token == null || token.isEmpty) {
//         _snack('Session expired. Please login again.', error: true);
//         return;
//       }
//
//       final uri = Uri.parse(
//         "${JblApiService.baseUrlJBL}/BaleDepartment/GetDispatchByNo",
//       );
//       final response = await http
//           .get(
//             uri,
//           headers: await InStockService.authHeaders(),
//           )
//           .timeout(const Duration(seconds: 20));
//
//       debugPrint("PARTY STATUS: ${response.statusCode}");
//       debugPrint("PARTY BODY: ${response.body}");
//
//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//
//         final companies =
//             data
//                 .map((e) => e['companY_NAME']?.toString().trim() ?? '')
//                 .where((name) => name.isNotEmpty)
//                 .toSet() // remove duplicates
//                 .toList()
//               ..sort();
//
//         setState(() {
//           partyList = companies;
//         });
//       } else {
//         _snack('Failed to load party list', error: true);
//       }
//     } catch (e) {
//       _snack('Party API Error: $e', error: true);
//     } finally {
//       if (mounted) setState(() => isPartyLoading = false);
//     }
//   }
//
//   Future<void> fetchAndAddEntry(String barcode) async {
//     final trimmed = barcode.trim();
//     if (trimmed.isEmpty) return;
//
//     if (entries.any((e) => e['packingNo'] == trimmed)) {
//       _snack('Already added: $trimmed', error: true);
//       return;
//     }
//
//     setState(() => isFetching = true);
//
//     try {
//       // 🔐 Get saved token
//       final token = await AppSession.getToken();
//
//       if (token == null || token.isEmpty) {
//         _snack('Session expired. Please login again.', error: true);
//         return;
//       }
//
//       final uri = Uri.parse(
//         '$_apiBase?packingNo=${Uri.encodeComponent(trimmed)}',
//       );
//
//       final response = await http
//           .get(
//             uri,
//           headers: await InStockService.authHeaders(),
//
//     )
//           .timeout(const Duration(seconds: 15));
//
//       debugPrint("STATUS: ${response.statusCode}");
//       debugPrint("BODY: ${response.body}");
//
//       if (response.statusCode == 200) {
//         final List<dynamic> decoded = jsonDecode(response.body);
//
//         if (decoded.isEmpty) {
//           _snack('No data found for: $trimmed', error: true);
//           return;
//         }
//
//         final data = decoded.first;
//
//         final double gross = _toDouble(data['bailingGrossWt']);
//         final double tare = _toDouble(data['bailingTareWt']);
//         final double net = _toDouble(data['bailingNetWt']);
//
//         final entry = {
//           'packingNo': data['packingNo'],
//           'bomNo': data['bomNo'], // ✅ store separately
//           'bagSize': data['bagSize'],
//           'pcs': data['noOfPcsPerPacking'],
//           'grossWt': gross,
//           'tareWt': tare,
//           'netWt': net,
//         };
//
//         setState(() => entries.add(entry));
//         _snack('✓ Added: ${data['packingNo']}');
//       } else if (response.statusCode == 401) {
//         _snack('Unauthorized. Please login again.', error: true);
//       } else {
//         _snack('Error ${response.statusCode}: ${response.body}', error: true);
//       }
//     } catch (e) {
//       _snack('Error: $e', error: true);
//     } finally {
//       if (mounted) setState(() => isFetching = false);
//     }
//   }
//
//   Future<void> fetchNextDispatchNo() async {
//     setState(() => isDispatchLoading = true);
//
//     try {
//       final token = await AppSession.getToken();
//
//       final uri = Uri.parse(
//         '${JblApiService.baseUrlJBL}/BaleDepartment/next-dispatch-no',
//       );
//
//       final response = await http.get(
//         uri,
//         headers: await InStockService.authHeaders()
//       );
//
//       debugPrint("DISPATCH BODY: ${response.body}");
//
//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//
//         if (decoded['success'] == true) {
//           setState(() {
//             _dispatchNoController.text = decoded['data'].toString();
//           });
//         } else {
//           _snack(decoded['message'], error: true);
//         }
//       } else {
//         _snack('Failed to load Dispatch No', error: true);
//       }
//     } catch (e) {
//       _snack('Dispatch API Error: $e', error: true);
//     } finally {
//       if (mounted) setState(() => isDispatchLoading = false);
//     }
//   }
//
//   String _extractError(String body) {
//     try {
//       final m = jsonDecode(body);
//       return (m['message'] ?? m['Message'] ?? body).toString();
//     } catch (_) {
//       return body.length > 80 ? '${body.substring(0, 80)}…' : body;
//     }
//   }
//
//   Future<void> _saveDispatchEntries() async {
//     if (selectedParty == null || selectedParty!.trim().isEmpty) {
//       _snack("Please select Party Name", error: true);
//       return;
//     }
//
//     if (entries.isEmpty) {
//       _snack("No entries to save", error: true);
//       return;
//     }
//
//     setState(() => isProcessing = true);
//
//     try {
//       final token = await AppSession.getToken();
//
//       if (token == null || token.isEmpty) {
//         _snack("Session expired. Please login again.", error: true);
//         return;
//       }
//
//       final payload = {
//         "dispatchNo": _dispatchNoController.text.trim(),
//         "partyName": selectedParty ?? "",
//         "poNo": _poNoController.text.trim(),
//         "invoiceNo": _invoiceNoController.text.trim(),
//         "transportName": _transportNameController.text.trim(),
//         "vehicleNo": _vehicleNoController.text.trim(),
//
//         "totalGwt": totalGross,
//         "totalTwt": totalTare,
//         "totalNetwt": totalNet,
//         "totalPcs": totalPcs,
//         "totalCount": entries.length,
//
//         "packingList": entries
//             .map(
//               (e) => {
//                 "packingNo": e['packingNo'],
//                 "bomNo": e['bomNo'],
//                 "bagSize": e['bagSize'],
//                 "noOfPcsPerPacking": _toDouble(e['pcs']).toInt(),
//                 "bailingGrossWt": _toDouble(e['grossWt']),
//                 "bailingTareWt": _toDouble(e['tareWt']),
//                 "bailingNetWt": _toDouble(e['netWt']),
//               },
//             )
//             .toList(),
//       };
//
//       debugPrint("── SAVE DISPATCH PAYLOAD ──");
//       debugPrint(const JsonEncoder.withIndent('  ').convert(payload));
//
//       final response = await http.post(
//         Uri.parse(
//           "${JblApiService.baseUrlJBL}/BaleDepartment/save-dispatch",
//         ),
//         headers:await InStockService.authHeaders(),
//         body: jsonEncode(payload),
//       );
//
//       debugPrint("SAVE STATUS: ${response.statusCode}");
//       debugPrint("SAVE BODY: ${response.body}");
//
//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//
//         if (decoded['success'] == true) {
//           _snack("Dispatch Saved Successfully ✅");
//
//           // Optional: Clear entries after save
//           setState(() {
//             entries.clear();
//           });
//
//           // Optional: Fetch next dispatch number automatically
//           await fetchNextDispatchNo();
//         } else {
//           _snack(decoded['message'] ?? "Save failed", error: true);
//         }
//       } else {
//         _snack("Error ${response.statusCode}", error: true);
//       }
//     } catch (e) {
//       _snack("Save Error: $e", error: true);
//     } finally {
//       if (mounted) setState(() => isProcessing = false);
//     }
//   }
//
//   // void _openScanner() {
//   //   isProcessing = false;
//   //
//   //   showModalBottomSheet(
//   //     context: context,
//   //     isScrollControlled: true,
//   //     backgroundColor: Colors.transparent,
//   //     builder: (_) => Container(
//   //       height: MediaQuery.of(context).size.height * 0.75,
//   //       decoration: const BoxDecoration(
//   //         color: Colors.black,
//   //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//   //       ),
//   //       child: Column(
//   //         children: [
//   //           Container(
//   //             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//   //             decoration: const BoxDecoration(
//   //               color: headerBlue,
//   //               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//   //             ),
//   //             child: Row(
//   //               children: [
//   //                 const Icon(Icons.qr_code_scanner, color: Colors.white),
//   //                 const SizedBox(width: 10),
//   //                 const Expanded(
//   //                   child: Text(
//   //                     'Scan QR / Barcode',
//   //                     style: TextStyle(
//   //                       color: Colors.white,
//   //                       fontSize: 16,
//   //                       fontWeight: FontWeight.w600,
//   //                     ),
//   //                   ),
//   //                 ),
//   //                 IconButton(
//   //                   icon: const Icon(Icons.close, color: Colors.white),
//   //                   onPressed: () => Navigator.pop(context),
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //
//   //           Expanded(
//   //             child: QRView(
//   //               key: qrKey,
//   //               onQRViewCreated: _onQRViewCreated,
//   //               overlay: QrScannerOverlayShape(
//   //                 borderColor: Colors.lightBlueAccent,
//   //                 borderRadius: 12,
//   //                 borderLength: 30,
//   //                 borderWidth: 10,
//   //                 cutOutSize: 260,
//   //               ),
//   //             ),
//   //           ),
//   //
//   //           const SizedBox(height: 12),
//   //           const Text(
//   //             "Scanner will close automatically in 10 seconds",
//   //             style: TextStyle(color: Colors.white60),
//   //           ),
//   //           const SizedBox(height: 12),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   //
//   //   // ✅ 10 second auto close timer
//   //   _scanTimer?.cancel();
//   //   _scanTimer = Timer(const Duration(seconds: 10), () {
//   //     if (Navigator.canPop(context)) {
//   //       Navigator.pop(context);
//   //       _snack("Scanner timeout", error: true);
//   //     }
//   //   });
//   // }
//   // ─── QR Scanner ───────────────────────────────────────────────────────────
//   void _onQRViewCreated(QRViewController ctrl) {
//     controller = ctrl;
//
//     controller!.scannedDataStream.listen((scanData) async {
//       if (isProcessing) return;
//
//       final code = scanData.code?.trim();
//       if (code == null || code.isEmpty) return;
//
//       isProcessing = true;
//
//       // ✅ STOP scanner (VERY IMPORTANT)
//       await controller?.pauseCamera();
//
//
//
//       _scanTimer?.cancel();
//
//       if (mounted && Navigator.canPop(context)) {
//         Navigator.pop(context);
//       }
//
//       await fetchAndAddEntry(code);
//
//       // ✅ resume camera for next scan (optional)
//       await controller?.resumeCamera();
//
//       isProcessing = false;
//     });
//   }
//
//   void _openScanner() {
//     isProcessing = false;
//     isSheetOpen = true;
//
//     // _scanTimer?.cancel(); // pehle ka timer cancel
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return Container(
//           height: MediaQuery.of(context).size.height * 0.95,
//           decoration: const BoxDecoration(
//             color: Colors.black,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 14,
//                 ),
//                 decoration: const BoxDecoration(
//                   color: C.headerBlue,
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.qr_code_scanner, color: Colors.white),
//                     const SizedBox(width: 10),
//                     const Expanded(
//                       child: Text(
//                         'Scan QR / Barcode',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close, color: Colors.white),
//                         onPressed: () {
//                           Navigator.pop(context); // ✅ close immediately
//                         }
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: QRView(
//                   key: qrKey,
//                   onQRViewCreated: _onQRViewCreated,
//                   overlay: QrScannerOverlayShape(
//                     borderColor: Colors.lightBlueAccent,
//                     borderRadius: 12,
//                     borderLength: 30,
//                     borderWidth: 10,
//                     cutOutSize: 260,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               const Text(
//                 "Scanner will close in 10 seconds",
//                 style: TextStyle(color: Colors.white60),
//               ),
//               const SizedBox(height: 12),
//             ],
//           ),
//         );
//       },
//     ).whenComplete(() {
//       // Bottom sheet close hone par timer cancel
//       isSheetOpen = false;
//       _scanTimer?.cancel();
//       // controller?.dispose();
//       controller?.pauseCamera();
//     });
//
//     // ✅ 10 sec auto close
//     _scanTimer = Timer(const Duration(seconds: 100), () {
//       if (mounted && Navigator.canPop(context)) {
//         Navigator.pop(context);
//         _snack("Scanner timeout", error: true);
//       }
//     });
//   }
//
//   // ─── Manual Entry dialog ──────────────────────────────────────────────────
//   void _openManualEntry() {
//     _barcodeController.clear();
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Row(
//           children: [
//             Flexible(
//               child: Text(
//                 'Enter Barcode No.',
//                 style: TextStyle(
//                   color: C.primary,
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         content: TextField(
//           controller: _barcodeController,
//           autofocus: true,
//           decoration: InputDecoration(
//             hintText: 'Enter Packing No.',
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(color: C.primary, width: 1),
//             ),
//             prefixIcon: const Icon(Icons.qr_code, color: C.primary),
//           ),
//           onSubmitted: (val) {
//             if (val.trim().isNotEmpty) {
//               Navigator.pop(ctx);
//               fetchAndAddEntry(val.trim());
//             }
//           },
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('Cancel', style: TextStyle(color: Colors.black)),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final val = _barcodeController.text.trim();
//               if (val.isNotEmpty) {
//                 Navigator.pop(ctx);
//                 fetchAndAddEntry(val);
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: C.primaryBlue,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text('Fetch', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ─── Delete row ───────────────────────────────────────────────────────────
//   void _deleteEntry(int index) {
//     final pno = entries[index]['packingNo'];
//     setState(() => entries.removeAt(index));
//     _snack('Removed: $pno');
//   }
//
//   // ─── Save ─────────────────────────────────────────────────────────────────
//
//   // ─── Helpers ──────────────────────────────────────────────────────────────
//   double _toDouble(dynamic val) {
//     if (val == null) return 0.0;
//     if (val is double) return val;
//     if (val is int) return val.toDouble();
//     return double.tryParse(val.toString()) ?? 0.0;
//   }
//
//   String _fmt(dynamic val) {
//     final d = _toDouble(val);
//     return (d % 1 == 0) ? d.toStringAsFixed(0) : d.toStringAsFixed(2);
//   }
//
//   void _snack(String msg, {bool error = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: error ? Colors.red.shade700 : C.primaryBlue,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
//
//   // ─── Header field builder ─────────────────────────────────────────────────
//   Widget _field(String label, TextEditingController ctrl) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         label,
//         style: const TextStyle(
//           fontSize: 10,
//           fontWeight: FontWeight.w700,
//           color: C.headerBlue,
//           letterSpacing: 0.4,
//         ),
//       ),
//       const SizedBox(height: 4),
//       SizedBox(
//         height: 36,
//         child: TextField(
//           controller: ctrl,
//           style: const TextStyle(fontSize: 13),
//           decoration: InputDecoration(
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 10,
//               vertical: 8,
//             ),
//             filled: true,
//             fillColor: Colors.white,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(7),
//               borderSide: BorderSide(color: Colors.blue.shade200),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(7),
//               borderSide: BorderSide(color: Colors.blue.shade200),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(7),
//               borderSide: const BorderSide(color: C.primaryBlue, width: 1.5),
//             ),
//           ),
//         ),
//       ),
//     ],
//   );
//
//   @override
//   void dispose() {
//     // controller?.dispose();
//     controller?.pauseCamera();
//     _scanTimer?.cancel();
//     _dispatchNoController.dispose();
//     for (final c in [
//       _partyNameController,
//       _transportNameController,
//       _poNoController,
//       _vehicleNoController,
//       _invoiceNoController,
//       _barcodeController,
//     ]) {
//       c.dispose();
//     }
//     super.dispose();
//   }
//
//   // ─── Build ────────────────────────────────────────────────────────────────
//
//   @override
//   void initState() {
//     super.initState();
//     fetchPartyList();
//     fetchNextDispatchNo();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final bool canSave = entries.isNotEmpty && !isFetching;
//
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//
//       backgroundColor: Colors.grey.shade100,
//
//       appBar: AppBar(
//         title: const Text(
//           "Packing Entry",
//           style: TextStyle(fontWeight: FontWeight.w600),
//         ),
//         backgroundColor: C.primaryBlue,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//       ),
//
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(minHeight: constraints.maxHeight),
//                 child: Column(
//                   children: [
//                     // ───── HEADER FIELDS ─────
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 8,
//                       ),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(14),
//                           color: Colors.white,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.05),
//                               blurRadius: 8,
//                               offset: const Offset(0, 3),
//                             ),
//                           ],
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 14,
//                             vertical: 12,
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _compactDispatchField(),
//                               const SizedBox(height: 12),
//
//                               /// 🔹 Row 1 → Party Name (Full Width)
//                               _compactPartyDropdown(),
//
//                               const SizedBox(height: 12),
//
//                               /// 🔹 Row 2 → Transport + PO No
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: _compactField(
//                                       "Transport",
//                                       _transportNameController,
//                                       Icons.local_shipping_outlined,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: _compactField(
//                                       "PO No",
//                                       _poNoController,
//                                       Icons.description_outlined,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//
//                               const SizedBox(height: 12),
//
//                               /// 🔹 Row 3 → Vehicle No + Invoice No
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: _compactField(
//                                       "Vehicle No",
//                                       _vehicleNoController,
//                                       Icons.directions_car_outlined,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: _compactField(
//                                       "Invoice No",
//                                       _invoiceNoController,
//                                       Icons.receipt_long_outlined,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     // ───── BUTTONS ─────
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: SizedBox(
//                               height: 38,
//                               child: OutlinedButton.icon(
//                                 onPressed: isFetching ? null : _openScanner,
//                                 icon: const Icon(
//                                   Icons.qr_code_scanner,
//                                   size: 18,
//                                 ),
//                                 label: const Text(
//                                   "Scan",
//                                   style: TextStyle(fontSize: 13),
//                                 ),
//                                 style: OutlinedButton.styleFrom(
//                                   foregroundColor: C.primaryBlue,
//                                   side: const BorderSide(
//                                     color: C.primaryBlue,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: SizedBox(
//                               height: 38,
//                               child: ElevatedButton.icon(
//                                 onPressed: isFetching
//                                     ? null
//                                     : _openManualEntry,
//                                 icon: const Icon(Icons.keyboard, size: 18),
//                                 label: const Text(
//                                   "Manual",
//                                   style: TextStyle(fontSize: 13),
//                                 ),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: C.primaryBlue,
//                                   foregroundColor: Colors.white,
//                                   elevation: 1,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 10),
//
//                     // ───── TABLE ─────
//                     entries.isEmpty
//                         ? Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: const Center(
//                               child: Text(
//                                 "No entries added",
//                                 style: TextStyle(color: Colors.grey),
//                               ),
//                             ),
//                         )
//                         : SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             child: SingleChildScrollView(
//                               child: DataTable(
//                                 columnSpacing:
//                                     12, // 👈 reduce space between columns
//                                 horizontalMargin:
//                                     8, // 👈 reduce left-right margin
//                                 dataRowMinHeight: 38,
//                                 headingRowHeight: 40,
//                                 headingRowColor: MaterialStateProperty.all(
//                                   C.primaryBlue,
//                                 ),
//
//                                 columns: [
//                                   DataColumn(
//                                     label: _tableHeader("Packing No"),
//                                   ),
//                                   DataColumn(label: _tableHeader("BOM")),
//                                   DataColumn(
//                                     label: _tableHeader("Bag Size"),
//                                   ),
//                                   DataColumn(label: _tableHeader("PCS")),
//                                   DataColumn(label: _tableHeader("Gross")),
//                                   DataColumn(label: _tableHeader("Tare")),
//                                   DataColumn(label: _tableHeader("Net")),
//                                   DataColumn(label: _tableHeader("")),
//                                 ],
//
//                                 rows: entries.asMap().entries.map((
//                                   entryMap,
//                                 ) {
//                                   final index = entryMap.key;
//                                   final e = entryMap.value;
//
//                                   return DataRow(
//                                     cells: [
//                                       DataCell(
//                                         SizedBox(
//                                           width: 115, // 👈 reduced from 140
//                                           child: Text(
//                                             e['packingNo'].toString(),
//                                             style: const TextStyle(
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       DataCell(
//                                         SizedBox(
//                                           width: 75, // 👈 reduced
//                                           child: Text(
//                                             e['bomNo'].toString(),
//                                             style: const TextStyle(
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       DataCell(
//                                         SizedBox(
//                                           width: 95,
//                                           child: Text(
//                                             e['bagSize'].toString(),
//                                             style: const TextStyle(
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       DataCell(
//                                         SizedBox(
//                                           width: 50,
//                                           child: Text(
//                                             e['pcs'].toString(),
//                                             style: const TextStyle(
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       DataCell(
//                                         SizedBox(
//                                           width: 70,
//                                           child: Text(
//                                             _fmt(e['grossWt']),
//                                             style: const TextStyle(
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       DataCell(
//                                         SizedBox(
//                                           width: 70,
//                                           child: Text(
//                                             _fmt(e['tareWt']),
//                                             style: const TextStyle(
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       DataCell(
//                                         SizedBox(
//                                           width: 70,
//                                           child: Text(
//                                             _fmt(e['netWt']),
//                                             style: const TextStyle(
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       DataCell(
//                                         SizedBox(
//                                           width: 50,
//                                           child: IconButton(
//                                             padding: EdgeInsets.zero,
//                                             constraints:
//                                                 const BoxConstraints(),
//                                             icon: const Icon(
//                                               Icons.delete,
//                                               color: Colors.red,
//                                               size: 18,
//                                             ),
//                                             onPressed: () =>
//                                                 _deleteEntry(index),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   );
//                                 }).toList(),
//                               ),
//                             ),
//                           ),
//
//                     // ───── FOOTER ─────
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         boxShadow: [
//                           BoxShadow(blurRadius: 4, color: Colors.black12),
//                         ],
//                       ),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               _simpleTotal("PCS", totalPcs.toString()),
//                               _simpleTotal(
//                                 "Gross",
//                                 totalGross.toStringAsFixed(2),
//                               ),
//                               _simpleTotal(
//                                 "Tare",
//                                 totalTare.toStringAsFixed(2),
//                               ),
//                               _simpleTotal(
//                                 "Net",
//                                 totalNet.toStringAsFixed(2),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 10),
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               onPressed: canSave
//                                   ? _saveDispatchEntries
//                                   : null,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: C.primaryBlue,
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 12,
//                                 ),
//                               ),
//                               child: const Text(
//                                 "SAVE",
//                                 style: TextStyle(fontWeight: FontWeight.w600),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _compactField(
//     String label,
//     TextEditingController controller,
//     IconData icon,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 4),
//         SizedBox(
//           height: 38, // 👈 reduced from 46
//           child: TextField(
//             controller: controller,
//             style: const TextStyle(fontSize: 13),
//             decoration: InputDecoration(
//               prefixIcon: Icon(icon, size: 16, color: C.primaryBlue),
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 10,
//                 vertical: 6,
//               ),
//               filled: true,
//               fillColor: Colors.grey.shade50,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: Colors.grey.shade300),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: const BorderSide(color: C.primaryBlue, width: 1.3),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _compactPartyDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Party Name",
//           style: TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 4),
//
//         GestureDetector(
//           onTap: () => _openPartySearchDialog(),
//           child: Container(
//             height: 38,
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: Colors.grey.shade300),
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.business, size: 16),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     selectedParty ?? "Select Party Name",
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: selectedParty == null ? Colors.grey : Colors.black,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 const Icon(Icons.arrow_drop_down),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _tableHeader(String text) {
//     return Text(
//       text,
//       style: const TextStyle(
//         color: Colors.white,
//         fontSize: 12,
//         fontWeight: FontWeight.w600,
//       ),
//     );
//   }
//
//   Widget _compactDispatchField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Dispatch No",
//           style: TextStyle(
//             fontSize: 10,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 3),
//
//         IntrinsicWidth(
//           // 👈 Makes width depend on content
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(
//               minWidth: 50, // minimum width
//               maxWidth: 120, // maximum limit (safe)
//             ),
//             child: SizedBox(
//               height: 32,
//               child: isDispatchLoading
//                   ? const SizedBox(
//                       height: 18,
//                       width: 18,
//                       child: CircularProgressIndicator(
//                           color: C.appBar3,
//                           strokeWidth: 2),
//                     )
//                   : TextField(
//                       controller: _dispatchNoController,
//                       readOnly: true,
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       decoration: InputDecoration(
//                         isDense: true,
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 6,
//                         ),
//                         filled: true,
//                         fillColor: Colors.blue.shade50,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide(color: Colors.blue.shade200),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: const BorderSide(
//                             color: C.primaryBlue,
//                             width: 1.2,
//                           ),
//                         ),
//                       ),
//                     ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   void _openPartySearchDialog() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         final TextEditingController searchController = TextEditingController();
//         List<String> filteredList = List.from(partyList);
//
//         return StatefulBuilder(
//           builder: (context, setStateDialog) {
//             return Container(
//               height: MediaQuery.of(context).size.height * 0.75,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//               ),
//               child: Column(
//                 children: [
//                   /// 🔹 HEADER
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 14,
//                     ),
//                     decoration: const BoxDecoration(
//                       color: C.primaryBlue,
//                       borderRadius: BorderRadius.vertical(
//                         top: Radius.circular(20),
//                       ),
//                     ),
//                     child: Row(
//                       children: const [
//                         Icon(Icons.business, color: Colors.white),
//                         SizedBox(width: 10),
//                         Text(
//                           "Select Party",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   /// 🔍 SEARCH BOX
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 10,
//                     ),
//                     child: TextField(
//                       controller: searchController,
//                       autofocus: true,
//                       decoration: InputDecoration(
//                         hintText: "Search party name...",
//                         prefixIcon: const Icon(Icons.search),
//                         suffixIcon: searchController.text.isNotEmpty
//                             ? IconButton(
//                           icon: const Icon(Icons.clear),
//                           onPressed: () {
//                             searchController.clear();
//                             setStateDialog(() {
//                               filteredList = List.from(partyList);
//                             });
//                           },
//                         )
//                             : null,
//                         filled: true,
//                         fillColor: Colors.grey.shade100,
//                         contentPadding:
//                         const EdgeInsets.symmetric(vertical: 0),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//
//                       /// 🔥 IMPORTANT: rebuild UI when typing (for clear button)
//                       onChanged: (value) {
//                         setStateDialog(() {
//                           filteredList = value.trim().isEmpty
//                               ? List.from(partyList)
//                               : partyList
//                               .where((e) => e.toLowerCase().contains(
//                             value.toLowerCase().trim(),
//                           ))
//                               .toList();
//                         });
//                       },
//                     ),
//                   ),
//
//                   /// 📋 LIST
//                   Expanded(
//                     child: filteredList.isEmpty
//                         ? const Center(
//                       child: Text(
//                         "No party found 😕",
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     )
//                         : ListView.separated(
//                       itemCount: filteredList.length,
//                       separatorBuilder: (_, __) => Divider(
//                         height: 1,
//                         color: Colors.grey.shade200,
//                       ),
//                       itemBuilder: (context, index) {
//                         final item = filteredList[index];
//                         final isSelected = item == selectedParty;
//
//                         return ListTile(
//                           contentPadding:
//                           const EdgeInsets.symmetric(horizontal: 16),
//                           title: Text(
//                             item,
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: isSelected
//                                   ? FontWeight.w600
//                                   : FontWeight.normal,
//                               color: isSelected
//                                   ? C.primaryBlue
//                                   : Colors.black,
//                             ),
//                           ),
//                           trailing: isSelected
//                               ? const Icon(
//                             Icons.check,
//                             color: C.primaryBlue,
//                           )
//                               : null,
//                           onTap: () {
//                             setState(() {
//                               selectedParty = item;
//                               _partyNameController.text = item;
//                             });
//                             Navigator.pop(context);
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   // ).whenComplete(() => searchController.dispose()); // ✅ dispose on close
//   }
//
//
// // ─── Helper Widgets ───────────────────────────────────────────────────────────
//
// class _HCell extends StatelessWidget {
//   final String label;
//   final double width;
//   const _HCell(this.label, this.width);
//
//   @override
//   Widget build(BuildContext context) => SizedBox(
//     width: width,
//     child: Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//       child: Text(
//         label,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 11,
//           fontWeight: FontWeight.w700,
//           letterSpacing: 0.4,
//         ),
//       ),
//     ),
//   );
// }
//
// class _DCell extends StatelessWidget {
//   final String value;
//   final double width;
//   final Color? color;
//   final bool bold;
//   const _DCell(this.value, this.width, {this.color, this.bold = false});
//
//   @override
//   Widget build(BuildContext context) => SizedBox(
//     width: width,
//     child: Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//       child: Text(
//         value,
//         style: TextStyle(
//           fontSize: 12,
//           color: color ?? const Color(0xFF1A1A2E),
//           fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
//         ),
//       ),
//     ),
//   );
// }
//
// Widget _simpleTotal(String label, String value) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
//       Text(
//         value,
//         style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//       ),
//     ],
//   );
// }
