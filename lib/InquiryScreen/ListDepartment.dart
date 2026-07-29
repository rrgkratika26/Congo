import 'package:flutter/material.dart';
import 'DepartmentModelClass.dart';

List<DepartmentReport> departments = [
  /// ── Only show Inquiry Count (no metrics) ──
  DepartmentReport(
    title: "INQUIRY",
    type: "INQUIRY",
    icon: Icons.query_stats,
    color: Colors.yellow.shade600,
    showMetrics: false,   // ← inquiry count only
  ),
  DepartmentReport(
    title: "Quotation",
    type: "QUOTATION",
    icon: Icons.request_quote,
    color: Colors.teal.shade200,
    showMetrics: false,
  ),
  DepartmentReport(
    title: "Work Order",
    type: "WORKORDER",
    icon: Icons.assignment,
    color: Colors.blueGrey.shade200,
    showMetrics: false,
  ),
  DepartmentReport(
    title: "BOM",
    type: "BOM",
    icon: Icons.assignment,
    color: Colors.blueGrey.shade200,
    showMetrics: false,
  ),
  DepartmentReport(
    title: "Planning",
    type: "PLANNING",
    icon: Icons.calendar_month,
    color: Colors.purple.shade200,
    showMetrics: false,
  ),
  DepartmentReport(
    title: "Quality",
    type: "QUALITY",
    icon: Icons.verified,
    color: Colors.green.shade200,
    showMetrics: false,
  ),

  /// ── Show Metrics (netWeight, rollLength, noOfRoll) ──
  DepartmentReport(
    title: "RMD",
    type: "RMD",
    icon: Icons.settings,
    color: Colors.indigo.shade200,
    showMetrics: true,    // ← shows KG / MTR / Rolls
  ),
  DepartmentReport(
    title: "Lamination",
    type: "LAMINATION",
    icon: Icons.layers,
    color: Colors.orange.shade200,
    showMetrics: true,
  ),
  DepartmentReport(
    title: "Cutting",
    type: "CUTTING",
    icon: Icons.content_cut,
    color: Colors.green.shade200,
    showMetrics: true,
  ),
  DepartmentReport(
    title: "Webbing",
    type: "WEBBING",
    icon: Icons.account_tree,
    color: Colors.deepOrange.shade200,
    showMetrics: true,
  ),
  DepartmentReport(
    title: "Loom",
    type: "LOOM",
    icon: Icons.factory,
    color: Colors.pink.shade200,
    showMetrics: true,
  ),
  DepartmentReport(
    title: "Bag Production",
    type: "BAGPRODUCTION",
    icon: Icons.shopping_bag,
    color: Colors.lightGreen.shade200,
    showMetrics: true,
  ),
  DepartmentReport(
    title: "Baling",
    type: "BALING",
    icon: Icons.inventory_2,
    color: Colors.redAccent.shade200,
    showMetrics: true,
  ),
  DepartmentReport(
    title: "Tape Line",
    type: "TAPELINE",
    icon: Icons.straighten,
    color: Colors.amber.shade200,
    showMetrics: true,
  ),
  DepartmentReport(
    title: "Cut Piece",
    type: "CUTPIECE",
    icon: Icons.crop_square,
    color: Colors.cyan.shade200,
    showMetrics: true,
  ),
];