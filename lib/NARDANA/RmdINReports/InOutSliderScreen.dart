import 'package:flutter/material.dart';


import '../../Color/Colorclass.dart';
import 'RmdOutReportScreen.dart';
import 'RmdReportsIn.dart';

class RmdSliderScreen extends StatefulWidget {
  const RmdSliderScreen({Key? key}) : super(key: key);

  @override
  State<RmdSliderScreen> createState() => _RmdSliderScreenState();
}

class _RmdSliderScreenState extends State<RmdSliderScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: SafeArea(
        child: Column(
          children: [

            /// 🔷 HEADER + TABS
            Container(
              color: Colors.blue.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [

                  /// 🔙 BACK BUTTON
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),

                  /// 🟦 TAB BAR
                  Expanded(
                    child: TabBar(
                      controller: _tabController,
                      splashFactory: NoSplash.splashFactory,

                      labelColor: C.primary,
                      unselectedLabelColor: Colors.grey,

                      indicatorColor: C.warning,
                      indicatorWeight: 5,

                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),

                      tabs: const [
                        Tab(text: 'In Report'),
                        Tab(text: 'Out Report'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// 🔄 TAB VIEW
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  RmdInReportScreen(),
                  RmdOutReportScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}