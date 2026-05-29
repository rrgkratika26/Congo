// import 'package:flutter/material.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf/pdf.dart';
// import 'package:printing/printing.dart';
//
// class PrintService {
//   /// Generates a PDF document from headers and rows
//   static Future<pw.Document> generatePdf({
//     required String title,
//     required List<String> headers,
//     required List<List<String>> rows,
//   }) async {
//     final pdf = pw.Document();
//
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(32),
//         build: (context) => [
//           pw.Header(
//             level: 0,
//             child: pw.Text(
//               title,
//               style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
//             ),
//           ),
//           pw.Table(
//             border: pw.TableBorder.all(),
//             children: [
//               // Table headers
//               pw.TableRow(
//                 children: headers.map((h) => _buildTableHeader(h)).toList(),
//               ),
//               // Table rows
//               ...rows.map((row) => pw.TableRow(
//                 children: row.map((cell) => _buildTableCell(cell)).toList(),
//               )),
//             ],
//           ),
//         ],
//       ),
//     );
//
//     return pdf;
//   }
//
//   /// Shows print preview and allows printing/sharing
//   static void showPrintPreview(BuildContext context, pw.Document pdf) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => Scaffold(
//           appBar: AppBar(
//             title: const Text('Print Preview'),
//             backgroundColor: const Color(0xFF42A5F5),
//           ),
//           body: PdfPreview(
//             build: (format) async => pdf.save(),
//             canChangePageFormat: true,
//             canChangeOrientation: true,
//             allowPrinting: true,
//             allowSharing: true,
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// Prints PDF directly to a device printer
//   static Future<void> printPdf(pw.Document pdf) async {
//     await Printing.layoutPdf(
//       onLayout: (PdfPageFormat format) async => pdf.save(),
//     );
//   }
//
//   // Private helpers
//   static pw.Widget _buildTableHeader(String text) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.all(8),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
//         textAlign: pw.TextAlign.center,
//       ),
//     );
//   }
//
//   static pw.Widget _buildTableCell(String text) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.all(8),
//       child: pw.Text(
//         text,
//         style: const pw.TextStyle(fontSize: 9),
//         textAlign: pw.TextAlign.center,
//       ),
//     );
//   }
// }
