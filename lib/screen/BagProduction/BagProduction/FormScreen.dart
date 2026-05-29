import 'package:flutter/material.dart';

import '../../../Color/Colorclass.dart';
import '../../../services/getSupervisors/getSupervisors.dart';
import 'BagItemModelClass.dart';

class FormScreen extends StatefulWidget {
  final String customerName;
  final String generatedInquiry;
  final String articleNo;
  final int quantity;
  final String poNum;
  final int requiredBag;
  final String bagType;
  final String bagSize;
  final int bagWeight;

  const FormScreen({
    Key? key,
    required this.customerName,
    required this.generatedInquiry,
    required this.articleNo,
    required this.quantity,
    required this.poNum,
    required this.requiredBag,
    required this.bagType, // ✅
    required this.bagSize, // ✅
    required this.bagWeight,
  }) : super(key: key);

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final InStockService _service = InStockService();
  bool _isSrLoading = true;
  List<BagItem> _items = [];

  // Controllers
  late TextEditingController _srNoController;
  late TextEditingController _partyNameController;
  late TextEditingController _bomNoController;
  late TextEditingController _articleNoController;
  late TextEditingController _poNumberController;
  late TextEditingController _bagTypeController;
  late TextEditingController _bagSizeController;
  late TextEditingController _bagWtController;
  late TextEditingController _bagQtyController;
  late TextEditingController _contractorController;
  late TextEditingController _remarkController;
  late TextEditingController _requiredBagController;
  late TextEditingController _printStatusController;

  DateTime _selectedDate = DateTime.now();
  String? _printStatus;
  // String _supervisorName = 'SELECT SUPERVISOR';
  String? _lineNo;
  String? _shift;
  String? _supervisorName;
  final List<String> _lineNumbers = List.generate(
    10,
    (index) => (index + 1).toString(),
  );
  // List<String> _supervisors = ['SELECT SUPERVISOR'];
  List<String> _supervisors = [];
  List<Map<String, dynamic>> itemsList = [];


  @override
  void initState() {
    super.initState();

    _srNoController = TextEditingController();
    _partyNameController = TextEditingController(text: widget.customerName);
    _bomNoController = TextEditingController(text: widget.generatedInquiry);
    _articleNoController = TextEditingController(text: widget.articleNo);
    _poNumberController = TextEditingController(text: widget.poNum);
    _printStatusController = TextEditingController();
    _bagTypeController = TextEditingController(text: widget.bagType);
    _bagSizeController = TextEditingController(text: widget.bagSize);
    _bagWtController = TextEditingController(text: widget.bagWeight.toString());

    _bagQtyController = TextEditingController(
      text: widget.requiredBag.toString(),
    );
    _contractorController = TextEditingController();
    _remarkController = TextEditingController();
    _requiredBagController = TextEditingController(
      text: widget.requiredBag.toString(),
    );

    _loadNextSrNo(); // 👈 API call
    _loadProductDetails();
    _loadSupervisors();
  }

  Future<void> _loadNextSrNo() async {
    final nextId = await _service.getNextBagEntryId();
    debugPrint("NEXT ID UI SET: $nextId");
    if (!mounted) return;

    setState(() {
      _srNoController.text = nextId?.toString() ?? '';
      _isSrLoading = false;
    });
  }

  Future<void> _loadSupervisors() async {
    final list = await _service.getSupervisorsList();

    if (!mounted) return;

    setState(() {
      _supervisors = list;
      // RESET value if list is empty or value not found
      if (_supervisors.isEmpty || !_supervisors.contains(_supervisorName)) {
        _supervisorName = null;
      }
    });
  }

  Future<void> _loadProductDetails() async {
    final data = await _service.getProductDetails(
      partyName: widget.customerName,
      articleNo: widget.articleNo,
      generatedInquiry: widget.generatedInquiry,
    );

    if (!mounted || data == null) return;

    setState(() {
      // _printStatus = data['printStatus'] ?? _printStatus;
      _printStatusController.text = data['printStatus'] ?? '';
      _bagTypeController.text = data['bagType'] ?? '';
      _bagSizeController.text = data['bagSize'] ?? '';
      _bagWtController.text = data['bagWeight'] ?? '';
      _bagQtyController.text = data['bagQty'] ?? '';
    });
  }


  void addItem() {
    if (_bagTypeController.text.isEmpty ||
        _bagSizeController.text.isEmpty ||
        _bagQtyController.text.isEmpty ||
        _bagWtController.text.isEmpty ||
        _shift == null ||
        _lineNo == null ||
        _supervisorName == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all required item fields")),
      );
      return;
    }

    final item = BagItem(
      bagType: _bagTypeController.text,
      bagSize: _bagSizeController.text,
      bagQty: int.parse(_bagQtyController.text),
      bagWeight: int.parse(_bagWtController.text),
      shift: _shift!,

    );

    setState(() {
      _items.add(item);

      itemsList.add({
        "contractor": _contractorController.text.trim().isEmpty
            ? "N/A"
            : _contractorController.text.trim(),

        "remark": _remarkController.text.trim().isEmpty
            ? "N/A"
            : _remarkController.text.trim(),
        "shift": _shift!,
        "bagQty": item.bagQty,
        "lineNo": _lineNo!,
        "supervisorName": _supervisorName!,
        "operatorName": "string",
        "tableQuantity": int.tryParse(_requiredBagController.text) ?? widget.requiredBag,
      });
    });
    // debugPrint("FINAL ITEMS COUNT: ${itemsList.length}");
    // debugPrint("FINAL ITEMS DATA: $itemsList");
    // debugPrint("ITEMS LIST AFTER ADD: $itemsList");

    // ✅ Reset for next entry
    _contractorController.clear();
    _remarkController.clear();
    _shift = null;
    _lineNo = null;
    _supervisorName = null;
  }

  // void _saveEntry() async {
  //   // debugPrint("REQUIRED BAG CONTROLLER: '${_requiredBagController.text}'");
  //   // debugPrint("WIDGET REQUIRED BAG: ${widget.requiredBag}");
  //   if (!_formKey.currentState!.validate()) return;
  //   // debugPrint("SAVING tableQuantity: ${_requiredBagController.text}");
  //   //
  //   // debugPrint("ITEM COUNT: ${_items.length}");
  //   // final response = await _service.saveBagProductionEntry(
  //   //   srNo: int.parse(_srNoController.text),
  //   //   date: _selectedDate,
  //   //   partyName: _partyNameController.text,
  //   //   bomNo: _bomNoController.text,
  //   //   articleNo: _articleNoController.text,
  //   //   poNumber: _poNumberController.text,
  //   //   printStatus: _printStatusController.text,
  //   //   bagSize: _bagSizeController.text,
  //   //   contractor: _contractorController.text,
  //   //   remark: _remarkController.text,
  //   //   bagType: _bagTypeController.text,
  //   //   bagWeight: int.parse(_bagWtController.text),
  //   //   shift: _shift!,
  //   //   bagQty: int.parse(_bagQtyController.text),
  //   //   lineNo: _lineNo!,
  //   //   supervisorName: _supervisorName!,
  //   //   // tableQuantity: int.parse(_requiredBagController.text), // ✅ NEW
  //   //   tableQuantity:
  //   //       int.tryParse(_requiredBagController.text) ?? widget.requiredBag,
  //   //   operatorName: "string", // future use
  //   // );
  //
  //
  //
  //
  //
  //   final response = await _service.saveBagProductionEntry(
  //     srNo: int.parse(_srNoController.text),
  //     date: _selectedDate,
  //     partyName: _partyNameController.text,
  //     bomNo: _bomNoController.text,
  //     articleNo: _articleNoController.text,
  //     poNumber: _poNumberController.text,
  //     printStatus: _printStatusController.text,
  //     bagSize: _bagSizeController.text,
  //     bagType: _bagTypeController.text,
  //     bagWeight: int.parse(_bagWtController.text),
  //     items: itemsList,
  //     // ✅ NEW: items list
  //     // items: [
  //     //   {
  //     //     "contractor": _contractorController.text,
  //     //     "remark": _remarkController.text,
  //     //     "shift": _shift ?? "",
  //     //     "bagQty": int.tryParse(_bagQtyController.text) ?? 0,
  //     //     "lineNo": _lineNo ?? "",
  //     //     "supervisorName": _supervisorName ?? "",
  //     //     "operatorName": "string",
  //     //     "tableQuantity":
  //     //     int.tryParse(_requiredBagController.text) ?? widget.requiredBag,
  //     //   }
  //     // ],
  //   );
  //   // debugPrint("TABLE QTY SAVE: ${_requiredBagController.text}");
  //   if (response != null && response['success'] == true) {
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         padding: EdgeInsets.all(20),
  //         content: Text(response['message']),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //
  //     Navigator.pop(context);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Failed to save entry'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }
  void _saveEntry() async {
    // ✅ Validate form first
    // if (!_formKey.currentState!.validate()) return;

    // ✅ VERY IMPORTANT: check items list
    if (itemsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add at least one item"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      debugPrint("FINAL ITEMS LIST: $itemsList");

      final response = await _service.saveBagProductionEntry(
        srNo: int.tryParse(_srNoController.text) ?? 0,
        date: _selectedDate,
        partyName: _partyNameController.text,
        bomNo: _bomNoController.text,
        articleNo: _articleNoController.text,
        poNumber: _poNumberController.text,
        printStatus: _printStatusController.text,
        bagSize: _bagSizeController.text,
        bagType: _bagTypeController.text,
        bagWeight: int.tryParse(_bagWtController.text) ?? 0,
        items: itemsList,
      );

      debugPrint("API RESPONSE: $response");

      // ✅ Handle success
      if (response != null && response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? "Saved successfully"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } else {
        // ✅ Handle API failure response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?['message'] ?? "Failed to save entry"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // ✅ Handle exception (network / parsing etc.)
      debugPrint("SAVE ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _srNoController.dispose();
    _partyNameController.dispose();
    _bomNoController.dispose();
    _articleNoController.dispose();
    _poNumberController.dispose();
    _bagTypeController.dispose();
    _bagSizeController.dispose();
    _bagWtController.dispose();
    _bagQtyController.dispose();
    _contractorController.dispose();
    _remarkController.dispose();
    _requiredBagController.dispose(); // ✅ Yeh missing tha
    _printStatusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        title: const Text(
          'BAG ENTRY FORM',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: addItem)],
        backgroundColor: C.primary,
        foregroundColor: C.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: C.bg),

      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BASIC INFORMATION Section
              _buildSectionTitle('BASIC INFORMATION'),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'SR. NO.',
                      controller: _srNoController,
                      required: true,
                      readOnly: true,
                      suffix: _isSrLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(color: C.appBar3,strokeWidth: 2),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDateField()),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'PARTY NAME',
                      controller: _partyNameController,
                      required: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'BOM NO.',
                      controller: _bomNoController,
                      required: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildTextField(
                label: 'ARTICLE NO',
                controller: _articleNoController,
                required: true,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'PO NUMBER',
                      controller: _poNumberController,
                      required: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'PRINT STATUS',
                      controller: _printStatusController,
                      readOnly: true,
                      required: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildTextField(
                label: 'BAG TYPE',
                controller: _bagTypeController,
                required: true,
              ),

              const SizedBox(height: 24),

              // BAG DETAILS Section
              // BAG DETAILS Section
              _buildSectionTitle('BAG DETAILS'),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'BAG SIZE',
                      controller: _bagSizeController,
                      required: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      label: 'BAG WT (GM)',
                      controller: _bagWtController,
                      keyboardType: TextInputType.number,
                      required: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildTextField(
                label: 'BAG QTY (IN PCS)',
                controller: _bagQtyController,
                keyboardType: TextInputType.number,
                required: true,
              ),

              const SizedBox(height: 12),

              _buildTextField(
                label: 'REQUIRED BAG',
                controller: _requiredBagController,
                keyboardType: TextInputType.number,
                // readOnly: true,
              ),
              const SizedBox(height: 12),
              // PRODUCTION DETAILS Section
              _buildSectionTitle('PRODUCTION DETAILS'),
              const SizedBox(height: 12),

              _buildTextField(
                label: 'CONTRACTOR',
                controller: _contractorController,
                // required: true,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildDropdownField(
                      label: 'SUPERVISOR NAME',
                      value: _supervisorName,
                      hint: _supervisors.isEmpty
                          ? 'No supervisors available'
                          : 'Select Supervisor',
                      items: _supervisors,
                      onChanged: _supervisors.isEmpty
                          ? null
                          : (value) {
                              setState(() {
                                _supervisorName = value;
                              });
                            },
                      required: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: _buildDropdownField(
                      label: 'LINE NO',
                      value: _lineNo,
                      hint: 'Select Line',
                      items: _lineNumbers,
                      onChanged: (value) {
                        setState(() {
                          _lineNo = value!;
                        });
                      },
                      required: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildDropdownField(
                label: 'SHIFT',
                value: _shift,
                hint: 'SELECT SHIFT',
                items: ['A', 'B'],
                onChanged: (value) {
                  setState(() {
                    _shift = value!;
                  });
                },
                required: true,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                label: 'REMARK',
                controller: _remarkController,
                maxLines: 4,
                hint: 'Any additional remarks...',
              ),

              const SizedBox(height: 32),
              const SizedBox(height: 20),
              _buildSectionTitle('ADDED ITEMS'),
              const SizedBox(height: 10),

              _items.isEmpty
                  ? const Text("No items added")
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          child: ListTile(
                            title: Text(item.bagType),
                            subtitle: Text(
                              "Size: ${item.bagSize} | Qty: ${item.bagQty} | Wt: ${item.bagWeight}",
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _items.removeAt(index);
                                  itemsList.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF546E7A),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        // side: const BorderSide(color: Color(0xFF546E7A)),
                      ),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _items.isEmpty
                          ? null
                          : _saveEntry, // ✅ key change
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'SAVE ENTRY',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF546E7A), width: 2)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF546E7A),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hint,
    bool required = false,
    bool readOnly = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF546E7A),
            ),
            children: [
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            suffixIcon: suffix,
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF546E7A), width: 2),
            ),
          ),
          validator: required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    Function(String?)? onChanged, // ✅ nullable
    String? hint,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF546E7A),
            ),
            children: [
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : null, // ✅ safe
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
          hint: Text(hint ?? ''),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged, // ✅ now allowed to be null
          validator: required
              ? (val) {
                  if (val == null) {
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
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF546E7A),
          ),
        ),
        const SizedBox(height: 6),
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
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF546E7A),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              setState(() {
                _selectedDate = date;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.year}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Color(0xFF546E7A),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
