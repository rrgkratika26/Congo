import 'package:flutter/material.dart';
import '../AdminDashBoard/DashBoard.dart';

import '../AdminDashBoard/DepartmentDashboard.dart';


Future<void> navigateByRedirect(
  BuildContext context,
  String? redirect,
  String? department,
) async {


  print("NAVIGATE REDIRECT: $redirect");
  print("NAVIGATE DEPARTMENT: $department");

  // Determine the effective department
  String? effectiveDepartment =
      _extractDepartmentFromRedirect(redirect) ?? department;
  print("FINAL EFFECTIVE DEPARTMENT: $effectiveDepartment");
  // Widget screen = const AdminDashboard();
  Widget screen = const NewAdminDashboard();

  if (effectiveDepartment != null) {
    final dept = effectiveDepartment.toUpperCase();

    if (dept == 'PADMIN' || dept == 'ADMIN') {
      // ✅ Admin → show all departments
      // screen = const AdminDashboard();
      screen = const NewAdminDashboard();

    } else {
      // ✅ Normal user → show only their department in dashboard
      // screen = AdminDashboard(forceDepartment: dept);
      // screen = NewAdminDashboard(forceDepartment: dept);

    }
  } else {
    // fallback
    // screen = const AdminDashboard();
    screen = const NewAdminDashboard();

  }

  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => screen));
}

// Helper function to extract department from redirect string
String? _extractDepartmentFromRedirect(String? redirect) {
  if (redirect == null || redirect.isEmpty) return null;

  final cleaned = redirect.toLowerCase().replaceAll('.dashboard', '');

  final redirectMap = {
    'admin': 'PADMIN',
    'padmin': 'PADMIN',
    'rmd': 'RMD',
    'webbing': 'WEBBING',
    'jbl webbing': 'WEBBING',
    'bag': 'BAG',
    'bag production': 'BAG',
    'bagentry': 'BAG',
    'production': 'BAG',
    'baling': 'BALING',
    'bale': 'BALING',
  };

  return redirectMap[cleaned]?.toUpperCase();
}
