// import 'dart:async';
// import 'package:IMS/services/getSupervisors/getSupervisors.dart';
// import 'package:flutter/material.dart';
// import '../../Color/Colorclass.dart';
// import '../../JBL/JBL_Loom/LoomFormENtry.dart';
// import '../../JBL/JBL_Loom/modelClass/FIBCmodel.dart';
// import '../../util/sharedpreference/shared_preference.dart';
// import 'LoomEntryScreen.dart';
// import 'LoomModelClass.dart';
//
// // Model class for Loom Order
//
// class LoomForwardScreen extends StatefulWidget {
//   const LoomForwardScreen({Key? key}) : super(key: key);
//
//   @override
//   State<LoomForwardScreen> createState() => _LoomForwardScreenState();
// }
//
// class _LoomForwardScreenState extends State<LoomForwardScreen> {
//   String _selectedFilter = 'All';
//   final TextEditingController _searchController = TextEditingController();
//   Timer? _debounce;
//   List<LoomOrder> _orders = [];
//   List<LoomOrder> _filteredOrders = [];
//   bool _isLoading = false;
//   // final String _unit = "UNIT-NARDANA";
//   // final String _unit = "UNIT-SILVASSA";
//   final String _unit = "UNIT-1";
//
//
//   // unit = await AppSession.getUnit();
//   bool isMobile(BuildContext context) =>
//       MediaQuery.of(context).size.width < 700;
//
//   bool isTablet(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     return w >= 700 && w < 1100;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadOrders(viewType: 'all', unit: _unit);
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//
//   Future<void> _loadOrders({
//     required String viewType,
//     required String unit,
//   }) async {
//     setState(() => _isLoading = true);
//
//     try {
//       final orders = await InStockService.fetchLoomOrders(
//         viewType: viewType,
//         unit: unit,
//       );
//
//       setState(() {
//         _orders = orders;
//         _filteredOrders = orders;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(e.toString())));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   void _applyFilter(String filter) {
//     setState(() {
//       _selectedFilter = filter;
//     });
//
//     switch (filter) {
//       case 'Process':
//         _loadOrders(viewType: 'process', unit: _unit);
//         break;
//
//       case 'Finish':
//         _loadOrders(viewType: 'finish', unit: _unit);
//         break;
//
//       default:
//         _loadOrders(viewType: 'all', unit: _unit);
//     }
//   }
//
//   void _filterOrders() {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//
//     _debounce = Timer(const Duration(milliseconds: 400), () {
//       final q = _searchController.text.toLowerCase();
//
//       setState(() {
//         _filteredOrders = _orders.where((e) {
//           return e.requiredFabricCode.toLowerCase().contains(q) ||
//               e.customerName.toLowerCase().contains(q) ||
//               e.orderNo.toUpperCase().contains(q)||
//           e.fabricCode.toLowerCase().contains(q)||
//               e.loomOrderNo.toLowerCase().contains(q);
//         }).toList();
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//
//       body: Column(
//         children: [
//           _buildHeader(),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator(color: C.appBar3,))
//                 : isMobile(context)
//                 ? _buildMobileList()
//                 : _buildDataTable(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
//       child: Column(
//         children: [
//           // Filter buttons and record count
//           LayoutBuilder(
//             builder: (context, constraints) {
//               final isMobile = constraints.maxWidth < 600;
//
//               return isMobile
//                   ? Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Wrap(
//                           spacing: 10,
//                           runSpacing: 10,
//                           children: [
//                             _buildFilterButton(
//                               'Process',
//                               Colors.blue,
//                               Icons.settings,
//                             ),
//                             _buildFilterButton(
//                               'All',
//                               Colors.blue,
//                               Icons.view_list,
//                             ),
//                             _buildFilterButton(
//                               'Finish',
//                               Colors.green,
//                               Icons.check_circle,
//                             ),
//                             // _processViewBadge(),
//                           ],
//                         ),
//
//                         // const SizedBox(height: 8),
//                       ],
//                     )
//                   : Row(
//                       children: [
//                         _buildFilterButton(
//                           'Process',
//                           Colors.grey,
//                           Icons.settings,
//                         ),
//                         const SizedBox(width: 8),
//                         _buildFilterButton(
//                           'All',
//                           const Color(0xFF2196F3),
//                           Icons.view_list,
//                         ),
//                         const SizedBox(width: 8),
//                         _buildFilterButton(
//                           'Finish',
//                           Colors.green,
//                           Icons.check_circle,
//                         ),
//                         const Spacer(),
//                         // _processViewBadge(),
//                       ],
//                     );
//             },
//           ),
//
//           const SizedBox(height: 5),
//           // Search bar and record info
//           Row(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Align(
//                   alignment: Alignment.centerRight,
//                   child: Text(
//                     "Record: ${_filteredOrders.length}",
//                     style: const TextStyle(
//                       fontSize: 15,
//                       // fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//
//               Expanded(
//                 child: Container(
//                   height: 45,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                     boxShadow: [
//                       BoxShadow(color: Colors.grey.shade300, blurRadius: 4),
//                     ],
//                   ),
//                   child: TextField(
//                     controller: _searchController,
//                     onChanged: (value) => _filterOrders(),
//                     decoration: InputDecoration(
//                       hintText: 'Search order / customer...',
//                       prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                       suffixIcon: _searchController.text.isNotEmpty
//                           ? IconButton(
//                               icon: const Icon(Icons.close),
//                               onPressed: () {
//                                 _searchController.clear();
//                                 _filterOrders();
//                               },
//                             )
//                           : null,
//                       border: InputBorder.none,
//                       contentPadding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFilterButton(String label, Color color, IconData icon) {
//     final isSelected = _selectedFilter == label;
//     return InkWell(
//       onTap: () => _applyFilter(label),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
//         decoration: BoxDecoration(
//           color: isSelected ? color : Colors.white,
//           border: Border.all(
//             color: isSelected ? color : Colors.grey[300]!,
//             width: 1.5,
//           ),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, color: isSelected ? Colors.white : color, size: 18),
//             const SizedBox(width: 6),
//             Text(
//               label,
//               style: TextStyle(
//                 color: isSelected ? Colors.white : Colors.black87,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _processViewBadge() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.orange,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: const Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             'View',
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMobileList() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(8),
//       itemCount: _filteredOrders.length,
//       itemBuilder: (context, index) {
//         final order = _filteredOrders[index];
//
//         return Card(
//           color: Colors.white,
//
//           margin: const EdgeInsets.symmetric(vertical: 4),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           elevation: 2,
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _mobileRow('Order No.', order.loomOrderNo.toString()),
//                 _mobileRow('Article No.', order.articleNo.toString()),
//                 _mobileRow('PO No.', order.poNumber), // ✅ NEW
//                 _mobileRow('Required Fabric', order.fabricCode),
//                 _mobileRow('Party Name', order.customerName),
//                 _mobileRow('Req Qnt.Kg', order.requiredQuantityKg.toString()),
//                 _mobileRow('Req Qnt.Mtr', order.requiredQuantityMtr.toString()),
//
//                 _mobileRow('Prod Kg', order.productionKg.toString()),
//                 _mobileRow('Prod Mtr', order.productionMtr.toString()),
//
//                 _mobileRow(
//                   'Balance Kg',
//                   order.balanceKg.toString(),
//                   valueColor: order.balanceKg < 0 ? Colors.red : Colors.green,
//                 ),
//                 _mobileRow(
//                   'Balance Mtr',
//                   order.balanceMtr.toString(),
//                   valueColor: order.balanceMtr < 0 ? Colors.red : Colors.green,
//                 ),
//                 _mobileRow('Status', order.status.toString()),
//
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) =>
//                               LoomForm(production: convertToProduction(order)),
//                         ),
//                       );
//                     },
//                     child: const Text(
//                       'Open',
//                       style: TextStyle(color: Colors.black),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _mobileRow(
//     String label,
//     String value, {
//     Color valueColor = Colors.black,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 3),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 110,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//                 color: valueColor,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDataTable() {
//     final width = MediaQuery.of(context).size.width;
//
//     if (_filteredOrders.isEmpty) {
//       return const Center(child: Text("No Data Found"));
//     }
//
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: SizedBox(
//         width: width < 1200 ? 1200 : width,
//         child: PaginatedDataTable(
//           rowsPerPage: 10,
//           columnSpacing: 12,
//           headingRowColor: MaterialStateProperty.all(const Color(0xFF5179A8)),
//
//           // headingTextStyle: const TextStyle(
//           //   color: Colors.white,
//           //   fontWeight: FontWeight.bold,
//           // ),
//           columns: const [
//             DataColumn(label: Text('ORDER NO')),
//             DataColumn(label: Text('WO NO')),
//             DataColumn(label: Text('PO NO')),
//             DataColumn(label: Text('FABRIC')),
//             DataColumn(label: Text('REQ KG')),
//             DataColumn(label: Text('REQ MTR')),
//             DataColumn(label: Text('PROD KG')),
//             DataColumn(label: Text('PROD MTR')),
//             DataColumn(label: Text('BAL KG')),
//             DataColumn(label: Text('BAL MTR')),
//             DataColumn(label: Text('STATUS')),
//             DataColumn(label: Text('CUSTOMER')),
//             DataColumn(label: Text('ACTION')),
//           ],
//
//           source: _LoomDataSource(orders: _filteredOrders, context: context),
//         ),
//       ),
//     );
//   }
//
//   void _showOrderDetails(LoomOrder order) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Order #${order.loomOrderNo}'),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _detailRow('PO Number', order.poNumber.isNotEmpty ? order.poNumber : '-'),
//               _detailRow('WO Number', order.woNo.isNotEmpty ? order.woNo : '-'),
//
//               _detailRow('Fabric Code', order.requiredFabricCode),
//               _detailRow('Customer', order.customerName),
//
//               _detailRow('Required Qty (Kg)', order.requiredQuantityKg.toStringAsFixed(0)),
//               _detailRow('Required Qty (Mtr)', order.requiredQuantityMtr.toStringAsFixed(0)),
//
//               _detailRow('Production (Kg)', order.productionKg.toStringAsFixed(0)),
//               _detailRow('Production (Mtr)', order.productionMtr.toStringAsFixed(0)),
//
//               _detailRow('Balance (Kg)', order.balanceKg.toStringAsFixed(0)),
//               _detailRow('Balance (Mtr)', order.balanceMtr.toStringAsFixed(0)),
//
//               _detailRow('Status', order.status ? "Active" : "Inactive"),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _detailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 140,
//             child: Text(
//               '$label:',
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontWeight: FontWeight.w500),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _LoomDataSource extends DataTableSource {
//   final List<LoomOrder> orders;
//   final BuildContext context;
//
//   _LoomDataSource({required this.orders, required this.context});
//
//   @override
//   DataRow? getRow(int index) {
//     if (index >= orders.length) return null;
//
//     final order = orders[index];
//
//     return DataRow(
//       cells: [
//         DataCell(Text(order.loomOrderNo)),
//
//         DataCell(Text(
//           order.woNo.isNotEmpty ? order.woNo : '-',
//         )),
//
//         DataCell(Text(
//           order.poNumber.isNotEmpty ? order.poNumber : '-',
//         )),
//
//         DataCell(SizedBox(
//           width: 150,
//           child: Text(
//             order.requiredFabricCode,
//             overflow: TextOverflow.ellipsis,
//           ),
//         )),
//
//         DataCell(Text(order.requiredQuantityKg.toStringAsFixed(0))),
//         DataCell(Text(order.requiredQuantityMtr.toStringAsFixed(0))),
//         DataCell(Text(order.productionKg.toStringAsFixed(0))),
//         DataCell(Text(order.productionMtr.toStringAsFixed(0))),
//
//         DataCell(Text(
//           order.balanceKg.toStringAsFixed(0),
//           style: TextStyle(
//             color: order.balanceKg < 0 ? Colors.red : Colors.green,
//             fontWeight: FontWeight.w600,
//           ),
//         )),
//
//         DataCell(Text(
//           order.balanceMtr.toStringAsFixed(0),
//           style: TextStyle(
//             color: order.balanceMtr < 0 ? Colors.red : Colors.green,
//             fontWeight: FontWeight.w600,
//           ),
//         )),
//
//         DataCell(Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: order.status ? Colors.green : Colors.red,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             order.status ? "Active" : "Inactive",
//             style: const TextStyle(color: Colors.white, fontSize: 12),
//           ),
//         )),
//
//         DataCell(Text(order.customerName.isNotEmpty ? order.customerName : '-')),
//       ],
//     );
//   }
//
//   @override
//   bool get isRowCountApproximate => false;
//
//   @override
//   int get rowCount => orders.length;
//
//   @override
//   int get selectedRowCount => 0;
// }

import 'dart:async';
import 'package:IMS/services/getSupervisors/getSupervisors.dart';
import 'package:flutter/material.dart';

import '../../Color/Colorclass.dart';
import '../../JBL/JBL_Loom/LoomFormENtry.dart';
import '../../JBL/JBL_Loom/modelClass/FIBCmodel.dart';
import '../../util/sharedpreference/shared_preference.dart';
import 'LoomModelClass.dart';

class LoomForwardScreen extends StatefulWidget {
  const LoomForwardScreen({Key? key}) : super(key: key);

  @override
  State<LoomForwardScreen> createState() => _LoomForwardScreenState();
}

class _LoomForwardScreenState extends State<LoomForwardScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  List<LoomOrder> _orders = [];
  List<LoomOrder> _filteredOrders = [];

  int _totalCount = 0;
  String _unit = "";
  int pagesize = 50;

  final StreamController<LoomOrderResponse> _ordersStreamController =
      StreamController<LoomOrderResponse>.broadcast();

  bool _isLoading = false;

  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 700;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _ordersStreamController.close();

    super.dispose();
  }

  Future<void> _loadOrders({
    required String viewType,
    required String unit,
    required int pagesize,
  }) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final response = await InStockService.fetchLoomOrders(
        viewType: viewType,
        unit: unit,
        pageNumber: 1,
        pageSize: pagesize,
      );

      if (!_ordersStreamController.isClosed) {
        _ordersStreamController.add(response);
      }
    } catch (e) {
      if (!_ordersStreamController.isClosed) {
        _ordersStreamController.addError(e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _initializeData() async {
    _unit = await AppSession.getUnit() ?? "RRG";

    await _loadOrders(viewType: 'all', unit: _unit, pagesize: pagesize);
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });

    _loadOrders(viewType: _getViewType(), unit: _unit, pagesize: pagesize);
  }

  void _filterOrders() {
    final q = _searchController.text.trim().toLowerCase();

    if (!mounted) return;

    setState(() {
      if (q.isEmpty) {
        _filteredOrders = List.from(_orders);
        return;
      }

      _filteredOrders = _orders.where((e) {
        return e.requiredFabricCode.toLowerCase().contains(q) ||
            e.bom.toLowerCase().contains(q) ||
            e.customerName.toLowerCase().contains(q) ||
            e.orderNo.toLowerCase().contains(q) ||
            e.fabricCode.toLowerCase().contains(q) ||
            e.loomOrderNo.toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: _buildAppBar(),
      body: StreamBuilder<LoomOrderResponse>(
        stream: _ordersStreamController.stream,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: C.brand700),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 50,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      _loadOrders(
                        viewType: _getViewType(),
                        unit: _unit,
                        pagesize: pagesize,
                      );
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          // Data received
          if (snapshot.hasData) {
            final response = snapshot.data!;
            _orders = response.orders;

            _filteredOrders = _orders.where((e) {
              final q = _searchController.text.toLowerCase();
              if (q.isEmpty) return true;
              return e.requiredFabricCode.toLowerCase().contains(q) ||
                  e.bom.toLowerCase().contains(q) ||
                  e.customerName.toLowerCase().contains(q) ||
                  e.orderNo.toLowerCase().contains(q) ||
                  e.fabricCode.toLowerCase().contains(q) ||
                  e.loomOrderNo.toLowerCase().contains(q);
            }).toList();

            _totalCount = response.totalCount;

            if (_filteredOrders.isEmpty) {
              return _emptyState();
            }

            return isMobile(context)
                ? _buildMobileList()
                : _buildDesktopTable();
          }

          return const Center(child: Text("No Data Found"));
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(140),

      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 5, 14, 10),
        decoration: const BoxDecoration(
          color: C.appBar1,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 25,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Loom Entry",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "Manage Loom Orders & Production",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                _recordBadge(),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(child: _searchBar()),
                const SizedBox(width: 8),
                Expanded(child: _filterDropdown()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget _filterDropdown() {
  //   return Container(
  //     height: 40,
  //     padding: const EdgeInsets.symmetric(horizontal: 10),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(10),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(.06),
  //           blurRadius: 6,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: DropdownButtonHideUnderline(
  //       child: DropdownButton<String>(
  //         value: _selectedFilter,
  //         isExpanded: true,
  //         isDense: true,
  //         icon: const Icon(Icons.expand_more_rounded, size: 18, color: C.brand700),
  //         style: const TextStyle(
  //           fontSize: 13,
  //           fontWeight: FontWeight.w600,
  //           color: C.textHigh,
  //         ),
  //         items: const [
  //           DropdownMenuItem(
  //             value: 'Process',
  //             child: Row(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Icon(Icons.sync, size: 16, color: C.textMid),
  //                 SizedBox(width: 6),
  //                 Text('Process'),
  //               ],
  //             ),
  //           ),
  //           DropdownMenuItem(
  //             value: 'All',
  //             child: Row(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Icon(Icons.grid_view_rounded, size: 16, color: C.textMid),
  //                 SizedBox(width: 6),
  //                 Text('All'),
  //               ],
  //             ),
  //           ),
  //           DropdownMenuItem(
  //             value: 'Finish',
  //             child: Row(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Icon(Icons.check_circle_rounded, size: 16, color: C.textMid),
  //                 SizedBox(width: 6),
  //                 Text('Finish'),
  //               ],
  //             ),
  //           ),
  //         ],
  //         onChanged: (value) {
  //           if (value != null) _applyFilter(value);
  //         },
  //       ),
  //     ),
  //   );
  // }

  Widget _recordBadge() {
    return Column(
      children: [
        Text(
          "$_totalCount",
          style: const TextStyle(
            color: C.bg,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Text(
          "Records",
          style: TextStyle(color: C.textMid, fontSize: 11),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: C.brand700,
            size: 18,
          ),

          const SizedBox(width: 6),

          Expanded(
            child: TextField(
              controller: _searchController,

              // 👇 Har character type hote hi search
              onChanged: (value) {
                _filterOrders();
                setState(() {});
              },

              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),

              decoration: InputDecoration(
                isDense: true,
                isCollapsed: true,
                hintText: "Search order / customer...",
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
                border: InputBorder.none,
              ),
            ),
          ),

          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();

                setState(() {
                  _filteredOrders = List.from(_orders);
                });
              },
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: C.textMid,
              ),
            ),
        ],
      ),
    );
  }

  Widget _filterDropdown() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFilter,
          isExpanded: true,
          isDense: true,
          icon: const Icon(
            Icons.expand_more_rounded,
            size: 18,
            color: C.brand700,
          ),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: C.textHigh,
          ),
          items: const [
            DropdownMenuItem(
              value: 'Process',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sync, size: 16, color: C.textMid),
                  SizedBox(width: 6),
                  Text('Process'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'All',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.grid_view_rounded, size: 16, color: C.headerBlue),
                  SizedBox(width: 6),
                  Text('All'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'Finish',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, size: 16, color: C.textMid),
                  SizedBox(width: 6),
                  Text('Finish'),
                ],
              ),
            ),
          ],
          onChanged: (value) {
            if (value != null) _applyFilter(value);
          },
        ),
      ),
    );
  }

  // ================= MOBILE LIST =================

  Widget _buildMobileList() {
    return RefreshIndicator(
      color: C.brand700,
      onRefresh: () async {
        _applyFilter(_selectedFilter);
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _filteredOrders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = _filteredOrders[index];

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: C.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                /// HEADER
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: C.bg,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order NO -${order.loomOrderNo}",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: C.primaryDark,
                              ),
                            ),

                            const SizedBox(height: 2),

                            Text(
                              "Party Name -${order.customerName}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                color: C.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: order.status ? C.borderLight : C.border,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order.status ? "ACTIVE" : "INACTIVE",
                          style: TextStyle(
                            color: order.status ? C.success : C.danger,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// TABLE
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.2),
                      1: FlexColumnWidth(1.8),
                    },
                    border: TableBorder.symmetric(
                      inside: BorderSide(color: C.borderLight),
                    ),
                    children: [
                      _tableRow("Bom No", order.bom.isEmpty ? "-" : order.bom),
                      _tableRow(
                        "Article No",
                        order.articleNo.isEmpty ? "-" : order.articleNo,
                      ),
                      _tableRow(
                        "PO No",
                        order.poNumber.isEmpty ? "-" : order.poNumber,
                      ),

                      _tableRow("Fabric Code", order.fabricCode),
                      _tableRow(
                        "Req Mtr",
                        order.requiredQuantityMtr.toStringAsFixed(0),
                      ),
                      _tableRow(
                        "Req KG",
                        order.requiredQuantityKg.toStringAsFixed(0),
                      ),

                      _tableRow(
                        "Prod KG",
                        order.productionKg.toStringAsFixed(0),
                      ),
                      _tableRow(
                        "Prod Mtr",
                        order.productionMtr.toStringAsFixed(0),
                      ),
                      _tableRow(
                        "Bal KG",
                        order.balanceKg.toStringAsFixed(0),
                        valueColor: order.balanceKg < 0 ? C.danger : C.success,
                      ),

                      _tableRow(
                        "Bal Mtr",
                        order.balanceMtr.toStringAsFixed(0),
                        valueColor: order.balanceMtr < 0 ? C.danger : C.success,
                      ),
                    ],
                  ),
                ),

                /// BUTTON
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoomForm(
                              production: convertToProduction(order),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: C.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Open Order",
                        style: TextStyle(
                          color: C.bg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  TableRow _tableRow(
    String title,
    String value, {
    Color valueColor = C.textHigh,
  }) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: C.textMid,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  // ================= DESKTOP TABLE =================
  Widget _buildDesktopTable() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.pink,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: C.borderLight),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            /// TABLE HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: const BoxDecoration(
                color: C.brand700,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "ORDER",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Text(
                      "PO",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 3,
                    child: Text(
                      "FABRIC",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Text(
                      "REQ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Text(
                      "PROD",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Text(
                      "BAL",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Text(
                      "CUSTOMER",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Text(
                      "STATUS",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// TABLE BODY
            Expanded(
              child: ListView.builder(
                itemCount: _filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = _filteredOrders[index];

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: C.borderLight)),
                      color: index.isEven ? Colors.white : C.pageBg,
                    ),
                    child: Row(
                      children: [
                        /// ORDER
                        Expanded(
                          flex: 2,
                          child: Text(
                            order.loomOrderNo,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        /// PO
                        Expanded(
                          flex: 2,
                          child: Text(
                            order.poNumber.isEmpty ? "-" : order.poNumber,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),

                        /// FABRIC
                        Expanded(
                          flex: 3,
                          child: Text(
                            order.fabricCode,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),

                        /// REQ
                        Expanded(
                          child: Text(
                            order.requiredQuantityKg.toStringAsFixed(0),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),

                        /// PROD
                        Expanded(
                          child: Text(
                            order.productionKg.toStringAsFixed(0),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),

                        /// BAL
                        Expanded(
                          child: Text(
                            order.balanceKg.toStringAsFixed(0),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: order.balanceKg < 0 ? C.danger : C.success,
                            ),
                          ),
                        ),

                        /// CUSTOMER
                        Expanded(
                          flex: 2,
                          child: Text(
                            order.customerName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),

                        /// STATUS
                        Expanded(
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: order.status
                                    ? C.success.withOpacity(.12)
                                    : C.danger.withOpacity(.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                order.status ? "ACTIVE" : "INACTIVE",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: order.status ? C.success : C.danger,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= EMPTY =================

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: C.brand50,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 60,
              color: C.brand700,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "No Orders Found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: C.textHigh,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Try changing filter or search keyword",
            style: TextStyle(color: C.textMid),
          ),
        ],
      ),
    );
  }

  String _getViewType() {
    switch (_selectedFilter) {
      case 'Process':
        return 'process';

      case 'Finish':
        return 'finish';

      default:
        return 'all';
    }
  }
}
