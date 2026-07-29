import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../Color/Colorclass.dart';
import '../../services/getSupervisors/getSupervisors.dart';
import 'OutStockList.dart';

class BarcodeEntryScreen extends StatefulWidget {
  const BarcodeEntryScreen({super.key});

  @override
  State<BarcodeEntryScreen> createState() => _BarcodeEntryScreenState();
}

class _BarcodeEntryScreenState extends State<BarcodeEntryScreen> {
  String? selectedSupervisor;
  String? selectedOperator;
  String? selectedDept;
  bool isSaved = false;
  Map<String, dynamic>? barcodeData;
  bool isBarcodeLoading = false;

  final TextEditingController fabricController = TextEditingController();
  final TextEditingController issueQtyController = TextEditingController();
  List<String> supervisors = [];
  List<String> operators = [];
  final List<String> departments = ['LOOM', 'NEEDLE LOOM'];
  bool isChecked = false;
  bool isLoading = true;
  bool isSaving = false;

  final InStockService api = InStockService();

  @override
  void initState() {
    super.initState();
    fetchOperatorSupervisor();
  }

  String get currentDate {
    final now = DateTime.now();
    return "${now.day}-${now.month}-${now.year}";
  }

  String get currentTime {
    final now = DateTime.now();
    return "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
  }

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

  Future<void> fetchBarcodeData(String code) async {
    if (code.trim().isEmpty) return;

    try {
      setState(() {
        isBarcodeLoading = true;
        barcodeData = null;
        isChecked = false;
        issueQtyController.clear();
      });

      final data = await api.getBarcodeDetails(code);

      setState(() {
        barcodeData = data;
        isBarcodeLoading = false;
      });
    } catch (e) {
      setState(() => isBarcodeLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Barcode not found"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
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

  Future<void> _saveOutstock() async {
    if (isSaving || isSaved) return;

    setState(() {
      isSaving = true;
    });
    try {
      double currentBalance =
          double.tryParse(barcodeData?['balance']?.toString() ?? "0") ?? 0;

      double existingIssueQty =
          double.tryParse(barcodeData?['issuekg']?.toString() ?? "0") ?? 0;

      double issueQty =
          double.tryParse(
            issueQtyController.text.isEmpty ? "0" : issueQtyController.text,
          ) ??
          0;
      double newBalance = currentBalance - issueQty;

      final response = await InStockService().saveOutstock(
        date: currentDate,
        time: currentTime,
        supervisor: selectedSupervisor ?? "",
        operator: selectedOperator ?? "",
        dept: selectedDept ?? "",

        item: {
          "id": barcodeData?['id'] ?? 0,
          "balanceQty": currentBalance,
          "issueQty": issueQty,
          "existingIssueQty": existingIssueQty,
          "statuS_ISSUE": isChecked ? "True" : "False",
        },
      );

      bool status = response['status'] ?? false;
      String message = response['message'] ?? "Something went wrong";

      if (!mounted) return;
      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: status ? Colors.green.shade600 : Colors.red.shade600,
          duration: const Duration(seconds: 1),
        ),
      );

      if (status) {
        setState(() {
          isSaved = true;
        });

        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;

        Get.offAll(() => const TapelineOutStockScreen());
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("API Error"),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final horizontalPad = isMobile ? 16.0 : (width < 1000 ? 32.0 : 100.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text(
          "Out Stock Issue",
          style: TextStyle(color: C.bg, fontWeight: FontWeight.w600),
        ),
        backgroundColor: C.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: C.bg),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPad,
                16,
                horizontalPad,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionCard(
                    children: [
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
                          const SizedBox(width: 12),
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
                      const SizedBox(height: 14),
                      _dropdown(
                        "Issue Department",
                        selectedDept,
                        departments,
                        (v) => setState(() => selectedDept = v),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _infoChip(
                              Icons.calendar_today,
                              "Date",
                              currentDate,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _infoChip(
                              Icons.access_time,
                              "Time",
                              currentTime,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _sectionCard(
                    children: [
                      TextField(
                        controller: fabricController,
                        onSubmitted: fetchBarcodeData,
                        decoration: InputDecoration(
                          hintText: "Enter or scan fabric code",
                          prefixIcon: const Icon(
                            Icons.qr_code,
                            color: C.success,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () =>
                                fetchBarcodeData(fabricController.text),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      if (isBarcodeLoading) ...[
                        const SizedBox(height: 16),
                        const Center(child: CircularProgressIndicator()),
                      ],
                    ],
                  ),

                  if (barcodeData != null) ...[
                    const SizedBox(height: 16),
                    _itemDetailCard(isMobile),
                  ],

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (isChecked && !isSaving && !isSaved)
                          ? _saveOutstock
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isChecked
                            ? C.primaryDark
                            : Colors.grey.shade300,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: isChecked ? 2 : 0,
                      ),
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "Save",
                              style: TextStyle(
                                color: isChecked ? C.bg : Colors.grey.shade500,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ── Reusable elegant section card wrapper ──
  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [...children],
      ),
    );
  }

  // ── Item detail — clean elegant row-table format ──
  Widget _itemDetailCard(bool isMobile) {
    final balance = _calculateBalance();
    final code = barcodeData!['code']?.toString() ?? '';
    final issuedKg =
        (barcodeData?['issuekg'] != null &&
            barcodeData!['issuekg'].toString().isNotEmpty)
        ? barcodeData!['issuekg'].toString()
        : '0';

    return _sectionCard(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              horizontalMargin: 14,
              headingRowHeight: 42,
              dataRowMinHeight: 56,
              dataRowMaxHeight: 64,
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F3F5)),
              headingTextStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: Colors.grey.shade700,
                letterSpacing: .3,
              ),
              dataTextStyle: const TextStyle(
                fontSize: 13.5,
                color: Colors.black87,
              ),
              dividerThickness: 0.6,
              columns: const [
                DataColumn(label: Text("CODE")),
                DataColumn(label: Text("BALANCE")),
                DataColumn(label: Text("ISSUE QTY")),
                DataColumn(label: Text("ISSUED QTY")),
                DataColumn(label: Text("STATUS")),
              ],
              rows: [
                DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 130,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.qr_code_2,
                              size: 15,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                code,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        balance.toStringAsFixed(2),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: balance < 0 ? Colors.red.shade600 : C.primary,
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: issueQtyController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) {},
                          decoration: InputDecoration(
                            hintText: "Qty",
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        issuedKg,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataCell(
                      Checkbox(
                        value: isChecked,
                        activeColor: Colors.green.shade600,
                        onChanged: (val) =>
                            setState(() => isChecked = val ?? false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdown(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: C.primaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        DropdownButtonFormField<String>(
          initialValue: items.contains(value) ? value : null,
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: TextStyle(color: C.textHigh, fontSize: 15),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8F9FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoChip(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: C.primaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 15, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                  color: C.primaryDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
