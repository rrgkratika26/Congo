import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../../services/getSupervisors/getSupervisors.dart';



enum ScanType { inStock, outStock }

class QRFoldingScanScreen extends StatefulWidget {
  final String operatorName;
  final String supervisor;
  final String location;


  const QRFoldingScanScreen({
    Key? key,
    required this.operatorName,
    required this.supervisor,
    required this.location,

  }) : super(key: key);

  @override
  State<QRFoldingScanScreen> createState() => _QRFoldingScanScreenState();
}

class _QRFoldingScanScreenState extends State<QRFoldingScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  final InStockService _service = InStockService();

  bool isFlashOn = false;
  bool isScanned = false;
  Timer? timeoutTimer;

  final String department = "FOLDING"; // ✅ FIXED

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
        _showError('Scan timeout. Try again.');
        Navigator.pop(context);
      }
    });
  }

  void _toggleFlash() async {
    if (controller != null) {
      await controller!.toggleFlash();
      setState(() => isFlashOn = !isFlashOn);
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  // ================= API =================

  Future<void> _processBarcode(String barcode) async {
    final result = await _service.checkBarcodeIn(
      barcode: barcode,
      roll_entry: "FOLDING", // 🔥 CHANGE FOR FOLDING
      storage: widget.location,
      operatorName: widget.operatorName,
      supervisor: widget.supervisor,
      department: department,
    );

    if (!mounted) return;

    if (result == null) {
      _showError("Server not responding");
      return;
    }

    final status = result['status']?.toString().toLowerCase() ?? '';
    final message = result['message'] ?? 'Unknown response';

    if (status == 'ok') {
      _showSnack(message, true);
      await Future.delayed(const Duration(milliseconds: 800));
      Navigator.pop(context, barcode);
    }
    else if (status == 'exists') {
      _showSnack(message, false);
      await Future.delayed(const Duration(milliseconds: 800));
      Navigator.pop(context, barcode);
    }
    else {
      _showError(message);
    }
  }

  // ================= UI HELPERS =================

  void _showSnack(String msg, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  void _showError(String msg) {
    isScanned = false;
    controller?.resumeCamera();
    _showSnack(msg, false);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Folding IN Scan"

        ),
        actions: [
          IconButton(
            onPressed: _toggleFlash,
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: isFlashOn ? Colors.amber : null,
            ),
          )
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
                  _showError("Invalid QR Code");
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
              ),
            ),
          )
        ],
      ),
    );
  }
}