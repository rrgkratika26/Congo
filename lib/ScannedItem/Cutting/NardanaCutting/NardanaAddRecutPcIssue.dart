// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// import '../../../Color/Colorclass.dart';
// import '../../../services/getSupervisors/getSupervisors.dart';
// import '../../../services/JBL_apis/jbl_api_bailing_reports.dart';
//
// class AddRecutPcsPopup_Naradan {
//   static Future<void> show(
//       BuildContext context, {
//         VoidCallback? onSaved,
//       }) async {
//     // ── Controllers ──────────────────────────────────────────────────────────
//     final cutWidthCtrl = TextEditingController();
//     final cutLengthCtrl = TextEditingController();
//     final cutSizeQtyCtrl = TextEditingController();
//     final netWtCtrl = TextEditingController();
//
//     // ── Dropdown state ───────────────────────────────────────────────────────
//     List<Map<String, dynamic>> idList = []; // [{id, woNumber}]
//     List<String> woList = [];
//     List<String> components = [];
//     // int? rollEntryId;
//     int? selectedId;
//     String? selectedWo;
//     String? selectedComponent;
//
//     bool isLoadingIds = true;
//     bool isLoadingWo = false;
//     bool isLoadingComp = false;
//     bool isSaving = false;
//     String? fetchError;
//
//     // ── Fetch Work Orders for selected IID ───────────────────────────────────
//     // ✅ FIRST define loadWorkOrders
//     Future<void> loadWorkOrders(StateSetter setState) async {
//       setState(() {
//         isLoadingWo = true;
//         woList = [];
//       });
//
//       try {
//         final url = Uri.parse('${InStockService.baseUrl}/Cutting/wo-numbers');
//
//         debugPrint("===== WORK ORDER API HIT =====");
//         debugPrint("URL: $url");
//
//         final res = await http.get(
//           url,
//           headers: await InStockService.authHeaders(),
//         );
//
//         debugPrint("STATUS: ${res.statusCode}");
//         debugPrint("BODY: ${res.body}");
//
//         if (res.statusCode == 200) {
//           final List data = jsonDecode(res.body);
//
//           final List<String> tempList = data
//               .map<String>((e) => e['wO_NUMBER'].toString())
//               .toList();
//
//           setState(() {
//             woList = tempList;
//           });
//
//           debugPrint("WO COUNT: ${woList.length}");
//         } else {
//           debugPrint("WO API FAILED");
//         }
//       } catch (e) {
//         debugPrint("WO ERROR: $e");
//       }
//
//       setState(() {
//         isLoadingWo = false;
//       });
//     }
// // ✅ THEN define fetchIds
//     Future<void> fetchIds(StateSetter setState) async {
//       try {
//         setState(() => isLoadingIds = true);
//
//         final id = await JblApiService.getNextRollEntryId();
//
//         setState(() {
//           selectedId = id;
//           isLoadingIds = false;
//         });
//
//         // ✅ now works
//         await loadWorkOrders(setState);
//
//       } catch (e) {
//         debugPrint("ID ERROR: $e");
//         setState(() => isLoadingIds = false);
//       }
//     }
//
//     Future<void> fetchFabricCutSize(
//         StateSetter setState,
//         String woNumber,
//         String component,
//         ) async {
//       try {
//         final data = await JblApiService.getFabricCutSize(
//           woNumber: woNumber,
//           component: component,
//         );
//         // 🔥 PRINT FULL RESPONSE
//         debugPrint("Fabric Cut Size API Response: $data");
//
//         // 🔥 OPTIONAL: print specific fields
//         debugPrint("Width: ${data['fabricsize_addqty']}");
//         debugPrint("Length: ${data['cutsize_addwt']}");
//
//         setState(() {
//           cutWidthCtrl.text = data['fabricsize_addqty'].toString();
//           cutLengthCtrl.text = data['cutsize_addwt'].toString();
//         });
//       } catch (e) {
//         debugPrint('Error fetching Fabric Cut Size: $e');
//       }
//     }
//
//     // ── Fetch IID list ───────────────────────────────────────────────────────
//
//
//     // ── Fetch Components for selected WO ─────────────────────────────────────
//     Future<void> fetchComponents(StateSetter setState, String woNumber) async {
//       setState(() {
//         isLoadingComp = true;
//         components = [];
//         selectedComponent = null;
//       });
//       try {
//         // final url = Uri.parse(
//         //   'https://190.92.175.47:80/JblAPI/api/Cutting/ComponentInCuttingIssued?woNumber=${Uri.encodeComponent(woNumber)}',
//         // );
//         final url = Uri.parse(
//           '${InStockService.baseUrl}/Cutting/ComponentInCuttingIssued?woNumber=${Uri.encodeComponent(woNumber)}',
//         );
//         final res = await http.get(
//           url,
//           headers: await InStockService.authHeaders(),
//         );
//         if (res.statusCode == 200) {
//           final List data = jsonDecode(res.body);
//           components = data
//               .map<String>((e) => e['component'].toString())
//               .toList();
//         }
//       } catch (_) {}
//       setState(() {
//         isLoadingComp = false;
//       });
//     }
//
//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 440),
//           child: StatefulBuilder(
//             builder: (context, setState) {
//               // Trigger initial fetch
//               if (isLoadingIds && idList.isEmpty && fetchError == null) {
//                 fetchIds(setState);
//               }
//
//               return ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // ── Header ───────────────────────────────────────────
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 16,
//                       ),
//                       color: C.primary,
//                       child: Row(
//                         children: [
//                           const Icon(
//                             Icons.add_circle_outline,
//                             color: Colors.white,
//                             size: 22,
//                           ),
//                           const SizedBox(width: 10),
//                           const Expanded(
//                             child: Text(
//                               'Add Recut PCS Issue',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: () => Navigator.pop(context),
//                             child: const Icon(
//                               Icons.close,
//                               color: Colors.white70,
//                               size: 20,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     // ── Form ─────────────────────────────────────────────
//                     Flexible(
//                       child: SingleChildScrollView(
//                         padding: const EdgeInsets.all(20),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             if (fetchError != null)
//                               Container(
//                                 padding: const EdgeInsets.all(10),
//                                 margin: const EdgeInsets.only(bottom: 14),
//                                 decoration: BoxDecoration(
//                                   color: Colors.red.shade50,
//                                   borderRadius: BorderRadius.circular(8),
//                                   border: Border.all(
//                                     color: Colors.red.shade200,
//                                   ),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Icon(
//                                       Icons.warning_amber_rounded,
//                                       color: Colors.red.shade400,
//                                       size: 18,
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                       child: Text(
//                                         fetchError!,
//                                         style: TextStyle(
//                                           color: Colors.red.shade700,
//                                           fontSize: 12,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//
//                             // ── ID (IID) ──────────────────────────────────
//                             // ── ID (IID) ──────────────────────────────────
//                             _SectionLabel(label: 'ID (IID)'),
//                             const SizedBox(height: 6),
//                             isLoadingIds
//                                 ? _LoadingField(label: 'Fetching ID...')
//                                 : Container(
//                               height: 48,
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: C.brand50,
//                                 borderRadius: BorderRadius.circular(10),
//                                 border: Border.all(color: C.borderLight),
//                               ),
//                               alignment: Alignment.centerLeft,
//                               child: Text(
//                                 selectedId?.toString() ?? '—',
//                                 style: const TextStyle(
//                                   fontSize: 13,
//                                   color: C.textHigh,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//
//                             const SizedBox(height: 14),
//
//                             // ── Work Order ────────────────────────────────
//                             _SectionLabel(label: 'Work Order'),
//                             const SizedBox(height: 6),
//
//                             isLoadingWo
//                                 ? _LoadingField(label: 'Loading work orders...')
//                                 : DropdownButtonFormField<String>(
//                               value: selectedWo,
//                               isExpanded: true,
//                               hint: const Text("Select Work Order"),
//                               items: woList.map((wo) {
//                                 return DropdownMenuItem<String>(
//                                   value: wo,
//                                   child: Text(wo),
//                                 );
//                               }).toList(),
//                               onChanged: (val) {
//                                 setState(() {
//                                   selectedWo = val;
//                                 });
//
//                                 if (val != null) {
//                                   fetchComponents(setState, val);
//                                 }
//                               },
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 contentPadding:
//                                 const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                             ),
//
//                             const SizedBox(height: 14),
//
//                             // ── Component ─────────────────────────────────
//                             _SectionLabel(label: 'Component'),
//                             const SizedBox(height: 6),
//                             isLoadingComp
//                                 ? _LoadingField(label: 'Loading components...')
//                                 : _StyledDropdown<String>(
//                               hint: selectedWo == null
//                                   ? 'Select Work Order first'
//                                   : components.isEmpty
//                                   ? 'No components found'
//                                   : 'Select Component',
//                               value: selectedComponent,
//                               items: components
//                                   .map(
//                                     (c) => DropdownMenuItem(
//                                   value: c,
//                                   child: Text(c),
//                                 ),
//                               )
//                                   .toList(),
//                               onChanged: components.isEmpty
//                                   ? null
//                                   : (val) {
//                                 setState(
//                                       () => selectedComponent = val,
//                                 );
//                                 if (selectedWo != null &&
//                                     val != null) {
//                                   fetchFabricCutSize(
//                                     setState,
//                                     selectedWo!,
//                                     val,
//                                   );
//                                 }
//                               },
//                             ),
//
//                             const SizedBox(height: 15),
//
//                             // ── Divider ───────────────────────────────────
//                             Divider(color: C.borderLight, height: 1),
//                             const SizedBox(height: 18),
//
//                             // ── Cut Width & Cut Length (side by side) ─────
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       _SectionLabel(label: 'Cut Width (CM)'),
//                                       const SizedBox(height: 6),
//                                       _StyledTextField(
//                                         controller: cutWidthCtrl,
//                                         hint: '0.00',
//                                         isNumeric: true,
//                                         readOnly: true, // ← NEW
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       _SectionLabel(label: 'Cut Length (CM)'),
//                                       const SizedBox(height: 6),
//                                       _StyledTextField(
//                                         controller: cutLengthCtrl,
//                                         hint: '0.00',
//                                         isNumeric: true,
//                                         readOnly: true,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//
//                             const SizedBox(height: 14),
//
//                             // ── Cut Size QTY & Net Wt (side by side) ──────
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       _SectionLabel(label: 'Cut Size QTY'),
//                                       const SizedBox(height: 6),
//                                       _StyledTextField(
//                                         controller: cutSizeQtyCtrl,
//                                         hint: '0',
//                                         isNumeric: true,
//                                         readOnly: false,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       _SectionLabel(label: 'Net Wt (KG)'),
//                                       const SizedBox(height: 6),
//                                       _StyledTextField(
//                                         controller: netWtCtrl,
//                                         hint: '0.00',
//                                         isNumeric: true,
//                                         readOnly: true,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//
//                             const SizedBox(height: 28),
//
//                             // ── Buttons ───────────────────────────────────
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: ElevatedButton(
//                                     onPressed: isSaving
//                                         ? null
//                                         : () async {
//                                       // Validation
//                                       if (selectedId == null ||
//                                           selectedWo == null ||
//                                           selectedComponent == null ||
//                                           cutWidthCtrl.text
//                                               .trim()
//                                               .isEmpty ||
//                                           cutLengthCtrl.text
//                                               .trim()
//                                               .isEmpty ||
//                                           cutSizeQtyCtrl.text
//                                               .trim()
//                                               .isEmpty ||
//                                           netWtCtrl.text.trim().isEmpty) {
//                                         ScaffoldMessenger.of(
//                                           context,
//                                         ).showSnackBar(
//                                           const SnackBar(
//                                             content: Text(
//                                               'Please fill all fields',
//                                             ),
//                                             backgroundColor:
//                                             Colors.orange,
//                                           ),
//                                         );
//                                         return;
//                                       }
//
//                                       setState(() => isSaving = true);
//
//                                       final success =
//                                       await JblApiService.addRecutPcsIssue(
//                                         iid: selectedId!,
//                                         woNumber: selectedWo!,
//                                         component: selectedComponent!,
//                                         cutWidth:
//                                         double.tryParse(
//                                           cutWidthCtrl.text,
//                                         ) ??
//                                             0,
//                                         cutLength:
//                                         double.tryParse(
//                                           cutLengthCtrl.text,
//                                         ) ??
//                                             0,
//                                         cutSizeQty:
//                                         double.tryParse(
//                                           cutSizeQtyCtrl.text,
//                                         ) ??
//                                             0,
//                                         netWt:
//                                         double.tryParse(
//                                           netWtCtrl.text,
//                                         ) ??
//                                             0,
//                                       );
//
//                                       setState(() => isSaving = false);
//
//                                       ScaffoldMessenger.of(
//                                         context,
//                                       ).showSnackBar(
//                                         SnackBar(
//                                           content: Text(
//                                             success
//                                                 ? 'Saved successfully'
//                                                 : 'Save failed',
//                                           ),
//                                           backgroundColor: success
//                                               ? Colors.green
//                                               : Colors.red,
//                                           behavior:
//                                           SnackBarBehavior.floating,
//                                         ),
//                                       );
//
//                                       if (success) {
//                                         Navigator.pop(context);
//                                         onSaved?.call();
//                                       }
//                                     },
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: C.primary,
//                                       foregroundColor: Colors.white,
//                                       padding: const EdgeInsets.symmetric(
//                                         vertical: 13,
//                                       ),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(10),
//                                       ),
//                                       elevation: 2,
//                                     ),
//                                     child: isSaving
//                                         ? const SizedBox(
//                                       height: 18,
//                                       width: 18,
//                                       child: CircularProgressIndicator(
//                                         color: Colors.white,
//                                         strokeWidth: 2,
//                                       ),
//                                     )
//                                         : const Text(
//                                       'Save',
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.w700,
//                                         fontSize: 15,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ── Helper Widgets ────────────────────────────────────────────────────────────
//
// class _SectionLabel extends StatelessWidget {
//   final String label;
//   const _SectionLabel({required this.label});
//
//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       label,
//       style: const TextStyle(
//         fontSize: 12,
//         fontWeight: FontWeight.w600,
//         color: C.textMid,
//         letterSpacing: 0.3,
//       ),
//     );
//   }
// }
//
// class _LoadingField extends StatelessWidget {
//   final String label;
//   const _LoadingField({required this.label});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 48,
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: C.brand50,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: C.borderLight),
//       ),
//       child: Row(
//         children: [
//           const SizedBox(
//             width: 16,
//             height: 16,
//             child: CircularProgressIndicator(strokeWidth: 2, color: C.brand500),
//           ),
//           const SizedBox(width: 10),
//           Text(label, style: const TextStyle(fontSize: 13, color: C.textMid)),
//         ],
//       ),
//     );
//   }
// }
//
// class _StyledDropdown<T> extends StatelessWidget {
//   final String hint;
//   final T? value;
//   final List<DropdownMenuItem<T>> items;
//   final ValueChanged<T?>? onChanged;
//
//   const _StyledDropdown({
//     required this.hint,
//     required this.value,
//     required this.items,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: onChanged == null ? C.brand50 : Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: C.borderLight),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButtonFormField<T>(
//           value: value,
//           hint: Text(
//             hint,
//             style: const TextStyle(fontSize: 13, color: C.textMid),
//           ),
//           items: items,
//           onChanged: onChanged,
//           decoration: const InputDecoration(
//             border: InputBorder.none,
//             contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//             isDense: true,
//           ),
//           style: const TextStyle(
//             fontSize: 13,
//             color: C.textHigh,
//             fontWeight: FontWeight.w500,
//           ),
//           icon: const Icon(
//             Icons.keyboard_arrow_down_rounded,
//             color: C.brand600,
//             size: 22,
//           ),
//           isExpanded: true,
//         ),
//       ),
//     );
//   }
// }
//
// class _StyledTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hint;
//   final bool isNumeric;
//   final bool readOnly;
//
//   const _StyledTextField({
//     required this.controller,
//     required this.hint,
//     this.isNumeric = false,
//     required this.readOnly,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       readOnly: readOnly, // ✅ FIXED
//       keyboardType: isNumeric
//           ? const TextInputType.numberWithOptions(decimal: true)
//           : TextInputType.text,
//       decoration: InputDecoration(
//         hintText: hint,
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//     );
//   }
// }
