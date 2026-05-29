import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Color/Colorclass.dart';

class InquiryReportScreen extends StatefulWidget {
  const InquiryReportScreen({super.key});

  @override
  State<InquiryReportScreen> createState() => _InquiryReportScreenState();
}

class _InquiryReportScreenState extends State<InquiryReportScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  final List<Map<String, dynamic>> inquiryData = [
    {
      "title": "Inquiry",
      "count": "4",
      "icon": Icons.work_outline_rounded,
      "color": Colors.green,
      "date": "5/28/2026 - 5/28/2026",
    },
    {
      "title": "Quotation",
      "count": "4",
      "icon": Icons.description_outlined,
      "color": Colors.purple,
      "date": "5/28/2026 - 5/28/2026",
    },
    {
      "title": "Work Order",
      "count": "0",
      "icon": Icons.business_center_outlined,
      "color": Colors.teal,
      "date": "5/28/2026 - 5/28/2026",
    },
    {
      "title": "Bill Material",
      "count": "0",
      "icon": Icons.settings_suggest_outlined,
      "color": Colors.orange,
      "date": "5/28/2026 - 5/28/2026",
    },
    {
      "title": "Sample Status",
      "count": "3",
      "icon": Icons.manage_search_rounded,
      "color": Colors.amber,
      "date": "Pending / Process / Dispatch",
    },
    {
      "title": "Planning",
      "count": "0",
      "icon": Icons.calendar_month_rounded,
      "color": Colors.deepPurple,
      "date": "Total Planning",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      body: SafeArea(
        child: Column(
          children: [
            /// TOP BAR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black12)],
              ),
              child: Row(
                children: [
                  /// TITLE
                  const Expanded(
                    child: Text(
                      "Inquiry Report",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  /// DATE RANGE PICKER
                  GestureDetector(
                    onTap: () async {
                      DateTimeRange? pickedRange = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        initialDateRange: fromDate != null && toDate != null
                            ? DateTimeRange(start: fromDate!, end: toDate!)
                            : null,
                      );

                      if (pickedRange != null) {
                        setState(() {
                          fromDate = pickedRange.start;
                          toDate = pickedRange.end;
                        });
                      }
                    },

                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_month_outlined,
                        color: Colors.orange,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// FILTER ICON
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.filter_alt_outlined,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            /// SELECTED DATE RANGE VIEW
            if (fromDate != null && toDate != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black.withOpacity(.04),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    const Icon(
                      Icons.date_range,
                      color: Colors.orange,
                      size: 20,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        "${DateFormat('dd MMM yyyy').format(fromDate!)}"
                        "  →  "
                        "${DateFormat('dd MMM yyyy').format(toDate!)}",

                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          fromDate = null;
                          toDate = null;
                        });
                      },

                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 10),

            /// REPORT GRID
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: inquiryData.length,

                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 2 : 4,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: isMobile ? .90 : 1.2,
                    ),

                    itemBuilder: (context, index) {
                      final item = inquiryData[index];

                      return Container(
                        decoration: BoxDecoration(
                          color: C.bgColor,

                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                              color: Colors.black.withOpacity(.04),
                            ),
                          ],
                        ),

                        child: Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 12,
                                ),

                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    /// ICON
                                    Container(
                                      padding: EdgeInsets.all(
                                        isMobile ? 10 : 14,
                                      ),

                                      decoration: BoxDecoration(
                                        color: item["color"].withOpacity(.12),
                                        borderRadius: BorderRadius.circular(16),
                                      ),

                                      child: Icon(
                                        item["icon"],
                                        color: item["color"],
                                        size: isMobile ? 22 : 30,
                                      ),
                                    ),

                                    /// TITLE
                                    Text(
                                      item["title"],
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,

                                      style: TextStyle(
                                        fontSize: isMobile ? 12 : 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),

                                    /// COUNT
                                    Text(
                                      item["count"],

                                      maxLines: 1,

                                      style: TextStyle(
                                        fontSize: isMobile ? 20 : 26,
                                        fontWeight: FontWeight.bold,
                                        color: item["color"],
                                      ),
                                    ),

                                    /// DATE
                                    Text(
                                      item["date"],
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,

                                      style: TextStyle(
                                        fontSize: isMobile ? 9 : 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            /// BOTTOM BAR
                            Container(
                              height: 5,
                              decoration: BoxDecoration(
                                color: item["color"],
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
