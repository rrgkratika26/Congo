import 'package:flutter/material.dart';

import '../../Color/Colorclass.dart';
import 'BailingReportScreen.dart';

import 'StockReportScreen.dart';

class BailingSliderScreen extends StatefulWidget {
  const BailingSliderScreen({Key? key}) : super(key: key);

  @override
  State<BailingSliderScreen> createState() => _BailingSliderScreenState();
}

class _BailingSliderScreenState extends State<BailingSliderScreen>
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
      body: SafeArea(
        child: Column(
          children: [
            /// ✅ Tab Bar at the top
            Container(
              color: C.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  /// 🔙 Back Button
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    color: C.bg,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  /// 🟦 Tabs
                  Expanded(
                    child: TabBar(
                      controller: _tabController,
                      splashFactory: NoSplash.splashFactory,
                      labelColor: C.cardOrange,
                      unselectedLabelColor: C.border,
                      indicatorColor: C.actionOrange,
                      indicatorWeight: 5,
                      indicatorSize: TabBarIndicatorSize.tab,

                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: const [
                        Tab(
                          // icon: Icon(Icons.factory_outlined),
                          text: 'Stock Report',
                        ),
                        Tab(
                          // icon: Icon(Icons.inventory_2_outlined),
                          text: ' Bailing Report',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// ✅ Swipeable screens
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [StockReportScreen(), BailingReportScreen()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
