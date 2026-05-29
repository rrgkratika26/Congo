import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../../../services/getSupervisors/getSupervisors.dart';

class CuttingQRScanScreen extends StatefulWidget {
  final String operator;
  final String supervisor;
  final String location;
  final String department;
  final String plant;

  const CuttingQRScanScreen({
    Key? key,
    required this.operator,
    required this.supervisor,
    required this.location,
    required this.department,
    required this.plant,
  }) : super(key: key);

  @override
  State<CuttingQRScanScreen> createState() => _CuttingQRScanScreenState();
}

class _CuttingQRScanScreenState extends State<CuttingQRScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;

  final InStockService _service = InStockService();

  bool isFlashOn = false;
  bool isProcessing = false;
  Timer? timeoutTimer;

  @override
  void initState() {
    super.initState();
    _startTimeout();
  }

  @override
  void dispose() {
    timeoutTimer?.cancel();
    qrController?.dispose();
    super.dispose();
  }

  void _startTimeout() {
    timeoutTimer = Timer(const Duration(seconds: 12), () {
      if (!isProcessing && mounted) {
        qrController?.pauseCamera();
        _showSnackBar('Scan timeout. Try again', isSuccess: false);
        Navigator.pop(context);
      }
    });
  }

  void _toggleFlash() async {
    if (qrController != null) {
      await qrController!.toggleFlash();
      setState(() => isFlashOn = !isFlashOn);
    }
  }

  // ================= CUTTING API =================

  Future<void> _handleBarcode(String barcode) async {
    final result = await _service.cuttingBarcode(
      barcode: barcode,
      operatorName: widget.operator,
      supervisor: widget.supervisor,
      location: widget.location,
      department: widget.department, // CUTTING
      cuttingRecParty: '',
      workOrderCutting: '',
    );

    if (!mounted) return;

    if (result == null) {
      _showSnackBar('Server not responding', isSuccess: false);
      qrController?.resumeCamera();
      isProcessing = false;
      return;
    }

    final status = result['status'] ?? '';
    final message = result['message'] ?? 'Scan completed';

    if (status.toString().toLowerCase() == 'ok') {
      _showSnackBar(message, isSuccess: true);
      await Future.delayed(const Duration(milliseconds: 800));
      Navigator.pop(context, barcode);
    } else {
      _showSnackBar(message, isSuccess: false);
      qrController?.resumeCamera();
      isProcessing = false;
    }
  }

  // ================= UI HELPERS =================

  void _showSnackBar(String message, {required bool isSuccess}) {
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
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cutting QR Scan'),
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
            onQRViewCreated: (controller) {
              qrController = controller;
              qrController!.scannedDataStream.listen((scanData) async {
                if (isProcessing) return;

                final barcode = scanData.code;
                if (barcode == null || barcode.isEmpty) {
                  _showSnackBar('Invalid QR code', isSuccess: false);
                  return;
                }

                isProcessing = true;
                timeoutTimer?.cancel();
                qrController!.pauseCamera();

                await _handleBarcode(barcode);
              });
            },
          ),

          Positioned(
            bottom: 30,
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
