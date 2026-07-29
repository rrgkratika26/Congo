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

            /// BUTTONS
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (selectedLocation == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select location"),
                          ),
                        );
                        return;
                      }

                      /// Navigate to QR Scanner
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      onTap: () async {
                        if (selectedLocation == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please select a location."),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        final barcode = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QRUpdateScannerScreen(),
                          ),
                        );

                        if (barcode == null) return;

                        final result = await InStockService.updateLocation(
                          barcode: barcode,
                          location: selectedLocation!,
                          plant: _plant!,
                        );

                        // if (result.contains("Success")) {
                        //   setState(() {
                        //     totalUpdated++;
                        //   });
                        // }

                        // ScaffoldMessenger.of(
                        //   context,
                        // ).showSnackBar(SnackBar(content: Text(result)));
                      },
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
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (selectedLocation == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select location"),
                          ),
                        );
                        return;
                      }

                      _manualEntry();
                    },
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
                          Icon(Icons.edit_note, color: Colors.green, size: 45),
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

  Future _manualEntry() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Enter Barcode"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              child: const Text("Submit"),
              onPressed: () async {
                final barcode = controller.text.trim();

                if (barcode.isEmpty) return;

                Navigator.pop(dialogContext);

                final result = await InStockService.updateLocation(
                  barcode: barcode,
                  location: selectedLocation!,
                  plant: _plant!,
                );

                if (!mounted) return;

                final bool success = result["success"] == true;
                final String message = result["message"] ?? "Unknown error";

                if (success) {
                  setState(() {
                    totalUpdated++;
                  });
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                if (!mounted) return;

                // if (result.contains("Success")) {
                //   setState(() {
                //     totalUpdated++;
                //   });
                // }

                // ScaffoldMessenger.of(
                //   this.context,
                // ).showSnackBar(SnackBar(content: Text(result)));
              },
            ),
          ],
        );
      },
    );
  }
}
