// import 'package:flutter/material.dart';
// import '../../Color/Colorclass.dart';
// import '../../services/getSupervisors/getSupervisors.dart';
// import '../../util/widget/dateFilterService.dart';
// import '../../util/widget/searchBar.dart';
// import 'BaleEntryForm.dart';
// import 'BaleModel.dart';
// import 'baleStockModel/BaleReportModel.dart';
//
// class BaleInReportsScreen extends StatefulWidget {
//   const BaleInReportsScreen({Key? key}) : super(key: key);
//
//   @override
//   State<BaleInReportsScreen> createState() => _BaleInReportsScreenState();
// }
//
// class _BaleInReportsScreenState extends State<BaleInReportsScreen> {
//   late InStockService _service;
//   late Future<List<BailingReportModel>> reportFuture;
//   DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
//   DateTime _toDate = DateTime.now();
//   bool _showDateFilter = false;
//   List<BaleEntryModel> _allEntries = [];
//   List<BaleEntryModel> _filteredEntries = [];
//
//   final TextEditingController _searchController = TextEditingController();
//
//   bool _isLoading = true;
//   String? _error;
//
//   @override
//   void initState() {
//     super.initState();
//     _service = InStockService();
//     _loadReports();
//   }
//
//   Future<void> _loadReports() async {
//     try {
//       final data = await _service.fetchBaleInReports();
//
//       setState(() {
//         _allEntries = data;
//         _filteredEntries = data; // initially show all
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _isLoading = false;
//       });
//     }
//   }
//
//   void _onSearchChanged(String query) {
//     final search = query.toLowerCase().trim();
//
//     final filtered = _allEntries.where((entry) {
//       final combinedData = '''
//       ${entry.id}
//       ${entry.customerName}
//       ${entry.articleNo}
//       ${entry.poNumber}
//       ${entry.worK_ORDER_NO}
//       ${entry.quantity}
//       ${entry.remaining}
//     '''
//           .toLowerCase();
//
//       return combinedData.contains(search);
//     }).toList();
//
//     setState(() {
//       _filteredEntries = filtered;
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: C.borderLight,
//       appBar: AppBar(
//         backgroundColor: C.primary,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: C.bg),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Baling Department',
//           style: TextStyle(
//             color: C.bg,
//             fontSize: 22,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.calendar_today, color: C.bg),
//             onPressed: () async {
//               final picked = await showDateRangePicker(
//                 context: context,
//                 firstDate: DateTime(2020),
//                 lastDate: DateTime(2035),
//                 initialDateRange: DateTimeRange(
//                   start: _fromDate,
//                   end: _toDate,
//                 ),
//                 builder: (context, child) {
//                   return Theme(
//                     data: Theme.of(context).copyWith(
//                       colorScheme: const ColorScheme.light(
//                         primary: Color(0xFF2196F3),
//                         onPrimary: Colors.white,
//                         surface: Colors.white,
//                       ),
//                     ),
//                     child: child!,
//                   );
//                 },
//               );
//
//               if (picked != null) {
//                 setState(() {
//                   _fromDate = picked.start;
//                   _toDate = picked.end;
//                 });
//
//                 _loadReports();
//               }
//             },
//           ),
//         ],
//         iconTheme: IconThemeData(color: C.bg),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: C.appBar3,))
//           : _error != null
//           ? Center(child: Text(_error!))
//           : Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 12,
//                   ),
//                   color: const Color(0xFF42A5F6).withOpacity(0.2),
//                   child: Row(
//                     children: [
//                       const Icon(
//                         Icons.list_alt,
//                         size: 18,
//                         color: Color(0xFF42A5F5),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         'Showing ${_filteredEntries.length} entries',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey[700],
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // 🔍 SEARCH BAR ADDED HERE
//                 InlineSearchBar(
//                   controller: _searchController,
//                   onChanged: _onSearchChanged,
//                 ),
//
//                 Expanded(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                     itemCount: _filteredEntries.length,
//                     itemBuilder: (context, index) {
//                       return _buildEntryCard(_filteredEntries[index]);
//                     },
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
//
//   Widget _buildEntryCard(BaleEntryModel entry) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => BaleEntryForm(
//                 partyName: entry.customerName,
//                 articleNo: entry.articleNo,
//                 bomNo: entry.worK_ORDER_NO,
//                 poNumber: entry.poNumber,
//                   remaining: entry.remaining,
//                 requiredBag: entry.requiredBag,
//
//
//               ),
//             ),
//           );
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Card(
//           elevation: 2,
//           color: Colors.white,
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Row(
//                         children: [
//                           Text("${entry.id}. ", style: TextStyle(fontSize: 15)),
//
//                           Text(
//                             '${entry.customerName} \n ${entry.worK_ORDER_NO}',
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF212121),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const Icon(
//                       Icons.chevron_right,
//                       color: Color(0xFFBDBDBD),
//                       size: 28,
//                     ),
//                   ],
//                 ),
//                 const Divider(height: 15, color: Color(0xFFE0E0E0)),
//                 _buildInfoRow(
//                   Icons.article_outlined,
//                   'Article No',
//                   entry.articleNo,
//                   false,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildInfoRow(
//                   Icons.description_outlined,
//                   'PO Number',
//                   entry.poNumber,
//                   false,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildInfoRow(
//                   Icons.shopping_cart_outlined,
//                   'Req Bag',
//                   entry.requiredBag.toString(),
//                   false,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildInfoRow(
//                   Icons.inventory_outlined,
//                   'Remaining',
//                   entry.remaining.toString(),
//                   true,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(IconData icon, String label, String value, bool isRed) {
//     return Row(
//       children: [
//         Icon(icon, color: const Color(0xFF64B5F6), size: 20),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Text(
//             label,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Color(0xFF757575),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w600,
//             color: isRed ? const Color(0xFFE53935) : const Color(0xFF212121),
//           ),
//         ),
//       ],
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import '../../Color/Colorclass.dart';
import '../../services/getSupervisors/getSupervisors.dart';
import '../../util/widget/dateFilterService.dart';
import '../../util/widget/searchBar.dart';
import 'BaleEntryForm.dart';
import 'BaleModel.dart';
import 'BalingManualEntry.dart';

import 'baleStockModel/BaleReportModel.dart';

class BaleInReportsScreen extends StatefulWidget {
  const BaleInReportsScreen({Key? key}) : super(key: key);

  @override
  State<BaleInReportsScreen> createState() => _BaleInReportsScreenState();
}

class _BaleInReportsScreenState extends State<BaleInReportsScreen> {
  late InStockService _service;
  late Future<List<BailingReportModel>> reportFuture;
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  bool _showDateFilter = false;
  List<BaleEntryModel> _allEntries = [];
  List<BaleEntryModel> _filteredEntries = [];

  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = InStockService();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final data = await _service.fetchBaleInReports();

      setState(() {
        _allEntries = data;
        _filteredEntries = data; // initially show all
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    final search = query.toLowerCase().trim();

    final filtered = _allEntries.where((entry) {
      final combinedData =
      '''
      ${entry.id}
      ${entry.customerName}
      ${entry.articleNo}
      ${entry.poNumber}
      ${entry.worK_ORDER_NO}
      ${entry.quantity}
      ${entry.remaining}
    '''
          .toLowerCase();

      return combinedData.contains(search);
    }).toList();

    setState(() {
      _filteredEntries = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.borderLight,
      appBar: AppBar(
        backgroundColor: C.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: C.bg),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Baling Department',
          style: TextStyle(
            color: C.bg,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.to(() => const BaleEntryManualForm());
            },

            child: Text(
              "Entry",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: C.primaryDark,
                fontSize: 15,
              ),
            ),
          ),
        ],
        iconTheme: IconThemeData(color: C.bg),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: C.appBar3))
          : _error != null
          ? Center(child: Text(_error!))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 5,
            ),
            color: const Color(0xFF42A5F6).withOpacity(0.2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              //
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.list_alt,
                      size: 18,
                      color: C.primaryDark,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Showing ${_filteredEntries.length} entries',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: C.primaryDark,
                  ),
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                      initialDateRange: DateTimeRange(
                        start: _fromDate,
                        end: _toDate,
                      ),
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
                        _fromDate = picked.start;
                        _toDate = picked.end;
                      });

                      _loadReports();
                    }
                  },
                ),
              ],
            ),
          ),

          // 🔍 SEARCH BAR ADDED HERE
          InlineSearchBar(
            controller: _searchController,
            onChanged: _onSearchChanged,
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              itemCount: _filteredEntries.length,
              itemBuilder: (context, index) {
                return _buildEntryCard(_filteredEntries[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(BaleEntryModel entry) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BaleEntryForm(
                partyName: entry.customerName,
                articleNo: entry.articleNo,
                bomNo: entry.worK_ORDER_NO,
                poNumber: entry.poNumber,
                remaining: entry.remaining,
                requiredBag: entry.requiredBag,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Card(
          elevation: 2,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text("${entry.id}. ", style: TextStyle(fontSize: 15)),

                          Text(
                            '${entry.customerName} \n ${entry.worK_ORDER_NO}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFFBDBDBD),
                      size: 28,
                    ),
                  ],
                ),
                const Divider(height: 15, color: Color(0xFFE0E0E0)),
                _buildInfoRow(
                  Icons.article_outlined,
                  'Article No',
                  entry.articleNo,
                  false,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.description_outlined,
                  'PO Number',
                  entry.poNumber,
                  false,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.shopping_cart_outlined,
                  'Req Bag',
                  entry.requiredBag.toString(),
                  false,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.inventory_outlined,
                  'Remaining',
                  entry.remaining.toString(),
                  true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isRed) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF64B5F6), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isRed ? const Color(0xFFE53935) : const Color(0xFF212121),
          ),
        ),
      ],
    );
  }
}
