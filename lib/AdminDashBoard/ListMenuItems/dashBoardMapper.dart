import 'package:flutter/material.dart';

import '../Dashboard Summary.dart';
import 'DashboardTopBarAnimated.dart';

List<DeptCountItem> createDepartments(DashboardSummary d) {
  return [
    DeptCountItem(
      title: "INQUIRY",

      icon: Icons.query_stats,
      color: Colors.yellow.shade600,
      metrics: [MetricItem("Total", d.inquiryCount)], // ← inquiry count only
    ),
    DeptCountItem(
      title: "Quotation",

      icon: Icons.request_quote,
      color: Colors.teal.shade200,
      metrics: [MetricItem("Total", d.inquiryCount)],
    ),
    //
    DeptCountItem(
      title: "Work Order",

      icon: Icons.assignment,
      color: Colors.blueGrey.shade200,
      metrics: [
        MetricItem("Total", d.woCount),
        // MetricItem("Net Wt", d.totalNetWt),
        // MetricItem("Out", d.totalBagOut),
      ],
    ),
    DeptCountItem(
      title: "Planning",
      icon: Icons.event_note,
      color: Colors.blue,
      metrics: [MetricItem("Total", d.planning)],
    ),

    // DeptCountItem(
    //   title: "BOM",
    //   icon: Icons.event_note,
    //   color: Colors.blue,
    //   metrics: [MetricItem("Count", d.planning)],
    // ),

    // kg/mter/rolls
    DeptCountItem(
      title: "Loom",
      icon: Icons.factory,
      color: Colors.pink.shade200,
      metrics: [
        MetricItem("KG", d.loomNetWeight),
        MetricItem("MTR", d.loomRollLength),
        MetricItem("Total Out", d.loomNoOfRoll),
      ],
    ),

    DeptCountItem(
      title: "RMD",

      icon: Icons.settings,
      color: Colors.indigo.shade200,
      metrics: [
        MetricItem("Prod", d.rmdNoOfRoll),
        MetricItem("Net Wt", d.rmdNetWeight),
        MetricItem("Out", d.rmdRollLength),
      ], // ← shows KG / MTR / Rolls
    ),

    DeptCountItem(
      title: "Lamination",

      icon: Icons.layers,
      color: Colors.orange.shade200,
      metrics: [
        MetricItem("Kg", d.laminationNetWeight),
        MetricItem("Mtr", d.laminationRollLength),
        MetricItem("Rolls", d.laminationNoOfRoll),
      ],
    ),
    //
    DeptCountItem(
      title: "Cutting",
      icon: Icons.content_cut,
      color: Colors.deepOrange,
      metrics: [
        MetricItem("Kg", d.cutKg),
        // MetricItem("Mtr", d.cutMtr),
        MetricItem("Total", d.cutTotal),
      ],
    ),

    DeptCountItem(
      title: "Cut Piece",
      icon: Icons.check_box,
      color: Colors.green,
      metrics: [
        MetricItem("Kg", d.cutPieceKg),
        MetricItem("Total", d.cutPieceTotal),
      ],
    ),

    // DeptCountItem(
    //   title: "WEBBING",
    //   icon: Icons.check_box,
    //   color: Colors.green,
    //   metrics: [
    //     MetricItem("Kg", d.)
    //   ],
    // ),
    DeptCountItem(
      title: "Bag Production",
      icon: Icons.shopping_bag,
      color: Colors.blue,
      metrics: [
        MetricItem("Prod Bag", d.totalBagProduction),
        MetricItem("Kg", d.totalNetWt),
        MetricItem("Out", d.totalBagOut),
      ],
    ),
    //
    // // stock/kg/tottal
    DeptCountItem(
      title: "Tape Line",
      icon: Icons.straighten,
      color: Colors.cyan,
      metrics: [MetricItem("Kg", d.tapeLineKg)],
    ),

    DeptCountItem(
      title: "Webbing",
      icon: Icons.account_tree,
      color: Colors.deepOrange.shade200,
      metrics: [
        MetricItem("Prod", d.totalBagProduction),
        MetricItem("Net Wt", d.totalNetWt),
        MetricItem("Out", d.totalBagOut),
      ],
    ),
    DeptCountItem(
      title: "Cutting",
      icon: Icons.content_cut,
      color: Colors.green.shade200,
      metrics: [
        MetricItem("Prod(kg)", d.totalBagProduction),
        // MetricItem("Net Wt", d.totalNetWt),
        MetricItem("Total", d.totalBagOut),
      ],
    ),
    //
    DeptCountItem(
      title: "Cut Piece",
      icon: Icons.crop_square,
      color: Colors.cyan.shade200,
      metrics: [
        MetricItem("Prod", d.totalBagProduction),
        MetricItem("Net Wt", d.totalNetWt),
        MetricItem("Out", d.totalBagOut),
      ],
    ),
    //
    // // In/Out
    DeptCountItem(
      title: "Bailing",
      icon: Icons.login,
      color: Colors.indigo,
      metrics: [
        MetricItem("In Kg", d.inCount),
        MetricItem("Out kg", d.inBagNwt),
      ],
    ),
    //
    DeptCountItem(
      title: "BOM",

      icon: Icons.assignment,
      color: Colors.blueGrey.shade200,
      metrics: [
        MetricItem("Total", d.bomCount),
        // MetricItem("Net Wt", d.totalNetWt),
        // MetricItem("Out", d.totalBagOut),
      ],
    ),
    DeptCountItem(
      title: "Planning",

      icon: Icons.calendar_month,
      color: Colors.purple.shade200,
      metrics: [
        MetricItem("Prod", d.totalBagProduction),
        MetricItem("Net Wt", d.totalNetWt),
        MetricItem("Out", d.totalBagOut),
      ],
    ),
    DeptCountItem(
      title: "Quality",

      icon: Icons.verified,
      color: Colors.green.shade200,
      metrics: [
        MetricItem("Prod", d.totalBagProduction),
        MetricItem("Net Wt", d.totalNetWt),
        MetricItem("Out", d.totalBagOut),
      ],
    ),
    //
    // /// ── Show Metrics (netWeight, rollLength, noOfRoll) ──
    DeptCountItem(
      title: "Baling",
      icon: Icons.inventory_2,
      color: Colors.redAccent.shade200,
      metrics: [MetricItem("In Kg", d.baleIn), MetricItem("Out Kg", d.baleout)],
    ),
    DeptCountItem(
      title: "Tape Line",
      icon: Icons.straighten,
      color: Colors.amber.shade200,
      metrics: [
        MetricItem("Prod", d.totalBagProduction),
        MetricItem("Net Wt", d.totalNetWt),
        MetricItem("Out", d.totalBagOut),
      ],
    ),
  ];
}
