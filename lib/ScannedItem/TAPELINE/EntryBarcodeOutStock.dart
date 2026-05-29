import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Color/Colorclass.dart';
import '../../services/getSupervisors/getSupervisors.dart';

class BarcodeEntryScreen extends StatefulWidget {
  const BarcodeEntryScreen({super.key});

  @override
  State<BarcodeEntryScreen> createState() => _BarcodeEntryScreenState();
}

class _BarcodeEntryScreenState extends State<BarcodeEntryScreen> {
  String? selectedSupervisor;
  String? selectedOperator;
  String? selectedDept;

  Map<String, dynamic>? barcodeData;
  bool isBarcodeLoading = false;

  final TextEditingController fabricController = TextEditingController();
  final TextEditingController issueQtyController = TextEditingController();
  List<String> supervisors = [];
  List<String> operators = [];
  final List<String> departments = ['LOOM', 'NEEDLE LOOM'];
  bool isChecked = false;
  bool isLoading = true;

  final InStockService api = InStockService();

  @override
  void initState() {
    super.initState();
    fetchOperatorSupervisor();
  }

  // ✅ DATE
  String get currentDate {
    final now = DateTime.now();
    return "${now.day}-${now.month}-${now.year}";
  }

  // ✅ TIME
  String get currentTime {
    final now = DateTime.now();
    return "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
  }

  // ✅ FETCH SUPERVISOR + OPERATOR
  Future<void> fetchOperatorSupervisor() async {
    try {
      final data = await api.getOperatorSupervisor();

      setState(() {
        supervisors = List<String>.from(data['supervisors'] ?? []);
        operators = List<String>.from(data['operators'] ?? []);
        selectedSupervisor = supervisors.isNotEmpty ? supervisors.first : null;
        selectedOperator = operators.isNotEmpty ? operators.first : null;

        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  // ✅ FETCH BARCODE
  Future<void> fetchBarcodeData(String code) async {
    try {
      setState(() {
        isBarcodeLoading = true;
        barcodeData = null;
      });

      final data = await api.getBarcodeDetails(code);

      setState(() {
        barcodeData = data;
        isBarcodeLoading = false;
      });
    } catch (e) {
      setState(() => isBarcodeLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Barcode not found")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        title: const Text("Out Stock Issue",style: TextStyle(color: C.bg),),
        backgroundColor: C.primary,
        iconTheme: IconThemeData(color: C.bg),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(width * 0.04),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black.withOpacity(0.05),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    /// 🔹 Supervisor + Operator
                    Row(
                      children: [
                        Expanded(
                          child: _dropdown(
                            "Supervisor",
                            selectedSupervisor,
                            supervisors,
                            (v) => setState(() => selectedSupervisor = v),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _dropdown(
                            "Operator",
                            selectedOperator,
                            operators,
                            (v) => setState(() => selectedOperator = v),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    /// 🔹 Date + Time
                    Row(
                      children: [
                        Expanded(child: _infoBox("Date", currentDate)),
                        const SizedBox(width: 10),
                        Expanded(child: _infoBox("Time", currentTime)),
                      ],
                    ),

                    const SizedBox(height: 12),

                    /// 🔹 Department
                    _dropdown(
                      "Issue Department",
                      selectedDept,
                      departments,
                      (v) => setState(() => selectedDept = v),
                    ),

                    const SizedBox(height: 12),

                    /// 🔹 Fabric Code
                    TextField(
                      controller: fabricController,
                      onSubmitted: fetchBarcodeData,
                      decoration: InputDecoration(
                        hintText: "Enter Fabric Code",
                        prefixIcon: const Icon(Icons.qr_code),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () =>
                              fetchBarcodeData(fabricController.text),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// 🔹 Barcode Loader
                    if (isBarcodeLoading) const CircularProgressIndicator(),

                    /// 🔹 Barcode Data UI
                    if (barcodeData != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 10,
                              headingRowColor: MaterialStateProperty.all(
                                Colors.grey.shade100,
                              ),
                              columns: const [
                                DataColumn(label: Text("Code")),
                                DataColumn(label: Text("Balance")),
                                DataColumn(label: Text("Issue Qty")),
                                DataColumn(label: Text("Issue KG")),
                                DataColumn(label: Text("Status")),
                              ],
                              rows: [
                                DataRow(
                                  cells: [
                                    DataCell(
                                      SizedBox(
                                        width: 180,
                                        child: Text(
                                          barcodeData!['code']?.toString() ??
                                              '',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),

                                    // 🔹 BALANCE (UPDATED LIVE)
                                    DataCell(
                                      Text(
                                        _calculateBalance().toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    // 🔹 ISSUE QTY INPUT
                                    DataCell(
                                      SizedBox(
                                        width: 70,
                                        child: TextField(
                                          controller: issueQtyController,
                                          keyboardType: TextInputType.number,
                                          onChanged: (_) => setState(() {}),
                                          decoration: const InputDecoration(
                                            hintText: "Qty",
                                            isDense: true,
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // 🔹 ISSUE KG (same as issue qty after save)
                                    DataCell(
                                      Text(
                                        (barcodeData?['issuekg'] != null &&
                                            barcodeData!['issuekg'].toString().isNotEmpty)
                                            ? barcodeData!['issuekg'].toString()
                                            : "0",
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                    ),

                                    // 🔹 STATUS
                                    DataCell(
                                      Checkbox(
                                        value: isChecked,
                                        onChanged: (val) {
                                          setState(() {
                                            isChecked = val ?? false;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 20),

                    /// 🔹 SAVE BUTTON
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 8),
                      child: ElevatedButton(
                        onPressed: isChecked
                            ? () async {
                          try {
                            double issueQty =
                                double.tryParse(issueQtyController.text.isEmpty
                                    ? "0"
                                    : issueQtyController.text) ??
                                    0;

                            final response = await InStockService().saveOutstock(
                              date: currentDate,
                              time: currentTime,
                              supervisor: selectedSupervisor ?? "",
                              operator: selectedOperator ?? "",
                              dept: selectedDept ?? "",
                              item: {
                                "id": barcodeData?['id'] ?? 0,
                                "balanceQty": _calculateBalance(),
                                "issueQty": issueQty,
                                "existingIssueQty":
                                double.tryParse(barcodeData?['issueqty'].toString() ?? "0") ?? 0,
                                "statuS_ISSUE": isChecked ? "True" : "False",
                              },
                            );

                            bool status = response['status'] ?? false;
                            String message =
                                response['message'] ?? "Something went wrong";

                            // 🔥 SNACKBAR
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                                backgroundColor: status ? Colors.green : Colors.red,
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );

                            // ✅ REFRESH AFTER SUCCESS
                            if (status) {
                              _refreshScreen();
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("API Error"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                            : null, // 🚫 disabled when unchecked
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isChecked ? C.warning : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Save", style: TextStyle(color: C.bg)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// 🔹 Dropdown (FIXED)
  Widget _dropdown(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : null, // ✅ FIXED
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
          ),
        ),
      ],
    );
  }

  /// 🔹 Info Box
  Widget _infoBox(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(value),
        ),
      ],
    );
  }

  double _calculateBalance() {
    double balance =
        double.tryParse(barcodeData?['balance'].toString() ?? "0") ?? 0;

    double issue =
        double.tryParse(
          issueQtyController.text.isEmpty ? "0" : issueQtyController.text,
        ) ??
        0;

    return balance - issue;
  }

  void _refreshScreen() {
    setState(() {
      fabricController.clear();
      issueQtyController.clear();
      barcodeData = null;
      isChecked = false;
    });

    fetchOperatorSupervisor(); // reload dropdowns
  }
}
