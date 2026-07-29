import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../../../services/JBL_apis/jbl_api_bailing_reports.dart';

/// 🔥 ENUM for dynamic scan type
enum ScanJBLType { inRmd, outRmd }

class Jbl_ScanBarcode extends StatefulWidget {
  final String operatorName;
  final String supervisor;
  final String storage; // IN = unit, OUT = issueTo
  final String department;
  final ScanJBLType scanType;
  final String unit;

  const Jbl_ScanBarcode({
    Key? key,
    required this.operatorName,
    required this.supervisor,
    required this.storage,
    required this.department,
    required this.scanType,
    required this.unit,
  }) : super(key: key);

  @override
  State<Jbl_ScanBarcode> createState() => _Jbl_ScanBarcodeState();
}

class _Jbl_ScanBarcodeState extends State<Jbl_ScanBarcode> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

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

  /// ⏱ Auto timeout
  void _startTimeout() {
    timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (!isScanned && mounted) {
        controller?.pauseCamera();
        _showError('Scan timed out. Try again.');
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

  /// 🔦 Flash toggle
  void _toggleFlash() async {
    if (controller != null) {
      await controller!.toggleFlash();
      setState(() => isFlashOn = !isFlashOn);
    }
  }

  // =====================================================
  // 🔥 MAIN LOGIC (DYNAMIC API SWITCH)
  // =====================================================

  Future<void> _processBarcode(String barcode) async {
    dynamic result;

    try {
      if (widget.scanType == ScanJBLType.inRmd) {
        result = await JblApiService().jbl_checkBarcodeIn(
          barcode: barcode,
          roll_entry: 'RMD',
          storage: widget.storage,
          operatorName: widget.operatorName,
          supervisor: widget.supervisor,
          department: widget.department,
          unit: widget.unit,
        );
      } else if (widget.scanType == ScanJBLType.outRmd) {
        result = await JblApiService().jbl_checkBarcodeOut(
          barcode: barcode,
          roll_entry: 'RMD',
          storage: widget.storage,
          operatorName: widget.operatorName,
          supervisor: widget.supervisor,
          department: widget.department,
          unit: widget.unit,
        );
      }
    } catch (e) {
      _showError("Something went wrong");
      return;
    }

    if (!mounted) return;

    if (result == null) {
      _showError('Server not responding');
      return;
    }

    final status = (result['status'] ?? '').toString().toLowerCase();
    final message = result['message'] ?? 'Unknown response';

    // Always show snackbar
    _showSnackBar(message, isSuccess: status == 'ok');

    if (status == 'ok') {
      // Success → close after short delay
      await Future.delayed(const Duration(milliseconds: 700));
      Navigator.pop(context, barcode);
    } else if (status == 'exists') {
      // Already exists → close after short delay
      await Future.delayed(const Duration(milliseconds: 700));
      Navigator.pop(context, barcode);
    } else {
      // invalid or other error → allow retry
      isScanned = false;
      controller?.resumeCamera();
    }
  }

  // =====================================================
  // UI HELPERS
  // =====================================================

  void _showSnackBar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
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

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.scanType == ScanJBLType.inRmd
              ? 'RMD IN Scan'
              : 'RMD OUT Scan',
        ),
        backgroundColor: Colors.blue.shade100,
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

          /// 🔦 Floating Flash Button
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
