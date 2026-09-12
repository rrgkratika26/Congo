import 'package:IMS/util/sharedpreference/shared_preference.dart';
import 'package:flutter/material.dart';
import '../../Color/Colorclass.dart';
import '../../services/getSupervisors/getSupervisors.dart';
import 'UpdateLocationQRScan.dart';

class UpdateLocationScreen extends StatefulWidget {
  const UpdateLocationScreen({super.key});

  @override
  State<UpdateLocationScreen> createState() => _UpdateLocationScreenState();
}

class _UpdateLocationScreenState extends State<UpdateLocationScreen> {
  List<String> locations = [];
  String? selectedLocation;

  bool isLoadingLocation = true;
  String? _plant;
  int totalUpdated = 0;
  @override
  void initState() {
    super.initState();
    _loadLocations();
    _init();
    debugPrint("AppSession.unit = ${AppSession.unit}");
    debugPrint("_plant = $_plant");
  }

  Future<void> _init() async {
    _plant = await AppSession.getUnit();

    debugPrint("Plant = $_plant");

    await _loadLocations();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadLocations() async {
    try {
      final data = await InStockService().getLocations();

      setState(() {
        locations = List<String>.from(data);
        isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        isLoadingLocation = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load locations\n$e")));
    }
  }
  Future<void> _scanAndUpdate() async {
    if (selectedLocation == null ||
        selectedLocation!.trim().isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a location."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_plant == null || _plant!.trim().isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Plant not available."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    debugPrint("📷 Opening QR Scanner...");

    final String? barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const QRUpdateScannerScreen(),
      ),
    );

    if (!mounted) return;

    if (barcode == null || barcode.trim().isEmpty) {
      debugPrint("❌ No barcode received");
      return;
    }

    final cleanBarcode = barcode.trim();

    debugPrint("📷 SCANNED BARCODE: [$cleanBarcode]");

    // Small delay lets Navigator finish its transition/build cycle
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    // SAME method used by manual entry
    await _updateBarcode(cleanBarcode);
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        title: const Text(
          "RMD Location",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: C.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          children: [
            Text(
              "Note: Only RMD In Stock barcodes will be updated",
              style: TextStyle(color: C.danger),
            ),
            const SizedBox(height: 15),

            /// LOCATION DROPDOWN
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: isLoadingLocation
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : DropdownButtonFormField<String>(
                      value: selectedLocation,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: "Select Location",
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      items: locations
                          .map(
                            (location) => DropdownMenuItem<String>(
                              value: location,
                              child: Text(location),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedLocation = value;
                        });
                      },
                    ),
            ),

            const SizedBox(height: 25),

            /// TOTAL UPDATED CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Total Updated",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "$totalUpdated",
                    style: const TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                      color: C.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            Row(
              children: [
                // ============================================================
                // SCAN QR
                // ============================================================
                Expanded(
                  child: InkWell(
                    onTap: _scanAndUpdate,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            color: C.primary,
                            size: 45,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Scan QR",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // ============================================================
                // MANUAL ENTRY
                // ============================================================
                Expanded(
                  child: InkWell(
                    onTap: _manualEntry,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_note,
                            color: Colors.green,
                            size: 45,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Manual Entry",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _manualEntry() async {
    // ------------------------------------------------------------
    // CHECK LOCATION
    // ------------------------------------------------------------
    if (selectedLocation == null ||
        selectedLocation!.trim().isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a location."),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // ------------------------------------------------------------
    // CHECK PLANT
    // ------------------------------------------------------------
    if (_plant == null || _plant!.trim().isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Plant not available."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // ------------------------------------------------------------
    // CONTROLLER
    // ------------------------------------------------------------
    final textController = TextEditingController();

    try {
      // ----------------------------------------------------------
      // OPEN MANUAL ENTRY DIALOG
      // ----------------------------------------------------------
      final String? barcode = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text("Enter Barcode"),
            content: TextField(
              controller: textController,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: "Barcode",
                hintText: "Enter barcode",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                final code = value.trim();

                if (code.isEmpty) {
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  code,
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text("Cancel"),
              ),

              ElevatedButton(
                onPressed: () {
                  final code = textController.text.trim();

                  if (code.isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter barcode."),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(
                    dialogContext,
                    code,
                  );
                },
                child: const Text("Submit"),
              ),
            ],
          );
        },
      );

      // ----------------------------------------------------------
      // USER CANCELLED
      // ----------------------------------------------------------
      if (barcode == null || barcode.trim().isEmpty) {
        return;
      }

      final cleanBarcode = barcode.trim();

      debugPrint("================================");
      debugPrint("⌨️ MANUAL BARCODE: [$cleanBarcode]");
      debugPrint("📍 LOCATION: $selectedLocation");
      debugPrint("🏭 PLANT: $_plant");
      debugPrint("================================");

      // ----------------------------------------------------------
      // LET DIALOG CLOSE COMPLETELY
      // ----------------------------------------------------------
      await Future.delayed(
        const Duration(milliseconds: 100),
      );

      if (!mounted) return;

      // ----------------------------------------------------------
      // SAME UPDATE METHOD AS QR
      // ----------------------------------------------------------
      await _updateBarcode(cleanBarcode);
    } finally {
      textController.dispose();
    }
  }

  Future<void> _updateBarcode(String barcode) async {
    final String cleanBarcode = barcode.trim();

    // ------------------------------------------------------------
    // VALIDATE BARCODE
    // ------------------------------------------------------------
    if (cleanBarcode.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid barcode"),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // ------------------------------------------------------------
    // VALIDATE LOCATION
    // ------------------------------------------------------------
    if (selectedLocation == null ||
        selectedLocation!.trim().isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a location"),
          backgroundColor: Colors.orange,
        ),
      );

      return;
    }

    // ------------------------------------------------------------
    // VALIDATE PLANT
    // ------------------------------------------------------------
    if (_plant == null || _plant!.trim().isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Plant not available"),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    debugPrint("================================");
    debugPrint("📦 BARCODE: [$cleanBarcode]");
    debugPrint("📍 LOCATION: $selectedLocation");
    debugPrint("🏭 PLANT: $_plant");
    debugPrint("📡 CALLING updateLocation()");
    debugPrint("================================");

    try {
      // ----------------------------------------------------------
      // SAME API FOR QR + MANUAL
      // ----------------------------------------------------------
      final result = await InStockService.updateLocation(
        barcode: cleanBarcode,
        location: selectedLocation!,
        plant: _plant!,
      );

      debugPrint("================================");
      debugPrint("📡 API RESULT: $result");
      debugPrint("================================");

      if (!mounted) return;

      final bool success = result["success"] == true;

      final String message =
          result["message"]?.toString() ??
              (success
                  ? "Location updated successfully"
                  : "Location update failed");

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------
      if (success) {
        setState(() {
          totalUpdated++;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "✅ $message",
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // ----------------------------------------------------------
      // FAILURE
      // ----------------------------------------------------------
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "❌ $message",
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ UPDATE LOCATION ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "❌ Update failed: $e",
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
