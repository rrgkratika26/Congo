// import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
// import 'package:esc_pos_utils/esc_pos_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// /// Handles Bluetooth thermal printer connection and printing QR labels for bailing.
// class BailingQrPrinter {
//   static const _channel = MethodChannel('flutter_bluetooth_basic/methods');
//
//   static final PrinterBluetoothManager _manager = PrinterBluetoothManager();
//   static PrinterBluetooth? _selectedPrinter;
//   static bool _isPrinting = false;
//
//   static PrinterBluetooth? get selectedPrinter => _selectedPrinter;
//   static Stream<List<PrinterBluetooth>> get scanResults => _manager.scanResults;
//   static Stream<bool> get isScanning => _manager.isScanningStream;
//
//   /// Load devices already paired with the phone (Classic Bluetooth). Most thermal
//   /// printers appear here, not in BLE scan.
//   static Future<List<PrinterBluetooth>> getBondedDevices() async {
//     try {
//       final result = await _channel.invokeMethod('getBondedDevices');
//       if (result == null || result is! List) return [];
//       final list = result as List<dynamic>;
//       return list.map((e) {
//         final map = Map<String, dynamic>.from(e as Map);
//         return PrinterBluetooth(BluetoothDevice.fromJson(map));
//       }).toList();
//     } on PlatformException catch (_) {
//       return [];
//     }
//   }
//
//   /// Build ESC/POS ticket bytes: title, QR code, and text lines.
//   static Future<List<int>> _buildTicketBytes({
//     required String packingNo,
//     required double netWt,
//     required double grossWt,
//     required double tareWt,
//     required String customerRef,
//   }) async {
//     final profile = await CapabilityProfile.load();
//     final generator = Generator(PaperSize.mm80, profile);
//     final List<int> bytes = [];
//
//     final qrData =
//         'Packing:$packingNo|Net:$netWt|Gross:$grossWt|Tare:$tareWt|Ref:$customerRef';
//
//     bytes.addAll(
//       generator.text(
//         'Bailing Entry',
//         styles: const PosStyles(
//           align: PosAlign.center,
//           bold: true,
//           height: PosTextSize.size2,
//           width: PosTextSize.size2,
//         ),
//         linesAfter: 1,
//       ),
//     );
//     bytes.addAll(generator.feed(1));
//     bytes.addAll(
//       generator.qrcode(qrData, size: QRSize.Size6, align: PosAlign.center),
//     );
//     bytes.addAll(generator.feed(1));
//     bytes.addAll(generator.hr());
//     bytes.addAll(
//       generator.text(
//         'Packing: $packingNo',
//         styles: const PosStyles(fontType: PosFontType.fontA),
//       ),
//     );
//     bytes.addAll(
//       generator.text(
//         'Net WT: $netWt',
//         styles: const PosStyles(fontType: PosFontType.fontA),
//       ),
//     );
//     bytes.addAll(
//       generator.text(
//         'Gross WT: $grossWt',
//         styles: const PosStyles(fontType: PosFontType.fontA),
//       ),
//     );
//     bytes.addAll(
//       generator.text(
//         'Tare WT: $tareWt',
//         styles: const PosStyles(fontType: PosFontType.fontA),
//       ),
//     );
//     bytes.addAll(
//       generator.text(
//         'Ref: $customerRef',
//         styles: const PosStyles(fontType: PosFontType.fontA),
//       ),
//     );
//     bytes.addAll(generator.feed(1));
//     bytes.addAll(
//       generator.text(
//         'Thank You',
//         styles: const PosStyles(align: PosAlign.center),
//       ),
//     );
//     bytes.addAll(generator.feed(2));
//     bytes.addAll(generator.cut());
//
//     return bytes;
//   }
//
//   /// Print QR label to Bluetooth printer. If no printer is selected, shows a
//   /// dialog to scan and pick a device, then prints.
//   static Future<void> printQr(
//       BuildContext context, {
//         required String packingNo,
//         required double netWt,
//         required double grossWt,
//         required double tareWt,
//         required String customerRef,
//       }) async {
//     if (!context.mounted) return;
//
//     if (_isPrinting) {
//       _showSnackBar(context, 'Already printing...', isError: false);
//       return;
//     }
//
//     _isPrinting = true;
//
//     try {
//       if (_selectedPrinter == null) {
//         final picked = await _showPrinterPicker(context);
//         if (!context.mounted || picked == null) return;
//         _selectedPrinter = picked;
//       }
//
//       _manager.selectPrinter(_selectedPrinter!);
//
//       // 🔵 Show connecting (optional)
//       _showSnackBar(context, 'Preparing printer...', isError: false);
//
//       // 🔵 Important delay (fixes many timeout issues)
//       await Future.delayed(const Duration(seconds: 2));
//
//       final bytes = await _buildTicketBytes(
//         packingNo: packingNo,
//         netWt: netWt,
//         grossWt: grossWt,
//         tareWt: tareWt,
//         customerRef: customerRef,
//       );
//
//       final result = await _manager.printTicket(
//         bytes,
//         chunkSizeBytes: 50,
//         queueSleepTimeMs: 200,
//       );
//
//       if (!context.mounted) return;
//
//       if (result == PosPrintResult.success) {
//         _showSnackBar(context, 'Printed successfully');
//       } else {
//         _showSnackBar(
//           context,
//           'Print failed: ${result.msg}',
//           isError: true,
//         );
//       }
//     } catch (e) {
//       if (context.mounted) {
//         _showSnackBar(context, 'Error: $e', isError: true);
//       }
//     } finally {
//       _isPrinting = false;
//     }
//   }
//
//   static Future<PrinterBluetooth?> _showPrinterPicker(
//     BuildContext context,
//   ) async {
//     return showDialog<PrinterBluetooth>(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) => _BluetoothPrinterPickerDialog(manager: _manager),
//     );
//   }
//
//   static void _showSnackBar(
//     BuildContext context,
//     String message, {
//     bool isError = false,
//   }) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : null,
//       ),
//     );
//   }
//
//   static void clearSelectedPrinter() {
//     _selectedPrinter = null;
//   }
// }
//
// class _BluetoothPrinterPickerDialog extends StatefulWidget {
//   final PrinterBluetoothManager manager;
//
//   const _BluetoothPrinterPickerDialog({required this.manager});
//
//   @override
//   State<_BluetoothPrinterPickerDialog> createState() =>
//       _BluetoothPrinterPickerDialogState();
// }
//
// class _BluetoothPrinterPickerDialogState
//     extends State<_BluetoothPrinterPickerDialog> {
//   List<PrinterBluetooth> _pairedDevices = [];
//   List<PrinterBluetooth> _scanDevices = [];
//   bool _scanning = false;
//   bool _loading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _loadDevices());
//   }
//
//   Future<void> _loadDevices() async {
//     await Permission.bluetoothConnect.request();
//     if (!mounted) return;
//
//     // Load paired/bonded devices first (where most thermal printers appear)
//     final bonded = await BailingQrPrinter.getBondedDevices();
//     if (!mounted) return;
//     setState(() {
//       _pairedDevices = bonded;
//       _loading = false;
//     });
//
//     // Also request scan permission and start BLE scan for devices that only show in scan
//     final scanOk = await Permission.bluetoothScan.request().then(
//       (s) => s.isGranted,
//     );
//     final connectOk = await Permission.bluetoothConnect.isGranted;
//     if (!mounted) return;
//     if (!connectOk || !scanOk) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Bluetooth permission is needed to find printers'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//     } else {
//       _startBleScan();
//     }
//   }
//
//   void _startBleScan() {
//     setState(() {
//       _scanning = true;
//       _scanDevices = [];
//     });
//     widget.manager.scanResults.listen((List<PrinterBluetooth> results) {
//       if (mounted) setState(() => _scanDevices = results);
//     });
//     widget.manager.isScanningStream.listen((bool scanning) {
//       if (mounted) setState(() => _scanning = scanning);
//     });
//     widget.manager.startScan(const Duration(seconds: 8));
//   }
//
//   List<PrinterBluetooth> get _allDevices {
//     final addresses = <String>{};
//     final list = <PrinterBluetooth>[];
//     for (final p in _pairedDevices) {
//       final a = p.address ?? '';
//       if (a.isNotEmpty && !addresses.contains(a)) {
//         addresses.add(a);
//         list.add(p);
//       }
//     }
//     for (final p in _scanDevices) {
//       final a = p.address ?? '';
//       if (a.isNotEmpty && !addresses.contains(a)) {
//         addresses.add(a);
//         list.add(p);
//       }
//     }
//     return list;
//   }
//
//   @override
//   void dispose() {
//     widget.manager.stopScan();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final devices = _allDevices;
//     return AlertDialog(
//       title: const Text('Select Bluetooth printer'),
//       content: SizedBox(
//         width: double.maxFinite,
//         child: _loading
//             ? const Center(child: CircularProgressIndicator())
//             : devices.isEmpty
//             ? const Text(
//                 'No printers found. Pair your printer in phone Settings > Bluetooth, then open this again. Or turn on the printer and tap "Scan again".',
//               )
//             : ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: devices.length,
//                 itemBuilder: (_, i) {
//                   final p = devices[i];
//                   final isPaired = _pairedDevices.any(
//                     (d) => d.address == p.address,
//                   );
//                   return ListTile(
//                     leading: Icon(
//                       isPaired ? Icons.link : Icons.bluetooth_searching,
//                       color: Theme.of(context).colorScheme.primary,
//                     ),
//                     title: Text(
//                       p.name?.isNotEmpty == true ? p.name! : 'Unknown',
//                     ),
//                     subtitle: Text(
//                       '${p.address ?? ""}${isPaired ? " (paired)" : ""}',
//                     ),
//                     onTap: () => Navigator.of(context).pop(p),
//                   );
//                 },
//               ),
//       ),
//       actions: [
//         if (!_scanning)
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 _scanDevices = [];
//                 _loading = true;
//               });
//               _loadDevices();
//             },
//             child: const Text('Scan again'),
//           ),
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Cancel'),
//         ),
//       ],
//     );
//   }
// }







//
// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothDevice;
// import 'package:permission_handler/permission_handler.dart';
//
// class BailingQrPrinter {
//   static final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;
//
//   static BluetoothDevice? _selectedDevice;
//   static bool _isPrinting = false;
//
//   static BluetoothDevice? get selectedPrinter => _selectedDevice;
//
//   static Future<void> printQr(
//     BuildContext context, {
//     required String packingNo,
//     required double netWt,
//     required double grossWt,
//     required double tareWt,
//     required String customerRef,
//   }) async {
//     if (_isPrinting) return;
//     _isPrinting = true;
//
//     try {
//       await Permission.bluetoothConnect.request();
//       await Permission.bluetoothScan.request();
//
//       List<BluetoothDevice> devices = await _bluetooth.getBondedDevices();
//
//       if (devices.isEmpty) {
//         _showSnackBar(
//           context,
//           "No paired printers found. Pair printer in Bluetooth settings.",
//           isError: true,
//         );
//         return;
//       }
//
//       _selectedDevice ??= devices.first;
//
//       bool isConnected = await _bluetooth.isConnected ?? false;
//       if (!isConnected) {
//         await _bluetooth.connect(_selectedDevice!);
//         await Future.delayed(const Duration(milliseconds: 800));
//       }
//
//       String qrData =
//           "Packing:$packingNo|Net:$netWt|Gross:$grossWt|Tare:$tareWt|Ref:$customerRef";
//
//       // Title
//       _bluetooth.printCustom("BAILING ENTRY", 3, 1);
//       _bluetooth.printNewLine();
//
//       // QR Code
//       _bluetooth.printQRcode(qrData, 250, 250, 1);
//       _bluetooth.printNewLine();
//
//       // Details
//       _bluetooth.printCustom("Packing: $packingNo", 1, 0);
//       _bluetooth.printCustom("Net WT: $netWt", 1, 0);
//       _bluetooth.printCustom("Gross WT: $grossWt", 1, 0);
//       _bluetooth.printCustom("Tare WT: $tareWt", 1, 0);
//       _bluetooth.printCustom("Ref: $customerRef", 1, 0);
//
//       _bluetooth.printNewLine();
//       _bluetooth.printCustom("Thank You", 1, 1);
//       _bluetooth.printNewLine();
//       _bluetooth.printNewLine();
//
//       _showSnackBar(context, "✅ Printed Successfully");
//     } catch (e) {
//       _showSnackBar(context, "Print Failed: $e", isError: true);
//     } finally {
//       _isPrinting = false;
//     }
//   }
//
//   static void _showSnackBar(
//     BuildContext context,
//     String msg, {
//     bool isError = false,
//   }) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: isError ? Colors.red : null,
//       ),
//     );
//   }
//
//   static void clearSelectedPrinter() {
//     _selectedDevice = null;
//   }
// }
