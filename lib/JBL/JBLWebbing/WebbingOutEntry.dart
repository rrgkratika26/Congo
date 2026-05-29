// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import '../../Color/Colorclass.dart';
// import '../../ScannedItem/Webbing/WebbingController.dart';
// import '../../services/JBL_apis/jbl_api_bailing_reports.dart';
// import 'model/WebbForwardResponse.dart';
// import 'model/WebbingListModel.dart';
// import 'model/webbingfilterModel.dart';
//
// Future<InStockWebController> webbFetchDropdowns() async {
//   final controller = InStockWebController();
//   await controller.loadWebInitialData();
//   return controller;
// }
//
// const _kAccents = [
//   Color(0xFF3F88F5),
//   Color(0xFF5D9CFF),
//   Color(0xFF2F6EDB),
//   Color(0xFF9CC2FF),
//   Color(0xFF2559B8),
// ];
//
// // ── Fixed column widths ──
// // SizedBox(width) instead of Expanded inside horizontal scroll
// const double _colCheck = 30;
// const double _colNo = 36;
// const double _colCode = 80;
// const double _colLot = 140;
// const double _colSpec = 160;
// const double _colWt = 72;
// const double _colBar = 72;
// const double _tableMinWidth =
//     _colCheck + _colNo + _colCode + _colLot + _colSpec + _colWt + _colBar + 24;
//
// class WebbingOut extends StatefulWidget {
//   const WebbingOut({super.key});
//
//   @override
//   State<WebbingOut> createState() => _WebbingOutState();
// }
//
// class _WebbingOutState extends State<WebbingOut> {
//   final _formKey = GlobalKey<FormState>();
//   String loggedUnit = "JBL"; // example (API ya login se aayega)
//   String? _selectedSupervisor;
//   String? _selectedOperator;
//   String? _selectedLocation;
//   String? _selectedDepartment;
//
//   late Future<InStockWebController> _dropdownFuture;
//   final ScrollController _scrollController = ScrollController();
//   final Map<String, WebbingOutResponse> _submitResults = {};
//   List<WebbingFilterModel> webbingList = [];
//   final Set<String> _selectedBarcodes = {};
//
//   TextEditingController _searchController = TextEditingController();
//   List<WebbingFilterModel> _filteredList = [];
//   Timer? _debounce;
//   bool isLoading = false;
//   bool _isSubmitting = false;
//   bool _isSubmitted = false;
//   String? _errorMsg;
//
//   int _pageSize = 20;
//   int _currentMax = 20;
//   @override
//   void initState() {
//     super.initState();
//     _dropdownFuture = webbFetchDropdowns();
//     loadWebbing();
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void loadWebbing() async {
//     setState(() {
//       isLoading = true;
//       _errorMsg = null;
//     });
//     try {
//       final result = await JblApiService.filterWebbing(
//         plant: "JBL",
//         fabricCodes: "",
//         lotNo: "",
//       );
//       setState(() {
//         webbingList = result;
//         _filteredList = result;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         _errorMsg = e.toString();
//       });
//     }
//   }
//
//   void _filterSearch(String query) {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//
//     _debounce = Timer(const Duration(milliseconds: 500), () async {
//       if (query.trim().isEmpty) {
//         loadWebbing();
//         return;
//       }
//
//       setState(() {
//         isLoading = true;
//         _errorMsg = null;
//       });
//
//       try {
//         // 🔥 Try both ways (important fix)
//         List<WebbingFilterModel> result = [];
//
//         // First try → lot search
//         result = await JblApiService.filterWebbing(
//           plant: "JBL",
//           fabricCodes: "",
//           lotNo: query,
//         );
//
//         // If empty → try fabric code
//         if (result.isEmpty) {
//           result = await JblApiService.filterWebbing(
//             plant: "JBL",
//             fabricCodes: query,
//             lotNo: "",
//           );
//         }
//
//         setState(() {
//           webbingList = result;
//           _filteredList = result;
//           isLoading = false;
//         });
//       } catch (e) {
//         setState(() {
//           isLoading = false;
//           _errorMsg = e.toString();
//         });
//       }
//     });
//   }
//
//   bool get _anySelected => _selectedBarcodes.isNotEmpty;
//   int get _selectedCount => _selectedBarcodes.length;
//   bool get _canForward =>
//       _anySelected &&
//       _selectedSupervisor != null &&
//       _selectedOperator != null &&
//       _selectedLocation != null &&
//       _selectedDepartment != null;
//
//   void _toggleItem(WebbingFilterModel item) {
//     setState(() {
//       final key = item.barcode ?? item.code ?? "";
//       _selectedBarcodes.contains(key)
//           ? _selectedBarcodes.remove(key)
//           : _selectedBarcodes.add(key);
//     });
//   }
//
//   bool _isItemSelected(WebbingFilterModel item) =>
//       _selectedBarcodes.contains(item.barcode ?? item.code ?? "");
//
//   // Future<void> _onForward() async {
//   //   if (!_formKey.currentState!.validate() || !_anySelected) return;
//   //   setState(() => _isSubmitting = true);
//   //
//   //   final selectedItems = webbingList
//   //       .where(_isItemSelected)
//   //       .map(
//   //         (e) => {
//   //           'barcode': e.barcode,
//   //           'code': e.code,
//   //           'lotNo': e.lotNo,
//   //           'flatTubeGusset': e.flatTubeGusset,
//   //           'netWt': e.netWt,
//   //         },
//   //       )
//   //       .toList();
//   //
//   //   final payload = {
//   //     'supervisor_name': _selectedSupervisor,
//   //     'operator_name': _selectedOperator,
//   //     'location': _selectedLocation,
//   //     'issue_to_department': _selectedDepartment,
//   //     'selected_items': selectedItems,
//   //   };
//   //   debugPrint(payload.toString());
//   //
//   //   await Future.delayed(const Duration(milliseconds: 800));
//   //
//   //   final count = _selectedCount;
//   //   setState(() {
//   //     _isSubmitting = false;
//   //     _isSubmitted = true;
//   //     _selectedBarcodes.clear();
//   //   });
//   //   Future.delayed(const Duration(seconds: 3), () {
//   //     if (mounted) setState(() => _isSubmitted = false);
//   //   });
//   //
//   //   if (!mounted) return;
//   //   ScaffoldMessenger.of(context).showSnackBar(
//   //     SnackBar(
//   //       content: Row(
//   //         children: [
//   //           const Icon(
//   //             Icons.check_circle_rounded,
//   //             color: Colors.white,
//   //             size: 18,
//   //           ),
//   //           const SizedBox(width: 8),
//   //           Text("$count item(s) forwarded successfully"),
//   //         ],
//   //       ),
//   //       backgroundColor: const Color(0xFF2E7D32),
//   //       behavior: SnackBarBehavior.floating,
//   //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//   //       margin: const EdgeInsets.all(16),
//   //     ),
//   //   );
//   // }
//
//   // ─────────────────────────────────────
//   //  FORWARD — calls webbingOutSave for
//   //  every selected item, shows result
//   // ─────────────────────────────────────
//   Future<void> _onForward() async {
//     if (!_formKey.currentState!.validate() || !_anySelected) return;
//
//     setState(() {
//       _isSubmitting = true;
//       _submitResults.clear();
//     });
//
//     final selectedItems = webbingList.where(_isItemSelected).toList();
//
//     debugPrint("Total items to forward: ${selectedItems.length}");
//     int successCount = 0;
//     int failCount = 0;
//     final List<String> failMessages = [];
//
//     for (final item in selectedItems) {
//       try {
//         final res = await JblApiService.webbingOutSave(
//           plant: "JBL",
//           location: _selectedDepartment!,
//           barcode: item.code ?? "",
//           operator: _selectedOperator!,
//           // supervisor: _selectedSupervisor!,
//           supervisor: _selectedDepartment!,
//
//           machine: _selectedSupervisor!,
//           // _selectedDepartment!, // mapped to "machine" as per API body
//           workOrderNo: "",
//         );
//         debugPrint(
//           "API Response -> ${item.barcode} : ${res.success} | ${res.message}",
//         );
//         // Store per-item result
//         setState(() {
//           _submitResults[item.barcode ?? item.code ?? ""] = res;
//         });
//
//         if (res.success) {
//           successCount++;
//         } else {
//           failCount++;
//           failMessages.add("${item.barcode ?? item.code}: ${res.message}");
//         }
//       } catch (e) {
//         debugPrint("API ERROR for ${item.barcode} : $e");
//         failCount++;
//         failMessages.add("${item.barcode ?? item.code}: Error - $e");
//       }
//     }
//
//     setState(() {
//       _isSubmitting = false;
//       // Clear only successful selections
//       for (final item in selectedItems) {
//         final key = item.barcode ?? item.code ?? "";
//         final res = _submitResults[key];
//         if (res != null && res.success) {
//           _selectedBarcodes.remove(key);
//         }
//       }
//     });
//
//     if (!mounted) return;
//
//     // Show combined result snackbar
//     if (failCount == 0) {
//       // All success
//       _showSnackbar(
//         icon: Icons.check_circle_rounded,
//         color: const Color(0xFF2E7D32),
//         message: "$successCount item(s) forwarded successfully",
//       );
//     } else if (successCount == 0) {
//       // All failed
//       _showSnackbar(
//         icon: Icons.error_rounded,
//         color: const Color(0xFFC62828),
//         message: failMessages.length == 1
//             ? failMessages.first
//             : "$failCount item(s) failed. Tap to see details",
//         details: failMessages,
//       );
//     } else {
//       // Mixed
//       _showSnackbar(
//         icon: Icons.warning_rounded,
//         color: const Color(0xFFE65100),
//         message: "$successCount success, $failCount failed",
//         details: failMessages,
//       );
//     }
//   }
//
//   void _showSnackbar({
//     required IconData icon,
//     required Color color,
//     required String message,
//     List<String>? details,
//   }) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, color: Colors.white, size: 18),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     message,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             if (details != null && details.isNotEmpty) ...[
//               const SizedBox(height: 6),
//               ...details.map(
//                 (d) => Padding(
//                   padding: const EdgeInsets.only(left: 26, bottom: 2),
//                   child: Text(
//                     "• $d",
//                     style: const TextStyle(fontSize: 11, color: Colors.white70),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         margin: const EdgeInsets.all(16),
//         duration: const Duration(seconds: 5),
//       ),
//     );
//   }
//
//   // ─────────────────────────────────────
//   //  Helpers
//   // ─────────────────────────────────────
//   Widget _sectionLabel(String text) => Row(
//     children: [
//       Container(
//         width: 3,
//         height: 15,
//         decoration: BoxDecoration(
//           color: C.brand700,
//           borderRadius: BorderRadius.circular(4),
//         ),
//       ),
//       const SizedBox(width: 8),
//       Text(
//         text,
//         style: const TextStyle(
//           fontSize: 10,
//           fontWeight: FontWeight.w700,
//           color: C.textMid,
//           letterSpacing: 1.5,
//         ),
//       ),
//     ],
//   );
//
//   Widget _buildDropdown({
//     required String hint,
//     required List<String> items,
//     required String? value,
//     required ValueChanged<String?> onChanged,
//     required FormFieldValidator<String> validator,
//   }) => DropdownButtonFormField<String>(
//     value: value,
//     isExpanded: true,
//     isDense: true,
//     dropdownColor: C.cardBg,
//     decoration: InputDecoration(
//       hintText: hint,
//       hintStyle: const TextStyle(
//         fontSize: 12,
//         color: C.textMid,
//         fontWeight: FontWeight.w500,
//       ),
//       filled: true,
//       fillColor: C.brand50,
//       isDense: true,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: C.borderLight),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: C.borderLight, width: 1.2),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: C.brand600, width: 1.8),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: const BorderSide(color: Colors.redAccent),
//       ),
//       errorStyle: const TextStyle(fontSize: 10, height: 1.0),
//     ),
//     icon: const Padding(
//       padding: EdgeInsets.only(right: 4),
//       child: Icon(
//         Icons.keyboard_arrow_down_rounded,
//         color: C.brand500,
//         size: 18,
//       ),
//     ),
//     style: const TextStyle(
//       fontSize: 13,
//       color: C.textHigh,
//       fontWeight: FontWeight.w600,
//     ),
//     selectedItemBuilder: (context) => items
//         .map(
//           (e) => DropdownMenuItem<String>(
//             value: e,
//             child: Text(
//               e,
//               overflow: TextOverflow.ellipsis,
//               maxLines: 1,
//               style: const TextStyle(
//                 fontSize: 13,
//                 color: C.textHigh,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         )
//         .toList(),
//     items: items
//         .map(
//           (e) => DropdownMenuItem<String>(
//             value: e,
//             child: Text(
//               e,
//               style: const TextStyle(fontSize: 13, color: C.textHigh),
//             ),
//           ),
//         )
//         .toList(),
//     onChanged: onChanged,
//     validator: validator,
//   );
//
//   Widget _labeledDropdown({
//     required String label,
//     required IconData icon,
//     required List<String> items,
//     required String? value,
//     required ValueChanged<String?> onChanged,
//   }) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 13, color: C.brand600),
//           const SizedBox(width: 4),
//           Flexible(
//             child: Text(
//               label,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//                 color: C.textMid,
//               ),
//             ),
//           ),
//         ],
//       ),
//       const SizedBox(height: 5),
//       _buildDropdown(
//         hint: "Select",
//         items: items,
//         value: value,
//         onChanged: onChanged,
//         validator: (v) => v == null ? "Required" : null,
//       ),
//     ],
//   );
//
//   Widget _forwardButton() {
//     final Color bg = _isSubmitted
//         ? const Color(0xFF2E7D32)
//         : (_canForward ? C.brand700 : C.brand200);
//
//     Widget label;
//     if (_isSubmitting) {
//       label = const SizedBox(
//         width: 20,
//         height: 20,
//         child: CircularProgressIndicator(color: C.appBar3, strokeWidth: 2.5),
//       );
//     } else if (_isSubmitted) {
//       label = const Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Icon(Icons.check_rounded, color: Colors.white, size: 18),
//           SizedBox(width: 8),
//           Text(
//             "Forwarded Successfully",
//             style: TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.w700,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       );
//     } else {
//       label = Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             "Forward",
//             style: TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.w700,
//               color: _canForward ? Colors.white : C.brand600,
//             ),
//           ),
//           if (_anySelected) ...[
//             const SizedBox(width: 8),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//               decoration: BoxDecoration(
//                 color: Colors.white24,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(
//                 "$_selectedCount",
//                 style: const TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ],
//           const SizedBox(width: 6),
//           Icon(
//             Icons.arrow_forward_rounded,
//             color: _canForward ? Colors.white : C.brand600,
//             size: 18,
//           ),
//         ],
//       );
//     }
//
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       height: 50,
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: _canForward && !_isSubmitting
//             ? [
//                 BoxShadow(
//                   color: C.brand700.withOpacity(0.30),
//                   blurRadius: 14,
//                   offset: const Offset(0, 5),
//                 ),
//               ]
//             : [],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: (_canForward && !_isSubmitting) ? _onForward : null,
//           borderRadius: BorderRadius.circular(12),
//           splashColor: C.brand600.withOpacity(0.2),
//           child: Center(child: label),
//         ),
//       ),
//     );
//   }
//
//   // ─────────────────────────────────────
//   //  TABLE — fixed SizedBox widths only
//   //  NO Expanded, NO LayoutBuilder inside
//   //  SingleChildScrollView(horizontal)
//   // ─────────────────────────────────────
//
//   // Helper: fixed-width cell
//   Widget _cell(Widget child, double w) => SizedBox(width: w, child: child);
//
//   Widget _thText(String t) => Text(
//     t,
//     overflow: TextOverflow.ellipsis,
//     style: const TextStyle(
//       fontSize: 10,
//       fontWeight: FontWeight.w700,
//       color: Colors.white,
//       letterSpacing: 0.4,
//     ),
//   );
//
//   // Table header row
//   Widget _tableHeader() {
//     final allSel = webbingList.isNotEmpty && webbingList.every(_isItemSelected);
//     final someSel = _anySelected && !allSel;
//
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [C.brand700, C.brand600],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         ),
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(12),
//           topRight: Radius.circular(12),
//         ),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
//       child: Row(
//         mainAxisSize: MainAxisSize.min, // ← min, not max
//         children: [
//           _cell(
//             SizedBox(
//               width: 15,
//               height: 22,
//               child: Checkbox(
//                 value: allSel ? true : (someSel ? null : false),
//                 tristate: true,
//                 onChanged: (v) => setState(() {
//                   if (v == true) {
//                     for (final e in webbingList) {
//                       _selectedBarcodes.add(e.barcode ?? e.code ?? "");
//                     }
//                   } else {
//                     _selectedBarcodes.clear();
//                   }
//                 }),
//                 side: const BorderSide(color: Colors.white70, width: 1.5),
//                 checkColor: C.brand700,
//                 fillColor: WidgetStateProperty.resolveWith(
//                   (s) => s.contains(WidgetState.selected)
//                       ? Colors.white
//                       : Colors.transparent,
//                 ),
//                 materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                 visualDensity: VisualDensity.compact,
//               ),
//             ),
//             _colCheck,
//           ),
//
//           _cell(_thText("Code"), _colCode),
//           _cell(_thText("Lot No."), _colLot),
//           _cell(_thText("Fabric Code"), _colSpec),
//           _cell(_thText("Net Wt"), _colWt),
//           _cell(_thText("Barcode"), _colBar),
//         ],
//       ),
//     );
//   }
//
//   // Single data row
//   Widget _tableRow(WebbingFilterModel item, int index, bool isLast) {
//     final sel = _isItemSelected(item);
//     final isEven = index % 2 == 0;
//     final accent = _kAccents[index % _kAccents.length];
//
//     return GestureDetector(
//       onTap: () => _toggleItem(item),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 220),
//         curve: Curves.easeOut,
//         decoration: BoxDecoration(
//           color: sel ? C.brand100 : (isEven ? C.cardBg : C.brand50),
//
//           borderRadius: isLast
//               ? const BorderRadius.only(
//                   bottomLeft: Radius.circular(12),
//                   bottomRight: Radius.circular(12),
//                 )
//               : BorderRadius.zero,
//
//           border: const Border(
//             left: BorderSide(color: C.borderLight),
//             right: BorderSide(color: C.borderLight),
//             bottom: BorderSide(color: C.borderLight),
//           ),
//
//           boxShadow: sel
//               ? [
//                   const BoxShadow(
//                     color: C.brand500,
//                     blurRadius: 0,
//                     spreadRadius: 0,
//                     offset: Offset(-2, 0), // left highlight effect
//                   ),
//                 ]
//               : [],
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
//         child: Row(
//           mainAxisSize: MainAxisSize.min, // ← min, not max
//           children: [
//             // Checkbox
//             _cell(
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 150),
//                 width: 15,
//                 height: 20,
//                 decoration: BoxDecoration(
//                   color: sel ? C.brand600 : Colors.transparent,
//                   borderRadius: BorderRadius.circular(5),
//                   border: Border.all(
//                     color: sel ? C.brand600 : C.brand300,
//                     width: 1.8,
//                   ),
//                 ),
//                 child: sel
//                     ? const Icon(
//                         Icons.check_rounded,
//                         size: 13,
//                         color: Colors.white,
//                       )
//                     : null,
//               ),
//               _colCheck,
//             ),
//
//             // Code
//             _cell(
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Container(
//                   //   width: 3,
//                   //   height: 22,
//                   //   margin: const EdgeInsets.only(right: 5),
//                   //   decoration: BoxDecoration(
//                   //     color: accent,
//                   //     borderRadius: BorderRadius.circular(3),
//                   //   ),
//                   // ),
//                   SizedBox(
//                     width: _colCode - 12,
//                     child: Text(
//                       item.code ?? "-",
//                       overflow: TextOverflow.ellipsis,
//                       maxLines: 1,
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700,
//                         color: sel ? C.brand800 : C.textHigh,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               _colCode,
//             ),
//
//             // Lot No.
//             _cell(
//               SizedBox(
//                 width: _colLot - 6,
//                 child: Text(
//                   item.lotNo ?? "-",
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: sel ? C.brand700 : C.textMid,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//               _colLot,
//             ),
//
//             // Specification (flatTubeGusset)
//             _cell(
//               SizedBox(
//                 width: _colSpec - 6,
//                 child: Text(
//                   item.flatTubeGusset ?? "-",
//                   overflow: TextOverflow.ellipsis,
//                   maxLines: 1,
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: sel ? C.brand700 : C.textMid,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//               _colSpec,
//             ),
//
//             // Net Wt
//             _cell(
//               Container(
//                 width: _colWt - 4,
//                 padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
//                 decoration: BoxDecoration(
//                   color: sel ? C.brand700.withOpacity(0.12) : C.brand50,
//                   borderRadius: BorderRadius.circular(6),
//                   border: Border.all(color: C.brand200),
//                 ),
//                 child: Text(
//                   item.netWt != null
//                       ? "${item.netWt!.toStringAsFixed(2)}"
//                       : "-",
//                   textAlign: TextAlign.center,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w700,
//                     color: sel ? C.brand800 : C.brand700,
//                   ),
//                 ),
//               ),
//               _colWt,
//             ),
//
//             // Barcode
//             _cell(
//               Container(
//                 width: _colBar - 4,
//                 padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
//                 decoration: BoxDecoration(
//                   color: sel ? C.brand700 : C.pillBg,
//                   borderRadius: BorderRadius.circular(6),
//                   border: Border.all(color: sel ? C.brand700 : C.brand200),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.qr_code_rounded,
//                       size: 10,
//                       color: sel ? Colors.white70 : C.brand500,
//                     ),
//                     const SizedBox(width: 3),
//                     SizedBox(
//                       width: _colBar - 26,
//                       child: Text(
//                         item.barcode ?? "-",
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w700,
//                           color: sel ? Colors.white : C.pillText,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               _colBar,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Loading / Error / Empty / Data states
//   Widget _tableBody(double tableW) {
//     Widget inner;
//
//     if (isLoading) {
//       inner = Container(
//         padding: const EdgeInsets.symmetric(vertical: 48),
//         child: const Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircularProgressIndicator(color: C.appBar3, strokeWidth: 2.5),
//             SizedBox(height: 14),
//             Text(
//               "Loading webbing data...",
//               style: TextStyle(fontSize: 12, color: C.textMid),
//             ),
//           ],
//         ),
//       );
//     } else if (_errorMsg != null) {
//       inner = Padding(
//         padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(
//               Icons.error_outline_rounded,
//               color: Color(0xFFE53935),
//               size: 32,
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               "Failed to load data",
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w700,
//                 color: Color(0xFFE53935),
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               _errorMsg!,
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 11, color: C.textMid),
//             ),
//             const SizedBox(height: 16),
//             GestureDetector(
//               onTap: loadWebbing,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: C.brand600,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Text(
//                   "Retry",
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     } else if (_filteredList.isEmpty) {
//       inner = const Padding(
//         padding: EdgeInsets.symmetric(vertical: 40),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.inventory_2_outlined, color: C.brand300, size: 36),
//             SizedBox(height: 10),
//             Text(
//               "No webbing stock found",
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: C.textMid,
//               ),
//             ),
//           ],
//         ),
//       );
//     } else {
//       // Real data rows — Column with fixed-width rows
//       inner = SizedBox(
//         height: 500, // give table a fixed height
//         child: ListView.builder(
//           itemCount: _filteredList.length,
//           itemBuilder: (context, i) {
//             return _tableRow(
//               _filteredList[i],
//               i,
//               i == _filteredList.length - 1,
//             );
//           },
//         ),
//       );
//     }
//
//     return Container(
//       width: tableW,
//       decoration: BoxDecoration(
//         color: _errorMsg != null ? const Color(0xFFFFF5F5) : C.brand50,
//         border: _errorMsg != null
//             ? Border.all(color: const Color(0xFFFFCDD2))
//             : const Border(
//                 left: BorderSide(color: C.borderLight),
//                 right: BorderSide(color: C.borderLight),
//                 bottom: BorderSide(color: C.borderLight),
//               ),
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(12),
//           bottomRight: Radius.circular(12),
//         ),
//       ),
//       child: webbingList.isNotEmpty && _errorMsg == null
//           ? inner // rows don't need Center
//           : Center(child: inner),
//     );
//   }
//
//   // ── Build ──────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     // ← Use MediaQuery here (outside scroll) — safe, no LayoutBuilder inside scroll
//     final screenW = MediaQuery.of(context).size.width;
//     final tableW = screenW > _tableMinWidth + 32
//         ? screenW -
//               32 // stretch on wide screens
//         : _tableMinWidth; // scroll on narrow screens
//
//     return Scaffold(
//       backgroundColor: C.pageBg,
//
//       appBar: AppBar(
//         backgroundColor: C.primary,
//         elevation: 0,
//         // leading: IconButton(
//         //   icon: const Icon(
//         //     Icons.arrow_back_sharp,
//         //     color: Colors.white,
//         //     size: 22,
//         //   ),
//         //   onPressed: () => Navigator.maybePop(context),
//         // ),
//         iconTheme: const IconThemeData(color: Colors.white),
//
//         title: Row(
//           children: [
//             const Flexible(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Webbing Out",
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w800,
//                       color: Colors.white,
//                     ),
//                   ),
//                   // Text(
//                   //   "Issue Management",
//                   //   overflow: TextOverflow.ellipsis,
//                   //   style: TextStyle(
//                   //     fontSize: 10,
//                   //     color: Colors.white70,
//                   //     letterSpacing: 0.8,
//                   //   ),
//                   // ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           if (_anySelected)
//             Padding(
//               padding: const EdgeInsets.only(right: 8),
//               child: TextButton.icon(
//                 onPressed: (_canForward && !_isSubmitting) ? _onForward : null,
//                 icon: _isSubmitting
//                     ? const SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: C.appBar3,
//                         ),
//                       )
//                     : const Icon(Icons.arrow_forward, color: Colors.white),
//                 label: Text(
//                   _isSubmitting ? "Forwarding..." : "Forward ($_selectedCount)",
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),
//         ],
//       ),
//
//       body: FutureBuilder<InStockWebController>(
//         future: _dropdownFuture,
//         builder: (context, ddSnap) {
//           if (ddSnap.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(color: C.appBar3,),
//             );
//           }
//           final dd = ddSnap.data!;
//
//           return Form(
//             key: _formKey,
//             child: CustomScrollView(
//               controller: _scrollController,
//               slivers: [
//                 // ── Form Card ─────────────────────
//                 SliverToBoxAdapter(
//                   child: Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: C.cardBg,
//                       borderRadius: BorderRadius.circular(18),
//                       border: Border.all(color: C.borderLight),
//                       boxShadow: [
//                         BoxShadow(
//                           color: C.brand300.withOpacity(0.18),
//                           blurRadius: 20,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // _sectionLabel("ISSUE DETAILS"),
//                         // const SizedBox(height: 14),
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               child: _labeledDropdown(
//                                 label: "Supervisor",
//                                 icon: Icons.person_outline_rounded,
//                                 items: dd.supervisors,
//                                 value: _selectedSupervisor,
//                                 onChanged: (v) =>
//                                     setState(() => _selectedSupervisor = v),
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: _labeledDropdown(
//                                 label: "Operator",
//                                 icon: Icons.engineering_outlined,
//                                 items: dd.operators,
//                                 value: _selectedOperator,
//                                 onChanged: (v) =>
//                                     setState(() => _selectedOperator = v),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               child: _labeledDropdown(
//                                 label: "Location",
//                                 icon: Icons.location_on_outlined,
//                                 // items: dd.locations,
//                                 items: dd.locations
//                                     .map((e) {
//                                       if (e == loggedUnit) {
//                                         return "CUTTING"; // replace logged unit with Cutting
//                                       }
//                                       return e;
//                                     })
//                                     .toSet()
//                                     .toList(),
//                                 value: _selectedLocation,
//                                 onChanged: (v) =>
//                                     setState(() => _selectedLocation = v),
//                               ),
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: _labeledDropdown(
//                                 label: "Department",
//                                 icon: Icons.business_outlined,
//                                 items: const ["CUTTING", "FINISHING", "OTHER"],
//
//                                 value: _selectedDepartment,
//                                 onChanged: (v) =>
//                                     setState(() => _selectedDepartment = v),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 // ── Stock Section Label ───────────
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
//                     child: Row(
//                       children: [
//                         _sectionLabel("WEBBING STOCK"),
//                         const SizedBox(width: 8),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 3,
//                           ),
//                           decoration: BoxDecoration(
//                             color: C.pillBg,
//                             borderRadius: BorderRadius.circular(20),
//                             border: Border.all(color: C.brand200),
//                           ),
//                           child: Text(
//                             // "${webbingList.length} items",
//                             "${_filteredList.length} items",
//                             style: const TextStyle(
//                               fontSize: 10,
//                               fontWeight: FontWeight.w700,
//                               color: C.pillText,
//                             ),
//                           ),
//                         ),
//                         const Spacer(),
//                         GestureDetector(
//                           onTap: isLoading ? null : loadWebbing,
//                           child: Container(
//                             padding: const EdgeInsets.all(6),
//                             decoration: BoxDecoration(
//                               color: C.brand100,
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: C.brand200),
//                             ),
//                             child: Icon(
//                               isLoading
//                                   ? Icons.hourglass_top_rounded
//                                   : Icons.refresh_rounded,
//                               size: 14,
//                               color: C.brand600,
//                             ),
//                           ),
//                         ),
//                         if (_anySelected) ...[
//                           const SizedBox(width: 10),
//                           GestureDetector(
//                             onTap: () =>
//                                 setState(() => _selectedBarcodes.clear()),
//                             child: const Text(
//                               "Clear all",
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: C.brand600,
//                                 fontWeight: FontWeight.w600,
//                                 decoration: TextDecoration.underline,
//                                 decorationColor: C.brand600,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(12, 0, 16, 10),
//                     child: TextField(
//                       controller: _searchController,
//                       // onChanged: _filterSearch,
//                       onChanged: (value) {
//                         setState(() {}); // for clear icon visibility
//                         _filterSearch(value);
//                       },
//                       decoration: InputDecoration(
//                         hintText: "Search Code or Lot No",
//                         prefixIcon: const Icon(Icons.search),
//                         suffixIcon: _searchController.text.isNotEmpty
//                             ? IconButton(
//                                 icon: const Icon(Icons.clear),
//                                 onPressed: () {
//                                   _searchController.clear();
//                                   setState(() {}); // refresh UI
//                                   loadWebbing(); // reload full data
//                                 },
//                               )
//                             : null,
//                         filled: true,
//                         fillColor: Colors.white,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // ── Table ─────────────────────────
//                 // KEY FIX: MediaQuery-computed tableW used here
//                 // No LayoutBuilder inside SingleChildScrollView
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       physics: const BouncingScrollPhysics(),
//                       child: SizedBox(
//                         width: tableW,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.stretch,
//                           children: [_tableHeader(), _tableBody(tableW)],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 const SliverToBoxAdapter(child: SizedBox(height: 24)),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
