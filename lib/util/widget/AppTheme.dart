import 'package:flutter/material.dart';

import '../../Color/Colorclass.dart';


class AppTheme {
  static final light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: C.pageBg,
    primaryColor: C.primary,
    appBarTheme: const AppBarTheme(
      backgroundColor: C.primary,
      foregroundColor: Colors.white,
    ),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    primaryColor: C.primary,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF042F2E),
      foregroundColor: Colors.white,
    ),
  );
}