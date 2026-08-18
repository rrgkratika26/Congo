import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Color/Colorclass.dart';
import '../../JBL/Lamination/lamination_Instock_screen.dart';
import 'LaminationIn/LaminationInScreen.dart';
import 'LaminationOutScreen.dart';

class LaminationScreen extends StatefulWidget {
  const LaminationScreen({Key? key}) : super(key: key);

  @override
  State<LaminationScreen> createState() => _LaminationScreenState();
}

class _LaminationScreenState extends State<LaminationScreen> {
  int _currentIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  DateTime? startDate;
  DateTime? endDate;
  String unitTitle = '';

  @override
  void initState() {
    super.initState();
    _loadUnit();
  }

  Future<void> _loadUnit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      unitTitle = prefs.getString('unit') ?? 'UNIT';
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;


    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: C.appBar1,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        iconTheme: IconThemeData(color: C.bg),
        title: Row(
          children: [

            Text(
              'Lamination IN',
              style: TextStyle(
                color: C.bg,
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),



      ),

      body: Column(
        children: [
          // Tab Indicator
          Container(
            // color: Colors.blueGrey.shade50,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabIndicator('IN Stock', 0, isTablet),
                // const SizedBox(width: 40),
                // _buildTabIndicator('IN Report', 1, isTablet),
              ],
            ),
          ),
          // Carousel Slider
          Expanded(
            child: CarouselSlider(
              carouselController: _controller,
              options: CarouselOptions(
                height: double.infinity,
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() => _currentIndex = index);
                },
              ),
              items: [
                const LaminationInStockScreen(),
                // LaminationOutScreen(startDate: startDate, endDate: endDate),
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
        _controller.animateToPage(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? const Color(0xFFFFA726) : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 5,
            width: isTablet ? 100 : 80,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFFFA726) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }


}