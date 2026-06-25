import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Color/Colorclass.dart';
import '../CuttingController/CuttingController.dart';
import 'CuttinInStock.dart';
import 'CuttingOut.dart';

class CuttingScreen extends StatefulWidget {
  const CuttingScreen({Key? key}) : super(key: key);

  @override
  State<CuttingScreen> createState() => _CuttingScreenState();
}

class _CuttingScreenState extends State<CuttingScreen> {
  int _currentIndex = 0;
  String? selectedOperator;
  String? selectedSupervisor;
  final controller = CuttingController();
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
        backgroundColor: C.primary,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: C.textHigh),
          onPressed: () => Navigator.pop(context),
        ),

        title: Text(
          unitTitle.isNotEmpty ? unitTitle : 'Unit Name',
          style: TextStyle(
            color: C.bg,
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.bold,
          ),
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
                      backgroundColor: Color(0xFF66BB6A),
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
                const CuttingInScreen(),
                // CuttingOutScreen(startDate: startDate, endDate: endDate),
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
              color: isActive ? const Color(0xFF66BB6A) : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 5,
            width: isTablet ? 100 : 80,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF66BB6A) : Colors.transparent,
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
                    color: const Color(0xFF66BB6A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.date_range,
                    color: Color(0xFF66BB6A),
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
                              primary: Color(0xFF66BB6A),
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
                          // color: Color(0xFF66BB6A),
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
                                        'dd-MM-yyyy',
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
                              primary: Color(0xFF66BB6A),
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
                          color: Color(0xFF66BB6A),
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
                                        'dd-MM-yyyy',
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
                        color: const Color(0xFF66BB6A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Color(0xFF66BB6A),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${tempEndDate!.difference(tempStartDate!).inDays + 1} days selected',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF66BB6A),
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
                  _controller.jumpToPage(_currentIndex);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF66BB6A),
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
