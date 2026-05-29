// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
//
// import '../services/getSupervisors/getSupervisors.dart';
//
// class QRRMDScanScreen extends StatefulWidget {
//   final String operatorName;
//   final String supervisor;
//   final String location;
//   final String department;
//
//   const QRRMDScanScreen({
//     Key? key,
//     required this.operatorName,
//     required this.supervisor,
//     required this.location,
//     required this.department,
//   }) : super(key: key);
//
//   @override
//   State<QRRMDScanScreen> createState() => _QRRMDScanScreenState();
// }
//
// class _QRRMDScanScreenState extends State<QRRMDScanScreen> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   QRViewController? controller;
//
//   final InStockService _service = InStockService();
//
//   bool isFlashOn = false;
//   bool isScanned = false;
//   Timer? timeoutTimer;
//
//   @override
//   void initState() {
//     super.initState();
//     _startTimeout();
//   }
//
//   @override
//   void dispose() {
//     timeoutTimer?.cancel();
//     controller?.dispose();
//     super.dispose();
//   }
//
//   void _startTimeout() {
//     timeoutTimer = Timer(const Duration(seconds: 10), () {
//       if (!isScanned && mounted) {
//         controller?.pauseCamera();
//         _showError('Please try again');
//         Navigator.pop(context);
//       }
//     });
//   }
//
//   @override
//   void reassemble() {
//     super.reassemble();
//     controller?.pauseCamera();
//     controller?.resumeCamera();
//   }
//
//   void _toggleFlash() async {
//     if (controller != null) {
//       await controller!.toggleFlash();
//       setState(() => isFlashOn = !isFlashOn);
//     }
//   }
//
//   // ================= API VIA SERVICE =================
//
//   Future<void> _processBarcode(String barcode) async {
//     final result = await _service.checkBarcodeIn(
//       // barcode: "LO00010",
//       roll_entry: "R01",
//       barcode: barcode,
//       storage: widget.location,
//       // storage: "R-1",
//       operatorName: widget.operatorName,
//       supervisor: widget.supervisor,
//       // department: widget.department,
//       // operatorName: "OP1",
//       // supervisor: "Harish Patil",
//       department: "RMD",
//     );
//
//     if (!mounted) return;
//
//     if (result == null) {
//       _showError('Server not responding');
//       return;
//     }
//
//     final String status = result['status'] ?? '';
//     final String message = result['message'] ?? 'Barcode Scanned Successfully';
//
//     if (status == 'ok') {
//       _showSnackBar(message, isSuccess: true);
//
//       // ✅ Close scanner after success
//       await Future.delayed(const Duration(milliseconds: 800));
//       Navigator.pop(context, barcode);
//     } else {
//       _showError(message);
//     }
//   }
//
//   // ================= UI HELPERS =================
//
//   void _showSnackBar(String message, {bool isSuccess = true}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               isSuccess ? Icons.check_circle : Icons.error,
//               color: Colors.white,
//             ),
//             const SizedBox(width: 12),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: isSuccess ? Colors.green.shade600 : Colors.redAccent,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
//
//   void _showError(String message) {
//     isScanned = false;
//     controller?.resumeCamera();
//     _showSnackBar(message, isSuccess: false);
//   }
//
//   // ================= UI =================
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scan QR Code'),
//         actions: [
//           IconButton(
//             onPressed: _toggleFlash,
//             icon: Icon(
//               isFlashOn ? Icons.flash_on : Icons.flash_off,
//               color: isFlashOn ? Colors.amber : null,
//             ),
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           QRView(
//             key: qrKey,
//             overlay: QrScannerOverlayShape(
//               borderRadius: 12,
//               borderColor: Colors.blue,
//               borderWidth: 8,
//               borderLength: 24,
//             ),
//             onQRViewCreated: (ctrl) {
//               controller = ctrl;
//               controller!.scannedDataStream.listen((scanData) async {
//                 if (isScanned) return;
//
//                 isScanned = true;
//                 timeoutTimer?.cancel();
//                 controller!.pauseCamera();
//
//                 final barcode = scanData.code;
//                 if (barcode != null && barcode.isNotEmpty) {
//                   await _processBarcode(barcode);
//                 } else {
//                   _showError('Invalid QR Code');
//                 }
//               });
//             },
//           ),
//
//           Positioned(
//             bottom: 40,
//             right: 20,
//             child: FloatingActionButton(
//               onPressed: _toggleFlash,
//               backgroundColor: isFlashOn ? Colors.amber : Colors.blue,
//               child: Icon(
//                 isFlashOn ? Icons.flash_on : Icons.flash_off,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../services/getSupervisors/getSupervisors.dart';

enum ScanType { inStock, outStock, webbingStock }

class QRRMDScanScreen extends StatefulWidget {
  final String operatorName;
  final String supervisor;
  final String location;
  final String department;
  final ScanType scanType; // 👈 NEW

  const QRRMDScanScreen({
    Key? key,
    required this.operatorName,
    required this.supervisor,
    required this.location,
    required this.department,
    required this.scanType,
  }) : super(key: key);

  @override
  State<QRRMDScanScreen> createState() => _QRRMDScanScreenState();
}

class _QRRMDScanScreenState extends State<QRRMDScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  final InStockService _service = InStockService();

  bool isFlashOn = false;
  bool isScanned = false;
  Timer? timeoutTimer;

  @override
  void initState() {
    super.initState();
    _startTimeout();
  }

  @override
  void dispose() {
    timeoutTimer?.cancel();
    controller?.dispose();
    super.dispose();
  }

  void _startTimeout() {
    timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (!isScanned && mounted) {
        controller?.pauseCamera();
        _showError('Scan timed out. Please try again.');
        Navigator.pop(context);
      }
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  void _toggleFlash() async {
    if (controller != null) {
      await controller!.toggleFlash();
      setState(() => isFlashOn = !isFlashOn);
    }
  }

  // ================= API HANDLER =================
  Future<void> _processBarcode(String barcode) async {

    // ✅ Same API jo manual entry mein use hoti hai
    final result = await _service.checkBarcodeIn(
      barcode: barcode,
      roll_entry: 'R01',
      storage: widget.location,
      operatorName: widget.operatorName,
      supervisor: widget.supervisor,
      department: widget.department,
    );

    if (!mounted) return;

    if (result == null) {
      _showError('Server not responding');
      return;
    }

    final status = (result['status'] ?? '').toString().toLowerCase();
    final message = result['message'] ?? 'Unknown response';

    // ✅ SUCCESS
    if (status == 'ok') {
      _showSnackBar(message, isSuccess: true);
      await Future.delayed(const Duration(milliseconds: 800));
      Navigator.pop(context, barcode);
    }

    // ⚠️ ALREADY EXISTS
    else if (status == 'exists') {
      _showSnackBar(message, isSuccess: false);
      await Future.delayed(const Duration(milliseconds: 800));
      Navigator.pop(context, barcode);
    }

    // ❌ OTHER ERROR
    else {
      _showSnackBar(message, isSuccess: false);
      isScanned = false;
      controller?.resumeCamera();
    }
  }



  void _showSnackBar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green.shade600 : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    isScanned = false;
    controller?.resumeCamera();
    _showSnackBar(message, isSuccess: false);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.scanType == ScanType.inStock ? 'Scan In QR' : 'Scan Out QR',
        ),
        actions: [
          IconButton(
            onPressed: _toggleFlash,
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: isFlashOn ? Colors.amber : null,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            overlay: QrScannerOverlayShape(
              borderRadius: 12,
              borderColor: Colors.blue,
              borderWidth: 8,
              borderLength: 24,
            ),
            onQRViewCreated: (ctrl) {
              controller = ctrl;
              controller!.scannedDataStream.listen((scanData) async {
                if (isScanned) return;

                isScanned = true;
                timeoutTimer?.cancel();
                controller!.pauseCamera();

                final barcode = scanData.code?.trim();
                if (barcode != null && barcode.isNotEmpty) {
                  await _processBarcode(barcode);
                } else {
                  _showError('Invalid QR Code');
                }
              });
            },
          ),

          Positioned(
            bottom: 40,
            right: 20,
            child: FloatingActionButton(
              onPressed: _toggleFlash,
              backgroundColor: isFlashOn ? Colors.amber : Colors.blue,
              child: Icon(
                isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
