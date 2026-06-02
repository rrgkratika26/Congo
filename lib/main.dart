import 'dart:io';

import 'package:IMS/services/GlobalLoader/GLobalLoader.dart';
import 'package:IMS/util/widget/AppTheme.dart';
import 'package:IMS/util/widget/ThemeController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  Get.put(LoaderController());
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  // final isLoggedIn = prefs.getString('unit') != null;

  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // ✅ auto system mode

      initialRoute: AppRoutes.login,
      getPages: AppRoutes.pages,
    );
  }
}
