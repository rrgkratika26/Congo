// import 'package:flutter/material.dart';
//
// class C {
//   // ─────────────────────────────────────────────
//   // PRIMARY BRAND (BLUE SYSTEM)
//   // ─────────────────────────────────────────────
//   static const Color brand50 = Color(0xFFF4F8FF);
//   static const Color brand100 = Color(0xFFEAF2FF);
//   static const Color brand200 = Color(0xFFD6E6FF);
//   static const Color brand300 = Color(0xFFBDD7FF);
//   static const Color brand400 = Color(0xFF9CC2FF);
//   static const Color brand500 = Color(0xFF7DAFFF);
//   static const Color brand600 = Color(0xFF5D9CFF);
//   static const Color brand700 = Color(0xFF3F88F5);
//   static const Color brand800 = Color(0xFF2F6EDB);
//   static const Color brand900 = Color(0xFF2559B8);
//   static const Color borderLight = Color(0xFFE6EDFF);
//   static const Color primary = brand500;
//   static const Color primaryDark = brand600;
//   static const Color primaryBlue = Color(0xFF1565C0);
//   static const Color appBar1 =  Color(0xFF0E2458);
//   static const Color appBar2 =   Color(0xFF1A4A8A);
//   static const Color appBar3 =   Color(0xFFC97554);
//   static const Color appBar4 =  Color(0xFFF1BCA7);
//
//
//   // ─────────────────────────────────────────────
//   // BACKGROUNDS
//   // ─────────────────────────────────────────────
//   static const Color bg = Color(0xFFF0F8FF);
//   static const Color pageBg = Color(0xFFFAFCFF);
//   static const Color cardBg = Colors.white;
//   static const Color bgrColor = Color(0xFFF0F7FF);
//
//   // ─────────────────────────────────────────────
//   // TEXT COLORS
//   // ─────────────────────────────────────────────
//   static const Color textHigh = Color(0xFF2C3A5A);
//   static const Color textMid = Color(0xFF7A8DB3);
//   static const Color textLow = Color(0xFFB2C0DA);
//   static const Color label = Color(0xFF000000);
//   static const Color text = Color(0xFF1A2E4A); static const Color textSub = Color(0xFF78909C);
//   // ─────────────────────────────────────────────
//   // BORDER / DIVIDER
//   // ─────────────────────────────────────────────
//   static const Color border = Color(0xFFE6EDFF);
//   static const Color divider = Color(0xFFF0F4FF);
//   static const Color pillBg = brand100;
//   static const Color pillLight = brand50;
//   static const Color pillText = brand700;
//   static const Color lightGreen = Color(0xFFF1F8F2);
//   // ─────────────────────────────────────────────
//   // STATUS COLORS
//   // ─────────────────────────────────────────────
//   static const Color success = Color(0xFF16A34A);
//   static const Color warning = Color(0xFFF59E0B);
//   static const Color danger = Color(0xFFDC2626);
//   static const Color red = Colors.red;
//   static const Color teal = Colors.teal;
//
//   // ─────────────────────────────────────────────
//   // HEADER COLORS
//   // ─────────────────────────────────────────────
//   static const Color headerTop = brand700;
//   static const Color headerMid = brand500;
//   static const Color headerBot = brand300;
//
//   // ─────────────────────────────────────────────
//   // UI ACCENTS
//   // ─────────────────────────────────────────────
//   static const Color accent = Color(0xFF0EA5E9);
//   static const Color lightBlue = Color(0xFFE3F2FD);
//
//   static const Color card = Color(0xFFF5FAFF);
//
//   // ─────────────────────────────────────────────
//   // OPACITY HELPERS
//   // ─────────────────────────────────────────────
//   static const Color brandOp10 = Color(0x1A7DAFFF);
//   static const Color brandOp20 = Color(0x337DAFFF);
//   static const Color brandOp30 = Color(0x4D7DAFFF);
//
//
//
//   // ─────────────────────────── THEME TOKENS ───────────────────────────
//
//
//   static const surface = Colors.white;
//
//   static const primaryLight = Color(0xFFEEF3FF);
//   static const primaryBorder = Color(0xFFBFD0FF);
//   static const textHead = Color(0xFF0F172A);
//   static const textBody = Color(0xFF334155);
//   static const textMuted = Color(0xFF94A3B8);
//
//   static const successBg = Color(0xFFECFDF5);
//   static const successBorder = Color(0xFFA7F3D0);
//   static const error = Color(0xFFDC2626);
//   static const errorBg = Color(0xFFFEF2F2);
//   static const errorBorder = Color(0xFFFECACA);
//
//   static const warningBg = Color(0xFFFFFBEB);
//   static const warningBorder = Color(0xFFFDE68A);
//   static const purple = Color(0xFF7C3AED);
//   static const purpleBg = Color(0xFFF5F3FF);
//   static const purpleBorder = Color(0xFFDDD6FE);
//   static const shadow =
//   BoxShadow(color: Color(0x0D0F172A), blurRadius: 16, offset: Offset(0, 4));
//   static const shadowSm =
//   BoxShadow(color: Color(0x0A0F172A), blurRadius: 8, offset: Offset(0, 2));
//
//
//
//
//
//
//
//   // ─────────────────────────────────────────────
//   // EXTRA ALIASES (for backward compatibility)
//   // ─────────────────────────────────────────────
//   static const Color bgColor = pageBg;
//   static const Color primaryColor = primaryBlue;
//   static const Color headerBlue = primaryBlue;
//   static const Color primaryblue = primaryBlue;
//   static const Color bgr = Color(0xFFEBF5FD);
//
//   // ─────────────────────────────────────────────
//   // DEPARTMENT COLORS (CENTRALIZED)
//   // ─────────────────────────────────────────────
//   static Color deptColor(String label) {
//     switch (label.toUpperCase()) {
//       case 'LOOM':
//       case 'JBL LOOM':
//         return brand700;
//
//       case 'RMD':
//       case 'JBL RMD':
//         return teal;
//
//       case 'LAMINATION':
//       case 'JBL LAMINATION':
//         return warning;
//
//       case 'CUTTING':
//       case 'JBL CUTTING':
//         return danger;
//
//       case 'BAG':
//       case 'JBL BAG':
//         return primaryBlue;
//
//       case 'BALING':
//       case 'JBL BALING':
//         return Color(0xFF0891B2);
//
//       case 'WEBBING':
//       case 'JBL WEBBING':
//         return Color(0xFF9333EA);
//
//       case 'TAPELINE':
//         return Color(0xFF16A34A);
//
//       default:
//         return primary;
//     }
//   }
//
//   static Color deptLight(String label) {
//     final c = deptColor(label);
//     return Color.fromARGB(20, c.red, c.green, c.blue);
//   }
// }



import 'package:flutter/material.dart';

class C {
  // ==========================================================
  // BRAND COLORS (FROM MULTI PACKAGING CONGO LOGO)
  // ==========================================================

  static const Color primary = Color(0xFF1E3A8A); // Logo Blue
  static const Color primaryDark = Color(0xFF1E628D);
  static const Color primaryLight = Color(0xFFEAF5FC);
  static const Color rmdColor = Color(0xFF06B6D4);

  static const Color secondary = Color(0xFF1F2937); // Logo Orange
  static const Color secondaryDark = Color(0xFFD86D00);
  static const Color secondaryLight = Color(0xFFFFF2E4);

  // ==========================================================
  // APPBAR GRADIENT
  // ==========================================================

  static const Color appBar1 = Color(0xFF1E3A8A);
  static const Color appBar2 = Color(0xFF287DB3);
  static const Color appBar3 = Color(0xFFEE7D00);
  static const Color appBar4 = Color(0xFFFFD2A3);
  static const Color bgColor = pageBg;


  static const Color brand50 = Color(0xFFF4F8FF);
  static const Color brand100 = Color(0xFFEAF2FF);
  static const Color brand200 = Color(0xFFD6E6FF);
  static const Color brand300 = Color(0xFFBDD7FF);
  static const Color brand400 = Color(0xFF9CC2FF);
  static const Color brand500 = Color(0xFF7DAFFF);
  static const Color brand600 = Color(0xFF5D9CFF);



  static const Color brand700 = Color(0xFF3F88F5);
  static const Color brand800 = Color(0xFF2F6EDB);
  static const Color brand900 = Color(0xFF2559B8);
  static const Color borderLight = Color(0xFFE6EDFF);
  // ==========================================================
  // BACKGROUND COLORS
  // ==========================================================

  static const Color pageBg = Color(0xFFF7FAFC);
  static const Color bg = Color(0xFFF4F8FB);
  static const Color cardBg = Colors.white;
  static const Color surface = Colors.white;

  // ==========================================================
  // TEXT COLORS
  // ==========================================================

  static const Color textHigh = Color(0xFF2E2E2E);
  static const Color textMid = Color(0xFF6B7280);
  static const Color textLow = Color(0xFF9CA3AF);

  static const Color textHead = Color(0xFF1F2937);
  static const Color textBody = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF9CA3AF);

  // ==========================================================
  // BORDER / DIVIDER
  // ==========================================================

  static const Color border = Color(0xFFE5E7EB);
  // static const Color borderLight = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFF3F4F6);

  // ==========================================================
  // STATUS COLORS
  // ==========================================================

  static const Color success = Color(0xFF16A34A);
  static const Color successBg = Color(0xFFECFDF5);

  static const Color warning = Color(0xFFEE7D00);
  static const Color warningBg = Color(0xFFFFF7ED);

  static const Color danger = Color(0xFFDC2626);
  static const Color errorBg = Color(0xFFFEF2F2);

  static const Color teal = Color(0xFF0F766E);
  static const Color purple = Color(0xFF7C3AED);

  // ==========================================================
  // DASHBOARD CARD COLORS
  // ==========================================================

  static const Color cardBlue = Color(0xFFEAF5FC);
  static const Color cardOrange = Color(0xFFFFF2E4);
  static const Color cardGreen = Color(0xFFECFDF5);
  static const Color cardPurple = Color(0xFFF5F3FF);

  // ==========================================================
  // QUICK ACTION COLORS
  // ==========================================================


  static const Color primaryColor = primary;
  static const Color headerBlue = primary;
  static const Color primaryblue = primary;
  static const Color bgr = Color(0xFFEBF5FD);



  static const Color actionBlue = primary;
  static const Color actionOrange = secondary;
  static const Color actionGreen = success;
  static const Color actionPurple = purple;

  // ==========================================================
  // SHADOWS
  // ==========================================================

  static const BoxShadow shadow = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  static const BoxShadow shadowSm = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  // ==========================================================
  // DEPARTMENT COLORS
  // ==========================================================

  static Color deptColor(String label) {
    switch (label.toUpperCase()) {
      case 'LOOM':
      case 'JBL LOOM':
        return primary;

      case 'RMD':
      case 'JBL RMD':
        return secondary;

      case 'LAMINATION':
      case 'JBL LAMINATION':
        return Color(0xFF0F766E);

      case 'CUTTING':
      case 'JBL CUTTING':
        return Color(0xFFDC2626);

      case 'BAG':
      case 'JBL BAG':
        return Color(0xFF2563EB);

      case 'BALING':
      case 'JBL BALING':
        return Color(0xFF0891B2);

      case 'WEBBING':
      case 'JBL WEBBING':
        return Color(0xFF7C3AED);

      case 'TAPELINE':
        return Color(0xFF16A34A);

      default:
        return primary;
    }
  }

  static Color deptLight(String label) {
    final c = deptColor(label);
    return Color.fromARGB(
      25,
      c.red,
      c.green,
      c.blue,
    );
  }
}