import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'WebbingInStock.dart';
import 'WebbingOutStock.dart';
import 'WebbingReports/OutReports.dart';
import 'WebbingReports/WebbingInRepeorts.dart';

class WebbingScreen extends StatefulWidget {
  final String screenType; // "IN" or "OUT"
  const WebbingScreen({Key? key, required this.screenType}) : super(key: key);

  @override
  State<WebbingScreen> createState() => _WebbingScreenState();
}

class _WebbingScreenState extends State<WebbingScreen> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  DateTime? startDate;
  DateTime? endDate;

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
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "${_unitTitle.isNotEmpty ? _unitTitle : 'Unit'} WEBBING",
          style: TextStyle(
            color: Colors.black87,
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),

      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          /// Tabs (Dynamic based on IN or OUT)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTab(
                widget.screenType == "IN" ? "IN Stock" : "OUT Stock",
                0,
              ),
              // const SizedBox(width: 40),
              // _buildTab(
              //   widget.screenType == "IN" ? "IN Reports" : "OUT Reports",
              //   1,
              // ),
            ],
          ),

          const SizedBox(height: 10),

          /// Slider Pages
          Expanded(
            child: CarouselSlider(
              carouselController: _carouselController,
              options: CarouselOptions(
                height: double.infinity,
                viewportFraction: 1,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() => _currentIndex = index);
                },
              ),
              items: widget.screenType == "IN"
                  ? [
                      /// IN FLOW
                      const WebbingInStock(),
                      const WebbingInReport(),
                    ]
                  : [
                      /// OUT FLOW
                      const WebOutStock(),
                      const WebbOutReportDetailsScreen(),
                    ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _carouselController.animateToPage(index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? Colors.orange : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 4,
            width: 80,
            color: isActive ? Colors.orange : Colors.transparent,
          ),
        ],
      ),
    );
  }

  void _showDateFilterDialog(BuildContext context) {
    DateTime? tempStartDate = startDate;
    DateTime? tempEndDate = endDate;

    showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    ).then((picked) {
      if (picked != null) {
        setState(() {
          startDate = picked.start;
          endDate = picked.end;
        });
      }
    });
  }
}



