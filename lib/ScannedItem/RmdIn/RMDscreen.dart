import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Color/Colorclass.dart';
import '../../screen/inStock/inStockScreen.dart';
import 'RMDStockIn.dart';
import 'RMDinStock.dart';

class RmdScreen extends StatefulWidget {
  final String screenType; // "IN" or "OUT"
  const RmdScreen({Key? key, required this.screenType}) : super(key: key);

  @override
  State<RmdScreen> createState() => _RmdScreenState();
}

class _RmdScreenState extends State<RmdScreen> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  // Date filter state
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
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: C.appBar1,
        elevation: 2,
        iconTheme: IconThemeData(color: C.primaryLight),
        // flexibleSpace: Container(
        //   decoration: BoxDecoration(
        //     gradient: LinearGradient(
        //       colors:  [C.appBar2, C.appBar3],
        //       begin: Alignment.topLeft,
        //       end: Alignment.bottomRight,
        //     ),
        //   ),
        // ),

        shadowColor: Colors.black.withOpacity(0.1),

        leadingWidth: 110, // important
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: C.primaryLight),
              onPressed: () => Navigator.pop(context),
            ),
            // Image.asset(
            //   'assets/images/logo-1.png',
            //   height: 28,
            //   fit: BoxFit.contain,
            // ),
          ],
        ),

        title: Row(
          children: [
            Text(
              _unitTitle.isNotEmpty ? _unitTitle : 'Unit Name',
              style: TextStyle(
                color: C.primaryLight,
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            // SizedBox(width: 5,),
            // Text(
            //   'RMD ${widget.screenType}',
            //   style: TextStyle(
            //     color: C.primaryLight,
            //     fontSize: isTablet ? 20 : 18,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
          ],
        ),

        actions: [
          if (_currentIndex == 1)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.black87),
                  onPressed: () => _showDateFilterDialog(context),
                  tooltip: 'Date Filter',
                ),
                if (startDate != null || endDate != null)
                  const Positioned(
                    right: 8,
                    top: 8,
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  ),
              ],
            ),
        ],
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
                _buildTabIndicator('RMD IN', 0, isTablet),
                // const SizedBox(width: 40),
                // _buildTabIndicator('IN Report', 1, isTablet),
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
                const RMDStockIn(),
                // InReportScreen(
                //   key: _inStockKey,
                //   startDate: startDate,
                //   endDate: endDate,
                // ),
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
              fontSize: isTablet ? 18 : 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ?C.actionOrange: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 5,
            width: isTablet ? 100 : 80,
            decoration: BoxDecoration(
              color: isActive ? C.actionOrange : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  void _showDateFilterDialog(BuildContext context) {
    DateTime? tempStartDate = startDate;
    DateTime? tempEndDate = endDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.date_range,
                    color: Color(0xFF4CAF50),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Date Range Filter',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Start Date
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: tempStartDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF4CAF50),
                              onPrimary: Colors.white,
                              onSurface: Colors.black87,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setDialogState(() => tempStartDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF4CAF50),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tempStartDate != null
                                    ? DateFormat(
                                        'dd MMM yyyy',
                                      ).format(tempStartDate!)
                                    : 'Select Date',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: tempStartDate != null
                                      ? Colors.black87
                                      : Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (tempStartDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              setDialogState(() => tempStartDate = null);
                            },
                            color: Colors.grey[600],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // End Date
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: tempEndDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF4CAF50),
                              onPrimary: Colors.white,
                              onSurface: Colors.black87,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setDialogState(() => tempEndDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF4CAF50),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'End Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tempEndDate != null
                                    ? DateFormat(
                                        'dd MMM yyyy',
                                      ).format(tempEndDate!)
                                    : 'Select Date',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: tempEndDate != null
                                      ? Colors.black87
                                      : Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (tempEndDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              setDialogState(() => tempEndDate = null);
                            },
                            color: Colors.grey[600],
                          ),
                      ],
                    ),
                  ),
                ),

                // Date range info
                if (tempStartDate != null && tempEndDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Color(0xFF4CAF50),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${tempEndDate!.difference(tempStartDate!).inDays + 1} days selected',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              if (tempStartDate != null || tempEndDate != null)
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      tempStartDate = null;
                      tempEndDate = null;
                    });
                  },
                  child: const Text(
                    'Clear All',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    startDate = tempStartDate;
                    endDate = tempEndDate;
                  });
                  Navigator.pop(context);
                  // Rebuild the carousel to apply filter
                  _carouselController.jumpToPage(_currentIndex);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Apply Filter',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
