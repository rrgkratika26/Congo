import 'package:flutter/cupertino.dart';

import '../../NARDANA/LaminationReports/NaradanaModelLami.dart';

class PrintPreviewWidget extends StatelessWidget {
  final NewBarcodeNardanaModel roll;

  const PrintPreviewWidget({
    super.key,
    required this.roll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text("Roll No : ${roll.rollCode}"),

          Text("Party : ${roll.contNo}"),

          Text("WO : ${roll.workOrderNo}"),

          Text("Date : ${roll.date}"),

          Text("GSM : ${roll.gsm}"),



          const SizedBox(height: 20),

          Center(
            child: Image.network(
              "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${roll.barcode}",
              height: 180,
            ),
          ),

          const SizedBox(height: 10),

          Center(
            child: Text(
              roll.barcode ?? "",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}