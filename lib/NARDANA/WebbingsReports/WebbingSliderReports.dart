import 'package:flutter/material.dart';

import 'WebInReportScreen.dart';
import 'WebOutReportScreen.dart';


class WebbingSliderScreen extends StatefulWidget {
  const WebbingSliderScreen({Key? key}) : super(key: key);

  @override
  State<WebbingSliderScreen> createState() => _WebbingSliderScreenState();
}

class _WebbingSliderScreenState extends State<WebbingSliderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    /// ✅ 2 Tabs: In & Out
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
      body: SafeArea(
        child: Column(
          children: [
            /// 🔷 Top Bar with Back + Tabs
            Container(
              color: Colors.blue.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  /// 🔙 Back Button
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    color: Colors.black87,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  /// 🔷 Tabs
                  Expanded(
                    child: TabBar(
                      controller: _tabController,
                      splashFactory: NoSplash.splashFactory,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      tabs: const [
                        Tab(
                          text: 'In Report',
                        ),
                        Tab(
                          text: 'Out Report',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// 🔄 Swipe Screens
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  WebbingInReportScreen(),
                  WebbingOutReportScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}