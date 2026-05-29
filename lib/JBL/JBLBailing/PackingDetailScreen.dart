// // import 'package:IMS/JBL/app_colors.dart';
// // import 'package:flutter/material.dart';
// //
// // import 'PrintScreen.dart';
// // import 'QRPrinterBailing.dart';
// // import 'modelClass.dart';
// //
// // class PackingDetailsScreen extends StatelessWidget {
// //   final BailingDetail detail;
// //   final double netWt;
// //   final double diffWt;
// //   final double grossWt;
// //   final double tareWt;
// //   final String customerRef;
// //
// //   const PackingDetailsScreen({
// //     super.key,
// //     required this.detail,
// //     required this.netWt,
// //     required this.diffWt,
// //     required this.grossWt,
// //     required this.tareWt,
// //     required this.customerRef,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("Packing Details"),
// //         backgroundColor: AppColors.primary,
// //       ),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             _buildDetailCard("Party & Article", [
// //               _detailRow("Party", detail.partyName),
// //               _detailRow("BOM", detail.bomNo),
// //               _detailRow("Article", detail.articleNo),
// //               _detailRow("Packing No", detail.packingNo),
// //             ]),
// //             const SizedBox(height: 16),
// //             _buildDetailCard("Weights", [
// //               _detailRow("Gross WT", grossWt.toString()),
// //               _detailRow("Tare WT", tareWt.toString()),
// //               _detailRow("Net WT", netWt.toString()),
// //               _detailRow("Diff WT", diffWt.toString()),
// //               _detailRow("Customer Ref", customerRef),
// //             ]),
// //             const SizedBox(height: 24),
// //             SizedBox(
// //               width: double.infinity,
// //               child: ElevatedButton(
// //                 onPressed: () {
// //                   Navigator.push(
// //                     context,
// //                     MaterialPageRoute(builder: (context) => PrintScreen()),
// //                   );
// //                 },
// //                 child: const Text('Test Print (Simple Text)'),
// //               ),
// //             ),
// //             const SizedBox(height: 12),
// //             SizedBox(
// //               width: double.infinity,
// //               child: ElevatedButton(
// //                 onPressed: () async {
// //                   await BailingQrPrinter.printQr(
// //                     context,
// //                     packingNo: detail.packingNo,
// //                     netWt: netWt,
// //                     grossWt: grossWt,
// //                     tareWt: tareWt,
// //                     customerRef: customerRef,
// //                   );
// //                 },
// //                 child: const Text('Print QR Label'),
// //               ),
// //             ),
// //             if (BailingQrPrinter.selectedPrinter != null) ...[
// //               const SizedBox(height: 8),
// //               TextButton(
// //                 onPressed: () {
// //                   BailingQrPrinter.clearSelectedPrinter();
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     const SnackBar(
// //                       content: Text(
// //                         'Printer cleared. Next print will ask to select again.',
// //                       ),
// //                     ),
// //                   );
// //                 },
// //                 child: Text(
// //                   'Change printer (${BailingQrPrinter.selectedPrinter?.name ?? "?"})',
// //                 ),
// //               ),
// //             ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildDetailCard(String title, List<Widget> rows) {
// //     return Card(
// //       elevation: 2,
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               title,
// //               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
// //             ),
// //             const SizedBox(height: 12),
// //             ...rows,
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _detailRow(String label, String value) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 6),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           SizedBox(
// //             width: 110,
// //             child: Text(
// //               "$label:",
// //               style: const TextStyle(fontWeight: FontWeight.w500),
// //             ),
// //           ),
// //           Expanded(child: Text(value)),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// import 'package:IMS/JBL/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_instance/src/extension_instance.dart';
//
// import 'PrintController.dart';
// import 'PrintScreen.dart';
// import 'QRPrinterBailing.dart';
// import 'modelClass.dart';
//
// class PackingDetailsScreen extends StatelessWidget {
//   final BailingDetail detail;
//   final double netWt;
//   final double diffWt;
//   final double grossWt;
//   final double tareWt;
//   final String customerRef;
//
//   const PackingDetailsScreen({
//     super.key,
//     required this.detail,
//     required this.netWt,
//     required this.diffWt,
//     required this.grossWt,
//     required this.tareWt,
//     required this.customerRef,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Packing Details"),
//         backgroundColor: AppColors.primary,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildDetailCard("Party & Article", [
//               _detailRow("Party", detail.partyName),
//               _detailRow("BOM", detail.bomNo),
//               _detailRow("Article", detail.articleNo),
//               _detailRow("Packing No", detail.packingNo),
//             ]),
//             const SizedBox(height: 16),
//             _buildDetailCard("Weights", [
//               _detailRow("Gross WT", grossWt.toString()),
//               _detailRow("Tare WT", tareWt.toString()),
//               _detailRow("Net WT", netWt.toString()),
//               _detailRow("Diff WT", diffWt.toString()),
//               _detailRow("Customer Ref", customerRef),
//             ]),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Get.put(ShowPrintController());
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => ShowPrintDocPage()),
//                   );
//                 },
//                 child: const Text('Test Print (Simple Text)'),
//               ),
//             ),
//             const SizedBox(height: 12),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () async {
//                   await BailingQrPrinter.printQr(
//                     context,
//                     packingNo: detail.packingNo,
//                     netWt: netWt,
//                     grossWt: grossWt,
//                     tareWt: tareWt,
//                     customerRef: customerRef,
//                   );
//                 },
//                 child: const Text('Print QR Label'),
//               ),
//             ),
//             if (BailingQrPrinter.selectedPrinter != null) ...[
//               const SizedBox(height: 8),
//               TextButton(
//                 onPressed: () {
//                   BailingQrPrinter.clearSelectedPrinter();
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text(
//                         'Printer cleared. Next print will ask to select again.',
//                       ),
//                     ),
//                   );
//                 },
//                 child: Text(
//                   'Change printer (${BailingQrPrinter.selectedPrinter?.name ?? "?"})',
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDetailCard(String title, List<Widget> rows) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             const SizedBox(height: 12),
//             ...rows,
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _detailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 110,
//             child: Text(
//               "$label:",
//               style: const TextStyle(fontWeight: FontWeight.w500),
//             ),
//           ),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }
// }

// PackingDetailsScreen.dart — Updated version
// "Print Barcode Label" button add kiya gaya hai jo 10×10 label screen pe jaata hai.

import 'package:IMS/JBL/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

// ← NEW import
import 'BarcodeLabel.dart';
import 'PrintController.dart';
import 'PrintScreen.dart';
import 'QRPrinterBailing.dart';
import 'modleclass/modelClass.dart';

class PackingDetailsScreen extends StatelessWidget {
  final BailingDetail detail;
  final double netWt;
  final double diffWt;
  final double grossWt;
  final double tareWt;
  final String customerRef;

  const PackingDetailsScreen({
    super.key,
    required this.detail,
    required this.netWt,
    required this.diffWt,
    required this.grossWt,
    required this.tareWt,
    required this.customerRef,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Packing Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Detail Cards ────────────────────────────────────────────────
            _buildDetailCard("Party & Article", [
              _detailRow("Party", detail.partyName),
              _detailRow("BOM", detail.bomNo),
              _detailRow("Article", detail.articleNo),
              _detailRow("Packing No", detail.packingNo),

              // _detailRow("Packing No", detail.pcsPerPacking as String),
            ]),
            const SizedBox(height: 16),
            _buildDetailCard("Weights", [
              _detailRow("Gross WT", grossWt.toString()),
              _detailRow("Tare WT", tareWt.toString()),
              _detailRow("Net WT", netWt.toString()),
              _detailRow("Diff WT", diffWt.toString()),
              _detailRow("Customer Ref", customerRef),
            ]),
            const SizedBox(height: 24),

            // ── NEW: Print Barcode Label (10×10) ────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_2),
                label: const Text('Print QRCode'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  // Data pass karo BarcodeLabelScreen ko
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BarcodeLabelScreen(
                        labelData: BarcodeLabelData(
                          pcsPerPacking: detail.pcsPerPacking.toString(),
                          packingNo: detail.packingNo,
                          bag_size: detail.bag_size,
                          partyName: detail.partyName,
                          bomNo: detail.bomNo,
                          articleNo: detail.articleNo,
                          netWt: netWt,
                          grossWt: grossWt,
                          tareWt: tareWt,
                          diffWt: diffWt,
                          customerRef: customerRef,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // // ── Existing: QR Label Print ─────────────────────────────────────
            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton(
            //     onPressed: () async {
            //       await BailingQrPrinter.printQr(
            //         context,
            //         packingNo: detail.packingNo,
            //         netWt: netWt,
            //         grossWt: grossWt,
            //         tareWt: tareWt,
            //         customerRef: customerRef,
            //       );
            //     },
            //     child: const Text('Print QR Label'),
            //   ),
            // ),

            // ── Existing: Change Printer ─────────────────────────────────────
            if (BailingQrPrinter.selectedPrinter != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  BailingQrPrinter.clearSelectedPrinter();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Printer cleared. Next print will ask to select again.',
                      ),
                    ),
                  );
                },
                child: Text(
                  'Change printer (${BailingQrPrinter.selectedPrinter?.name ?? "?"})',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildDetailCard(String title, List<Widget> rows) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
