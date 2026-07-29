// import 'dart:typed_data';
// import 'package:get/get.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
//
// class ShowPrintController extends GetxController {
//   Uint8List? uint8list;
//   pw.Document? pdf;
//
//   Future<void> loadData(int? type) async {
//     pdf = pw.Document();
//
//     pdf!.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (context) {
//           return pw.Center(
//             child: pw.Text(
//               "Sample Print Document\nType: $type",
//               style: pw.TextStyle(fontSize: 24),
//             ),
//           );
//         },
//       ),
//     );
//
//     uint8list = await pdf!.save();
//     update(); // Important for GetBuilder
//   }
// }



import 'package:flutter/services.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:pdf/widgets.dart' as pw;

class ShowPrintController extends GetxController {
  Uint8List? uint8list;
  pw.Document? pdf;

  Future<void> loadData(int? type) async {
    switch (type) {
      case 1:
      // Option A: Direct bytes load karo
        uint8list = await rootBundle.load('assets/receipt.pdf')
            .then((data) => data.buffer.asUint8List());
        break;

      case 2:
      // Option B: pw.Document (pdf package) se generate karo
        pdf = pw.Document();
        pdf!.addPage(
          pw.Page(
            build: (pw.Context context) => pw.Center(
              child: pw.Text('Receipt #1234'),
            ),
          ),
        );
        uint8list = await pdf!.save();
        break;
    }
    update();
  }
}