import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class ScanRmdTrasnfer extends StatefulWidget {
  const ScanRmdTrasnfer({super.key});

  @override
  State<ScanRmdTrasnfer> createState() => _ScanRmdTrasnferState();
}

class _ScanRmdTrasnferState extends State<ScanRmdTrasnfer> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanned = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: (ctrl) {
              controller = ctrl;

              ctrl.scannedDataStream.listen((scanData) {
                if (isScanned) return;

                final code = scanData.code;

                if (code != null && code.isNotEmpty) {
                  isScanned = true;
                  controller?.pauseCamera();

                  Navigator.pop(context, code); // return result
                }
              });
            },
          ),

          // back button
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // scan box
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}