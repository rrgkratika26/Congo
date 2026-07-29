import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../JBLBailing/modleclass/Bailing_summary_model.dart';

class BalingTableSource extends DataTableSource {
  final List<BailingSummaryModel> data;
  final Function(String bomNo) onBomTap;

  BalingTableSource(this.data, {required this.onBomTap});

  @override
  DataRow getRow(int index) {
    final row = data[index];

    return DataRow(
      cells: [
        DataCell(Text("${index + 1}")),

        /// 👇 CLICKABLE BOM
        DataCell(
          InkWell(
            onTap: () => onBomTap(row.bomNo),
            child: Text(
              row.bomNo,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        DataCell(Text(row.partyName)),
        DataCell(Text(row.articleNo)),
        DataCell(Text(row.totalQty.toString())),
        DataCell(Text(row.bagProduction.toString())),
        DataCell(Text(row.bailQty.toString())),
        DataCell(Text(row.dispatchQty.toString())),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
