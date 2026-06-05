// import 'dart:convert';
//
// import 'package:flutter/material.dart';
//
// import '../../Color/Colorclass.dart';
// import '../../services/getSupervisors/getSupervisors.dart';
//
// class BaleEntryForm extends StatefulWidget {
//   final String? partyName;
//   final String? articleNo;
//   final String? poNumber;
//   final String? bomNo;
//
//   const BaleEntryForm({
//     Key? key,
//     this.partyName,
//     this.articleNo,
//     this.poNumber,
//     this.bomNo,
//   }) : super(key: key);
//
//   @override
//   State<BaleEntryForm> createState() => _BaleEntryFormState();
// }
//
// class _BaleEntryFormState extends State<BaleEntryForm> {
//   final _formKey = GlobalKey<FormState>();
//   late InStockService _service;
//   int? _nextSrNo;
//   bool _isSrLoading = true;
//   late FocusNode _articleFocusNode;
//   List<Map<String, dynamic>> _baleItems = [];
//
//   // Controllers
//   late TextEditingController _srNoController;
//   late TextEditingController _partyNameController;
//   late TextEditingController _supervisorController;
//   // late TextEditingController _checkedByController;
//   late TextEditingController _submittedByController;
//   late TextEditingController _machineController;
//   late TextEditingController _statusController;
//
//   late TextEditingController _poNumberController;
//
//   final TextEditingController _bagTypeController = TextEditingController();
//   final TextEditingController _totalController = TextEditingController();
//
//   final TextEditingController _printStatusController = TextEditingController();
//   final TextEditingController _bagSizeController = TextEditingController();
//   final TextEditingController _baleQTyController = TextEditingController();
//   final TextEditingController _bomNoController = TextEditingController();
//   // Product Details
//   late TextEditingController _articleNoController;
//   // final TextEditingController baleGwtController = TextEditingController();
//   // final TextEditingController tareWtController = TextEditingController();
//   // final TextEditingController baleQtyController = TextEditingController();
//
//   // final TextEditingController baleNwtController = TextEditingController();
//   // final TextEditingController bagWtController = TextEditingController();
//
//   late TextEditingController _baleGwtController;
//   late TextEditingController _baleNwtController;
//   late TextEditingController _remarkController;
//   late TextEditingController _activeInController;
//   late TextEditingController _activeOutController;
//   late TextEditingController _requiredNewtController;
//
//   // Bag Details
//   late TextEditingController _tareWtController;
//   late TextEditingController _bagWtController;
//   late TextEditingController _baleNoController;
//
//   // Additional Information
//   late TextEditingController _palletSizeController;
//
//   DateTime _selectedDate = DateTime.now();
//   String? _selectedShift;
//   bool _withoutM = false;
//
//   final List<String> _shifts = ['Select shift', 'A', 'B'];
//   String? _selectedSupervisor;
//   String? _selectedCheckedBy;
//   // List<String> _supervisors = ['Select supervisor'];
//
//   List<String> _supervisors = [];
//   List<String> _checkedbylist = [];
//   @override
//   void initState() {
//     super.initState();
//
//     _service = InStockService();
//     _initializeControllers();
//     _baleGwtController.addListener(() {
//       debugPrint("🔥 baleGwtController changed → ${_baleGwtController.text}");
//     });
//
//     _baleGwtController.addListener(_calculateWeights);
//     _baleGwtController.addListener(() {
//       debugPrint("🔥 baleGwtController changed → ${_baleGwtController.text}");
//     });
//
//     _tareWtController.addListener(_calculateWeights);
//     _baleQTyController.addListener(_calculateWeights);
//     _baleNwtController = TextEditingController();
//     _articleFocusNode = FocusNode();
//     _articleFocusNode.addListener(_onArticleUnfocus);
//
//     _fetchNextSerialNumber();
//
//     // Populate fields with data passed from previous screen
//     _populateInitialData();
//     _loadSupervisors();
//     _loadCheckedBy();
//   }
//
//   // void _clearItemFields() {
//   //   _tareWtController.clear();
//   //   _baleQTyController.clear();
//   //   _bagWtController.clear();
//   //   _baleNwtController.clear();
//   //   _baleNoController.clear();
//   //   _palletSizeController.clear();
//   // }
//
//   void _addItem() {
//     if (_baleGwtController.text.isEmpty ||
//         _tareWtController.text.isEmpty ||
//         _baleQTyController.text.isEmpty ||
//         _baleNoController.text.isEmpty) {
//       _showSnack("Fill all Bale details before adding", isError: true);
//       return;
//     }
//
//     final item = {
//       "baleGwt": double.tryParse(_baleGwtController.text) ?? 0,
//       "tareWt": double.tryParse(_tareWtController.text) ?? 0,
//       // "baleQty": int.tryParse(_baleQTyController.text) ?? 0,
//       // "baleQtyPcs": double.tryParse ?? 0,
//       "baleQtyPcs": int.tryParse(_baleQTyController.text) ?? 0, // ✅ snapshot
//       // "baleQtyPcs": int.tryParse(_baleQTyController.text) ?? 0,
//       "baleNwt": double.tryParse(_baleNwtController.text) ?? 0,
//       "bagWt": double.tryParse(_bagWtController.text) ?? 0,
//       "baleNo": _baleNoController.text.trim(),
//       "palletSize": _palletSizeController.text.trim(),
//     };
//
//     setState(() {
//       _baleItems.add(Map<String, dynamic>.from(item)); // ✅ explicit copy
//     });
//
//     _showSnack("Item Added ✅");
//   }
//
//   void _calculateWeights() {
//     final double gwt = double.tryParse(_baleGwtController.text) ?? 0.0;
//     // 807
//
//     final double tare = double.tryParse(_tareWtController.text) ?? 0.0;
//     // 4
//     final int qty = int.tryParse(_baleQTyController.text) ?? 0;
//     debugPrint("⚙️ _calculateWeights triggered");
//     debugPrint("GWT before calc: ${_baleGwtController.text}");
//
//     // BALE NWT = GWT - TARE
//     final double nwt = gwt - tare;
//     // 803
//     _baleNwtController.text = nwt > 0 ? nwt.toStringAsFixed(2) : '0';
//
//     // BAG WT = NWT / QTY
//     final double bagWt = (qty > 0 && nwt > 0) ? (nwt / qty) : 0;
//
//     _bagWtController.text = bagWt > 0 ? bagWt.toStringAsFixed(2) : '0';
//     debugPrint("⚙️ _calculateWeights triggered");
//     debugPrint("GWT before calc: ${_baleGwtController.text}");
//   }
//
//   void _populateInitialData() {
//     if (widget.partyName != null) {
//       _partyNameController.text = widget.partyName!;
//     }
//     if (widget.articleNo != null) {
//       _articleNoController.text = widget.articleNo!;
//       // Trigger product details fetch if both party name and article no are provided
//       if (widget.partyName != null) {
//         _fetchProductDetailsInitial();
//       }
//     }
//     if (widget.poNumber != null) {
//       _poNumberController.text = widget.poNumber!;
//     }
//     if (widget.bomNo != null) {
//       _bomNoController.text = widget.bomNo!;
//     }
//   }
//
//   Future<void> _fetchProductDetailsInitial() async {
//     try {
//       final res = await _service.fetchProductDetails(
//         partyName: widget.partyName!,
//         articleNo: widget.articleNo!,
//         generatedInquiry: widget.bomNo!,
//       );
//       debugPrint("📦 Product API tBAGotal (GWT) → ${res['bagwt']}");
//
//       setState(() {
//         _bagTypeController.text = res['typee']?.toString() ?? '';
//         _printStatusController.text = res['printStatus']?.toString() ?? '';
//         _bagSizeController.text = res['bagSize']?.toString() ?? '';
//         // _baleGwtController.text = res['bagwt']?.toString() ?? '';
//
//         _bagWtController.text = res['bagwt']?.toString() ?? '';
//
//         // Don't override BOM if it was passed from previous screen
//         if (widget.bomNo == null) {
//           _bomNoController.text = res['bomNo']?.toString() ?? '';
//         }
//         debugPrint("📦 Product API total (GWT) → ${res['total']}");
//       });
//     } catch (e) {
//       debugPrint('Product details error: $e');
//     }
//   }
//
//   @override
//   void dispose() {
//     _articleFocusNode.dispose();
//     _baleGwtController.dispose();
//     _tareWtController.dispose();
//     _baleQTyController.dispose();
//     _bagWtController.dispose();
//     _baleNwtController.dispose(); // ✅ ADD THIS
//
//     super.dispose();
//   }
//
//   Future<void> _onArticleUnfocus() async {
//     if (_articleFocusNode.hasFocus) return;
//
//     final partyName = _partyNameController.text.trim();
//     final articleNo = _articleNoController.text.trim();
//     final bomNo = _bomNoController.text.trim();
//
//     if (partyName.isEmpty || articleNo.isEmpty) return;
//
//     try {
//       final res = await _service.fetchProductDetails(
//         partyName: partyName,
//         articleNo: articleNo,
//         generatedInquiry: bomNo,
//       );
//
//       setState(() {
//         _bagTypeController.text = res['typee']?.toString() ?? '';
//         _printStatusController.text = res['printStatus']?.toString() ?? '';
//         _bagSizeController.text = res['bagSize']?.toString() ?? '';
//         _baleGwtController.text = res['total']?.toString() ?? '';
//         _bomNoController.text = res['bomNo']?.toString() ?? '';
//         debugPrint("📦 Product API total (GWT) → ${res['total']}");
//       });
//       debugPrint("📦 Product API total (GWT) → ${res['total']}");
//     } catch (e) {
//       debugPrint('Product details error: $e');
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Product details not found'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
//
//   Future<void> _fetchNextSerialNumber() async {
//     try {
//       final srNo = await _service.fetchNextBaleSerialNumber();
//
//       setState(() {
//         _nextSrNo = srNo;
//         _srNoController.text = srNo.toString();
//         _isSrLoading = false;
//       });
//     } catch (e) {
//       debugPrint('Error fetching serial number: $e');
//
//       setState(() {
//         _isSrLoading = false;
//       });
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Failed to load serial number'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
//
//   void _clearFormFields() {
//     _tareWtController.clear();
//     _baleQTyController.clear();
//     _bagWtController.clear();
//     _baleNwtController.clear();
//     _baleNoController.clear();
//     _palletSizeController.clear();
//     _printStatusController.clear();
//
//     setState(() {
//       _selectedShift = null;
//       _withoutM = false;
//     });
//   }
//
//   void _initializeControllers() {
//     _srNoController = TextEditingController();
//     _partyNameController = TextEditingController();
//     _supervisorController = TextEditingController();
//     // _checkedByController = TextEditingController();
//     _submittedByController = TextEditingController();
//
//     _poNumberController = TextEditingController();
//
//     _articleNoController = TextEditingController();
//
//     _baleGwtController = TextEditingController();
//
//     _tareWtController = TextEditingController();
//     _bagWtController = TextEditingController();
//     _baleNoController = TextEditingController();
//
//     _palletSizeController = TextEditingController();
//
//     _selectedDate = DateTime.now();
//   }
//
//   Future<void> _saveEntry() async {
//     int totalBaleQty = _baleItems.fold(
//       0,
//       (sum, item) => sum + ((item["baleQtyPcs"] ?? 0) as num).toInt(),
//     );
//     if (!_formKey.currentState!.validate()) {
//       _showSnack('Please fill all required fields', isError: true);
//       return;
//     }
//     final now = DateTime.now();
//
//     // final payload = {
//     //   "srNo": _srNoController.text.trim(), // ✅ STRING (important)
//     //   "partyName": _partyNameController.text.trim(),
//     //   "supervisor": _selectedSupervisor?.trim() ?? "",
//     //   "checkedBy": _checkedByController.text.trim(),
//     //   "submittedBy": _submittedByController.text.trim(),
//     //   "bomNo": _bomNoController.text.trim(),
//     //   "articleNo": _articleNoController.text.trim(),
//     //
//     //   // "date": _selectedDate.toIso8601String(),
//     //   "date": now.toIso8601String(),
//     //   "time":
//     //       "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",
//     //   "printStatus": _printStatusController.text.trim(),
//     //   "baleQtyPcs": int.tryParse(_baleQTyController.text) ?? 0,
//     //   "baleNwt": double.tryParse(_baleNwtController.text) ?? 0,
//     //   "baleGwt": double.tryParse(_baleGwtController.text) ?? 0,
//     //   "bagType": _bagTypeController.text.trim(),
//     //   "tareWt": double.tryParse(_tareWtController.text) ?? 0,
//     //   "palletSize": _palletSizeController.text.trim(),
//     //   "shift": _selectedShift ?? "",
//     //   "bagWt": double.tryParse(_bagWtController.text) ?? 0,
//     //   "withoutM": _withoutM,
//     //   "bagSize": _bagSizeController.text.trim(),
//     //   "baleNo": _baleNoController.text.trim(),
//     //   "total": _totalController.text.trim(),
//     //   "typee": _bagTypeController.text.trim(),
//     //   "poNumber": _poNumberController.text.trim(),
//     //   "operator": _bomNoController.text.trim(), // ✅ match Postman
//     //   "entryOut": _baleNoController.text.trim(),
//     //   "status": _baleQTyController.text.trim(),
//     //   "remark": _baleNwtController.text.trim(),
//     //   "activeIn": _baleGwtController.text.trim(),
//     //   "activeOut": _palletSizeController.text.trim(),
//     //   "weekNo": _getWeekNumber(_selectedDate),
//     //   "requiredNewt": 0,
//     // };
//
//     final payload = {
//       "srNo": _srNoController.text.trim(),
//       "partyName": _baleGwtController.text.trim(),
//       "model": "",
//       "machine": _partyNameController.text.trim(),
//       "bomNo": _bomNoController.text.trim(), //bom number
//       "supervisor": _selectedSupervisor?.trim() ?? "",
//       "checkedBy": _selectedCheckedBy ?? "",
//       "submittedBy": _submittedByController.text.trim(),
//       "operator": _bomNoController.text.trim(), //bom number
//       "articleNo": _articleNoController.text.trim(),
//       "date": now.toIso8601String(),
//       "time":
//           "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",
//       "shift": _selectedShift ?? "",
//       "withoutM": _withoutM,
//       "poNumber": _poNumberController.text.trim(),
//       "weekNo": _getWeekNumber(_selectedDate),
//       "status": int.tryParse(_baleQTyController.text) ?? 0,
//       "remark": int.tryParse(_bagWtController.text) ?? 0,
//       "activeIn": int.tryParse(_baleNwtController.text) ?? 0,
//       // "activeOut": int.tryParse(_palletSizeController.text) ?? 0,
//       "activeOut": double.tryParse(_palletSizeController.text) ?? 0,
//
//       "requiredNewt": 0,
//
//       // 🔥 Multiple items
//       // "items": _baleItems,
//       "rows": _baleItems.map((item) {
//         // return {
//         //   "baleNo": item["baleNo"],
//         //   // "baleQty": int.tryParse(_baleQTyController.text) ?? 0,
//         //   // "baleQty": item["baleQtyPcs"] ?? 0,
//         //   // "baleNwt": item["baleNwt"],
//         //   // "tareWt": item["tareWt"],
//         //   // "bagWt": item["bagWt"],
//         //
//         //
//         //   "baleQty": item["baleQtyPcs"],   // ✅ from snapshot
//         //   "baleNwt": item["baleNwt"],            // ✅ from snapshot
//         //   "tareWt": item["tareWt"],              // ✅ from snapshot
//         //   "bagWt": item["bagWt"],               // ✅ from snapshot
//         //   "baleGwt": item["baleGwt"],
//         //
//         //   // "total": item["total"],
//         //   // "total": 0,
//         //   "total": totalBaleQty,
//         //   // "bagSize": "90*90*120",
//         //   "bagSize": _bagSizeController.text.trim(),
//         //   "typee": _bagTypeController.text.trim(),
//         // };
//
//         return {
//           "baleNo": item["baleNo"],
//           "baleQtyPcs": item["baleQtyPcs"], // ✅ snapshot value (1, 7 etc.)
//           "baleNwt": item["baleNwt"],
//           // "baleGwt": item["baleGwt"],
//           "tareWt": item["tareWt"],
//           "bagWt": item["bagWt"],
//           "total": totalBaleQty,
//           "bagSize": _bagSizeController.text.trim(),
//           "typee": _bagTypeController.text.trim(),
//         };
//       }).toList(),
//     };
//
//     debugPrint("🚀 FINAL baleGwt before POST → ${_baleGwtController.text}");
//
//     debugPrint("POST PAYLOAD 👉 ${jsonEncode(payload)}");
//
//     // final success = await _service.saveBaleEntry(payload);
//     final response = await _service.saveBaleEntry(payload);
//
//     if (!mounted) return;
//
//     if (response != null && response["success"] == true) {
//       _showSnack(response["message"] ?? "Saved successfully ✅");
//
//       await _fetchNextSerialNumber();
//       _clearFormFields();
//       Navigator.pop(context, true);
//     } else {
//       _showSnack(
//         response?["message"] ?? "Failed to save bale entry",
//         isError: true,
//       );
//     }
//   }
//
//   void _showSnack(String msg, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         backgroundColor: isError ? Colors.red : Colors.green,
//       ),
//     );
//   }
//
//   int _getWeekNumber(DateTime date) {
//     final firstDay = DateTime(date.year, 1, 1);
//     return ((date.difference(firstDay).inDays + firstDay.weekday) / 7).ceil();
//   }
//
//   Future<void> _loadSupervisors() async {
//     final list = await _service.getBaleSupervisorsList();
//
//     if (!mounted) return;
//
//     setState(() {
//       _supervisors = list;
//     });
//   }
//
//   // getBagProCheckedByList
//
//   Future<void> _loadCheckedBy() async {
//     final list = await _service.getBaleProCheckedByList();
//     debugPrint("CheckedBy List: $list");
//     if (!mounted) return;
//
//     setState(() {
//       _checkedbylist = list;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // floatingActionButton: FloatingActionButton.extended(
//       //   onPressed: _addItem,
//       //   backgroundColor: C.bgrColor,
//       //   icon: const Icon(Icons.add),
//       //   label: const Text("Add Item"),
//       // ),
//       backgroundColor: const Color(0xFFF5F8FA),
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'BALE ENTRY FORM',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         actions: [
//           TextButton.icon(
//             onPressed: _addItem,
//             icon: Icon(Icons.add, color: C.bgrColor),
//             label: Text("Add Item", style: TextStyle(color: C.bgrColor)),
//           ),
//         ],
//         backgroundColor: C.primary,
//         elevation: 0,
//         centerTitle: false,
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(_getResponsivePadding(context)),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // BASIC INFORMATION SECTION
//               _buildSectionHeader('BASIC INFORMATION'),
//               SizedBox(height: _getResponsiveSpacing(context)),
//
//               _buildResponsiveRow(
//                 context,
//                 children: [
//                   _buildTextField(
//                     label: 'SR. NO.',
//                     controller: _srNoController,
//                     required: true,
//                   ),
//                   _buildTextField(
//                     label: 'PARTY NAME',
//                     controller: _partyNameController,
//                     required: true,
//                   ),
//                   _buildDropdown(
//                     label: 'SUPERVISOR',
//                     value: _selectedSupervisor,
//                     hint: 'Select Supervisor',
//                     items: _supervisors,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedSupervisor = value;
//                       });
//                     },
//                   ),
//                 ],
//                 columns: 3,
//               ),
//
//               SizedBox(height: _getResponsiveSpacing(context)),
//
//               _buildResponsiveRow(
//                 context,
//                 children: [
//                   // _buildTextField(
//                   //   label: 'CHECKED BY',
//                   //   controller:  _selectedCheckedBy ?? "",
//                   //   // required: true,
//                   // ),
//                   _buildDropdown(
//                     label: 'CHECKED BY',
//                     value: _selectedCheckedBy,
//                     hint: 'Select Checked By',
//                     items: _checkedbylist,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedCheckedBy = value;
//                       });
//                     },
//                   ),
//
//                   _buildTextField(
//                     label: 'SUBMITTED BY',
//                     controller: _submittedByController,
//                     // required: true,
//                   ),
//                   _buildTextField(
//                     label: 'BOM NO.',
//                     controller: _bomNoController,
//                     required: true,
//                   ),
//                 ],
//                 columns: 3,
//               ),
//
//               SizedBox(height: _getResponsiveSpacing(context)),
//
//               _buildTextField(
//                 label: 'PO NUMBER',
//                 controller: _poNumberController,
//                 // required: true,
//               ),
//
//               SizedBox(height: _getResponsiveSpacing(context) * 2),
//
//               // PRODUCT DETAILS SECTION
//               _buildSectionHeader('PRODUCT DETAILS'),
//               SizedBox(height: _getResponsiveSpacing(context)),
//
//               _buildResponsiveRow(
//                 context,
//                 children: [
//                   _buildTextField(
//                     label: 'ARTICLE NO',
//                     controller: _articleNoController,
//                     required: true,
//                     keyboardType: TextInputType.number,
//                     focusNode: _articleFocusNode,
//                   ),
//
//                   _buildTextField(
//                     label: 'BAG TYPE',
//                     controller: _bagTypeController,
//                     // required: true,
//                   ),
//                   _buildTextField(
//                     label: 'PRINT STATUS',
//                     controller: _printStatusController,
//                     required: true,
//                   ),
//                 ],
//                 columns: 3,
//               ),
//
//               SizedBox(height: _getResponsiveSpacing(context)),
//
//               _buildResponsiveRow(
//                 context,
//                 children: [
//                   _buildTextField(
//                     label: 'BAG SIZE (LXWXH)',
//                     controller: _bagSizeController,
//                     required: true,
//                   ),
//                   _buildTextField(
//                     label: 'BALE (GWT)',
//                     controller: _baleGwtController,
//                     required: true,
//                     keyboardType: TextInputType.number,
//                   ),
//                   _buildDateField(),
//                 ],
//                 columns: 3,
//               ),
//
//               SizedBox(height: _getResponsiveSpacing(context) * 2),
//
//               // BAG DETAILS SECTION
//               _buildSectionHeader('BAG DETAILS'),
//               SizedBox(height: _getResponsiveSpacing(context)),
//
//               _buildResponsiveRow(
//                 context,
//                 children: [
//                   _buildTextField(
//                     label: 'TARE (WT)',
//                     controller: _tareWtController,
//                     required: true,
//                     keyboardType: TextInputType.number,
//                   ),
//                   _buildTextField(
//                     label: 'BAG NWT (GM)',
//                     // controller: _baleNwtController,
//                     controller: _bagWtController,
//                     required: true,
//                     keyboardType: TextInputType.number,
//                   ),
//                   _buildTextField(
//                     label: 'BALE QTY (PCS)',
//                     controller: _baleQTyController,
//                     required: true,
//                     keyboardType: TextInputType.number,
//                   ),
//
//                   _buildTextField(
//                     label: 'BAG WT (GM)',
//                     // controller: _bagWtController,
//                     controller: _baleNwtController,
//                     required: true,
//                     keyboardType: TextInputType.number,
//                   ),
//
//                   _buildWithoutMCheckbox(),
//                 ],
//                 columns: 3,
//               ),
//
//               SizedBox(height: _getResponsiveSpacing(context)),
//
//               _buildTextField(
//                 label: 'BALE NO',
//                 hint: 'Bale No.',
//                 controller: _baleNoController,
//                 required: true,
//                 keyboardType: TextInputType.number,
//               ),
//
//               SizedBox(height: _getResponsiveSpacing(context) * 2),
//
//               // ADDITIONAL INFORMATION SECTION
//               _buildSectionHeader('ADDITIONAL INFORMATION'),
//               SizedBox(height: _getResponsiveSpacing(context)),
//
//               _buildResponsiveRow(
//                 context,
//                 children: [
//                   _buildTextField(
//                     label: 'PALLET SIZE',
//                     controller: _palletSizeController,
//                     required: true,
//                     keyboardType: TextInputType.text,
//                   ),
//                   _buildDropdown(
//                     label: 'SHIFT',
//                     value: _selectedShift,
//                     hint: 'Select Shift',
//                     items: _shifts,
//                     onChanged: (value) {
//                       setState(() => _selectedShift = value);
//                     },
//                     required: true,
//                     placeholder: 'SELECT SHIFT',
//                   ),
//                 ],
//                 columns: 2,
//               ),
//
//               SizedBox(height: _getResponsiveSpacing(context) * 2),
//
//               // Action Buttons
//               // Show Added Items Table
//               _buildItemsTable(),
//
//               SizedBox(height: _getResponsiveSpacing(context) * 2),
//
//               // Action Buttons
//               _buildResponsiveButtons(context),
//
//               SizedBox(height: _getResponsiveSpacing(context)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Helper method to get responsive padding
//   double _getResponsivePadding(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     if (width < 600) return 16; // Mobile
//     if (width < 1200) return 24; // Tablet
//     return 32; // Desktop
//   }
//
//   // Helper method to get responsive spacing
//   double _getResponsiveSpacing(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     if (width < 600) return 12; // Mobile
//     if (width < 1200) return 16; // Tablet
//     return 20; // Desktop
//   }
//
//   // Helper method to get responsive gap between fields
//   double _getResponsiveGap(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     if (width < 600) return 12; // Mobile
//     if (width < 1200) return 16; // Tablet
//     return 16; // Desktop
//   }
//
//   // Responsive row builder that adapts to screen size
//   Widget _buildResponsiveRow(
//     BuildContext context, {
//     required List<Widget> children,
//     required int columns,
//   }) {
//     final width = MediaQuery.of(context).size.width;
//     final gap = _getResponsiveGap(context);
//
//     // Mobile: Stack vertically (1 column)
//     if (width < 600) {
//       return Column(
//         children: children
//             .map(
//               (child) => Padding(
//                 padding: EdgeInsets.only(bottom: gap),
//                 child: child,
//               ),
//             )
//             .toList(),
//       );
//     }
//
//     // Tablet: 2 columns for 3-column layouts, keep 2 columns for 2-column layouts
//     if (width < 900) {
//       if (columns == 3) {
//         // Split into rows of 2, with last one potentially alone
//         List<Widget> rows = [];
//         for (int i = 0; i < children.length; i += 2) {
//           final rowChildren = children.skip(i).take(2).toList();
//           rows.add(
//             Padding(
//               padding: EdgeInsets.only(
//                 bottom: i + 2 < children.length ? gap : 0,
//               ),
//               child: Row(
//                 children: [
//                   for (int j = 0; j < rowChildren.length; j++) ...[
//                     Expanded(child: rowChildren[j]),
//                     if (j < rowChildren.length - 1) SizedBox(width: gap),
//                   ],
//                   // Add empty space if odd number of items
//                   if (rowChildren.length == 1) Expanded(child: Container()),
//                 ],
//               ),
//             ),
//           );
//         }
//         return Column(children: rows);
//       } else {
//         // 2 columns layout
//         return Row(
//           children: [
//             for (int i = 0; i < children.length; i++) ...[
//               Expanded(child: children[i]),
//               if (i < children.length - 1) SizedBox(width: gap),
//             ],
//           ],
//         );
//       }
//     }
//
//     // Desktop and large tablets: Full columns as specified
//     return Row(
//       children: [
//         for (int i = 0; i < children.length; i++) ...[
//           Expanded(child: children[i]),
//           if (i < children.length - 1) SizedBox(width: gap),
//         ],
//       ],
//     );
//   }
//
//   // Responsive button layout
//   Widget _buildResponsiveButtons(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final gap = _getResponsiveGap(context);
//
//     // Mobile: Stack buttons vertically
//     if (width < 600) {
//       return Column(
//         children: [
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton(
//               onPressed: () => Navigator.pop(context),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: const Color(0xFF607D8B),
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 side: const BorderSide(color: Color(0xFF9E9E9E), width: 1.5),
//               ),
//               child: const Text(
//                 'CANCEL',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: gap),
//           if (_baleItems.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 12),
//               child: Text(
//                 "Items Added: ${_baleItems.length}",
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: Colors.green,
//                 ),
//               ),
//             ),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: _baleItems.isEmpty ? null : _saveEntry,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: _baleItems.isEmpty
//                     ? Colors.grey
//                     : const Color(0xFF4CAF50),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 elevation: 0,
//               ),
//               child: const Text(
//                 'SAVE ENTRY',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       );
//     }
//
//     // Tablet and Desktop: Side by side
//     return Row(
//       children: [
//         Expanded(
//           child: OutlinedButton(
//             onPressed: () => Navigator.pop(context),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: const Color(0xFF607D8B),
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               side: const BorderSide(color: Color(0xFF9E9E9E), width: 1.5),
//             ),
//             child: const Text(
//               'CANCEL',
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ),
//         ),
//         SizedBox(width: gap),
//         Expanded(
//           child: ElevatedButton(
//             onPressed: _saveEntry,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF4CAF50),
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               elevation: 0,
//             ),
//             child: const Text(
//               'SAVE ENTRY',
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSectionHeader(String title) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w700,
//             color: Color(0xFF5F7C8A),
//             letterSpacing: 0.5,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           height: 3,
//           width: 60,
//           decoration: const BoxDecoration(
//             color: Color(0xFF5F7C8A),
//             borderRadius: BorderRadius.all(Radius.circular(2)),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildItemsTable() {
//     if (_baleItems.isEmpty) return const SizedBox();
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 20),
//         const Text(
//           "ADDED ITEMS",
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w700,
//             color: Color(0xFF5F7C8A),
//           ),
//         ),
//         const SizedBox(height: 10),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: DataTable(
//             headingRowColor: MaterialStateProperty.all(const Color(0xFFEAF2F5)),
//             columns: const [
//               DataColumn(label: Text("Bale No")),
//               DataColumn(label: Text("GWT")),
//               DataColumn(label: Text("Tare")),
//               DataColumn(label: Text("NWT")),
//               DataColumn(label: Text("Qty")),
//               DataColumn(label: Text("Bag WT")),
//               DataColumn(label: Text("Pallet")),
//               DataColumn(label: Text("Action")),
//             ],
//             rows: List.generate(_baleItems.length, (index) {
//               final item = _baleItems[index];
//
//               return DataRow(
//                 cells: [
//                   DataCell(Text(item["baleNo"].toString())),
//                   DataCell(Text(item["baleGwt"].toString())),
//                   DataCell(Text(item["tareWt"].toString())),
//                   DataCell(Text(item["baleNwt"].toString())),
//                   // DataCell(Text(item["baleQty"].toString())),
//                   DataCell(Text(item["baleQtyPcs"].toString())),
//                   DataCell(Text(item["bagWt"].toString())),
//                   DataCell(Text(item["palletSize"].toString())),
//                   DataCell(
//                     IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: () {
//                         setState(() {
//                           _baleItems.removeAt(index);
//                         });
//                       },
//                     ),
//                   ),
//                 ],
//               );
//             }),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTextField({
//     required String label,
//     required TextEditingController controller,
//
//     // readOnly: controller == _bagWtController ||
//     //     controller == _baleNwtController,
//     FocusNode? focusNode,
//     bool required = false,
//
//     TextInputType? keyboardType,
//     int maxLines = 1,
//     String? hint,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         RichText(
//           text: TextSpan(
//             text: label,
//             style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF5F7C8A),
//               height: 1.2,
//             ),
//             children: [
//               if (required)
//                 const TextSpan(
//                   text: ' *',
//                   style: TextStyle(color: Color(0xFFE53935)),
//                 ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: controller,
//           // controller: controller,
//           // readOnly:
//           //     controller == _bagWtController ||
//           //     controller == _baleNwtController,
//           enableInteractiveSelection: false,
//
//           focusNode: focusNode,
//           keyboardType: keyboardType,
//           maxLines: maxLines,
//           style: const TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF212121),
//           ),
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
//             filled: true,
//             fillColor: Colors.white,
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 14,
//               vertical: 10,
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Color(0xFF5F7C8A), width: 2),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Color(0xFFE53935)),
//             ),
//             focusedErrorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
//             ),
//           ),
//           validator: required
//               ? (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'This field is required';
//                   }
//                   return null;
//                 }
//               : null,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDropdown({
//     required String label,
//     required String? value,
//     required String hint,
//     required List<String> items,
//     required Function(String?) onChanged,
//     bool required = false,
//     String? placeholder,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         RichText(
//           text: TextSpan(
//             text: label,
//
//             style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF5F7C8A),
//               height: 1.2,
//             ),
//             children: [
//               if (required)
//                 const TextSpan(
//                   text: ' *',
//                   style: TextStyle(color: Color(0xFFE53935)),
//                 ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         DropdownButtonFormField<String>(
//           value: value,
//
//           isExpanded: true,
//           hint: placeholder != null ? Text(placeholder) : null,
//           style: const TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF212121),
//           ),
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: Colors.white,
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 10,
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: const BorderSide(color: Color(0xFF5F7C8A), width: 2),
//             ),
//           ),
//           items: items.map((item) {
//             return DropdownMenuItem<String>(value: item, child: Text(item));
//           }).toList(),
//           onChanged: onChanged,
//           validator: required
//               ? (val) {
//                   if (val == null ||
//                       val.isEmpty ||
//                       val == placeholder ||
//                       val == items.first) {
//                     return 'Please select $label';
//                   }
//                   return null;
//                 }
//               : null,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDateField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'DATE *',
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF5F7C8A),
//             height: 1.2,
//           ),
//         ),
//         const SizedBox(height: 8),
//         InkWell(
//           onTap: () async {
//             final date = await showDatePicker(
//               context: context,
//               initialDate: _selectedDate,
//               firstDate: DateTime(2020),
//               lastDate: DateTime(2030),
//               builder: (context, child) {
//                 return Theme(
//                   data: Theme.of(context).copyWith(
//                     colorScheme: const ColorScheme.light(
//                       primary: Color(0xFF5F7C8A),
//                     ),
//                   ),
//                   child: child!,
//                 );
//               },
//             );
//             if (date != null) {
//               setState(() => _selectedDate = date);
//             }
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.grey.shade300),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     '${_selectedDate.day.toString().padLeft(2, '0')}-${_getMonthName(_selectedDate.month)}-${_selectedDate.year}',
//                     style: const TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF212121),
//                     ),
//                   ),
//                 ),
//                 Icon(
//                   Icons.calendar_today_outlined,
//                   size: 20,
//                   color: Colors.grey.shade600,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildWithoutMCheckbox() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'WITHOUT M',
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF5F7C8A),
//             height: 1.2,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Checkbox(
//               value: _withoutM,
//               onChanged: (value) {
//                 setState(() => _withoutM = value ?? false);
//               },
//               activeColor: const Color(0xFF5F7C8A),
//               materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//               visualDensity: VisualDensity.compact,
//             ),
//             const SizedBox(width: 4),
//             const Flexible(
//               child: Text(
//                 'CHECK IF WITHOUT M',
//                 style: TextStyle(fontSize: 13, color: Color(0xFF212121)),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   String _getMonthName(int month) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return months[month - 1];
//   }
// }






import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../Color/Colorclass.dart';
import '../../services/getSupervisors/getSupervisors.dart';
import 'BaleEntryModle/BaleEntryModle.dart';
import 'BaleEntryModle/BaleEntryROwModle.dart';

class BaleEntryForm extends StatefulWidget {
  final String? partyName;
  final String? articleNo;
  final String? poNumber;
  final String? bomNo;
  final int? remaining;

  const BaleEntryForm({
    Key? key,
    this.partyName,
    this.articleNo,
    this.poNumber,
    this.bomNo,
    this.remaining,
  }) : super(key: key);

  @override
  State<BaleEntryForm> createState() => _BaleEntryFormState();
}

class _BaleEntryFormState extends State<BaleEntryForm> {
  final _formKey = GlobalKey<FormState>();
  late InStockService _service;
  int? _nextSrNo;
  bool _isSrLoading = true;
  late FocusNode _articleFocusNode;
  List<Map<String, dynamic>> _baleItems = [];

  // Controllers
  late TextEditingController _srNoController;
  late TextEditingController _partyNameController;
  late TextEditingController _supervisorController;
  // late TextEditingController _checkedByController;
  late TextEditingController _submittedByController;
  late TextEditingController _machineController;
  late TextEditingController _statusController;

  late TextEditingController _poNumberController;

  final TextEditingController _bagTypeController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();

  final TextEditingController _printStatusController = TextEditingController();
  final TextEditingController _bagSizeController = TextEditingController();
  final TextEditingController _baleQTyController = TextEditingController();
  final TextEditingController _bomNoController = TextEditingController();
  // Product Details
  late TextEditingController _articleNoController;
  // final TextEditingController baleGwtController = TextEditingController();
  // final TextEditingController tareWtController = TextEditingController();
  // final TextEditingController baleQtyController = TextEditingController();

  // final TextEditingController baleNwtController = TextEditingController();
  // final TextEditingController bagWtController = TextEditingController();

  late TextEditingController _baleGwtController;
  late TextEditingController _baleNwtController;
  late TextEditingController _remarkController;
  late TextEditingController _activeInController;
  late TextEditingController _activeOutController;
  late TextEditingController _requiredNewtController;

  // Bag Details
  late TextEditingController _tareWtController;
  late TextEditingController _bagWtController;
  late TextEditingController _baleNoController;

  // Additional Information
  late TextEditingController _palletSizeController;


  DateTime _selectedDate = DateTime.now();
  String? _selectedShift;
  bool _withoutM = false;

  final List<String> _shifts = ['Select shift', 'A', 'B'];
  String? _selectedSupervisor;
  String? _selectedCheckedBy;
  String _requiredBag = "0";
  String _availableBag = "0";
  // List<String> _supervisors = ['Select supervisor'];

  List<String> _supervisors = [];
  List<String> _checkedbylist = [];
  @override
  void initState() {
    super.initState();

    _service = InStockService();
    _initializeControllers();
    _baleGwtController.addListener(() {
      debugPrint("🔥 baleGwtController changed → ${_baleGwtController.text}");
    });

    _baleGwtController.addListener(_calculateWeights);
    _baleGwtController.addListener(() {
      debugPrint("🔥 baleGwtController changed → ${_baleGwtController.text}");
    });

    _tareWtController.addListener(_calculateWeights);
    _baleQTyController.addListener(_calculateWeights);
    _baleNwtController = TextEditingController();
    _articleFocusNode = FocusNode();
    _articleFocusNode.addListener(_onArticleUnfocus);

    _fetchNextSerialNumber();

    // Populate fields with data passed from previous screen
    _populateInitialData();
    _loadSupervisors();
    _loadCheckedBy();
  }

  // void _clearItemFields() {
  //   _tareWtController.clear();
  //   _baleQTyController.clear();
  //   _bagWtController.clear();
  //   _baleNwtController.clear();
  //   _baleNoController.clear();
  //   _palletSizeController.clear();
  // }

  void _addItem() {
    if (_baleGwtController.text.isEmpty ||
        _tareWtController.text.isEmpty ||
        _baleQTyController.text.isEmpty ||
        _baleNoController.text.isEmpty) {
      _showPopup("Fill all Bale details before adding", isError: true);
      return;
    }
    // final palletSize =
    // _palletSizeController.text
    //     .replaceAll(RegExp(r'\s*x\s*', caseSensitive: false), ' X ')
    //     .trim();

    final item = {
      "baleGwt": double.tryParse(_baleGwtController.text) ?? 0,
      "tareWt": double.tryParse(_tareWtController.text) ?? 0,
      "baleQty": int.tryParse(_baleQTyController.text) ?? 0,
      // "baleQtyPcs": double.tryParse ?? 0,
      // "baleQtyPcs": int.tryParse(_baleQTyController.text) ?? 0, // ✅ snapshot
      // "baleQtyPcs": _printStatusController.text,
      "baleQtyPcs": _baleQTyController.text,

      "baleNwt": double.tryParse(_baleNwtController.text) ?? 0,
      "bagWt": double.tryParse(_bagWtController.text) ?? 0,
      "baleNo": _baleNoController.text.trim(),
      "palletSize": _palletSizeController.text.trim(),

      // "activeOut": palletSize,

    };

    setState(() {
      _baleItems.add(Map<String, dynamic>.from(item));
    });

    _showPopup("Item Added ✅");
  }

  void _calculateWeights() {
    final double gwt = double.tryParse(_baleGwtController.text) ?? 0.0;
    // 807

    final double tare = double.tryParse(_tareWtController.text) ?? 0.0;
    // 4
    final int qty = int.tryParse(_baleQTyController.text) ?? 0;
    debugPrint("⚙️ _calculateWeights triggered");
    debugPrint("GWT before calc: ${_baleGwtController.text}");

    // BALE NWT = GWT - TARE
    final double nwt = gwt - tare;
    // 803
    _baleNwtController.text = nwt > 0 ? nwt.toStringAsFixed(2) : '0';

    // BAG WT = NWT / QTY
    final double bagWt = (qty > 0 && nwt > 0) ? (nwt / qty) : 0;

    _bagWtController.text = bagWt > 0 ? bagWt.toStringAsFixed(2) : '0';
    debugPrint("⚙️ _calculateWeights triggered");
    debugPrint("GWT before calc: ${_baleGwtController.text}");
  }

  void _populateInitialData() {
    if (widget.partyName != null) {
      _partyNameController.text = widget.partyName!;
    }
    if (widget.articleNo != null) {
      _articleNoController.text = widget.articleNo!;
      // Trigger product details fetch if both party name and article no are provided
      if (widget.partyName != null) {
        _fetchProductDetailsInitial();
      }
    }
    if (widget.poNumber != null) {
      _poNumberController.text = widget.poNumber!;
    }
    if (widget.bomNo != null) {
      _bomNoController.text = widget.bomNo!;
    }
  }

  Future<void> _fetchProductDetailsInitial() async {
    try {
      final res = await _service.fetchProductDetails(
        partyName: widget.partyName!,
        articleNo: widget.articleNo!,
        generatedInquiry: widget.bomNo!,


      );
      debugPrint("📦 Product API tBAGotal (GWT) → ${res['bagwt']}");

      setState(() {
        _requiredBag = widget.remaining?.toString() ?? "0";
        _availableBag = res['availableBag']?.toString() ?? "0";
        _bagTypeController.text = res['typee']?.toString() ?? '';
        _printStatusController.text = res['printStatus']?.toString() ?? '';
        _bagSizeController.text = res['bagSize']?.toString() ?? '';
        // _baleGwtController.text = res['bagwt']?.toString() ?? '';
        // _baleQTyController.text = res['printStatus']?.toString() ?? '';
        _bagWtController.text = res['bagwt']?.toString() ?? '';

        // Don't override BOM if it was passed from previous screen
        if (widget.bomNo == null) {
          _bomNoController.text = res['bomNo']?.toString() ?? '';
        }
        debugPrint("📦 Product API total (GWT) → ${res['total']}");
      });
    } catch (e) {
      debugPrint('Product details error: $e');
    }
  }

  @override
  void dispose() {
    _articleFocusNode.dispose();
    _baleGwtController.dispose();
    _tareWtController.dispose();
    _baleQTyController.dispose();
    _bagWtController.dispose();
    _baleNwtController.dispose(); // ✅ ADD THIS

    super.dispose();
  }

  Future<void> _onArticleUnfocus() async {
    if (_articleFocusNode.hasFocus) return;

    final partyName = _partyNameController.text.trim();
    final articleNo = _articleNoController.text.trim();
    final bomNo = _bomNoController.text.trim();

    if (partyName.isEmpty || articleNo.isEmpty) return;

    try {
      final res = await _service.fetchProductDetails(
        partyName: partyName,
        articleNo: articleNo,
        generatedInquiry: bomNo,
      );

      setState(() {
        _bagTypeController.text = res['typee']?.toString() ?? '';
        _printStatusController.text = res['printStatus']?.toString() ?? '';
        _bagSizeController.text = res['bagSize']?.toString() ?? '';
        _baleGwtController.text = res['total']?.toString() ?? '';
        _bomNoController.text = res['bomNo']?.toString() ?? '';
        debugPrint("📦 Product API total (GWT) → ${res['total']}");
      });
      debugPrint("📦 Product API total (GWT) → ${res['total']}");
    } catch (e) {
      debugPrint('Product details error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product details not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchNextSerialNumber() async {
    try {
      final srNo = await _service.fetchNextBaleSerialNumber();

      setState(() {
        _nextSrNo = srNo;
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

    setState(() {
      _selectedShift = null;
      _withoutM = false;
    });
  }

  void _initializeControllers() {
    _srNoController = TextEditingController();
    _partyNameController = TextEditingController();
    _supervisorController = TextEditingController();
    // _checkedByController = TextEditingController();
    _submittedByController = TextEditingController();

    _poNumberController = TextEditingController();

    _articleNoController = TextEditingController();

    _baleGwtController = TextEditingController();

    _tareWtController = TextEditingController();
    _bagWtController = TextEditingController();
    _baleNoController = TextEditingController();

    _palletSizeController = TextEditingController();

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
      "poNumber": _poNumberController.text.trim().isEmpty
          ? "N/A"
          : _poNumberController.text.trim(),
      "date":
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
      "operator": _bomNoController.text.trim(),
      "supervisor": _selectedSupervisor ?? "",
      "checkedBy": _selectedCheckedBy ?? "",
      "submittedBy": _submittedByController.text.trim(),
      "activeIn": double.tryParse(_baleGwtController.text) ?? 0,
      "requiredNewt": 0,

      /// 🔥 ROWS
      "rows": _baleItems.map((item) {
        return {
          "baleNo": item["baleNo"].toString(),

          /// ⚠️ IMPORTANT (API expects STRING like N/A00)
          // "baleQtyPcs": _printStatusController.text.trim(),
          "baleQtyPcs": _printStatusController.text,
          "tareWt": item["tareWt"] ?? 0,
          "bagWt": item["bagWt"] ?? 0,

          /// total = sum of all qty
          "total": 0,

          // "total": _baleItems.fold(
          //   0,
          //   (sum, e) => sum + ((e["baleQtyPcs"] ?? 0) as num).toInt(),
          // ),
          "bagSize": _bagSizeController.text.trim(),
          "typee": _bagTypeController.text.trim(),
          "status": item["baleQty"].toString(),
          /// 🔥 THESE WERE WRONG BEFORE
          // "status": _baleQTyController.text.trim(),
          "remark": _baleNwtController.text.trim(),
          "partyName": item["bagWt"].toString(),

          "shift": _selectedShift ?? "",

          /// pallet size
          "activeOut": item["palletSize"].toString(),
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
      _clearFormFields();

      Navigator.pop(context, true);
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: isError ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }
  int _getWeekNumber(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    return ((date.difference(firstDay).inDays + firstDay.weekday) / 7).ceil();
  }

  Future<void> _loadSupervisors() async {
    final list = await _service.getBaleSupervisorsList();

    if (!mounted) return;

    setState(() {
      _supervisors = list;
    });
  }

  // getBagProCheckedByList

  Future<void> _loadCheckedBy() async {
    final list = await _service.getBaleProCheckedByList();
    debugPrint("CheckedBy List: $list");
    if (!mounted) return;

    setState(() {
      _checkedbylist = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _addItem,
      //   backgroundColor: C.bgrColor,
      //   icon: const Icon(Icons.add),
      //   label: const Text("Add Item"),
      // ),
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'BALE ENTRY FORM',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
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
                  // _buildTextField(
                  //   label: 'CHECKED BY',
                  //   controller:  _selectedCheckedBy ?? "",
                  //   // required: true,
                  // ),
                  _buildDropdown(
                    label: 'CHECKED BY',
                    value: _selectedCheckedBy,
                    hint: 'Select Checked By',
                    items: _checkedbylist,
                    onChanged: (value) {
                      setState(() {
                        _selectedCheckedBy = value;
                      });
                    },
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'SUBMITTED BY',
                          controller: _submittedByController,
                          inputFormatters: [],
                          // required: true,
                        ),
                      ),const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'PO NUMBER',
                          controller: _poNumberController,
                          inputFormatters: [],
                          // required: true,
                        ),
                      ),
                    ],
                  ),

                ],
                // columns: 3,
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
                          focusNode: _articleFocusNode,
                          inputFormatters: [],
                        ),
                      ),
      const SizedBox(width: 12),

                      Expanded(
                        child: _buildTextField(
                          label: 'BAG TYPE',
                          controller: _bagTypeController,
                          inputFormatters: [],
                          // required: true,
                        ),
                      ),
                    ],
                  ),

                ],
                // columns: 3,
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
                // columns: 3,
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
                          // controller: _baleNwtController,
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
                          // controller: _bagWtController,
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
                // columns: 3,
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
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                    ],
                  ),
                  _buildDropdown(
                    label: 'SHIFT',
                    value: _selectedShift,
                    hint: 'Select Shift',
                    items: _shifts,
                    onChanged: (value) {
                      setState(() => _selectedShift = value);
                    },
                    required: true,
                    placeholder: 'SELECT SHIFT',
                  ),
                ],
                // columns: 2,
              ),

              SizedBox(height: _getResponsiveSpacing(context) * 2),

              // Action Buttons
              // Show Added Items Table
              _buildItemsTable(),

              SizedBox(height: _getResponsiveSpacing(context) * 2),

              // Action Buttons
              _buildResponsiveButtons(context),

              SizedBox(height: _getResponsiveSpacing(context)),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get responsive padding
  double _getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 16; // Mobile
    if (width < 1200) return 24; // Tablet
    return 32; // Desktop
  }

  // Helper method to get responsive spacing
  double _getResponsiveSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 12; // Mobile
    if (width < 1200) return 16; // Tablet
    return 20; // Desktop
  }

  // Helper method to get responsive gap between fields
  double _getResponsiveGap(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 12; // Mobile
    if (width < 1200) return 16; // Tablet
    return 16; // Desktop
  }

  // Responsive row builder that adapts to screen size
  Widget _buildResponsiveRow(
    BuildContext context, {
    required List<Widget> children,

  }) {
    final width = MediaQuery.of(context).size.width;
    final gap = _getResponsiveGap(context);

    // Mobile: Stack vertically (1 column)
    if (width < 600) {
      return Column(
        children: children
            .map(
              (child) => Padding(
                padding: EdgeInsets.only(bottom: gap),
                child: child,
              ),
            )
            .toList(),
      );
    }



    // Desktop and large tablets: Full columns as specified
    return Row(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          Expanded(child: children[i]),
          if (i < children.length - 1) SizedBox(width: gap),
        ],
      ],
    );
  }

  // Responsive button layout
  Widget _buildResponsiveButtons(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final gap = _getResponsiveGap(context);

    // Mobile: Stack buttons vertically
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: const BorderSide(color: Color(0xFF9E9E9E), width: 1.5),
              ),
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          SizedBox(height: gap),
          if (_baleItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                "Items Added: ${_baleItems.length}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _baleItems.isEmpty ? null : _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _baleItems.isEmpty
                    ? Colors.grey
                    : const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'SAVE ENTRY',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Tablet and Desktop: Side by side
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF607D8B),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              side: const BorderSide(color: Color(0xFF9E9E9E), width: 1.5),
            ),
            child: const Text(
              'CANCEL',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'SAVE ENTRY',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF5F7C8A),
          ),
        ),
        const SizedBox(height: 10),
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
                  // DataCell(Text(item["baleQty"].toString())),
                  DataCell(Text(item["baleQtyPcs"].toString())),
                  DataCell(Text(item["bagWt"].toString())),
                  DataCell(Text(item["palletSize"].toString())),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _baleItems.removeAt(index);
                        });
                      },
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

    // readOnly: controller == _bagWtController ||
    //     controller == _baleNwtController,
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
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFFE53935)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          // controller: controller,
          // readOnly:
          //     controller == _bagWtController ||
          //     controller == _baleNwtController,
          enableInteractiveSelection: false,

          focusNode: focusNode,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF212121),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
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
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFFE53935)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,

          isExpanded: true,
          hint: placeholder != null ? Text(placeholder) : null,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF212121),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
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
          items: items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
          validator: required
              ? (val) {
                  if (val == null ||
                      val.isEmpty ||
                      val == placeholder ||
                      val == items.first) {
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
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5F7C8A),
            height: 1.2,
          ),
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
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF5F7C8A),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              setState(() => _selectedDate = date);
            }
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
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
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5F7C8A),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: _withoutM,
              onChanged: (value) {
                setState(() => _withoutM = value ?? false);
              },
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
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Widget _buildBagSummary() {
    final width = MediaQuery.of(context).size.width;

    Widget card({
      required String title,
      required String value,
      required Color color,
    }) {
      return Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 120,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: color),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (width < 600) {
      return Row(
        children: [
          card(
            title: "REQUIRED BAG",
            value: _requiredBag,
            color: Colors.red,
          ),
          // const SizedBox(width: 12),
          // card(
          //   title: "AVAILABLE BAG",
          //   value: _availableBag,
          //   color: Colors.green,
          // ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: card(
            title: "REQUIRED BAG",
            value: _requiredBag,
            color: Colors.red,
          ),
        ),
        // const SizedBox(width: 20),
        // Expanded(
        //   child: card(
        //     title: "AVAILABLE BAG",
        //     value: _availableBag,
        //     color: Colors.green,
        //   ),
        // ),
      ],
    );
  }
}
