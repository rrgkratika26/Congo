import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../../services/getSupervisors/MAchineApiService.dart';
import 'MachineDetailScreen.dart';
import 'ModelClass.dart';

class ScanMachineQrScreen extends StatefulWidget {
  const ScanMachineQrScreen({Key? key}) : super(key: key);

  @override
  State<ScanMachineQrScreen> createState() => _ScanMachineQrScreenState();
}

class _ScanMachineQrScreenState extends State<ScanMachineQrScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isProcessing = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) async {
      if (isProcessing) return;
      isProcessing = true;

      await controller.pauseCamera();

      final scannedCode = scanData.code?.trim() ?? "";
      print("Scanned Code: [$scannedCode]");

      try {
        final machines = await MachineApiService.fetchMachines();
        MachineModel? machine;

        try {
          machine = machines.firstWhere(
                (m) => m.machineBrId.trim().toLowerCase() ==
                scannedCode.toLowerCase(),
          );
        } catch (e) {
          machine = null;
        }

        if (!mounted) return;

        if (machine != null) {
          // ✅ Use the correct variable here
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MachineDetailScreen(
                machineBrId: machine!.machineBrId, // ✅ for details API
                machineId: machine.id,            // for insertFault API
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Machine not found")),
          );
          isProcessing = false;
          await controller.resumeCamera();
        }
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error fetching machines")),
        );
        isProcessing = false;
        await controller.resumeCamera();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Scan Machine QR"),
        backgroundColor: const Color(0xFF1E5AA8),
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.blue,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 250,
        ),
      ),
    );
  }
}
