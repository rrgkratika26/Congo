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

    // Stop camera immediately
    await controller?.pauseCamera();

    try {
      final url = Uri.parse(
        "${JblApiService.baseUrlJBL}/Lamination/SubmitBarcode",
      );

      debugPrint("Lamination scanned URL ::::: $url");

      final body = {
        "barcode": barcode,
        "rollEntry": "LAMINATION",
        "operator": widget.operator,
        "supervisor": widget.supervisor,
        "department": widget.department,
        "location": widget.location,

        // ⚠️ If API expects plant, use widget.plant here
        "plant": widget.plant,
      };

      debugPrint("Request Body: $body");

      final response = await http.post(
        url,
        headers: await InStockService.authHeaders(),
        body: jsonEncode(body),
      );

      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response: ${response.body}");

      dynamic res;

      try {
        res = jsonDecode(response.body);
      } catch (e) {
        debugPrint("❌ JSON Decode Error: ${response.body}");

        res = {
          "status": "error",
          "message": "Invalid response from server",
        };
      }

      final String status =
          res['status']?.toString().toLowerCase() ?? 'error';

      final String message =
          res['message']?.toString() ?? 'No message from server';

      debugPrint("API STATUS: $status");
      debugPrint("API MESSAGE: $message");

      if (!mounted) return;

      // Hide previous snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // =========================================================
      // SUCCESS
      // =========================================================
      if (status == "ok") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Give Snackbar time to appear
        await Future.delayed(
          const Duration(milliseconds: 500),
        );

        if (mounted) {
          Navigator.pop(context, true);
        }

        return;
      }

      // =========================================================
      // ALREADY EXISTS
      // =========================================================
      if (status == "exists") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Wait before allowing camera to scan again
        await Future.delayed(_rescanCooldown);

        if (mounted) {
          await controller?.resumeCamera();
        }

        return;
      }

      // =========================================================
      // ERROR
      // =========================================================
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [

              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Resume scanner after error
      await Future.delayed(_rescanCooldown);

      if (mounted) {
        await controller?.resumeCamera();
      }
    } catch (e) {
      debugPrint("❌ API ERROR: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Something went wrong: $e",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );

        await Future.delayed(_rescanCooldown);

        if (mounted) {
          await controller?.resumeCamera();
        }
      }
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  // ================= QR SCAN =================
  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;

    ctrl.scannedDataStream.listen((scanData) async {
      final code = scanData.code;
      if (code == null || isProcessing) return;

      final now = DateTime.now();


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