//
//
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:image/image.dart' as img;
// import 'package:pdfx/pdfx.dart';
// import 'package:print_bluetooth_thermal/post_code.dart';
//
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// import 'package:printing/printing.dart';
//
// import 'package:thermal_printer_plus/esc_pos_utils_platform/src/capability_profile.dart';
// import 'package:thermal_printer_plus/esc_pos_utils_platform/src/enums.dart';
// import 'package:thermal_printer_plus/esc_pos_utils_platform/src/generator.dart';
// import 'package:thermal_printer_plus/esc_pos_utils_platform/src/pos_styles.dart';
// import 'package:thermal_printer_plus/thermal_printer.dart';
// import 'package:thermal_printer_plus/esc_pos_utils_platform/esc_pos_utils_platform.dart' as esc;
// import 'package:print_bluetooth_thermal/post_code.dart' as pbt; // agar kahin aur use ho raha ho
// import 'PrintController.dart';
//
// class ShowPrintDocPage extends StatefulWidget {
//   const ShowPrintDocPage({super.key});
//
//   @override
//   State<ShowPrintDocPage> createState() => _ShowPrintDocPageState();
// }
//
// class _ShowPrintDocPageState extends State<ShowPrintDocPage> {
//   final _logic = Get.find<ShowPrintController>();
//
//   var defaultPrinterType = PrinterType.bluetooth;
//   var _isBle = false;
//   var _isConnected = false;
//   var printerManager = PrinterManager.instance;
//   var devices = <BluetoothPrinter>[];
//
//   StreamSubscription<PrinterDevice>? _subscription;
//   StreamSubscription<BTStatus>? _subscriptionBtStatus;
//
//   BTStatus _currentStatus = BTStatus.none;
//   List<int>? pendingTask;
//
//   BluetoothPrinter? selectedPrinter;
//   bool _isPrinting = false;
//   String _statusMessage = '';
//
//   var storage = Get.isRegistered<GetStorage>()
//       ? Get.find<GetStorage>()
//       : Get.put(GetStorage());
//
//   // ─── Lifecycle ────────────────────────────────────────────────────────────
//
//   @override
//   void initState() {
//     super.initState();
//     _initBtStatusListener();
//     _scan();
//     _loadStoredPrinter();
//     _initPage();
//   }
//
//   @override
//   void dispose() {
//     _subscription?.cancel();
//     _subscriptionBtStatus?.cancel();
//     super.dispose();
//   }
//
//   // ─── Init ─────────────────────────────────────────────────────────────────
//
//   Future<void> _initPage() async {
//     var parameter = Get.parameters;
//     try {
//       if (parameter['type'] != null) {
//         await _logic.loadData(int.tryParse(parameter['type'].toString()));
//         setState(() {});
//       }
//     } catch (e) {
//       debugPrint('loadData error: $e');
//     }
//   }
//
//   void _initBtStatusListener() {
//     _subscriptionBtStatus = PrinterManager.instance.stateBluetooth.listen((
//         status,
//         ) {
//       debugPrint('BT Status: $status');
//       _currentStatus = status;
//
//       if (status == BTStatus.connected) {
//         setState(() => _isConnected = true);
//
//         // Send any queued task
//         if (pendingTask != null) {
//           Future.delayed(const Duration(milliseconds: 800), () {
//             PrinterManager.instance.send(
//               type: PrinterType.bluetooth,
//               bytes: pendingTask!,
//             );
//             pendingTask = null;
//           });
//         }
//       }
//
//       if (status == BTStatus.none) {
//         setState(() => _isConnected = false);
//       }
//     });
//   }
//   Future<void> printQrLabel({
//     required String packingNo,
//     required double netWt,
//     required double grossWt,
//     required double tareWt,
//     required String customerRef,
//   }) async {
//     if (selectedPrinter == null) {
//       _setStatus('❌ Pehle printer select karein');
//       return;
//     }
//
//     setState(() {
//       _isPrinting = true;
//       _statusMessage = 'QR Code print ho raha hai...';
//     });
//
//     try {
//       CapabilityProfile profile;
//       try {
//         profile = await CapabilityProfile.load(name: 'RP80USE');
//       } catch (_) {
//         profile = await CapabilityProfile.load();
//       }
//
//       final generator = Generator(PaperSize.mm58, profile);
//       List<int> bytes = [];
//
//       bytes += [0x1B, 0x40]; // Initialize printer
//
//       // 🔷 QR Data (important: short & clean string rakho)
//       String qrData =
//           "Packing:$packingNo|Net:$netWt|Gross:$grossWt|Tare:$tareWt|Ref:$customerRef";
//
//       // 🧾 Title
//       bytes += generator.text(
//         'BAILING ENTRY',
//         styles: const PosStyles(
//           bold: true,
//           align: PosAlign.center,
//           height: PosTextSize.size2,
//           width: PosTextSize.size2,
//         ),
//       );
//
//       bytes += generator.feed(1);
//
//       // 🔳 QR Code
//       bytes += generator.qrcode(
//         qrData,
//         size: esc.QRSize.Size6,
//         align: esc.PosAlign.center,
//       );
//
//       bytes += generator.feed(1);
//
//       // 📝 Details
//       bytes += generator.text("Packing: $packingNo");
//       bytes += generator.text("Net WT: $netWt");
//       bytes += generator.text("Gross WT: $grossWt");
//       bytes += generator.text("Tare WT: $tareWt");
//       bytes += generator.text("Ref: $customerRef");
//
//       bytes += generator.feed(2);
//
//       bytes += generator.text(
//         "Thank You",
//         styles: const PosStyles(align: PosAlign.center),
//       );
//
//       bytes += generator.feed(2);
//       bytes += generator.cut();
//
//       await _sendBytes(bytes);
//     } catch (e) {
//       _setStatus('❌ Error: $e');
//     } finally {
//       setState(() => _isPrinting = false);
//     }
//   }
//   // ─── Device Scanning ──────────────────────────────────────────────────────
//
//   void _scan() {
//     _subscription?.cancel();
//     devices.clear();
//     _subscription = printerManager
//         .discovery(type: defaultPrinterType, isBle: _isBle)
//         .listen((device) {
//       devices.add(
//         BluetoothPrinter(
//           deviceName: device.name,
//           address: device.address,
//           isBle: _isBle,
//           vendorId: device.vendorId,
//           productId: device.productId,
//           typePrinter: defaultPrinterType,
//         ),
//       );
//       if (mounted) setState(() {});
//       debugPrint('Device found: ${device.name} - ${device.address}');
//     });
//   }
//
//   // ─── Stored Printer ───────────────────────────────────────────────────────
//
//   Future<void> _loadStoredPrinter() async {
//     final address = storage.read<String>('printer_address');
//     final name = storage.read<String>('printer_name');
//     final port = storage.read<String>('printer_port');
//
//     if (address != null && name != null) {
//       final device = BluetoothPrinter(
//         deviceName: name,
//         address: address,
//         port: port,
//         typePrinter: PrinterType.bluetooth,
//       );
//       await selectDevice(device);
//     }
//   }
//
//   // ─── Select & Connect Device ──────────────────────────────────────────────
//
//   Future<void> selectDevice(BluetoothPrinter device) async {
//     // Disconnect previous printer if different
//     if (selectedPrinter != null && selectedPrinter!.address != device.address) {
//       await PrinterManager.instance.disconnect(
//         type: selectedPrinter!.typePrinter,
//       );
//     }
//
//     selectedPrinter = device;
//
//     try {
//       if (Platform.isIOS) {
//         // iOS uses PrintBluetoothThermal
//         if (device.address != null) {
//           final connected = await PrintBluetoothThermal.connect(
//             macPrinterAddress: device.address!,
//           );
//           _isConnected = connected;
//           debugPrint('iOS connect result: $connected');
//         }
//       } else {
//         // Android / Windows
//         await PrinterManager.instance.connect(
//           type: PrinterType.bluetooth,
//           model: BluetoothPrinterInput(
//             name: device.deviceName ?? '',
//             address: device.address ?? '',
//             isBle: device.isBle ?? false,
//             autoConnect: true,
//           ),
//         );
//         // _isConnected is updated via the BT status stream
//       }
//     } catch (e) {
//       debugPrint('selectDevice error: $e');
//     }
//
//     // Persist selection
//     await storage.write('printer_address', device.address);
//     await storage.write('printer_name', device.deviceName);
//     await storage.write('printer_port', device.port ?? '9100');
//
//     if (mounted) setState(() {});
//   }
//
//   // ─── Print Core ───────────────────────────────────────────────────────────
//
//   /// Sends bytes to the selected Bluetooth printer.
//   Future<void> _sendBytes(List<int> bytes) async {
//     if (selectedPrinter == null) {
//       _setStatus('Pehle printer select karein');
//       return;
//     }
//
//     if (Platform.isIOS) {
//       final ok = await PrintBluetoothThermal.writeBytes(bytes);
//       _setStatus(ok ? 'Print ho gaya' : 'Print fail');
//       return;
//     }
//
//     try {
//       if (_currentStatus == BTStatus.connected) {
//         await Future.delayed(const Duration(milliseconds: 300));
//         await PrinterManager.instance.send(
//           type: PrinterType.bluetooth,
//           bytes: bytes,
//         );
//         _setStatus('Print ho gaya!');
//         return;
//       }
//
//       await PrinterManager.instance.connect(
//         type: PrinterType.bluetooth,
//         model: BluetoothPrinterInput(
//           name: selectedPrinter!.deviceName ?? '',
//           address: selectedPrinter!.address ?? '',
//           isBle: selectedPrinter!.isBle ?? false,
//           autoConnect: true,
//         ),
//       );
//
//       int waited = 0;
//       while (_currentStatus != BTStatus.connected && waited < 12000) {
//         await Future.delayed(const Duration(milliseconds: 200));
//         waited += 200;
//       }
//
//       if (_currentStatus != BTStatus.connected) {
//         _setStatus('Printer connect nahi hua');
//         return;
//       }
//
//       await Future.delayed(const Duration(milliseconds: 600));
//       await PrinterManager.instance.send(
//         type: PrinterType.bluetooth,
//         bytes: bytes,
//       );
//       _setStatus('Print ho gaya!');
//     } catch (e) {
//       _setStatus('Error: $e');
//     }
//   }
//
//   /// Bilkul simple sample text, direct Bluetooth thermal plugin se.
//   /// Isko app bar ke print icon se call karenge.
//   Future<void> printSampleViaPbt() async {
//     if (selectedPrinter == null || selectedPrinter!.address == null) {
//       _setStatus('Pehle printer select karein');
//       return;
//     }
//
//     setState(() => _isPrinting = true);
//     _setStatus('Print ho raha hai...');
//
//     try {
//       // Connect using print_bluetooth_thermal
//       final okConnect = await PrintBluetoothThermal.connect(
//         macPrinterAddress: selectedPrinter!.address!,
//       );
//       if (!okConnect) {
//         _setStatus('Printer se connect nahi hua');
//         return;
//       }
//
//       // Very simple ESC/POS: init + plain ASCII text + kuch feed
//       List<int> bytes = [];
//       bytes += [0x1B, 0x40]; // ESC @ (initialize)
//       bytes += utf8.encode('SAMPLE PRINT\nHello from Flutter\n\n\n');
//
//       final okWrite = await PrintBluetoothThermal.writeBytes(bytes);
//       _setStatus(okWrite ? 'Print ho gaya!' : 'Print fail');
//     } catch (e) {
//       _setStatus('Error: $e');
//     } finally {
//       setState(() => _isPrinting = false);
//     }
//   }
//
//   // ─── Print PDF Document ───────────────────────────────────────────────────
//
//   Future<void> printDocument() async {
//     if (selectedPrinter == null) {
//       _setStatus('❌ Pehle Bluetooth printer select karein');
//       return;
//     }
//
//     // Get PDF bytes
//     Uint8List? pdfData = _logic.uint8list;
//     if (pdfData == null && _logic.pdf != null) {
//       pdfData = await _logic.pdf?.save();
//     }
//
//     if (pdfData == null) {
//       printTestPage();
//       _setStatus('❌ Print karne ke liye koi document nahi mila');
//       return;
//     }
//
//     setState(() {
//       _isPrinting = true;
//       _statusMessage = '⏳ Document prepare ho raha hai...';
//     });
//
//     try {
//       final profile = await CapabilityProfile.load(name: 'RP80USE');
//       final generator = Generator(PaperSize.mm58, profile);
//       List<int> bytes = [];
//
//       // ESC/POS init
//       bytes += [0x1B, 0x40];
//
//       final doc = await PdfDocument.openData(pdfData);
//       final pageCount = doc.pagesCount;
//
//       for (int i = 1; i <= pageCount; i++) {
//         _setStatus('⏳ Page $i / $pageCount render ho rahi hai...');
//
//         final page = await doc.getPage(i);
//         final pageImage = await page.render(
//           // 576px width good for 58mm thermal @ ~203dpi
//           width: 576,
//           height: 800,
//           backgroundColor: '#FFFFFFFF',
//         );
//         await page.close();
//
//         if (pageImage == null) continue;
//
//         img.Image? image = img.decodeImage(pageImage.bytes);
//         if (image == null) {
//           debugPrint('Page $i decode failed');
//           continue;
//         }
//
//         // Trim white borders
//         image = _trimWhiteSpace(image);
//
//         // Resize to 58mm paper width (max ~380px usable)
//         const int maxPrintWidth = 380;
//         final int newHeight = (maxPrintWidth * image.height / image.width)
//             .round();
//         img.Image resized = img.copyResize(
//           image,
//           width: maxPrintWidth,
//           height: newHeight,
//         );
//
//         // Grayscale → better quality on thermal printer
//         resized = img.grayscale(resized);
//
//         bytes += generator.imageRaster(resized, align: PosAlign.center);
//         bytes += generator.feed(1);
//       }
//
//       await doc.close();
//
//       // End feed + cut
//       bytes += generator.feed(2);
//       bytes += generator.cut();
//
//       _setStatus('⏳ Printer ko bhej raha hai...');
//       await _sendBytes(bytes);
//     } catch (e) {
//       _setStatus('❌ Error: $e');
//       debugPrint('printDocument error: $e');
//     } finally {
//       setState(() => _isPrinting = false);
//     }
//   }
//
//   // ─── Test Print ───────────────────────────────────────────────────────────
//
//   /// Sample text print — printer se slip pe text nikalti hai.
//   Future<void> printTestPage() async {
//     if (selectedPrinter == null) {
//       _setStatus('Pehle Bluetooth se printer select karein');
//       return;
//     }
//
//     setState(() => _isPrinting = true);
//     _setStatus('Print ho raha hai...');
//
//     try {
//       CapabilityProfile profile;
//       try {
//         profile = await CapabilityProfile.load(name: 'RP80USE');
//       } catch (_) {
//         profile = await CapabilityProfile.load();
//       }
//       final generator = Generator(PaperSize.mm58, profile);
//
//       List<int> bytes = [];
//       bytes += [0x1B, 0x40];
//       bytes += generator.text(
//         '*** SAMPLE PRINT ***',
//         styles: const PosStyles(bold: true, align: PosAlign.center),
//       );
//       bytes += generator.text(
//         'Printer: ${selectedPrinter!.deviceName ?? "Unknown"}',
//         styles: const PosStyles(align: PosAlign.center),
//       );
//       bytes += generator.text(
//         'Address: ${selectedPrinter!.address ?? "N/A"}',
//         styles: const PosStyles(align: PosAlign.center),
//       );
//       bytes += generator.feed(2);
//       bytes += generator.cut();
//
//       await _sendBytes(bytes);
//     } catch (e) {
//       _setStatus('Error: $e');
//     } finally {
//       setState(() => _isPrinting = false);
//     }
//   }
//
//   // ─── Image Helpers ────────────────────────────────────────────────────────
//
//   img.Image _trimWhiteSpace(img.Image src) {
//     int top = 0, bottom = src.height - 1, left = 0, right = src.width - 1;
//
//     for (int y = 0; y < src.height; y++) {
//       if (!_isRowWhite(src, y)) {
//         top = y;
//         break;
//       }
//     }
//     for (int y = src.height - 1; y >= 0; y--) {
//       if (!_isRowWhite(src, y)) {
//         bottom = y;
//         break;
//       }
//     }
//     for (int x = 0; x < src.width; x++) {
//       if (!_isColumnWhite(src, x, top, bottom)) {
//         left = x;
//         break;
//       }
//     }
//     for (int x = src.width - 1; x >= 0; x--) {
//       if (!_isColumnWhite(src, x, top, bottom)) {
//         right = x;
//         break;
//       }
//     }
//
//     final w = (right - left + 1).clamp(1, src.width - left);
//     final h = (bottom - top + 1).clamp(1, src.height - top);
//     return img.copyCrop(src, x: left, y: top, width: w, height: h);
//   }
//
//   bool _isRowWhite(img.Image image, int y) {
//     for (int x = 0; x < image.width; x++) {
//       final p = image.getPixel(x, y);
//       if (p.r < 250 || p.g < 250 || p.b < 250) return false;
//     }
//     return true;
//   }
//
//   bool _isColumnWhite(img.Image image, int x, int top, int bottom) {
//     for (int y = top; y <= bottom; y++) {
//       final p = image.getPixel(x, y);
//       if (p.r < 250 || p.g < 250 || p.b < 250) return false;
//     }
//     return true;
//   }
//
//   // ─── UI Helpers ───────────────────────────────────────────────────────────
//
//   void _setStatus(String msg) {
//     debugPrint(msg);
//     if (mounted) setState(() => _statusMessage = msg);
//   }
//
//   void _showDeviceDialog() {
//     // Rescan before showing
//     _scan();
//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (ctx, setDState) {
//           return AlertDialog(
//             title: const Text('Bluetooth Printers'),
//             content: SizedBox(
//               width: double.maxFinite,
//               height: 300,
//               child: devices.isEmpty
//                   ? const Center(child: CircularProgressIndicator())
//                   : ListView.builder(
//                 itemCount: devices.length,
//                 itemBuilder: (_, index) {
//                   final device = devices[index];
//                   final isSelected =
//                       selectedPrinter?.address == device.address;
//                   return ListTile(
//                     leading: Icon(
//                       Icons.print,
//                       color: isSelected ? Colors.green : null,
//                     ),
//                     title: Text(device.deviceName ?? 'Unknown'),
//                     subtitle: Text(device.address ?? ''),
//                     trailing: isSelected
//                         ? const Icon(
//                       Icons.check_circle,
//                       color: Colors.green,
//                     )
//                         : null,
//                     onTap: () async {
//                       Navigator.pop(context);
//                       await selectDevice(device);
//                       _setStatus(
//                         '🔗 ${device.deviceName} se connect ho raha hai...',
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   _scan();
//                   setDState(() {});
//                 },
//                 child: const Text('Refresh'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Close'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   // ─── Build ────────────────────────────────────────────────────────────────
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<ShowPrintController>(
//       init: Get.find<ShowPrintController>(),
//       builder: (logic) {
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('Print Document'),
//             actions: [
//               // BT status indicator
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 4),
//                 child: Icon(
//                   Icons.circle,
//                   size: 12,
//                   color: _isConnected ? Colors.greenAccent : Colors.grey,
//                 ),
//               ),
//               // Select printer
//               IconButton(
//                 icon: const Icon(Icons.bluetooth_searching),
//                 tooltip: 'Printer Select Karein',
//                 onPressed: _showDeviceDialog,
//               ),
//               // Sample text print (simple test)
//               IconButton(
//                 icon: const Icon(Icons.check_circle_outline),
//                 tooltip: 'Sample Text Print',
//                 onPressed: _isPrinting ? null : printSampleViaPbt,
//               ),
//               // Printer icon se bhi sample text hi print hoga
//               IconButton(
//                 icon: const Icon(Icons.print),
//                 tooltip: 'Sample Text Print',
//                 onPressed: _isPrinting ? null : printSampleViaPbt,
//               ),
//             ],
//           ),
//           body: Column(
//             children: [
//               // Status bar
//               if (_statusMessage.isNotEmpty)
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                   color: _statusMessage.startsWith('✅')
//                       ? Colors.green.shade100
//                       : _statusMessage.startsWith('❌')
//                       ? Colors.red.shade100
//                       : Colors.blue.shade50,
//                   child: Row(
//                     children: [
//                       if (_isPrinting)
//                         const SizedBox(
//                           width: 16,
//                           height: 16,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         ),
//                       if (_isPrinting) const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           _statusMessage,
//                           style: const TextStyle(fontSize: 13),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//               // Connected printer chip
//               if (selectedPrinter != null)
//                 Padding(
//                   padding: const EdgeInsets.all(8),
//                   child: Chip(
//                     avatar: Icon(
//                       Icons.bluetooth_connected,
//                       size: 18,
//                       color: _isConnected ? Colors.green : Colors.grey,
//                     ),
//                     label: Text(
//                       selectedPrinter!.deviceName ?? 'Printer',
//                       style: const TextStyle(fontSize: 12),
//                     ),
//                   ),
//                 ),
//
//               // PDF Preview
//               Expanded(
//                 child: logic.uint8list == null
//                     ? const Center(child: CircularProgressIndicator())
//                     : InteractiveViewer(
//                   panEnabled: true,
//                   minScale: 1,
//                   maxScale: 4,
//                   child: PdfPreview(
//                     useActions: false,
//                     canChangeOrientation: false,
//                     build: (_) => logic.uint8list!,
//                     allowPrinting: false,
//                     allowSharing: true,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//           // FAB — dabate hi sample text print
//           floatingActionButton: FloatingActionButton.extended(
//             onPressed: _isPrinting ? null : printTestPage,
//             icon: _isPrinting
//                 ? const SizedBox(
//               width: 20,
//               height: 20,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 color: Colors.white,
//               ),
//             )
//                 : const Icon(Icons.print),
//             label: Text(_isPrinting ? 'Print ho raha hai...' : 'Print'),
//           ),
//         );
//       },
//     );
//   }