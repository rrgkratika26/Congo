import 'dart:convert';
import 'package:IMS/services/getSupervisors/getSupervisors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../../services/JBL_apis/jbl_api_bailing_reports.dart';

class JBl_laminationQrScanScreen extends StatefulWidget {
  final String operator;
  final String supervisor;
  final String location;
  final String department;
  final String plant;
  final Function(String barcode)? onSubmitBarcode;
  const JBl_laminationQrScanScreen({
    Key? key,
    required this.operator,
    required this.supervisor,
    required this.location,
    required this.department,
    required this.plant,
    this.onSubmitBarcode, // optional
  }) : super(key: key);

  @override
  State<JBl_laminationQrScanScreen> createState() =>
      _JBl_laminationQrScanScreenState();
}

class _JBl_laminationQrScanScreenState
    extends State<JBl_laminationQrScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  bool isProcessing = false;

  // 🔒 Prevents the same barcode from re-triggering the API/snackbar
  // repeatedly while it's still in view of the camera.
  String? _lastScannedCode;
  DateTime? _lastScanTime;
  static const _rescanCooldown = Duration(seconds: 3);

  // 🔗 API CALL
  Future<void> submitBarcode(String barcode) async {
    if (isProcessing) return;

    setState(() => isProcessing = true);

    // Pause immediately so the camera doesn't keep firing scan events
    // for the same code while the request is in flight.
    await controller?.pauseCamera();

    try {
      final url = Uri.parse(
        "${JblApiService.baseUrlJBL}/Lamination/SubmitBarcode",
      );
      print("Lamination scanned url ::::: $url");

      final body = {
        "barcode": barcode,
        "rollEntry": "LAMINATION",
        "operator": widget.operator,
        "supervisor": widget.supervisor,
        "department": widget.department,
        "location": widget.location,
        "plant": widget.location,
      };

      print("Request Body: $body");

      final response = await http.post(
        url,
        headers: await InStockService.authHeaders(),
        body: jsonEncode(body),
      );

      dynamic res;
      try {
        res = jsonDecode(response.body);
      } catch (e) {
        debugPrint("❌ Failed to decode JSON: ${response.body}");
        res = {
          "status": "error",
          "message": "Server returned invalid response",
        };
      }

      final status = res['status'] ?? 'error';
      final message = res['message'] ?? 'No message';

      if (mounted) {
        // Clear any currently-showing snackbar before showing the new one,
        // so repeated statuses don't stack up on screen.
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: status == 'ok'
                ? Colors.green
                : (status == 'exists' ? Colors.orange : Colors.red),
          ),
        );
      }

      if (status == 'ok') {
        if (mounted) Navigator.pop(context, true); // success
        return;
      }

      // For 'exists' or 'error', wait briefly before resuming so the same
      // QR code (still under the camera) isn't picked up again instantly.
      await Future.delayed(_rescanCooldown);
      await controller?.resumeCamera();
    } catch (e) {
      debugPrint("❌ API ERROR: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong"),
            backgroundColor: Colors.red,
          ),
        );
      }
      await Future.delayed(_rescanCooldown);
      await controller?.resumeCamera();
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  // ================= QR SCAN =================
  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;

    ctrl.scannedDataStream.listen((scanData) async {
      final code = scanData.code;
      if (code == null || isProcessing) return;

      final now = DateTime.now();

      // Ignore the same barcode if it was just scanned within the
      // cooldown window — this is what was causing repeated
      // "already exists" snackbars for a single physical scan.
      if (_lastScannedCode == code &&
          _lastScanTime != null &&
          now.difference(_lastScanTime!) < _rescanCooldown) {
        return;
      }

      _lastScannedCode = code;
      _lastScanTime = now;

      await submitBarcode(code);
    });
  }

  // ================= MANUAL ENTRY =================
  void _manualEntry() {
    final textCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Manual Entry"),
        content: TextField(
          controller: textCtrl,
          decoration: const InputDecoration(labelText: "Enter Barcode"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final barcode = textCtrl.text.trim();

              if (barcode.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Enter valid barcode"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              submitBarcode(barcode);
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Lamination QR"),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _manualEntry),
        ],
      ),
      body: Column(
        children: [
          // 🔥 FULL SCREEN SCANNER
          Expanded(
            flex: 4,
            child: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}