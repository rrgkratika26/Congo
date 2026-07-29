import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../../../services/getSupervisors/getSupervisors.dart';

enum ScanType { inStock, outStock }

class LaminationQRScanScreen extends StatefulWidget {
  final String operator;
  final String supervisor;
  final String location;
  final String department;
  // final String plant;
  // final ScanType scanType; // 👈 NEW

  const LaminationQRScanScreen({
    Key? key,
    required this.operator,
    required this.supervisor,
    required this.location,
    required this.department,
    // required this.scanType,
    // required this.plant,
  }) : super(key: key);

  @override
  State<LaminationQRScanScreen> createState() => _LaminationQRScanScreenState();
}

class _LaminationQRScanScreenState extends State<LaminationQRScanScreen> {
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
    Map<String, dynamic>? result;

    /// 🔥 Decide API based on screen
    // if (widget.scanType == ScanType.inStock)
    {
      result = await _service.laminationBarcode(
        rollEntry: "LAMINATION",
        barcode: barcode,
        location: widget.location,
        supervisor: widget.supervisor,
        department: widget.department,
        operator: widget.operator,
        // plant: 'PLANT1',
      );
      // } else {
      //   result = await _service.checkBarcodeOut(
      //     roll_entry: "R01",
      //     barcode: barcode,
      //     location: widget.location,
      //     operator: widget.operator,
      //     supervisor: widget.supervisor,
      //     department: widget.department, operatorName: '',
      //   );
    }

    if (!mounted) return;

    if (result == null) {
      _showError('Server not responding');
      return;
    }

    final status = result['status'] ?? '';
    final message = result['message'] ?? 'Scan successful';

    if (status.toLowerCase() == 'ok') {
      _showSnackBar(message, isSuccess: true);
      await Future.delayed(const Duration(milliseconds: 800));
      Navigator.pop(context, barcode); // return barcode
    } else {
      _showError(message);
    }
  }

  // ================= UI HELPERS =================

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
        backgroundColor: isSuccess ? Colors.green.shade600 : Colors.green,
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
        // title: Text(
        //   widget.scanType == ScanType.inStock
        //       ? 'Scan In QR'
        //       : 'Scan Out QR',
        // ),
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

                final barcode = scanData.code;
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
