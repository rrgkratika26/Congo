import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QRUpdateScannerScreen extends StatefulWidget {
  const QRUpdateScannerScreen({super.key});

  @override
  State<QRUpdateScannerScreen> createState() =>
      _QRUpdateScannerScreenState();
}

class _QRUpdateScannerScreenState extends State<QRUpdateScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  QRViewController? controller;
  bool scanned = false;
  bool flashOn = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  Future<void> _toggleFlash() async {
    if (controller != null) {
      await controller!.toggleFlash();
      setState(() {
        flashOn = !flashOn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR"),
        actions: [
          IconButton(
            onPressed: _toggleFlash,
            icon: Icon(
              flashOn ? Icons.flash_on : Icons.flash_off,
            ),
          ),
        ],
      ),
      body: QRView(
        key: qrKey,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.blue,
          borderRadius: 12,
          borderLength: 25,
          borderWidth: 8,
          cutOutSize: 260,
        ),
        onQRViewCreated: (QRViewController ctrl) {
          controller = ctrl;

          controller!.scannedDataStream.listen((scanData) {
            if (scanned) return;

            final barcode = scanData.code?.trim();

            if (barcode != null && barcode.isNotEmpty) {
              scanned = true;
              controller?.pauseCamera();

              Navigator.pop(context, barcode);
            }
          });
        },
      ),
    );
  }
}