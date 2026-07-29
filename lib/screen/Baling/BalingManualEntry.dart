import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../Color/Colorclass.dart';
import '../../services/getSupervisors/getSupervisors.dart';
import 'BaleEntryModle/BaleEntryModle.dart';
import 'BaleEntryModle/BaleEntryROwModle.dart';

class BaleEntryManualForm extends StatefulWidget {
  const BaleEntryManualForm({Key? key}) : super(key: key);

  @override
  State<BaleEntryManualForm> createState() => _BaleEntryManualFormState();
}

class _BaleEntryManualFormState extends State<BaleEntryManualForm> {
  final _formKey = GlobalKey<FormState>();
  late InStockService _service;
  bool _isSrLoading = true;
  List<Map<String, dynamic>> _baleItems = [];

  // Controllers
  late TextEditingController _srNoController;
  late TextEditingController _partyNameController;
  late TextEditingController _submittedByController;

  late TextEditingController _poNumberController;

  final TextEditingController _bagTypeController = TextEditingController();
  final TextEditingController _printStatusController = TextEditingController();
  final TextEditingController _bagSizeController = TextEditingController();
  final TextEditingController _baleQTyController = TextEditingController();
  final TextEditingController _bomNoController = TextEditingController();
  late TextEditingController _supervisorController;
  late TextEditingController _checkedByController;
  // Product Details
  late TextEditingController _articleNoController;

  late TextEditingController _baleGwtController;
  late TextEditingController _baleNwtController;
  late TextEditingController _remarkController;

  // Bag Details
  late TextEditingController _tareWtController;
  late TextEditingController _bagWtController;
  late TextEditingController _baleNoController;

  // Additional Information
  late TextEditingController _palletSizeController;

  // Bag summary — now plain user-entered fields instead of values
  // passed in from a previous screen.
  late TextEditingController _requiredBagController;
  late TextEditingController _availableBagController;

  DateTime _selectedDate = DateTime.now();
  String? _selectedShift;
  bool _withoutM = false;

  final List<String> _shifts = ['Select shift', 'A', 'B'];


  @override
  void initState() {
    super.initState();
    _service = InStockService();
    _initializeControllers();

    // NWT / Bag Wt are still auto-computed from what the user types into
    // GWT / Tare / Qty — that's arithmetic on the user's own input, not
    // data pulled from an API, so it stays.
    _baleGwtController.addListener(_calculateWeights);
    _tareWtController.addListener(_calculateWeights);
    _baleQTyController.addListener(_calculateWeights);

    _fetchNextSerialNumber();

  }

  void _addItem() {
    if (_baleGwtController.text.isEmpty ||
        _tareWtController.text.isEmpty ||
        _baleQTyController.text.isEmpty ||
        _baleNoController.text.isEmpty) {
      _showPopup("Fill all Bale details before adding", isError: true);
      return;
    }
    String palletSize = _palletSizeController.text.trim().replaceAll(RegExp(r'[xX]'), '*');

    final item = {
      "baleGwt": double.tryParse(_baleGwtController.text) ?? 0,
      "tareWt": double.tryParse(_tareWtController.text) ?? 0,
      "baleQty": int.tryParse(_baleQTyController.text) ?? 0,
      "baleQtyPcs": _baleQTyController.text,
      "baleNwt": double.tryParse(_baleNwtController.text) ?? 0,
      "bagWt": double.tryParse(_bagWtController.text) ?? 0,
      "baleNo": _baleNoController.text.trim(),
      "activeOut": palletSize,
    };

    setState(() {
      _baleItems.add(Map<String, dynamic>.from(item));
    });
    debugPrint("========== ADDED ITEM ==========");
    debugPrint(jsonEncode(item));
    debugPrint("========== ALL ITEMS ==========");
    debugPrint(jsonEncode(_baleItems));
    _showPopup("Item Added ✅");
  }

  void _calculateWeights() {
    final double gwt = double.tryParse(_baleGwtController.text) ?? 0.0;
    final double tare = double.tryParse(_tareWtController.text) ?? 0.0;
    final int qty = int.tryParse(_baleQTyController.text) ?? 0;

    // BALE NWT = GWT - TARE
    final double nwt = gwt - tare;
    _baleNwtController.text = nwt > 0 ? nwt.toStringAsFixed(2) : '0';

    // BAG WT = NWT / QTY
    final double bagWt = (qty > 0 && nwt > 0) ? (nwt / qty) : 0;
    _bagWtController.text = bagWt > 0 ? bagWt.toStringAsFixed(2) : '0';
  }

  @override
  void dispose() {
    _supervisorController.dispose();
    _checkedByController.dispose();
    _srNoController.dispose();
    _partyNameController.dispose();
    _submittedByController.dispose();
    _poNumberController.dispose();
    _bagTypeController.dispose();
    _printStatusController.dispose();
    _bagSizeController.dispose();
    _baleQTyController.dispose();
    _bomNoController.dispose();
    _articleNoController.dispose();
    _baleGwtController.dispose();
    _baleNwtController.dispose();
    _remarkController.dispose();
    _tareWtController.dispose();
    _bagWtController.dispose();
    _baleNoController.dispose();
    _palletSizeController.dispose();
    _requiredBagController.dispose();
    _availableBagController.dispose();
    super.dispose();
  }

  Future<void> _fetchNextSerialNumber() async {
    try {
      final srNo = await _service.fetchNextBaleSerialNumber();

      setState(() {
        _srNoController.text = srNo.toString();
        _isSrLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching serial number: $e');

      setState(() {
        _isSrLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load serial number'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearFormFields() {
    _tareWtController.clear();
    _baleQTyController.clear();
    _bagWtController.clear();
    _baleNwtController.clear();
    _baleNoController.clear();
    _palletSizeController.clear();
    _printStatusController.clear();
    _partyNameController.clear();
    _bomNoController.clear();
    _articleNoController.clear();
    _bagTypeController.clear();
    _bagSizeController.clear();
    _baleGwtController.clear();
    _poNumberController.clear();
    _submittedByController.clear();
    _requiredBagController.clear();
    _availableBagController.clear();
    _supervisorController.clear();
    _checkedByController.clear();

    setState(() {
      _selectedShift = null;

      _withoutM = false;
      _baleItems = [];
    });
  }

  void _initializeControllers() {
    _supervisorController = TextEditingController();
    _checkedByController = TextEditingController();
    _srNoController = TextEditingController();
    _partyNameController = TextEditingController();
    _submittedByController = TextEditingController();
    _poNumberController = TextEditingController();
    _articleNoController = TextEditingController();
    _baleGwtController = TextEditingController();
    _baleNwtController = TextEditingController();
    _remarkController = TextEditingController();
    _tareWtController = TextEditingController();
    _bagWtController = TextEditingController();
    _baleNoController = TextEditingController();
    _palletSizeController = TextEditingController();
    _requiredBagController = TextEditingController();
    _availableBagController = TextEditingController();

    _selectedDate = DateTime.now();
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      _showPopup('Please fill all required fields', isError: true);
      return;
    }

    if (_baleItems.isEmpty) {
      _showPopup("Add at least one item", isError: true);
      return;
    }

    final now = DateTime.now();

    /// 🔥 MAIN PAYLOAD
    final payload = {
      "machine": _partyNameController.text.trim(),
      "bomNo": _bomNoController.text.trim(),
      "articleNo": _articleNoController.text.trim(),
      "poNumber": _poNumberController.text.trim().isEmpty ? "N/A" : _poNumberController.text.trim(),
      "date": "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
      "operator": _bomNoController.text.trim(),
      "supervisor": _supervisorController.text.trim(),
      "checkedBy": _checkedByController.text.trim(),
      "submittedBy": _submittedByController.text.trim(),
      "activeIn": double.tryParse(_baleGwtController.text) ?? 0,
      "requiredNewt": double.tryParse(_requiredBagController.text) ?? 0,
      "requiredBag": _requiredBagController.text.trim(),
      "availableBag": _availableBagController.text.trim(),

      /// 🔥 ROWS
      "rows": _baleItems.map((item) {
        return {
          "baleNo": item["baleNo"].toString(),
          "baleQtyPcs": _printStatusController.text,
          "tareWt": item["tareWt"] ?? 0,
          "bagWt": item["bagWt"] ?? 0,
          "total": 0,
          "bagSize": _bagSizeController.text.trim(),
          "typee": _bagTypeController.text.trim(),
          "status": item["baleQty"].toString(),
          "remark": _baleNwtController.text.trim(),
          "partyName": item["bagWt"].toString(),
          "shift": _selectedShift ?? "",
          "activeOut": item["activeOut"].toString(),
        };
      }).toList(),
    };

    debugPrint("🚀 FINAL PAYLOAD:");
    debugPrint(jsonEncode(payload));

    final response = await _service.saveBaleEntry(payload);

    debugPrint("📥 SAVE RESPONSE:");
    debugPrint(response.toString());
    if (!mounted) return;

    if (response != null && response["success"] == true) {
      _showPopup(response["message"] ?? "Saved successfully ✅");

      await _fetchNextSerialNumber();
      Navigator.pop(context, true);
      _clearFormFields();
    } else {
      _showPopup(
        response?["message"] ?? "Failed to save bale entry",
        isError: true,
      );
    }
  }

  void _showPopup(String msg, {bool isError = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: isError ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'BALE ENTRY FORM',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton.icon(
            onPressed: _addItem,
            icon: Icon(Icons.add, color: C.bg),
            label: Text("Add Item", style: TextStyle(color: C.bg)),
          ),
        ],
        backgroundColor: C.primary,
        elevation: 0,
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(_getResponsivePadding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BASIC INFORMATION SECTION
              _buildSectionHeader('BASIC INFORMATION'),
              SizedBox(height: _getResponsiveSpacing(context)),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'SR NO',
                      controller: _srNoController,
                      required: true,
                      inputFormatters: [],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'SUPERVISOR',
                      controller: _supervisorController,
                      required: true,
                      inputFormatters: [],
                    ),
                  ),
                ],
              ),
              SizedBox(height: _getResponsiveSpacing(context)),

              // Required / Available Bag — now manually entered by the user.
              _buildBagSummary(),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'PARTY NAME',
                      controller: _partyNameController,
                      required: true,
                      inputFormatters: [],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'BOM NO.',
                      controller: _bomNoController,
                      required: true,
                      inputFormatters: [],
                    ),
                  ),
                ],
              ),

              SizedBox(height: _getResponsiveSpacing(context)),

              _buildResponsiveRow(
                context,
                children: [
                  _buildTextField(
                    label: 'CHECKED BY',
                    controller: _checkedByController,
                    required: true,
                    inputFormatters: [],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'SUBMITTED BY',
                          controller: _submittedByController,
                          inputFormatters: [],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'PO NUMBER',
                          controller: _poNumberController,
                          inputFormatters: [],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // PRODUCT DETAILS SECTION
              _buildSectionHeader('PRODUCT DETAILS'),
              SizedBox(height: _getResponsiveSpacing(context)),

              _buildResponsiveRow(
                context,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'ARTICLE NO',
                          controller: _articleNoController,
                          required: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'BAG TYPE',
                          controller: _bagTypeController,
                          inputFormatters: [],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'PRINT STATUS',
                      controller: _printStatusController,
                      required: true,
                      inputFormatters: [],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'BAG SIZE (LXWXH)',
                      controller: _bagSizeController,
                      required: true,
                      inputFormatters: [],
                    ),
                  ),
                ],
              ),

              _buildResponsiveRow(
                context,
                children: [
                  _buildTextField(
                    label: 'BALE (GWT)',
                    controller: _baleGwtController,
                    required: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [],
                  ),
                  _buildDateField(),
                ],
              ),

              SizedBox(height: _getResponsiveSpacing(context) * 2),

              // BAG DETAILS SECTION
              _buildSectionHeader('BAG DETAILS'),
              SizedBox(height: _getResponsiveSpacing(context)),

              _buildResponsiveRow(
                context,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'TARE (WT)',
                          controller: _tareWtController,
                          required: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'BAG WT (GM)',
                          controller: _bagWtController,
                          required: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'BALE QTY (PCS)',
                          controller: _baleQTyController,
                          required: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'BALE NWT (GM)',
                          controller: _baleNwtController,
                          required: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [],
                        ),
                      ),
                    ],
                  ),
                  _buildWithoutMCheckbox(),
                ],
              ),

              SizedBox(height: _getResponsiveSpacing(context)),

              _buildTextField(
                label: 'BALE NO',
                hint: 'Bale No.',
                controller: _baleNoController,
                required: true,
                keyboardType: TextInputType.number,
                inputFormatters: [],
              ),

              SizedBox(height: _getResponsiveSpacing(context) * 2),

              // ADDITIONAL INFORMATION SECTION
              _buildSectionHeader('ADDITIONAL INFORMATION'),
              SizedBox(height: _getResponsiveSpacing(context)),

              _buildResponsiveRow(
                context,
                children: [
                  _buildTextField(
                    label: 'PALLET SIZE',
                    controller: _palletSizeController,
                    required: true,
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9xX*]')),
                    ],
                  ),
                  _buildDropdown(
                    label: 'SHIFT',
                    value: _selectedShift,
                    hint: 'Select Shift',
                    items: _shifts,
                    onChanged: (value) => setState(() => _selectedShift = value),
                    required: true,
                    placeholder: 'SELECT SHIFT',
                  ),
                ],
              ),

              SizedBox(height: _getResponsiveSpacing(context) * 2),

              _buildItemsTable(),

              SizedBox(height: _getResponsiveSpacing(context) * 2),

              _buildResponsiveButtons(context),

              SizedBox(height: _getResponsiveSpacing(context)),
            ],
          ),
        ),
      ),
    );
  }

  double _getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 16;
    if (width < 1200) return 24;
    return 32;
  }

  double _getResponsiveSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 12;
    if (width < 1200) return 16;
    return 20;
  }

  double _getResponsiveGap(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 12;
    if (width < 1200) return 16;
    return 16;
  }

  Widget _buildResponsiveRow(BuildContext context, {required List<Widget> children}) {
    final width = MediaQuery.of(context).size.width;
    final gap = _getResponsiveGap(context);

    if (width < 600) {
      return Column(
        children: children
            .map((child) => Padding(padding: EdgeInsets.only(bottom: gap), child: child))
            .toList(),
      );
    }

    return Row(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          Expanded(child: children[i]),
          if (i < children.length - 1) SizedBox(width: gap),
        ],
      ],
    );
  }

  Widget _buildResponsiveButtons(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final gap = _getResponsiveGap(context);

    if (width < 600) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF607D8B),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: const BorderSide(color: Color(0xFF9E9E9E), width: 1.5),
              ),
              child: const Text(
                'CANCEL',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.5),
              ),
            ),
          ),
          SizedBox(height: gap),
          if (_baleItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                "Items Added: ${_baleItems.length}",
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _baleItems.isEmpty ? null : _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _baleItems.isEmpty ? Colors.grey : const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text(
                'SAVE ENTRY',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.5),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF607D8B),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              side: const BorderSide(color: Color(0xFF9E9E9E), width: 1.5),
            ),
            child: const Text(
              'CANCEL',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.5),
            ),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveEntry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text(
              'SAVE ENTRY',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF5F7C8A),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 3,
          width: 60,
          decoration: const BoxDecoration(
            color: Color(0xFF5F7C8A),
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsTable() {
    if (_baleItems.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          "ADDED ITEMS",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF5F7C8A)),
        ),
        const SizedBox(height: 5),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(const Color(0xFFEAF2F5)),
            columns: const [
              DataColumn(label: Text("Bale No")),
              DataColumn(label: Text("GWT")),
              DataColumn(label: Text("Tare")),
              DataColumn(label: Text("NWT")),
              DataColumn(label: Text("Qty")),
              DataColumn(label: Text("Bag WT")),
              DataColumn(label: Text("Pallet")),
              DataColumn(label: Text("Action")),
            ],
            rows: List.generate(_baleItems.length, (index) {
              final item = _baleItems[index];
              return DataRow(
                cells: [
                  DataCell(Text(item["baleNo"].toString())),
                  DataCell(Text(item["baleGwt"].toString())),
                  DataCell(Text(item["tareWt"].toString())),
                  DataCell(Text(item["baleNwt"].toString())),
                  DataCell(Text(item["baleQtyPcs"].toString())),
                  DataCell(Text(item["bagWt"].toString())),
                  DataCell(Text(item["activeOut"]?.toString() ?? "")),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(() => _baleItems.removeAt(index)),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    FocusNode? focusNode,
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hint,
    required List<FilteringTextInputFormatter> inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5F7C8A),
              height: 1.2,
            ),
            children: [
              if (required) const TextSpan(text: ' *', style: TextStyle(color: Color(0xFFE53935))),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enableInteractiveSelection: true,
          focusNode: focusNode,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF212121)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF5F7C8A), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE53935)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
            ),
          ),
          validator: required
              ? (value) {
            if (value == null || value.isEmpty) return 'This field is required';
            return null;
          }
              : null,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
    bool required = false,
    String? placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5F7C8A),
              height: 1.2,
            ),
            children: [
              if (required) const TextSpan(text: ' *', style: TextStyle(color: Color(0xFFE53935))),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          hint: placeholder != null ? Text(placeholder) : null,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF212121)),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF5F7C8A), width: 2),
            ),
          ),
          items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          validator: required
              ? (val) {
            if (val == null || val.isEmpty || val == placeholder || val == items.first) {
              return 'Please select $label';
            }
            return null;
          }
              : null,
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DATE *',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5F7C8A), height: 1.2),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(primary: Color(0xFF5F7C8A)),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) setState(() => _selectedDate = date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}-${_getMonthName(_selectedDate.month)}-${_selectedDate.year}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF212121)),
                  ),
                ),
                Icon(Icons.calendar_today_outlined, size: 20, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWithoutMCheckbox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WITHOUT M',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5F7C8A), height: 1.2),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: _withoutM,
              onChanged: (value) => setState(() => _withoutM = value ?? false),
              activeColor: const Color(0xFF5F7C8A),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 4),
            const Flexible(
              child: Text(
                'CHECK IF WITHOUT M',
                style: TextStyle(fontSize: 13, color: Color(0xFF212121)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  // ── BAG SUMMARY — now two plain input fields, user types both values ──
  Widget _buildBagSummary() {
    final width = MediaQuery.of(context).size.width;

    Widget card({
      required String title,
      required TextEditingController controller,
      required Color color,
    }) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  filled: true,
                  fillColor: color.withOpacity(0.05),
                  hintText: '0',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: color),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: color),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: color, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        card(
          title: "REQUIRED BAG",
          controller: _requiredBagController,
          color: Colors.red.shade400,
        ),
        SizedBox(width: width < 600 ? 12 : 20),
        card(
          title: "AVAILABLE BAG",
          controller: _availableBagController,
          color: Colors.green.shade600,
        ),
      ],
    );
  }
}