import 'package:flutter/material.dart';

import 'StockGrouping/WebStockGrouping.dart';
import 'WebStockReprtScreen.dart';

class WebbingSliderStockScreen extends StatefulWidget {
  const WebbingSliderStockScreen({Key? key}) : super(key: key);

  @override
  State<WebbingSliderStockScreen> createState() =>
      _WebbingSliderStockScreenState();
}

class _WebbingSliderStockScreenState extends State<WebbingSliderStockScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    /// ✅ 2 Tabs Only
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _tabTitle(String title) {
    return Tab(
      child: Text(
        title,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /// 🔷 Top Bar
            Container(
              color: Colors.blue.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  /// 🔙 Back Button
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.pop(context),
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
                        fontSize: 13,
                      ),
                      tabs: [
                        _tabTitle("Stock Report"),
                        _tabTitle("FabricCode Stock"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// 🔄 Pages
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  WebNardanaStockScreen(),
                  FabricCodeWiseReportScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}