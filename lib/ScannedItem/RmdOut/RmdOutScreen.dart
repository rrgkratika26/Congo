import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Color/Colorclass.dart';
import 'RMDoutStock.dart';

class RmdOutScreen extends StatefulWidget {
  const RmdOutScreen({Key? key}) : super(key: key);

  @override
  State<RmdOutScreen> createState() => _RmdOutScreenState();
}

class _RmdOutScreenState extends State<RmdOutScreen> {
  String _unitTitle = '';

  @override
  void initState() {
    super.initState();
    _loadUnit();
  }

  Future<void> _loadUnit() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _unitTitle = prefs.getString('unit') ?? 'UNIT';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          "RMD OUT${_unitTitle.isNotEmpty ? " - $_unitTitle" : ""}",
          style: const TextStyle(color: C.bg),
        ),
        backgroundColor: C.appBar1,
        iconTheme: const IconThemeData(color: C.bg),
      ),
      body: const OutReportScreen(),
    );
  }
}