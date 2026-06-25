import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Color/Colorclass.dart';

import 'RMDoutStock.dart';

class RmdOutScreen extends StatefulWidget {
  final String screenType; // "IN" or "OUT"
  const RmdOutScreen({Key? key, required this.screenType}) : super(key: key);

  @override
  State<RmdOutScreen> createState() => _RmdOutScreenState();
}

class _RmdOutScreenState extends State<RmdOutScreen> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  // Date filter state
  DateTime? startDate;
  DateTime? endDate;
  String _unitTitle = '';

  Future<void> _loadUnit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _unitTitle = prefs.getString('unit') ?? 'UNIT';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUnit();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text("RMD OUT Reports", style: TextStyle(color: C.bg)),
          flexibleSpace: Container(
            decoration: const BoxDecoration(color: C.appBar1),
          ),
          // C.primary,
          iconTheme: IconThemeData(color: C.bg),
        ),
      body: Column(
        children: [
          // Tab Indicator
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabIndicator('OUT Stock', 0, isTablet),
                // const SizedBox(width: 40),
                // _buildTabIndicator('OUT Report', 1, isTablet),
              ],
            ),
          ),

          // Carousel Slider
          Expanded(
            child: CarouselSlider(
              carouselController: _carouselController,
              options: CarouselOptions(
                height: double.infinity,
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() => _currentIndex = index);
                },
              ),
              items: [
                const OutReportScreen(),
                             ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabIndicator(String title, int index, bool isTablet) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        _carouselController.animateToPage(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 18 : 18,
              fontWeight: isActive ? FontWeight.bold : FontWeight.bold,
              color: isActive ? const Color(0xFFFF5722) : const Color(0xFFFF5722),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: isTablet ? 100 : 80,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFFF5722) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }


}
