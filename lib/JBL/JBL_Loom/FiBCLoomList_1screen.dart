// import 'package:flutter/material.dart';
//
// import '../../Color/Colorclass.dart';
// import '../../services/JBL_apis/jbl_api_bailing_reports.dart';
// import 'LoomFormENtry.dart';
// import 'modelClass/FIBCmodel.dart';
//
//
// class LOOMList extends StatefulWidget {
//   const LOOMList({super.key});
//
//   @override
//   State<LOOMList> createState() =>
//       _LOOMListState();
// }
//
// class _LOOMListState extends State<LOOMList> {
//   List<ProductionModel> list = [];
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     loadData();
//   }
//
//   Future<void> loadData() async {
//     try {
//       final result = await JblApiService.getProductionReport();
//
//       setState(() {
//         list = result;
//         isLoading = false;
//       });
//     } catch (e) {
//       print("❌ UI ERROR: $e");
//       setState(() => isLoading = false);
//     }
//   }
//
//   Color getColor(double val) =>
//       val < 0 ? Colors.red : Colors.black;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Production Report")),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator(color: C.appBar3,))
//           : SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: SingleChildScrollView(
//           child: DataTable(
//             border: TableBorder.all(color: Colors.grey),
//             headingRowColor:
//             MaterialStateProperty.all(Colors.grey.shade300),
//             columns: const [
//               DataColumn(label: Text("ORDER NO")),
//               DataColumn(label: Text("PARTY NAME")),
//               DataColumn(label: Text("FABRIC CODE")),
//               DataColumn(label: Text("REQ KG")),
//               DataColumn(label: Text("REQ MTR")),
//               DataColumn(label: Text("PROD KG")),
//               DataColumn(label: Text("PROD MTR")),
//               DataColumn(label: Text("BAL KG")),
//               DataColumn(label: Text("BAL MTR")),
//               DataColumn(label: Text("FABRIC OUT")),
//               DataColumn(label: Text("STATUS")),
//               DataColumn(label: Text("FABRIC OUT")),
//               DataColumn(label: Text("JOB Finish")),
//             ],
//             rows: list.map((item) {
//               return DataRow(cells: [
//                 DataCell(Text(item.orderNo.toString())),
//                 DataCell(Text(item.partyName)),
//                 DataCell(Text(item.fabricCode)),
//                 DataCell(Text(item.actualRequiredKg.toString())),
//                 DataCell(Text(item.actualRequiredMtr.toString())),
//                 DataCell(Text(item.sumOutKg.toString(),
//                     style: TextStyle(color: getColor(item.sumOutKg)))),
//                 DataCell(Text(item.sumOutMtr.toString(),
//                     style: TextStyle(color: getColor(item.sumOutMtr)))),
//                 DataCell(Text(item.balanceKg.toString(),
//                     style: TextStyle(color: getColor(item.balanceKg)))),
//                 DataCell(Text(item.balanceMtr.toString(),
//                     style: TextStyle(color: getColor(item.balanceMtr)))),
//                 DataCell(Text(item.flatTubeGusset)),
//                 DataCell(Text('0')),
//                 DataCell(Text('0')),
//                 DataCell(
//                   InkWell(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => LoomForm(
//                             production: item,
//                           ),
//                         ),
//                       );
//                     },
//                     child: const Text(
//                       "Open",
//                       style: TextStyle(
//                         color: Colors.blue,
//                         decoration: TextDecoration.underline,
//                       ),
//                     ),
//                   ),
//                 ),
//               ]);
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }
// }