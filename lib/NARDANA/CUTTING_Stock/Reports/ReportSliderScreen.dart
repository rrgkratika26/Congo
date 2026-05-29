import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../Color/Colorclass.dart';
import 'ComponetReportScreen.dart';
import 'Cutting_InReportScreen.dart';
import 'RollWiseReportScreen.dart';

/// ================== DASHBOARD ==================
class ReportDashboardScreen extends StatelessWidget {
  const ReportDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: CommonReportAppBar(
          onDateChanged: (from, to) {
            print("From: $from To: $to");

            /// 👉 Pass to API / Provider if needed
          },
        ),

        /// 🔥 TAB VIEW
        body: const TabBarView(
          children: [
            RollWiseReportScreen(),
            ComponentReportScreen(),
            Cutting_InReportSCreen(), // Replace with CutReportScreen if needed
          ],
        ),
      ),
    );
  }
}

/// ================== COMMON APP BAR ==================
class CommonReportAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final Function(DateTime fromDate, DateTime toDate)? onDateChanged;

  const CommonReportAppBar({Key? key, this.onDateChanged})
      : super(key: key);

  @override
  State<CommonReportAppBar> createState() => _CommonReportAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(120);
}

class _CommonReportAppBarState extends State<CommonReportAppBar> {
  DateTime? fromDate;
  DateTime? toDate;

  /// 📅 PICK DATE RANGE
  Future<void> _pickDateRange() async {
    DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: (fromDate != null && toDate != null)
          ? DateTimeRange(start: fromDate!, end: toDate!)
          : null,
    );

    if (range != null) {
      setState(() {
        fromDate = range.start;
        toDate = range.end;
      });

      widget.onDateChanged?.call(fromDate!, toDate!);
    }
  }

  /// 📅 FORMAT TEXT
  String get dateText {
    if (fromDate == null || toDate == null) {
      return "Select Date Range";
    }
    return "${DateFormat('dd MMM yyyy').format(fromDate!)} - ${DateFormat('dd MMM yyyy').format(toDate!)}";
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: C.primary,
      title: const Text("Reports Dashboard",style: TextStyle(color: C.bg),),
      centerTitle: true,

iconTheme: IconThemeData(color: C.bg),
      /// 🔥 BOTTOM SECTION (DATE + TABS)
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Column(
          children: [
            /// 📅 DATE FILTER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: GestureDetector(
                onTap: _pickDateRange,
                child: Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      const Icon(Icons.calendar_today,
                          size: 18, color: C.bg),
                    ],
                  ),
                ),
              ),
            ),

            /// 🔥 TAB BAR (IMPORTANT: HERE ONLY)
            const TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: "Roll Wise",
                ),
                Tab(text: "Component"),
                Tab(text: "Cut Report"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}