import 'package:flutter/material.dart';
import '../../Color/Colorclass.dart';
import '../../services/NardanaApis/NardanaApi.dart';
import 'ModelClass/OrderPlanningModel.dart';
import 'OrderPlanningScreen2.dart';


class OrderPlanningScreen extends StatefulWidget {
  const OrderPlanningScreen({super.key});

  @override
  State<OrderPlanningScreen> createState() => _OrderPlanningScreenState();
}

class _OrderPlanningScreenState extends State<OrderPlanningScreen> {
  final ScrollController _horizCtrl = ScrollController();

  final ScrollController _listCtrl = ScrollController();

  final TextEditingController _searchCtrl = TextEditingController();

  List<OrderPlanningModel> orders = [];
  List<OrderPlanningModel> filtered = [];

  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;

  int page = 1;

  // ---------------- TABLE WIDTH ----------------

  static const cInquiry = 100.0;
  static const cCustomer = 180.0;
  static const cArticle = 200.0;
  static const cDate = 140.0;
  static const cQty = 90.0;
  static const cPo = 100.0;

  double get totalWidth => cInquiry + cCustomer + cArticle + cDate + cQty + cPo;

  @override
  void initState() {
    super.initState();

    loadOrders();

    _listCtrl.addListener(() {
      if (_listCtrl.position.pixels >=
              _listCtrl.position.maxScrollExtent - 200 &&
          !isLoadingMore &&
          hasMore) {
        loadMore();
      }
    });
  }

  Future loadOrders() async {
    try {
      setState(() {
        page = 1;
        isLoading = true;
        hasMore = true;
      });

      final result = await NaradanaApiService().fetchOrderPlanning(
        pageNumber: page,
        pageSize: 50,
      );

      setState(() {
        orders = result;
        filtered = result;

        isLoading = false;

        hasMore = result.length >= 50;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint(e.toString());
    }
  }

  Future loadMore() async {
    try {
      setState(() {
        isLoadingMore = true;
      });

      page++;

      final result = await NaradanaApiService().fetchOrderPlanning(
        pageNumber: page,
        pageSize: 50,
      );

      setState(() {
        orders.addAll(result);

        filter();

        isLoadingMore = false;

        hasMore = result.length >= 50;
      });
    } catch (e) {
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  void filter() {
    final q = _searchCtrl.text.toLowerCase();

    setState(() {
      filtered = orders.where((e) {
        return e.customerName.toLowerCase().contains(q) ||
            e.articleNo.toLowerCase().contains(q) ||
            e.generatedInquiry.toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        elevation: 0,

        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:  [C.appBar2, C.appBar3],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        iconTheme: const IconThemeData(color: Colors.white),

        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Order Planning",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            Text(
              "Total Records : ${filtered.length}",
              style: TextStyle(
                color: Colors.white.withOpacity(.9),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(14),

            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),

              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => filter(),

                decoration: InputDecoration(
                  hintText: "Search customer, article...",

                  prefixIcon: Icon(Icons.search, color: C.appBar2),

                  border: InputBorder.none,

                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: C.appBar3),
                  )
                : Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),

                    child: Scrollbar(
                      controller: _horizCtrl,
                      thumbVisibility: true,

                      child: SingleChildScrollView(
                        controller: _horizCtrl,
                        scrollDirection: Axis.horizontal,

                        child: SizedBox(
                          width: totalWidth < screenWidth
                              ? screenWidth
                              : totalWidth,

                          child: Column(
                            children: [
                              _header(),

                              Expanded(
                                child: ListView.builder(
                                  controller: _listCtrl,

                                  itemCount:
                                      filtered.length + (isLoadingMore ? 1 : 0),

                                  itemBuilder: (_, index) {
                                    if (index == filtered.length) {
                                      return const Padding(
                                        padding: EdgeInsets.all(15),

                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: C.appBar3,
                                          ),
                                        ),
                                      );
                                    }

                                    return _row(filtered[index], index);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 45,

      decoration: const BoxDecoration(
        color: C.border,

        borderRadius: BorderRadius.only(

          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),

      child: Row(
        children: [
          head("GEN.INQUIRY", cInquiry),
          head("CUSTOMER NAME", cCustomer),
          head("ARTICLE NO.", cArticle),
          head("TODAY DATE", cDate),
          head("QUANTITY", cQty),
          head("PO NO", cPo),
        ],
      ),
    );
  }

  Widget head(String text, double width) {
    return Container(
      width: width,
      height: 45,

      alignment: Alignment.center,

      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: C.primary.withOpacity(.4))),
      ),

      child: Text(
        text,

        textAlign: TextAlign.center,

        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: C.primary,
        ),
      ),
    );
  }

  Widget _row(OrderPlanningModel item, int index) {
    return Container(
      height: 40,
      color: index.isEven
          ? Colors.white
          : const Color(0xFFF7F9FC),

      child: Row(
        children: [

          // GEN INQUIRY CLICKABLE
          InkWell(
            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderPlanningScreen2(
                    orderData: item,
                  ),
                ),
              );

            },

            child: cell(
              item.generatedInquiry,
              cInquiry,
              textColor: Colors.blue,
              bold: true,
              underline: true,
            ),
          ),

          cell(
            item.customerName,
            cCustomer,
          ),

          cell(
            item.articleNo,
            cArticle,
          ),

          cell(
            item.todayDate
                ?.toString()
                .split(" ")[0] ??
                "-",
            cDate,
          ),

          cell(
            item.quantity,
            cQty,
          ),

          cell(
            item.poNum,
            cPo,
          ),
        ],
      ),
    );
  }

  Widget cell(
      String text,
      double width, {
        Color? textColor,
        bool bold = false,
        bool underline = false,
      }) {

    return Container(
      width: width,
      height: 55,

      alignment: Alignment.center,

      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),

      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.grey.shade300,
          ),
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),

      child: Text(
        text.isEmpty ? "-" : text,

        textAlign: TextAlign.center,

        maxLines: 2,
        overflow: TextOverflow.ellipsis,

        style: TextStyle(
          fontSize: 12,
          color: textColor ?? Colors.black,
          fontWeight:
          bold ? FontWeight.bold : FontWeight.normal,
          decoration: underline
              ? TextDecoration.underline
              : TextDecoration.none,
        ),
      ),
    );
  }
}
