import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../../services/getSupervisors/getSupervisors.dart';



class RmdScanScreen extends StatefulWidget {
  final String operatorName;
  final String supervisor;
  final String location;
  final String department;

  const RmdScanScreen({
    Key? key,
    required this.operatorName,
    required this.supervisor,
    required this.location,
    required this.department,
  }) : super(key: key);

  @override
  State<RmdScanScreen> createState() => _RmdScanScreenState();
}

class _RmdScanScreenState extends State<RmdScanScreen> {
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
        _showSnackBar("Scan timed out. Try again", false);
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
      setState(() {
        isFlashOn = !isFlashOn;
      });
    }
  }

  // ================= API CALL =================

  Future<void> _processBarcode(String barcode) async {
    final result = await _service.checkBarcodeIn(
      barcode: barcode,
      roll_entry: "RMD",
      storage: widget.location,
      operatorName: widget.operatorName,
      supervisor: widget.supervisor,
      department: widget.department,
    );

    if (!mounted) return;

    if (result == null) {
      _showSnackBar("Server not responding", false);
      controller?.resumeCamera();
      isScanned = false;
      return;
    }

    final status = (result["status"] ?? "").toString().toLowerCase();
    final message = result["message"] ?? "Unknown response";

    if (status == "ok") {
      _showSnackBar(message, true);

      await Future.delayed(const Duration(milliseconds: 800));
      Navigator.pop(context, barcode);
    } else {
      _showSnackBar(message, false);

      isScanned = false;
      controller?.resumeCamera();
    }
  }

  // ================= UI HELPERS =================

  void _showSnackBar(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: success ? Colors.green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RMD Scan Item"),
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
                  _showSnackBar("Invalid QR Code", false);
                  controller?.resumeCamera();
                  isScanned = false;
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