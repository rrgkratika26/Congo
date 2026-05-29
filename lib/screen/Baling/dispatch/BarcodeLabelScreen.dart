// // BarcodeLabel.dart
// // Print icon tap → auto connect → print → done

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import 'package:thermal_printer_plus/esc_pos_utils_platform/src/capability_profile.dart';
import 'package:thermal_printer_plus/esc_pos_utils_platform/src/enums.dart';
import 'package:thermal_printer_plus/esc_pos_utils_platform/src/generator.dart';
import 'package:thermal_printer_plus/esc_pos_utils_platform/src/pos_styles.dart';
import 'package:thermal_printer_plus/thermal_printer.dart';

import '../../../services/Bluetooth_services.dart';
import '../../../util/sharedpreference/shared_preference.dart';



// ─── Model ───────────────────────────────────────────────────────────────────

class BarcodeLabelData {
  final String packingNo;
  final String partyName;
  final String pcsPerPacking;
  final String bomNo;
  final String articleNo;
  final double netWt;
  final double grossWt;
  final double tareWt;
  final double diffWt;
  final String customerRef;
  final String bag_size;

  const BarcodeLabelData({
    required this.packingNo,
    required this.partyName,
    required this.pcsPerPacking,
    required this.bomNo,
    required this.articleNo,
    required this.netWt,
    required this.grossWt,
    required this.tareWt,
    required this.diffWt,
    required this.customerRef,
    required this.bag_size,
  });

  String get barcodeData =>
      'PKG:$packingNo|PARTY:$partyName|ART:$articleNo|NET:$netWt|GROSS:$grossWt|TARE:$tareWt|REF:$customerRef';
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class BagQRCodeScreen extends StatefulWidget {
  final BarcodeLabelData labelData;
  const BagQRCodeScreen({super.key, required this.labelData});

  @override
  State<BagQRCodeScreen> createState() => _BagQRCodeScreenState();
}

class _BagQRCodeScreenState extends State<BagQRCodeScreen> {
  final _storage = GetStorage();
  final GlobalKey _labelKey = GlobalKey();

  String _status = 'Connecting with printer...';
  bool _printing = false;
  bool _done = false;
  bool _isSaved = false;

  StreamSubscription<BTStatus>? _btSub;

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // Widget build hone ke baad flow start karo (taaki _labelKey ready ho)
    // WidgetsBinding.instance.addPostFrameCallback((_) => _startPrintFlow());
  }

  @override
  void dispose() {
    _btSub?.cancel();
    super.dispose();
  }

  // ─── Main Print Flow ───────────────────────────────────────────────────────
  Future<void> _startPrintFlow() async {
    // if (_printing) return;

    final address = _storage.read<String>('printer_address');
    final name = _storage.read<String>('printer_name') ?? 'Printer';

    if (address == null) {
      _setStatus('❌ Pehle printer select karein');
      return;
    }

    _setStatus('🔗 Printer se connect ho raha hai...');

    try {
      // 🔹 Pehle disconnect safe side ke liye
      await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
      await Future.delayed(const Duration(milliseconds: 400));
    } catch (_) {}

    try {
      // 🔹 Direct connect
      await PrinterManager.instance.connect(
        type: PrinterType.bluetooth,
        model: BluetoothPrinterInput(
          name: name,
          address: address,
          isBle: false,
          autoConnect: false,
        ),
      );

      // 🔹 Thoda wait (printer ready hone ke liye)
      await Future.delayed(const Duration(milliseconds: 800));

      // 🔹 Printer wake-up command
      await PrinterManager.instance.send(
        type: PrinterType.bluetooth,
        bytes: [27, 64], // ESC @
      );

      await Future.delayed(const Duration(milliseconds: 200));

      // 🔹 Direct print
      await _executePrint();
    } catch (e) {
      _setStatus('❌ Connection error: $e');
    }
  }

  // Future<void> _saveBailingEntry() async {
  //   try {
  //     setState(() {
  //       _isSaved = false; // reset before save
  //     });
  //
  //     _setStatus("💾 Saving data...");
  //
  //     final token = await AppSession.getToken();
  //     final data = widget.labelData;
  //
  //     final body = {
  //       "packingNo": data.packingNo,
  //       "bailingGrossWt": data.grossWt,
  //       "bailingTareWt": data.tareWt,
  //       "bailingNetWt": data.netWt,
  //       "bailingStageDiffNetWt": data.diffWt,
  //       "customerReference": data.customerRef,
  //       "bag_size": data.bag_size,
  //     };
  //
  //     final response = await http.post(
  //       Uri.parse(
  //         "http://190.92.175.47:80/JblAPI/api/BaleDepartment/save-bale-entry",
  //       ),
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": "Bearer $token",
  //       },
  //       body: jsonEncode(body),
  //     );
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       setState(() {
  //         _isSaved = true; // ✅ Enable print
  //       });
  //
  //       _setStatus("✅ Saved Successfully");
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text("Saved Successfully"),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //     } else {
  //       _isSaved = false; // ❌ keep print disabled
  //       _setStatus("❌ Save Failed");
  //     }
  //   } catch (e) {
  //     _isSaved = false;
  //     _setStatus("❌ Error: $e");
  //   }
  // }
  Future<void> _saveBailingEntry() async {
    if (_printing) return;

    setState(() {
      _printing = true;
      _isSaved = false;
    });

    try {
      _setStatus("💾 Saving data...");

      final token = await AppSession.getToken();
      final data = widget.labelData;

      final body = {
        "packingNo": data.packingNo,
        "bailingGrossWt": data.grossWt,
        "bailingTareWt": data.tareWt,
        "bailingNetWt": data.netWt,
        "bailingStageDiffNetWt": data.diffWt,
        "customerReference": data.customerRef,
        "bag_size": data.bag_size,
      };

      final response = await http.post(
        Uri.parse(
          "http://190.92.175.47:80/JblAPI/api/BaleDepartment/save-bale-entry",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _isSaved = true; // ✅ PRINT ENABLE
          _printing = false;
        });

        _setStatus("✅ Saved Successfully");
      } else {
        setState(() {
          _isSaved = false;
          _printing = false;
        });

        _setStatus("❌ Save Failed");
      }
    } catch (e) {
      _setStatus("❌ Error: $e");
      setState(() => _printing = false);
    }
  }
  // Future<void> _startPrintFlow() async {
  //   final address = _storage.read<String>('printer_address');
  //   final name = _storage.read<String>('printer_name') ?? 'Printer';
  //
  //   if (address == null) {
  //     _setStatus('❌ Koi printer saved nahi — pehle printer select karein');
  //     return;
  //   }
  //
  //   _setStatus('🔗 $name se connect ho raha hai...');
  //
  //   if (Platform.isIOS) {
  //     await _iOSFlow(address);
  //   } else {
  //     await _androidFlow(address, name);
  //   }
  // }

  // ─── Android: BT listener se connect → print ──────────────────────────────

  Future<void> _androidFlow(String address, String name) async {
    bool triggered = false;

    _btSub?.cancel();

    _btSub = PrinterManager.instance.stateBluetooth.listen((status) async {
      debugPrint('BT Status: $status');

      if (status == BTStatus.connected && !triggered) {
        triggered = true;

        _setStatus('✅ Connected. Printer ready ho raha hai...');

        // 🟢 IMPORTANT: Printer ko ready hone ka time do
        await Future.delayed(const Duration(milliseconds: 800));

        // 🟢 Test feed bhejo (printer wake-up)
        try {
          await PrinterManager.instance.send(
            type: PrinterType.bluetooth,
            bytes: [27, 64], // ESC @ (initialize)
          );
          await Future.delayed(const Duration(milliseconds: 200));
        } catch (_) {}

        await _executePrint();
      }
    });

    // Pehle disconnect
    try {
      await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
      await Future.delayed(const Duration(milliseconds: 400));
    } catch (_) {}

    // Connect
    try {
      await PrinterManager.instance.connect(
        type: PrinterType.bluetooth,
        model: BluetoothPrinterInput(
          name: name,
          address: address,
          isBle: false,
          autoConnect: false,
        ),
      );
    } catch (e) {
      _setStatus('❌ Connect error: $e');
    }
  }

  // Future<void> _androidFlow(String address, String name) async {
  //   bool triggered = false;
  //
  //   // BT status listen karo — connected hote hi print
  //   _btSub?.cancel();
  //   _btSub = PrinterManager.instance.stateBluetooth.listen((status) async {
  //     debugPrint('BT Status: $status');
  //
  //     if (status == BTStatus.connected && !triggered) {
  //       triggered = true;
  //       _setStatus('✅ Connected...');
  //       await Future.delayed(const Duration(milliseconds: 500));
  //       await _executePrint();
  //     }
  //   });
  //
  //   // Pehle old connection disconnect karo
  //   try {
  //     await PrinterManager.instance.disconnect(type: PrinterType.bluetooth);
  //     await Future.delayed(const Duration(milliseconds: 400));
  //   } catch (_) {}
  //
  //   // Fresh connect
  //   try {
  //     await PrinterManager.instance.connect(
  //       type: PrinterType.bluetooth,
  //       model: BluetoothPrinterInput(
  //         name: name,
  //         address: address,
  //         isBle: false,
  //         autoConnect: false,
  //       ),
  //     );
  //   } catch (e) {
  //     _setStatus('❌ Connect error: $e');
  //     debugPrint('connect error: $e');
  //   }
  // }

  // ─── iOS flow ─────────────────────────────────────────────────────────────

  Future<void> _iOSFlow(String address) async {
    try {
      final ok = await PrintBluetoothThermal.connect(
        macPrinterAddress: address,
      );
      if (!ok) {
        _setStatus('❌ iOS connect fail');
        return;
      }
      _setStatus('✅ Connected! Print shuru ho raha hai...');
      await Future.delayed(const Duration(milliseconds: 500));
      await _executePrint();
    } catch (e) {
      _setStatus('❌ iOS error: $e');
    }
  }

  // ─── Execute Print ─────────────────────────────────────────────────────────

  Future<void> _executePrint() async {
    if (_printing) return;
    setState(() => _printing = true);

    try {
      final data = widget.labelData;

      _setStatus('🖨️ Printing 10x10 Label...');
      int labelWidth = 400;
      int approxTextWidth = data.packingNo.length * 20;
      int xPosition = (labelWidth - approxTextWidth) ~/ 4;
      // int labelWidth = 800; // 100mm approx dots (printer DPI pe depend karega)
      int textWidth = data.packingNo.length * 24;
      int centerX = (labelWidth - textWidth) ~/ 2;
      //       String tspl =
      //           '''
      // SIZE 100 mm,100 mm
      // GAP 3 mm,0 mm
      // DIRECTION 1
      // CLS
      //
      // TEXT 40,40,"3",0,1,1,"Party Name : ${data.partyName}"
      // // BLOCK 40,40,520,80,"3",0,1,1,2,"Party Name : ${data.partyName}"
      // TEXT 40,75,"3",0,1,1,"Reference # : ${data.customerRef}"
      // TEXT 40,110,"3",0,1,1,"Bag Size : 90X90X110"
      // TEXT 40,145,"3",0,1,1,"Bail # : ${data.bomNo}"
      // TEXT 400,145,"3",0,1,1,"Bag/PC : ${data.pcsPerPacking}"
      //
      // // QRCODE 200,220,L,14,A,0,"${data.packingNo}"
      // QRCODE 120,200,L,18,A,0,"${data.packingNo}"
      // // TEXT 280,720,"3",0,2,2,"${data.packingNo}"
      // ALIGN CENTER
      // TEXT $xPosition,650,"3",0,2,2,"${data.packingNo}"
      // PRINT 1
      //
      // ''';
      String tspl =
      '''
SIZE 100 mm,100 mm
GAP 3 mm,0 mm
DIRECTION 1
CLS

TEXT 30,80,"3",0,1,2,"${data.partyName}"
// TEXT 30,80,"3",0,2,2,"#${data.partyName}"

TEXT 40,140,"3",0,2,2,"REFERENCE#:${data.customerRef}"
TEXT 40,200,"3",0,1,1,"BAG SIZE:${data.bag_size}"

 TEXT 40,260,"3",0,2,2,"BAIL#:${data.bomNo}"
 TEXT 40,320,"3",0,2,2,"BAG/PC : ${data.pcsPerPacking}"

QRCODE 240,390,L,12,A,0,"${data.packingNo}"

TEXT 180,660,"3",0,2,2,"${data.packingNo}"



// QRCODE 200,290,L,18,A,0,"${data.packingNo}"
//
// TEXT 120,680,"3",0,2,2,"${data.packingNo}"

PRINT 1
''';

      await PrinterManager.instance.send(
        type: PrinterType.bluetooth,
        bytes: tspl.codeUnits,
      );

      _setStatus('✅ Label Printed');
    } catch (e) {
      _setStatus('❌ Error: $e');
    }

    // setState(() => _printing = false);
    _done = true;
    setState(() {
      _printing = false;
    });
  }

  // ─── Send bytes in chunks ─────────────────────────────────────────────────

  Future<void> _sendBytes(List<int> bytes) async {
    if (Platform.isIOS) {
      final ok = await PrintBluetoothThermal.writeBytes(bytes);
      if (!ok) throw Exception('iOS writeBytes failed');
      return;
    }

    const chunkSize = 1024;
    int sent = 0;
    while (sent < bytes.length) {
      final end = (sent + chunkSize).clamp(0, bytes.length);
      await PrinterManager.instance.send(
        type: PrinterType.bluetooth,
        bytes: bytes.sublist(sent, end),
      );
      sent = end;
      await Future.delayed(const Duration(milliseconds: 30));
      debugPrint('Sent: $sent / ${bytes.length}');
    }
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  // ─── Helper ───────────────────────────────────────────────────────────────

  void _setStatus(String msg) {
    debugPrint(msg);
    if (mounted) setState(() => _status = msg);
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Print Label'),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => const BluetoothDeviceListScreen());
            },
            icon: const Icon(
              Icons.bluetooth,
              color: Colors.white, // apni choice ka color de sakte ho
              size: 28, // optional size
            ),
          ),
        ],
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Status banner
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: _done
                ? Colors.green.shade100
                : _status.startsWith('❌')
                ? Colors.red.shade100
                : Colors.blue.shade50,
            child: Row(
              children: [
                if (_printing)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    _done ? Icons.check_circle : Icons.info_outline,
                    size: 18,
                    color: _done ? Colors.green : Colors.blue.shade700,
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(_status, style: const TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),

          // Label preview
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: RepaintBoundary(
                  key: _labelKey,
                  child: _LabelWidget(data: widget.labelData),
                ),
              ),
            ),
          ),

          // Retry button — sirf error pe dikhao
          // Retry button ki jagah ye lagao:
          if (_status.startsWith('❌'))
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _printing ? null : _startPrintFlow,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            )
          // else if (!_done && !_printing) // ✅ Print button — jab tak print na ho
          else if (!_printing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 45),
              child: Row(
                children: [
                  /// SAVE BUTTON
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveBailingEntry,
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// PRINT BUTTON
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSaved ? _startPrintFlow : null,
                      icon: const Icon(Icons.print),
                      label: const Text('Print'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Padding(
          //   padding: const EdgeInsets.all(16),
          //   child: ElevatedButton.icon(
          //     onPressed: _startPrintFlow,
          //     icon: const Icon(Icons.print),
          //     label: const Text('Print'),
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: const Color(0xFF1565C0),
          //       foregroundColor: Colors.white,
          //       minimumSize: const Size(double.infinity, 48),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

// ─── Label Widget ─────────────────────────────────────────────────────────────

class _LabelWidget extends StatelessWidget {
  final BarcodeLabelData data;
  const _LabelWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final labelWidth = screenWidth * 0.9; // responsive width
    final labelHeight = labelWidth * 1.3; // maintain ratio

    return Center(
      child: Container(
        width: labelWidth,
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// PARTY NAME
            _responsiveRow("PARTY NAME :", data.partyName),

            /// REFERENCE
            _responsiveRow("REFERENCE # :", data.customerRef),

            /// BAG SIZE
            _responsiveRow("BAG SIZE :", data.bag_size),

            /// BAIL + BAG/PC (Responsive)
            Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Bail # : ${data.bomNo}", // 👈 YEH CHANGE
                      style: TextStyle(
                        fontFamily: 'Oswald',
                        fontWeight: FontWeight.w600,

                        fontSize: labelWidth * 0.055,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      "BAG/PC : ${data.pcsPerPacking}",
                      style: TextStyle(
                        fontFamily: 'Oswald',
                        fontWeight: FontWeight.w600,

                        fontSize: labelWidth * 0.055,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            /// SECOND BARCODE
            /// BIG QR CODE (10x10 optimized)
            SizedBox(
              height: labelWidth * 0.55, // 55% space QR ke liye
              child: Center(
                child: BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data: data.packingNo,
                  width: labelWidth * 0.65,
                  height: labelWidth * 0.65,
                  drawText: false,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// BIG NUMBER AGAIN
            Text(
              data.packingNo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Oswald',
                fontWeight: FontWeight.w400,

                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Responsive Row (No Overflow)
  Widget _responsiveRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Oswald',
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Flexible(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Oswald',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── BluetoothPrinter Model ───────────────────────────────────────────────────

class BluetoothPrinter {
  String? deviceName;
  String? address;
  String? port;
  String? vendorId;
  String? productId;
  bool? isBle;
  PrinterType typePrinter;

  BluetoothPrinter({
    this.deviceName,
    this.address,
    this.port,
    this.vendorId,
    this.productId,
    this.typePrinter = PrinterType.bluetooth,
    this.isBle = false,
  });
}
