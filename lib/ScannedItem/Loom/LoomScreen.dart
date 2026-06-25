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
  bool _isLoading = false;

  String _unit = "";
  int pagesize= 50;

  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 700;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadOrders(viewType: 'all', unit: _unit,pagesize: pagesize);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders({
    required String viewType,
    required String unit,
    required int pagesize,
  }) async {
    setState(() => _isLoading = true);

    try {
      final response = await InStockService.fetchLoomOrders(
        viewType: viewType,
        unit: unit,
        pageNumber: 1,
        pageSize: pagesize
      );
      final today = DateTime.now();
      setState(() {
        _orders = response.orders;
        _filteredOrders = response.orders;
        _totalCount = response.totalCount;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _initializeData() async {
    _unit = await AppSession.getUnit() ?? "UNIT-1";

    _loadOrders(viewType: 'all', unit: _unit,pagesize: pagesize);
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });

    switch (filter) {
      case 'Process':
        _loadOrders(viewType: 'process', unit: _unit,pagesize: pagesize);
        break;

      case 'Finish':
        _loadOrders(viewType: 'finish', unit: _unit,pagesize: pagesize);
        break;

      default:
        _loadOrders(viewType: 'all', unit: _unit,pagesize: pagesize);
    }
  }

  void _filterOrders() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 300), () {
      final q = _searchController.text.toLowerCase();

      setState(() {
        _filteredOrders = _orders.where((e) {
          return e.requiredFabricCode.toLowerCase().contains(q) ||
              e.bom.contains(q)||
              e.customerName.toLowerCase().contains(q) ||
              e.orderNo.toLowerCase().contains(q) ||
              e.fabricCode.toLowerCase().contains(q) ||
              e.loomOrderNo.toLowerCase().contains(q);
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.pageBg,
      body: Column(
        children: [
          _topHeader(),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: C.brand700),
                  )
                : _filteredOrders.isEmpty
                ? _emptyState()
                : isMobile(context)
                ? _buildMobileList()
                : _buildDesktopTable(),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================

  Widget _topHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        color: C.appBar1,
        // gradient: LinearGradient(
        //   colors: [C.appBar1, C.appBar4,],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Your remaining widgets
                  ],
                ),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Loom Entry",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
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

            const SizedBox(height: 10),

            _searchBar(),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _filterCard(title: "Process", icon: Icons.sync),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _filterCard(
                    title: "All",
                    icon: Icons.grid_view_rounded,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _filterCard(
                    title: "Finish",
                    icon: Icons.check_circle_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _recordBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(.15)),
      ),
      child: Column(
        children: [
          Text("$_totalCount",
            style: const TextStyle(
              color: C.textHigh,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Text(
            "Records",
            style: TextStyle(color: C.textHigh, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => _filterOrders(),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: "Search Bom No / Order / Customer / Fabric",
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: const Icon(Icons.search_rounded, color: C.brand700),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _filterOrders();
                  },
                  icon: const Icon(Icons.close_rounded),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _filterCard({required String title, required IconData icon}) {
    final isSelected = _selectedFilter == title;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _applyFilter(title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? C.border : C.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? C.actionOrange : C.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isSelected ? C.success : C.textMid),

            const SizedBox(width: 8),

            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? C.success : C.textHigh,
              ),
            ),
          ],
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
}
