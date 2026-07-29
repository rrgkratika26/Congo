import 'dart:async';
import 'package:IMS/QRScan/QrScanScreen.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import '../../services/getSupervisors/getSupervisors.dart';

class WebbingScanScreen extends StatefulWidget {
  final String operatorName;
  final String supervisor;
  final String location;
  final String department;
  final ScanType scanType;


  const WebbingScanScreen({
    Key? key,
    required this.operatorName,
    required this.supervisor,
    required this.location,
    required this.department,
     required this.scanType,
  }) : super(key: key);

  @override
  State<WebbingScanScreen> createState() => _WebbingScanScreenState();
}

class _WebbingScanScreenState extends State<WebbingScanScreen> {
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
        _showSnackBar("Scan timed out. Try again", false); // ✅ fix
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

  // ================= API CALL =================

  Future<void> _processBarcode(String barcode) async {
    print("====== API PARAMETERS ======");
    print("barcode: $barcode");
    print("plant: ${widget.location}");
    print("department: ${widget.department}");
    print("supervisor: ${widget.supervisor}");
    print("operator: ${widget.operatorName}");
    print("rollEntry: ROLL_ENTRY_1");
    print("location: ${widget.location}");
    print("============================");
    final Map<String, dynamic>? result = await _service.checkWebbBarcode(
      barcode: barcode,
      plant: widget.location,
      department: widget.department,
      supervisor: widget.supervisor,
      operator: widget.operatorName,
      rollEntry: 'ROLL_ENTRY_1',
      location: widget.location,
    );

    if (!mounted) return;

    if (result == null) {
      _showSnackBar('Server not responding', false);
      isScanned = false;
      controller?.resumeCamera();
      return;
    }

    final bool isSuccess = result['success'] == true;
    final message = result['message'] ?? 'Unknown response';

    if (isSuccess) {
      _showSnackBar(message, true);

      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pop(context, barcode);
    } else {
      // 🔴 HANDLE ALL FAIL CASES HERE
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
              success ? Icons.check_circle : Icons.warning_amber_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: success ? Colors.green : Colors.orange,
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
        title: const Text("Webbing Scan Item"), // ✅ Title fix kiya
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
              borderColor: Colors.orange, // ✅ Webbing ke liye orange
              borderWidth: 8,
              borderLength: 24,
            ),
            onQRViewCreated: (ctrl) {
              controller = ctrl;
              controller!.scannedDataStream.listen((scanData) async {
                if (isScanned) return;

                isScanned = true;
                timeoutTimer?.cancel();
                controller?.pauseCamera();

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
              backgroundColor: isFlashOn ? Colors.amber : Colors.orange,
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
