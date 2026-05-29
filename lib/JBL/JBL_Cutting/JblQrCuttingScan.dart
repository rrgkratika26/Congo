import 'dart:async';
import 'package:IMS/services/JBL_apis/jbl_api_bailing_reports.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../../../services/getSupervisors/getSupervisors.dart';

class JblQRCuttingScanScreen extends StatefulWidget {
  final String operatorName;
  final String supervisor;
  final String location;
  final String department;
  final String plant;

  const JblQRCuttingScanScreen({
    Key? key,
    required this.operatorName,
    required this.supervisor,
    required this.location,
    required this.department,
    required this.plant,
  }) : super(key: key);

  @override
  State<JblQRCuttingScanScreen> createState() =>
      _JblQRCuttingScanScreenState();
}

class _JblQRCuttingScanScreenState extends State<JblQRCuttingScanScreen> {
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
    timeoutTimer = Timer(const Duration(seconds: 15), () {
      if (!isScanned && mounted) {
        controller?.pauseCamera();
        _showSnackBar('Scan timed out. Try again', isSuccess: false);
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

  // ================= API CALL =================

  Future<void> _processBarcode(String barcode) async {
    final result = await JblApiService.jbl_CuttingcheckBarcode(
      barcode: barcode,
      supervisor: widget.supervisor,
      operator: widget.operatorName,
      location: widget.location,
      department: widget.department,
      plant: widget.plant,
    );

    if (!mounted) return;

    final status = (result['status'] ?? '').toString().toLowerCase();
    final message = result['message'] ?? 'Unknown response';

    if (status == 'ok') {
      _showSnackBar(message, isSuccess: true);
      await Future.delayed(const Duration(milliseconds: 700));
      Navigator.pop(context, barcode);
    } else if (status == 'exists') {
      _showSnackBar(message, isSuccess: false);
      await Future.delayed(const Duration(milliseconds: 700));
      Navigator.pop(context, barcode);
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
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
        isSuccess ? Colors.green.shade600 : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🔥 FULL SCREEN CAMERA
          Positioned.fill(
            child: QRView(
              key: qrKey,
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
          ),

          // 🔝 TOP BAR
          Positioned(
            top: 40,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  "Cutting IN Scan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _toggleFlash,
                  icon: Icon(
                    isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: isFlashOn ? Colors.amber : Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // 🎯 SCAN BOX
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.greenAccent, width: 3),
              ),
            ),
          ),

          // 🔽 INFO TEXT
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  "Align QR code inside the box",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  "${widget.operatorName} | ${widget.supervisor}",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}