import 'package:flutter/material.dart';

import '../../Color/Colorclass.dart';
import '../../JBL/Lamination/LaminationReportscreen.dart';
import 'LamOutScreen.dart';
import 'LaminationScreen.dart';
import 'OutReportScreen.dart';



class LaminationSliderScreen extends StatefulWidget {
  const LaminationSliderScreen({Key? key}) : super(key: key);

  @override
  State<LaminationSliderScreen> createState() => _LaminationSliderScreenState();
}

class _LaminationSliderScreenState extends State<LaminationSliderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
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
                      indicatorWeight: 3,

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
                  LamInReportScreen(),
                  LamOutScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  // ── Custom Tab Selector ────────────────────────────────────────────────────
  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _tabItem(
            index: 0,

            label: 'In Report',
          ),
          _tabItem(
            index: 1,

            label: 'Out Report',
          ),
        ],
      ),
    );
  }

  Widget _tabItem({
    required int index,

    required String label,
  }) {
    final bool isSelected = _tabController.index == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
          setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ?  C.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [


              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}