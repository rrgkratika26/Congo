import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Color/Colorclass.dart';
import '../../QRScan/QrScanScreen.dart';
import '../../screen/inStock/ReportScreen.dart';
import '../../screen/inStock/inStockController.dart';
import '../../services/getSupervisors/getSupervisors.dart';
import 'FoldingScanScreen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// const String baseUrl = "http://your-api-url.com/api"; // 🔥 change this
const String baseUrl = 'https://190.92.175.47:80/ASIA_API/api';

class FoldingIn extends StatefulWidget {
  const FoldingIn({Key? key}) : super(key: key);

  @override
  State<FoldingIn> createState() => _FoldingInState();
}

class _FoldingInState extends State<FoldingIn> {
  late final size = MediaQuery.of(context).size;
  late final isTablet = size.width > 600;
  late final isSmallScreen = size.width < 360;
  final controller = InStockController();

  String department = 'FOLDING';
  int totalScanned = 0;
  List<String> operators = [];
  List<String> supervisors = [];
  List<String> locations = [];

  String? selectedOperator;
  String? selectedSupervisor;
  String? selectedLocation;

  bool isLoading = true;
  String getApiDate() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  String getCurrentDate() {
    return DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    setState(() => isLoading = true);

    try {
      operators = await fetchList('/Folding/GetOperators');
      supervisors = await fetchList('/Folding/GetSupervisors');
      locations = await fetchList('/Folding/GetLocations');
    } catch (e) {
      debugPrint("API Error: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> _loadData() async {
    await controller.loadInitialData();
    setState(() {});
  }

  // ✅ VALIDATION
  bool _isFormValid() {
    return selectedOperator != null &&
        selectedSupervisor != null &&
        selectedLocation != null;
  }

  void _showValidationSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please fill all required fields'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        title: const Text('Folding IN'),
        backgroundColor: Colors.blue.shade100,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildDropdown(
                label: 'Select Operator',
                value: selectedOperator,
                items: operators,
                onChanged: (v) => setState(() => selectedOperator = v),
                icon: Icons.person,

                isTablet: isTablet,
                isSmallScreen: isSmallScreen,
              ),

              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Select Supervisor',
                value: selectedSupervisor,
                items: supervisors,
                icon: Icons.supervisor_account,
                onChanged: (v) => setState(() => selectedSupervisor = v),
                isTablet: isTablet,
                isSmallScreen: isSmallScreen,
              ),

              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Select Location',
                value: selectedLocation,
                items: locations,
                icon: Icons.location_on,
                onChanged: (v) => setState(() => selectedLocation = v),
                isTablet: isTablet,
                isSmallScreen: isSmallScreen,
              ),

              const SizedBox(height: 20),

              _buildDepartmentCard(),

              // const SizedBox(height: 10),
              // _buildScanningCard(),
              const SizedBox(height: 25),

              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI =================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
    required bool isTablet,
    required bool isSmallScreen,
  }) {
    final uniqueItems = items.toSet().toList(); // ✅ remove duplicates

    return Container(
      decoration: _boxDecoration(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _iconBox(icon),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: _labelStyle(isTablet, isSmallScreen)),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      // value: uniqueItems.contains(value) ? value : null,
                      value: value != null && uniqueItems.contains(value) ? value : null,
                      // ✅ safe value
                      hint: Text(
                        'Select an option',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      isExpanded: true,
                      items: uniqueItems.map((e) {
                        return DropdownMenuItem<String>(
                          value: e,
                          child: Text(
                            e,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: onChanged,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.business, color: Colors.blue),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Department",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                department,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScanningCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReportDetailScreen(date: getApiDate()),
          ),
        );
      },
      child: Center(
        child: Container(
          decoration: _boxDecoration(borderRadius: 20),
          padding: const EdgeInsets.all(24),
          child: FutureBuilder<int>(
            future: InStockService().getScannedItemsCount(getApiDate()),

            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;

              return Column(
                children: [
                  const Text(
                    'Total Items Scanned',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    // snapshot.connectionState == ConnectionState.waiting
                    //     ? '...'
                    //     :
                    '$count',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    getCurrentDate(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            icon: Icons.qr_code_scanner,
            label: "Scan QR",
            color: Colors.blue,
            onTap: _openScanner,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            icon: Icons.edit,
            label: "Manual Entry",
            color: Colors.green,
            onTap: _manualEntry,
          ),
        ),
      ],
    );
  }

  // ================= ACTIONS =================

  Future<void> _openScanner() async {
    // if (!_isFormValid()) {
    //   _showValidationSnackBar();
    //   return;
    // }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QRFoldingScanScreen(
          operatorName: selectedOperator!,
          supervisor: selectedSupervisor!,
          location: selectedLocation!,
        ),
      ),
    );

    setState(() {});
  }

  void _manualEntry() {
    if (!_isFormValid()) {
      _showValidationSnackBar();
      return;
    }

    final TextEditingController barcodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enter Barcode"),
        content: TextField(
          controller: barcodeController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Enter barcode number",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final barcode = barcodeController.text.trim();

              if (barcode.isEmpty) {
                _showSnack("Please enter barcode", false);
                return;
              }

              Navigator.pop(context);

              // 🔥 CALL API
              await _processBarcode(barcode);
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }


  BoxDecoration _boxDecoration({double borderRadius = 12}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.blue),
    );
  }

  TextStyle _labelStyle(bool isTablet, bool isSmallScreen) {
    return TextStyle(
      fontSize: isTablet ? 12 : (isSmallScreen ? 10 : 11),
      color: Colors.grey[600],
      fontWeight: FontWeight.w500,
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: _boxDecoration(borderRadius: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> fetchList(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.get(
        url,
        headers: await InStockService.authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ Case 1: List of Objects [{value: BB, label: BB}]
        if (data is List) {
          return data.map<String>((e) {
            if (e is Map) {
              return e['value']?.toString() ?? ''; // 🔥 ONLY VALUE
            }
            return e.toString();
          }).toList();
        }

        // ✅ Case 2: { data: [...] }
        if (data is Map && data['data'] is List) {
          return (data['data'] as List).map<String>((e) {
            if (e is Map) {
              return e['value']?.toString() ?? '';
            }
            return e.toString();
          }).toList();
        }

        throw Exception("Invalid API format");
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("FETCH ERROR: $e");
      return [];
    }
  }

  Future<void> _processBarcode(String barcode) async {
    final result = await InStockService().checkFoldingBarcodeOut(
      barcode: barcode,
      roll_entry: "FOLDING",
      storage: selectedLocation!,     // ✅ use selected value
      operatorName: selectedOperator!,
      supervisor: selectedSupervisor!,
      department: department,
      unit: "UNIT-1",

    );

    if (!mounted) return;

    if (result == null) {
      _showSnack("Server not responding", false);
      return;
    }

    final status = result['status']?.toString().toLowerCase() ?? '';
    final message = result['message'] ?? 'Unknown response';

    if (status == 'ok') {
      _showSnack(message, true);

      // ✅ Refresh UI / count after success
      setState(() {});

    } else if (status == 'exists') {
      _showSnack(message, false);

    } else {
      _showSnack(message, false);
    }
  }

  void _showSnack(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }


}
