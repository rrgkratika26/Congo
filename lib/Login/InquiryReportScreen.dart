import 'package:IMS/InquiryScreen/DepartmentModelClass.dart';
import 'package:IMS/util/sharedpreference/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Color/Colorclass.dart';
import '../InquiryScreen/ListDepartment.dart';
import '../InquiryScreen/Marketing/MarketingModel.dart';
import '../services/NardanaApis/NardanaApi.dart';

class InquiryReportScreen extends StatefulWidget {
  const InquiryReportScreen({super.key});

  @override
  State<InquiryReportScreen> createState() => _InquiryReportScreenState();
}

class _InquiryReportScreenState extends State<InquiryReportScreen> {
  String unit = '';

  MarketingCountModel? reportData;
  bool isLoading = false;

  DateTime fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime toDate = DateTime.now();


  List<Map<String, dynamic>> get inquiryData => [
    {
      "title": "Inquiry",
      "count": "${reportData?.totalInquiryCount ?? 0}",
      "icon": Icons.search,
      "color": Colors.green,
      "date":
      "${DateFormat('dd/MM/yyyy').format(fromDate)} - ${DateFormat('dd/MM/yyyy').format(toDate)}",
    },
    {
      "title": "Net Weight",
      "count": "${reportData?.netWeight ?? 0}",
      "icon": Icons.scale,
      "color": Colors.orange,
      "date":
      "${DateFormat('dd/MM/yyyy').format(fromDate)} - ${DateFormat('dd/MM/yyyy').format(toDate)}",
    },
    {
      "title": "Roll Length",
      "count": "${reportData?.rollLength ?? 0}",
      "icon": Icons.straighten,
      "color": Colors.blue,
      "date":
      "${DateFormat('dd/MM/yyyy').format(fromDate)} - ${DateFormat('dd/MM/yyyy').format(toDate)}",
    },
    {
      "title": "No Of Roll",
      "count": "${reportData?.noOfRoll ?? 0}",
      "icon": Icons.inventory_2_outlined,
      "color": Colors.purple,
      "date":
      "${DateFormat('dd/MM/yyyy').format(fromDate)} - ${DateFormat('dd/MM/yyyy').format(toDate)}",
    },
  ];


  @override
  void initState() {
    super.initState();
    _loadUnit();

  }

  Future loadReport() async {
    setState(() {
      isLoading = true;
    });

    for (var department in departments) {
      department.data = await NaradanaApiService.getMarketingCount(
        unit: unit,
        type: department.type,
        fromDate: fromDate,
        toDate: toDate,
      );

      debugPrint(
        "${department.title} => "
            "Inquiry: ${department.data?.totalInquiryCount}, "
            "Weight: ${department.data?.netWeight}, "
            "Length: ${department.data?.rollLength}, "
            "Rolls: ${department.data?.noOfRoll}",
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      body: SafeArea(
        child: Column(
          children: [
            /// TOP BAR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: const BoxDecoration(
                color: C.primary,
                boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black12)],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: C.bg,
                      size: 20,
                    ),
                  ),
                  /// TITLE
                  const Expanded(
                    child: Text(
                      "Inquiry Report",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: C.bg,
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
                        initialDateRange: DateTimeRange(
                          start: fromDate,
                          end: toDate,
                        )

                      );

                      if (pickedRange != null) {
                        setState(() {
                          fromDate = pickedRange.start;
                          toDate = pickedRange.end;
                        });

                        await loadReport();

                      }
                    },

                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: C.bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_month_outlined,
                        color: C.textHigh,
                      ),
                    ),
                  ),


                ],
              ),
            ),

            /// SELECTED DATE RANGE VIEW

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
                        "${DateFormat('dd MMM yyyy').format(fromDate)}"
                            "  →  "
                            "${DateFormat('dd MMM yyyy').format(toDate)}",

                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          fromDate =
                              DateTime.now().subtract(const Duration(days: 30));
                          toDate = DateTime.now();
                        });

                        loadReport();
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
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: departments.map((department) {
                          return SizedBox(
                            width: isMobile
                                ? (MediaQuery.of(context).size.width - 42) / 2
                                : (MediaQuery.of(context).size.width - 84) / 4,
                            child: _departmentCard(department),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                  // return GridView.builder(
                  //   padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                  //   physics: const BouncingScrollPhysics(),
                  //   itemCount: departments.length,
                  //
                  //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  //     crossAxisCount: isMobile ? 2 : 4,
                  //     mainAxisSpacing: 14,
                  //     crossAxisSpacing: 14,
                  //     childAspectRatio: isMobile ? .90 : 1.2,
                  //   ),
                  //     itemBuilder: (context, index) {
                  //       final department = departments[index];
                  //
                  //       return Container(
                  //         decoration: BoxDecoration(
                  //           color: Colors.white,
                  //           borderRadius: BorderRadius.circular(18),
                  //           boxShadow: [
                  //             BoxShadow(
                  //               color: Colors.black.withOpacity(.06),
                  //               blurRadius: 12,
                  //               offset: const Offset(0, 4),
                  //             ),
                  //           ],
                  //           border: Border(
                  //             bottom: BorderSide(
                  //               color: department.color,
                  //               width: 4,
                  //             ),
                  //           ),
                  //         ),
                  //         child: Padding(
                  //           padding: const EdgeInsets.all(10),
                  //           child: Column(
                  //             crossAxisAlignment: CrossAxisAlignment.center,
                  //             children: [
                  //
                  //               /// ICON
                  //               Row(
                  //                 children: [
                  //                   Container(
                  //                     height: 30,
                  //                     width: 30,
                  //                     child: Icon(
                  //                       department.icon,
                  //                       color: department.color,
                  //                       size: 20,
                  //                     ),
                  //                   ),
                  //
                  //
                  //
                  //                   /// TITLE
                  //                   Text(
                  //                     department.title,
                  //                     textAlign: TextAlign.center,
                  //                     style: const TextStyle(
                  //                       fontSize: 15,
                  //                       fontWeight: FontWeight.w700,
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //
                  //               const SizedBox(height: 4),
                  //
                  //               /// INQUIRY COUNT
                  //               Text(
                  //                 "${department.data?.totalInquiryCount ?? 0}",
                  //                 style: TextStyle(
                  //                   fontSize: 22,
                  //                   fontWeight: FontWeight.bold,
                  //                   color: C.textHead,
                  //                 ),
                  //               ),
                  //
                  //
                  //
                  //
                  //
                  //           if (department.showMetrics) ...[
                  //       // const Spacer(),
                  //
                  //       Divider(
                  //       color: Colors.grey.shade200,
                  //       ),
                  //
                  //       const SizedBox(height: 10),
                  //               /// VALUES
                  //               Row(
                  //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //                 children: [
                  //
                  //                   _metricColumn(
                  //                     "${department.data?.netWeight ?? 0}",
                  //                     "KG",
                  //                   ),
                  //
                  //                   _metricColumn(
                  //                     "${department.data?.rollLength ?? 0}",
                  //                     "MTR",
                  //                   ),
                  //
                  //                   _metricColumn(
                  //                     "${department.data?.noOfRoll ?? 0}",
                  //                     "Rolls",
                  //                   ),
                  //                 ],
                  //               ),
                  //       ],
                  //             ],
                  //           ),
                  //         ),
                  //       );
                  //     }
                  // );


                
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadUnit() async {
    unit = await AppSession.getUnit() ?? '';

    debugPrint("Loaded Unit => $unit");

    await loadReport();
  }

  Widget _metricColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _departmentCard(DepartmentReport department) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: department.color,
            width: 4,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  department.icon,
                  color: department.color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    department.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              "${department.data?.totalInquiryCount ?? 0}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (department.showMetrics) ...[
              const SizedBox(height: 10),
              Divider(color: Colors.grey.shade300),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _metricColumn(
                    "${department.data?.netWeight ?? 0}",
                    "KG",
                  ),
                  _metricColumn(
                    "${department.data?.rollLength ?? 0}",
                    "MTR",
                  ),
                  _metricColumn(
                    "${department.data?.noOfRoll ?? 0}",
                    "Rolls",
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
