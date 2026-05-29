import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WebbOutReportDetailsScreen extends StatefulWidget {
  const WebbOutReportDetailsScreen({super.key});

  @override
  State<WebbOutReportDetailsScreen> createState() => _WebbingInReportsState();
}

class _WebbingInReportsState extends State<WebbOutReportDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(28.0),
          child: Text("Webbing Out Reports"),
        ),
      ],
    ));
  }
}
