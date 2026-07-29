// import 'package:IMS/services/getSupervisors/getSupervisors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// import 'dispatch/DispatchModel.dart';
//
// class BalingDispatchScreen extends StatefulWidget {
//   const BalingDispatchScreen({Key? key}) : super(key: key);
//
//   @override
//   State<BalingDispatchScreen> createState() => _BalingDispatchScreenState();
// }
//
// class _BalingDispatchScreenState extends State<BalingDispatchScreen> {
//   final TextEditingController articleCtrl = TextEditingController();
//   final TextEditingController srCtrl = TextEditingController();
//   final TextEditingController barcodeCtrl = TextEditingController();
//   final TextEditingController flagCtrl = TextEditingController();
//   final TextEditingController baleNwtCtrl = TextEditingController();
//   final TextEditingController baleGwtCtrl = TextEditingController();
//   final TextEditingController tabNoCtrl = TextEditingController();
//   final TextEditingController entryoutCtrl = TextEditingController();
//
//   final DateTime now = DateTime.now();
//
//   List<DispatchBailRecord> dispatchRecords = [];
//   bool isLoading = true;
//
//   List<String> partyList = [];
//   List<String> bomList = [];
//   List<String> poList = [];
//   List<String> supervisorList = [];
//   List<String> operatorList = [];
//
//   String? party;
//   String? bom;
//   String? po;
//   String? supervisor;
//   String? operatorName;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadInitialData();
//     _loadSupervisors();
//   }
//
//   Future<void> _loadSupervisors() async {
//     try {
//       final list = await InStockService().getSupervisorsList();
//
//       setState(() {
//         supervisorList = list;
//       });
//     } catch (e) {
//       debugPrint("Supervisor fetch error: $e");
//     }
//   }
//
//   Future<void> _tryFetchArticle() async {
//     if (party == null || bom == null) return;
//
//     setState(() {
//       articleCtrl.text = "Fetching...";
//     });
//
//     try {
//       final articleNo = await InStockService.fetchArticleNumber(
//         partyName: party!,
//         bomNumber: bom!,
//       );
//
//       setState(() {
//         articleCtrl.text = articleNo ?? "";
//       });
//     } catch (e) {
//       setState(() {
//         articleCtrl.clear();
//       });
//
//       debugPrint("Article fetch error: $e");
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to fetch article number")),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     articleCtrl.dispose();
//     srCtrl.dispose();
//     // srNumCtrl.dispose();
//     barcodeCtrl.dispose();
//     // bagCtrl.dispose();
//     // baleCtrl.dispose();
//     flagCtrl.dispose();
//     // lam1Ctrl.dispose();
//     // lam2Ctrl.dispose();
//     tabNoCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadInitialData() async {
//     try {
//       final result = await InStockService.fetchDispatchInit();
//
//       setState(() {
//         srCtrl.text = result.srNo.toString();
//         partyList = result.partyNames;
//         supervisorList = result.supervisors;
//         operatorList = result.operators;
//         poList = result.poNumbers;
//         isLoading = false;
//       });
//     } catch (e) {
//       isLoading = false;
//       debugPrint("Dispatch init error: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _articleSection(),
//             _sectionCard(title: "Order Details", child: _dropdownSection()),
//             const SizedBox(height: 16),
//             _sectionCard(title: "Personnel", child: _supervisorSection()),
//             const SizedBox(height: 10),
//             _barcodeSection(),
//             const SizedBox(height: 10),
//             _dataTable(),
//             const SizedBox(height: 10),
//             _actionButtons(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Section Card with Title
//   Widget _sectionCard({required String title, required Widget child}) {
//     return Card(
//       elevation: 0,
//       color: Colors.white,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: Colors.grey.shade200, width: 1),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[700],
//                 letterSpacing: 0.5,
//               ),
//             ),
//             const SizedBox(height: 10),
//             child,
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// ARTICLE & SR
//   Widget _articleSection() {
//     return Row(
//       children: [
//         Expanded(
//           flex: 3,
//           child: _buildTextField(
//             controller: articleCtrl,
//             label: "Article Number",
//             hint: "Enter article number",
//             readOnly: true,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: _buildTextField(
//             controller: srCtrl,
//             label: "Sr.No.",
//             readOnly: true,
//           ),
//         ),
//       ],
//     );
//   }
//
//   /// Custom TextField
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     String? hint,
//     bool readOnly = false,
//   }) {
//     return TextField(
//       controller: controller,
//       readOnly: readOnly,
//       style: const TextStyle(
//         fontSize: 12,
//         height: 1.2,
//       ), // 👈 keeps text compact),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: Colors.black, fontSize: 14),
//         hintText: hint,
//         hintStyle: TextStyle(color: Colors.grey),
//
//         isDense: true,
//         filled: true,
//         fillColor: readOnly ? Colors.grey[100] : Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Colors.grey, width: 1),
//         ),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 10,
//           vertical: 14,
//         ),
//       ),
//     );
//   }
//
//   /// PARTY / BOM / PO
//   Widget _dropdownSection() {
//     return Column(
//       children: [
//         _dropdown("Party Name", party, partyList, (v) async {
//           if (v == null) return;
//
//           setState(() {
//             party = v;
//             bom = null;
//             po = null;
//
//             bomList.clear();
//             poList.clear();
//           });
//
//           try {
//             final boms = await InStockService.fetchBomNumbers(v);
//             final pos = await InStockService.fetchPONumbers(partyName: v);
//
//             setState(() {
//               bomList = boms;
//               poList = pos;
//             });
//           } catch (e) {
//             debugPrint("Party dependent fetch error: $e");
//           }
//         }),
//
//         const SizedBox(height: 14),
//
//         _dropdown("BOM No.", bom, bomList, (v) {
//           setState(() {
//             bom = v;
//             articleCtrl.clear();
//           });
//
//           _tryFetchArticle(); // 🔥 safe call
//         }),
//
//         const SizedBox(height: 14),
//         _dropdown("PO Number", po, poList, (v) {
//           setState(() => po = v);
//         }),
//       ],
//     );
//   }
//
//   /// SUPERVISOR / OPERATOR
//   Widget _supervisorSection() {
//     return Column(
//       children: [
//         _dropdown("Supervisor", supervisor, supervisorList, (v) {
//           setState(() => supervisor = v);
//         }),
//
//         const SizedBox(height: 14),
//         _dropdown("Operator", operatorName, operatorList, (v) {
//           setState(() => operatorName = v);
//         }),
//       ],
//     );
//   }
//
//   /// BARCODE
//   Widget _barcodeSection() {
//     return Card(
//       color: Colors.white,
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: Colors.grey.shade200, width: 1),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: barcodeCtrl,
//                 style: const TextStyle(fontSize: 12),
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                 decoration: InputDecoration(
//                   labelText: "Enter Barcode",
//                   labelStyle: TextStyle(color: Colors.grey),
//                   hintText: "Scan or enter manually",
//                   prefixIcon: Icon(Icons.qr_code, color: Colors.grey[600]),
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: BorderSide(color: Colors.grey.shade300),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: BorderSide(color: Colors.grey.shade300),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: const BorderSide(color: Colors.grey, width: 1),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 14,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             ElevatedButton.icon(
//               onPressed: () async {
//                 if (srCtrl.text.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("SR No not available")),
//                   );
//                   return;
//                 }
//
//                 FocusScope.of(context).unfocus();
//
//                 try {
//                   final srNo = int.tryParse(barcodeCtrl.text);
//
//                   if (srNo == null) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Invalid SR No")),
//                     );
//                     return;
//                   }
//
//                   setState(() {
//                     barcodeCtrl.clear(); // don't put text like "Fetching..."
//                   });
//
//                   final result = await InStockService.fetchBarcodeBySrNo(
//                     srNo: srNo,
//                   );
//
//                   if (!result.found) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text(result.message ?? "Barcode not found"),
//                       ),
//                     );
//                     return;
//                   }
//
//                   setState(() {
//                     // barcodeCtrl.text = result.barcode ?? "";
//
//                     dispatchRecords.add(
//                       DispatchBailRecord(
//                         srNo: srCtrl.text,
//                         srno: int.tryParse(result.srno?.toString() ?? "0") ?? 0,
//                         date: DateTime.now(),
//                         entryout: entryoutCtrl.text,
//                         barcode: result.barcode ?? "",
//                         partyName: result.partyname ?? "",
//                         workOrder: po ?? "",
//                         articleNo: articleCtrl.text,
//                         transportName: "",
//                         truckNo: "",
//                         driverContact: "",
//                         dispatchDepartment: "",
//                         dispatchPerson: "",
//                         supervisor: supervisor ?? "",
//                         operator: operatorName ?? "",
//                         remark: result.remark ?? "",
//                         printStatus: "",
//                         bagType: result.status ?? "",
//                         shift: "",
//                         baleNo: result.entryout ?? "",
//                         bagQtyInPcs:
//                             int.tryParse(result.remark?.toString() ?? "0") ?? 0,
//                         palletNwt:
//                             double.tryParse(
//                               result.activein?.toString() ?? "0",
//                             ) ??
//                             0.0,
//
//                         palletGrossWt:
//                             double.tryParse(
//                               result.activeout?.toString() ?? "0",
//                             ) ??
//                             0.0,
//
//                         palletWtGm:
//                             double.tryParse(result.remark?.toString() ?? "0") ??
//                             0.0,
//
//                         bagSize: result.department ?? "",
//                         palletSize: "",
//                       ),
//                     );
//                   });
//                 } catch (e) {
//                   debugPrint("Barcode fetch error: $e");
//
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Failed to fetch barcode")),
//                   );
//                 }
//               },
//
//               icon: const Icon(Icons.search, size: 20),
//               label: const Text("Fetch"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 16,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// ACTION BUTTONS
//   Widget _actionButtons() {
//     return Row(
//       children: [
//         Expanded(
//           child: _actionButton(
//             text: "SAVE",
//             icon: Icons.save_outlined,
//             color: Colors.green,
//             onTap: () async {
//               if (articleCtrl.text.isEmpty ||
//                   party == null ||
//                   supervisor == null) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text("Please fill all required fields"),
//                   ),
//                 );
//                 return;
//               }
//
//               try {
//                 final request = DispatchSaveRequest(
//                   flag: "U",
//                   id: int.tryParse(barcodeCtrl.text) ?? 0,
//                   srNo: barcodeCtrl.text,
//                   barcode: barcodeCtrl.text,
//                   partyName: party!,
//                   articleNo: articleCtrl.text,
//                   supervisorName: supervisor!,
//                   operatorName: operatorName ?? "",
//                   baleNo: entryoutCtrl.text,
//                   bagType: dispatchRecords.last.bagType, // NOT barcode
//
//                   laminationDate1: DateTime.now().toIso8601String(),
//                   laminationTime1: TimeOfDay.now().format(context),
//                   laminationRoll1: "",
//                   laminationToRoll1: "",
//
//                   tableBaleNo: entryoutCtrl.text,
//                   laminationOperator1: '',
//                   laminationLocation1: '',
//                   laminationSupervisor1: '',
//                   toRoll: '',
//                   forward: '',
//                   rmdSupervisor: '',
//                   rmdLocation: '',
//                   rmdOperator: '',
//                   rmdSupervisor1: '',
//                   rmdLocation1: '',
//                   rmdOperator1: '',
//                   toRoll1: '',
//                   forward1: '',
//                   statusRollType: '17',
//                   rmStatus: 'OUT',
//                   rmdRemark: 'OUT_STOCK',
//                   rmdSupervisorOut: 'ART001',
//                   fromRoll: 'OUT_STOCK',
//                   rmdTime: 17,
//                 );
//
//                 final success = await InStockService.saveDispatch(request);
//
//                 if (success) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text("Dispatch data saved successfully"),
//                       backgroundColor: Colors.green,
//                     ),
//                   );
//
//                   // Optional clear barcode after save
//                   if (success) {
//                     final updated = await InStockService.fetchDispatchInit();
//
//                     setState(() {
//                       srCtrl.text = updated.srNo.toString();
//                       barcodeCtrl.clear();
//                     });
//                   }
//                 }
//               } catch (e) {
//                 debugPrint("Save dispatch error: $e");
//
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Failed to save dispatch")),
//                 );
//               }
//             },
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: _actionButton(
//             text: "SCAN",
//             icon: Icons.qr_code_scanner,
//             color: Colors.blue,
//             onTap: () {
//               // open scanner
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _actionButton({
//     required String text,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: Padding(
//         padding: const EdgeInsets.only(left: 10.0, right: 10),
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             height: 40,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: color.withOpacity(0.3), width: 1.5),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(icon, color: color, size: 20),
//                 const SizedBox(width: 10),
//                 Text(
//                   text,
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     color: color,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// TABLE
//   Widget _dataTable() {
//     if (dispatchRecords.isEmpty) {
//       return Card(
//         elevation: 0,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: const Padding(
//           padding: EdgeInsets.all(24),
//           child: Center(
//             child: Text(
//               "No records yet",
//               style: TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//           ),
//         ),
//       );
//     }
//
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: dispatchRecords.length,
//       itemBuilder: (context, index) {
//         final record = dispatchRecords[index];
//
//         return Card(
//           color: Colors.white,
//           margin: const EdgeInsets.only(bottom: 10),
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//             side: BorderSide(color: Colors.grey.shade200),
//           ),
//
//           child: Padding(
//             padding: const EdgeInsets.all(14),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       "Record",
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(
//                         Icons.delete_forever_sharp,
//                         color: Colors.redAccent,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           dispatchRecords.removeAt(index);
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//
//                 _row("Barcode", record.srno.toString()),
//                 _row("Bale No", record.baleNo),
//                 _row("Bag Type", record.barcode),
//                 _row("Bag Qnt", record.bagType),
//                 _row("Bale NWT", record.remark),
//                 _row("Bale GWT", record.palletNwt.toStringAsFixed(2)),
//                 _row("Bag WT(GM)", record.partyName),
//                 _row("Bg Size", record.bagSize),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _row(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 90,
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontSize: 12, color: Colors.black87),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// COMMON DROPDOWN
//   Widget _dropdown(
//     String label,
//     String? value,
//     List<String> items,
//     Function(String?) onChanged,
//   ) {
//     return DropdownButtonFormField<String>(
//       value: value,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: Colors.black, fontSize: 12),
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Colors.grey, width: 1),
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
//       ),
//       items: items
//           .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//           .toList(),
//       onChanged: onChanged,
//     );
//   }
// }
