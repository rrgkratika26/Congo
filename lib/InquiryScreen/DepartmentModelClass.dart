import 'package:flutter/material.dart';
import '../InquiryScreen/Marketing/MarketingModel.dart';

class DepartmentReport {
  final String title;
  final String type;
  final IconData icon;
  final Color color;
  final bool showMetrics; // ← add this
  MarketingCountModel? data;

  DepartmentReport({
    required this.title,
    required this.type,
    required this.icon,
    required this.color,
    this.showMetrics = true, // default: show metrics
    this.data,
  });
}