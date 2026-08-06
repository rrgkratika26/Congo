import 'dart:async';
import 'package:IMS/services/GlobalLoader/GloabalUnit.dart';
import 'package:IMS/services/Visa_SmallbagAPIS/VISA_SApis.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QrSlittingScanInScree extends StatefulWidget {
  final String operatorName;
  // final String barcode;
  final String supervisor;
  final String location;
  final String roll;
  final String plant;
  final String party;
  final String workorder;

  const QrSlittingScanInScree({
    super.key,
    required this.operatorName,
    // required this.barcode,
    required this.supervisor,
    required this.location,
    required this.roll,
    required this.plant,
    required this.party,
    required this.workorder,
  });

  @override
  State<QrSlittingScanInScree> createState() => _QrSlittingScanInScreeState();
}

class _QrSlittingScanInScreeState extends State<QrSlittingScanInScree> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  final VisaSmallBagApiService _service = VisaSmallBagApiService();
  bool _isProcessing = false;
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
    final result = await _service.slittingIn(
      barcode: barcode,
      location: widget.location,
      operator: widget.operatorName,
      supervisor: widget.supervisor,
      roll: widget.roll,
      plant: widget.plant,
    );

    if (!mounted) return;

    if (result == null) {
      _showSnackBar("Server not responding", isSuccess: false);
      return;
    }

    final bool success = result["success"] == true;
    final String message = result["message"]?.toString() ?? "Unknown response";

    // Show only API response message
    _showSnackBar(message, isSuccess: success);

    await Future.delayed(const Duration(milliseconds: 800));

    Navigator.pop(context, success);
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
        backgroundColor: isSuccess ?Colors.green.shade600 :Colors.redAccent,
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
