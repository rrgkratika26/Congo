import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Color/Colorclass.dart';
import 'BailingDispatchScreen.dart';
import 'DispatchReport.dart';
import 'dispatch/DispatchEntryScreen.dart';

class DispatchScreen extends StatefulWidget {
  const DispatchScreen({Key? key}) : super(key: key);

  @override
  State<DispatchScreen> createState() => _DispatchScreenState();
}

class _DispatchScreenState extends State<DispatchScreen> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  // Date filter state
  DateTime? startDate;
  DateTime? endDate;
  String _unitTitle = '';

  final GlobalKey<DispatchReportScreenState> _dispatchReportKey =
      GlobalKey<DispatchReportScreenState>();

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
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: C.primary,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.05),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: C.bg),
          onPressed: () => Navigator.pop(context),
        ),

        title: Text(
          "Dispatch Report",
          style: const TextStyle(color: C.bg, fontWeight: FontWeight.bold),
        ),

        centerTitle: true,



        actions: [
          if (_currentIndex == 1)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: C.bg),
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                      initialDateRange: (startDate != null && endDate != null)
                          ? DateTimeRange(start: startDate!, end: endDate!)
                          : null,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF2196F3),
                              onPrimary: Colors.white,
                              surface: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (picked != null) {
                      setState(() {
                        startDate = picked.start;
                        endDate = picked.end;
                      });
                    }
                  },
                ),

                if (startDate != null || endDate != null)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
        ],
        iconTheme: IconThemeData(
          color: C.bg, // 👈 Back arrow color white
        ),
      ),
      body: Column(
        children: [
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
                // const BalingDispatchScreen(),
                DispatchReportScreen(
                  key: _dispatchReportKey,
                  startDate: startDate,
                  endDate: endDate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabIndicator(String title, int index, bool isTablet) {
    final isActive = _currentIndex == index;

    return InkWell(
      onTap: () {
        _carouselController.animateToPage(index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isTablet ? 25 : 18,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
              color: isActive ? C.bg : C.primaryLight,
            ),
          ),

          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 8,
            width: isActive ? 120 : 0,
            decoration: BoxDecoration(
              color: C.bg,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
