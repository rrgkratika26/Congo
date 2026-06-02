import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../Color/Colorclass.dart';
import '../Login/InquiryReportScreen.dart';
import '../Login/ProfileSCreen.dart';
import '../ScannedItem/Cutting/CuttinIN/CuttingScreen.dart';
import '../routes/app_routes.dart';
import '../services/JBL_apis/jbl_api_bailing_reports.dart';
import '../util/sharedpreference/shared_preference.dart';
import 'ActionButtonWidget.dart';

class NewAdminDashboard extends StatefulWidget {
  final String? forceDepartment;

  const NewAdminDashboard({super.key, this.forceDepartment});

  @override
  State<NewAdminDashboard> createState() => _NewAdminDashboardState();
}

class _NewAdminDashboardState extends State<NewAdminDashboard>
    with SingleTickerProviderStateMixin {
  String? unit;
  String? user;
  String? department;
  String? userType;
  String? selectedDepartment;
  int? selectedIndex;

  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    loadSession();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> loadSession() async {
    user = await AppSession.getUsername();
    unit = await AppSession.getUnit();

    if (widget.forceDepartment != null) {
      department = widget.forceDepartment;
    } else {
      department = await AppSession.getDepartment();
    }

    userType = await AppSession.getUserType();

    if (!mounted) return;

    setState(() {});

    _fadeCtrl.forward();
  }

  List<_DashboardItem> getItems() {
    final dept = department?.toUpperCase();

    final normalizedUnit = unit?.toUpperCase().replaceAll(" ", "");

    // JBL ITEMS
    const jblItems = [
      _DashboardItem(title: 'JBL LOOM', icon: Icons.looks),
      _DashboardItem(title: 'JBL RMD', icon: Icons.inventory),
      _DashboardItem(title: 'JBL LAMINATION', icon: Icons.layers),
      _DashboardItem(title: 'JBL Cutting', icon: Icons.cut),
      _DashboardItem(title: 'JBL BAG', icon: Icons.shopping_bag),
      _DashboardItem(title: 'JBL Baling', icon: Icons.waves),
      _DashboardItem(title: 'JBL Dispatch', icon: Icons.local_shipping),
      _DashboardItem(title: 'JBL Webbing', icon: Icons.web),
    ];

    // NORMAL ITEMS
    const all = [
      _DashboardItem(title: 'INQUIRY', icon: Icons.question_answer),

      _DashboardItem(title: 'PLANNING', icon: Icons.next_plan_rounded),
      _DashboardItem(title: 'LOOM', icon: Icons.looks),
      _DashboardItem(title: 'RMD', icon: Icons.inventory),
      _DashboardItem(title: 'LAMINATION', icon: Icons.layers),
      _DashboardItem(title: 'CUTTING', icon: Icons.cut),
      _DashboardItem(title: 'BAG', icon: Icons.shopping_bag),
      _DashboardItem(title: 'BALING', icon: Icons.waves),
      _DashboardItem(title: 'WEBBING', icon: Icons.web),
      _DashboardItem(title: 'LEDGER', icon: Icons.menu_book),
      // _DashboardItem(title: 'FOLDING', icon: Icons.dashboard_customize),
      _DashboardItem(title: 'TAPELINE', icon: Icons.dashboard),

      _DashboardItem(title: 'MARKETING', icon: Icons.bar_chart),
    ];

    // JBL LOGIC
    if (normalizedUnit != null &&
        (normalizedUnit.contains('JBL') ||
            normalizedUnit.contains('DINESH-POLYFAB'))) {
      if (dept == 'PADMIN') {
        return jblItems;
      }

      return jblItems
          .where((e) => e.title.toUpperCase().contains(dept ?? ''))
          .toList();
    }

    // NORMAL LOGIC
    if (dept == 'PADMIN') {
      return all;
    }

    return all.where((e) => e.title == dept).toList();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    final width = media.size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1000;
    final isDesktop = width >= 1000;

    final horizontalPadding = isDesktop
        ? width * .06
        : isTablet
        ? width * .05
        : width * .04;

    final items = getItems();

    return Scaffold(
      drawer: buildDrawer(context, isMobile),
      backgroundColor: C.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            buildHeader(context, horizontalPadding, isMobile),

            Expanded(
              child: selectedDepartment == null
                  ? const InquiryReportScreen()
                  : selectedDepartment == "INQUIRY"
                  ? const InquiryReportScreen()
                  : buildDepartmentGrid(
                selectedDepartment!,
                isMobile,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER

  Widget buildHeader(
    BuildContext context,
    double horizontalPadding,
    bool isMobile,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isMobile ? 14 : 18,
      ),
      decoration: const BoxDecoration(
        color: C.appBar1
        // gradient: LinearGradient(colors: [C.appBar2, C.appBar3]),
      ),
      child: Row(
        children: [
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: isMobile ? 24 : 28,
                ),
              );
            },
          ),
          // if (selectedDepartment != null)
          //   IconButton(
          //     onPressed: () {
          //       setState(() {
          //         selectedDepartment = null;
          //       });
          //     },
          //     icon: const Icon(Icons.home, color: Colors.white),
          //   ),
          // GestureDetector(
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) => ProfileScreen(
          //           user: user,
          //           unit: unit,
          //           department: department,
          //           userType: userType,
          //         ),
          //       ),
          //     );
          //   },
          //
          //   child: Container(
          //     width: isMobile ? 44 : 56,
          //     height: isMobile ? 44 : 56,
          //
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(100),
          //     ),
          //
          //     child: Icon(
          //       Icons.person,
          //       color: C.appBar3,
          //       size: isMobile ? 22 : 28,
          //     ),
          //   ),
          // ),
          // SizedBox(width: isMobile ? 12 : 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome To',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
                SizedBox(height: isMobile ? 2 : 5),
                Text(
                  selectedDepartment ?? userType ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 18 : 24,
                  ),
                ),
              ],
            ),
          ),
          if (unit != null)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 10 : 16,
                vertical: isMobile ? 7 : 10,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.factory,
                    color: Colors.white,
                    size: isMobile ? 14 : 18,
                  ),
                  SizedBox(width: isMobile ? 5 : 8),
                  Text(
                    unit ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 11 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // CARD

  Widget buildCard(BuildContext context, _DashboardItem item, bool isMobile) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) {
            return buildBottomSheet(item.title, context, isMobile);
          },
        );
      },
      child: Container(
        padding: EdgeInsets.all(isMobile ? 14 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isMobile ? 58 : 70,
              height: isMobile ? 58 : 70,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [C.bg, C.appBar4]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                item.icon,
                color: Colors.white,
                size: isMobile ? 30 : 36,
              ),
            ),
            SizedBox(height: isMobile ? 14 : 18),
            Text(
              item.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 14 : 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BOTTOM SHEET

  Widget buildBottomSheet(
    String department,
    BuildContext context,
    bool isMobile,
  ) {
    final actions = getActionsForMenu(department);

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 70,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          SizedBox(height: isMobile ? 18 : 24),
          Text(
            department,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 20 : 26,
            ),
          ),
          SizedBox(height: isMobile ? 14 : 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: actions.map((action) {
              return InkWell(
                onTap: () {
                  Navigator.pop(context);

                  navigateAction(context, department, action);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 14 : 18,
                    vertical: isMobile ? 10 : 14,
                  ),
                  decoration: BoxDecoration(
                    color: C.appBar1,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    action.name.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 12 : 14,
                      color: C.appBar3,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: isMobile ? 18 : 24),
        ],
      ),
    );
  }

  // EMPTY STATE

  Widget buildEmptyState(bool isMobile) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24 : 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard_customize,
              size: isMobile ? 70 : 100,
              color: C.appBar3,
            ),
            SizedBox(height: isMobile ? 18 : 24),
            Text(
              'No Department Available',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 18 : 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NAVIGATION

  void navigateAction(BuildContext context, String label, MenuAction action) {
    final isJBL = unit?.toUpperCase().contains('JBL') ?? false;

    // JBL FLOW

    if (isJBL) {
      switch (label) {
        case 'JBL LOOM':
          if (action == MenuAction.IN) {
            Navigator.pushNamed(context, AppRoutes.loomList);
          } else if (action == MenuAction.report) {
            Navigator.pushNamed(context, AppRoutes.loomIn);
          }
          break;

        case 'JBL RMD':
          if (action == MenuAction.IN) {
            Navigator.pushNamed(context, AppRoutes.jblRmdIn);
          } else if (action == MenuAction.OUT) {
            Navigator.pushNamed(context, AppRoutes.jblRmdOut);
          } else if (action == MenuAction.Stock_Report) {
            Navigator.pushNamed(context, AppRoutes.jblRmdStockReports);
          }
          break;

        case 'JBL LAMINATION':
          if (action == MenuAction.IN) {
            Navigator.pushNamed(context, AppRoutes.jblLamination);
          }
          break;

        case 'JBL Cutting':
          if (action == MenuAction.IN) {
            Navigator.pushNamed(context, AppRoutes.jblCuttingIn);
          }
          break;

        case 'JBL BAG':
          if (action == MenuAction.entry) {
            Navigator.pushNamed(context, AppRoutes.jblBagStoreIssue);
          }
          break;

        case 'JBL Baling':
          if (action == MenuAction.entry) {
            Navigator.pushNamed(context, AppRoutes.jblBailing);
          }
          break;

        case 'JBL Dispatch':
          if (action == MenuAction.entry) {
            Navigator.pushNamed(context, AppRoutes.jblScan);
          }
          break;

        case 'JBL Webbing':
          if (action == MenuAction.IN) {
            Navigator.pushNamed(context, AppRoutes.jblWebbIn);
          }
          break;
      }
    }
    // NORMAL FLOW
    else {
      switch (label) {
        case 'INQUIRY':
          if (action == MenuAction.Inquirey_Report) {
            Navigator.pushNamed(context, AppRoutes.inquiryReport);
          }
          break;
        case 'PLANNING':
          if (action == MenuAction.Order_Planning) {
            Navigator.pushNamed(context, AppRoutes.orderPlanning);
          } else if (action == MenuAction.Order_Composition) {
            Navigator.pushNamed(context, AppRoutes.orderComposition);
          } else if (action == MenuAction.To_Loom) {
            Navigator.pushNamed(context, AppRoutes.toLoom);
          }
          break;

        case 'LOOM':
          if (action == MenuAction.IN) {
            Navigator.pushNamed(context, AppRoutes.loomIn);
          } else if (action == MenuAction.In_Report) {
            Navigator.pushNamed(context, AppRoutes.loomReports);
          }
          else if (action == MenuAction.report) {
            Navigator.pushNamed(context, AppRoutes.loomSaveList);
          }
          break;

        case 'RMD':
          if (action == MenuAction.IN) {
            Navigator.pushNamed(context, AppRoutes.rmdIn);
          } else if (action == MenuAction.OUT) {
            Navigator.pushNamed(context, AppRoutes.rmdOut);
          } else if (action == MenuAction.report) {
            Navigator.pushNamed(context, AppRoutes.rmdNardanaReports);
          } else if (action == MenuAction.stock) {
            Navigator.pushNamed(context, AppRoutes.rmdNardanaStock);
          }
          break;

        case 'LAMINATION':
          if (action == MenuAction.IN) {
            Navigator.pushNamed(context, AppRoutes.lamination);
          } else if (action == MenuAction.OUT) {
            Navigator.pushNamed(context, AppRoutes.laminationOutStock);
          } else if (action == MenuAction.report) {
            Navigator.pushNamed(context, AppRoutes.lamNaradanaReports);
          }
          break;
        case 'CUTTING':
          if (action == MenuAction.IN) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CuttingScreen()),
            );
          }
          else if (action == MenuAction.In_Report) {
            Navigator.pushNamed(context, AppRoutes.nardanaInReport);
          }
          else if (action == MenuAction.OUT) {
          Navigator.pushNamed(context, AppRoutes.nardanaCutOutList);
            // Navigator.pushNamed(context, AppRoutes.visaCutOutStock);
          }
          // RollWiseReportScreen
          else if (action == MenuAction.report) {
            Navigator.pushNamed(context, AppRoutes.rollWisereport);
          }
          else if (action == MenuAction.stock) {
            Navigator.pushNamed(context, AppRoutes.cutGroupStock);
          }
          else if (action == MenuAction.Approval) {
            Navigator.pushNamed(context, AppRoutes.cuttingnardana);
          } else if (action == MenuAction.Pcs_Issue) {
            Navigator.pushNamed(context, AppRoutes.cuttingIssuenardana);
          }
          break;

        case 'BAG':
          if (action == MenuAction.entry) {
            Navigator.pushNamed(context, AppRoutes.bagEntry);
          } else if (action == MenuAction.report) {
            Navigator.pushNamed(context, AppRoutes.bagReport);
          }
          break;

        case 'BALING':
          if (action == MenuAction.entry) {
            Navigator.pushNamed(context, AppRoutes.baleEntry);
          } else if (action == MenuAction.report) {
            Navigator.pushNamed(context, AppRoutes.baleReport);
          } else if (action == MenuAction.dispatch) {
            Navigator.pushNamed(context, AppRoutes.baleDispatch);
          }
          else if(action == MenuAction.stock){
            Navigator.pushNamed(context, AppRoutes.baleStockgroup);
          }
          break;

        case 'WEBBING':
          if (action == MenuAction.IN) {
            Navigator.pushNamed(context, AppRoutes.webbingIn);
          } else if (action == MenuAction.OUT) {
            Navigator.pushNamed(context, AppRoutes.webbingOut);
          } else if (action == MenuAction.report) {
            Navigator.pushNamed(context, AppRoutes.webbNardanaReport);
          }
          break;

        case 'LEDGER':
          if (action == MenuAction.Webbing_Ledger) {
            Navigator.pushNamed(context, AppRoutes.stockLedger);
          }
          break;

        case 'FOLDING':
          if (action == MenuAction.IN) {
            Navigator.pushNamed(context, AppRoutes.foldingIn);
          }
          break;

        case 'TAPELINE':
          if (action == MenuAction.IN) {
            Navigator.pushNamed(context, AppRoutes.tapelineIn);
          }
          break;

        case 'MARKETING':
          if (action == MenuAction.Inquirey_Report) {
            Navigator.pushNamed(context, AppRoutes.InquiryPannel);
          }
          break;
      }
    }
  }

  List<_DashboardItem> getDrawerDepartments() {
    final normalizedUnit = unit?.toUpperCase().replaceAll(" ", "");

    // JBL Departments
    const jblItems = [
      _DashboardItem(title: 'JBL LOOM', icon: Icons.looks),
      _DashboardItem(title: 'JBL RMD', icon: Icons.inventory),
      _DashboardItem(title: 'JBL LAMINATION', icon: Icons.layers),
      _DashboardItem(title: 'JBL Cutting', icon: Icons.cut),
      _DashboardItem(title: 'JBL BAG', icon: Icons.shopping_bag),
      _DashboardItem(title: 'JBL Baling', icon: Icons.waves),
      _DashboardItem(title: 'JBL Dispatch', icon: Icons.local_shipping),
      _DashboardItem(title: 'JBL Webbing', icon: Icons.web),
    ];

    // NORMAL Departments
    const all = [
      _DashboardItem(title: 'INQUIRY', icon: Icons.question_answer),
      _DashboardItem(title: 'PLANNING', icon: Icons.next_plan_rounded),
      _DashboardItem(title: 'LOOM', icon: Icons.looks),
      _DashboardItem(title: 'RMD', icon: Icons.inventory),
      _DashboardItem(title: 'LAMINATION', icon: Icons.layers),
      _DashboardItem(title: 'CUTTING', icon: Icons.cut),
      _DashboardItem(title: 'BAG', icon: Icons.shopping_bag),
      _DashboardItem(title: 'BALING', icon: Icons.waves),
      _DashboardItem(title: 'WEBBING', icon: Icons.web),
      _DashboardItem(title: 'LEDGER', icon: Icons.menu_book),
      // _DashboardItem(title: 'FOLDING', icon: Icons.dashboard_customize),
      _DashboardItem(title: 'TAPELINE', icon: Icons.dashboard),
      _DashboardItem(title: 'MARKETING', icon: Icons.bar_chart),
    ];

    final isJBL =
        normalizedUnit != null &&
        (normalizedUnit.contains('JBL') ||
            normalizedUnit.contains('DINESH-POLYFAB'));

    return isJBL ? jblItems : all;
  }

  // DRAWER
  Widget buildDrawer(BuildContext context, bool isMobile) {
    final departments = getDrawerDepartments();

    return Drawer(
      width: isMobile ? MediaQuery.of(context).size.width * .82 : 340,
      child: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 18 : 24,
                vertical: isMobile ? 22 : 30,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [C.appBar1, C.appBar4]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: isMobile ? 28 : 34,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: C.appBar3,
                      size: isMobile ? 28 : 34,
                    ),
                  ),

                  SizedBox(height: isMobile ? 14 : 18),

                  Text(
                    user ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 18 : 22,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    userType ?? '',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),

                  SizedBox(height: isMobile ? 12 : 16),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.factory,
                          color: Colors.white,
                          size: 16,
                        ),

                        const SizedBox(width: 6),

                        Flexible(
                          child: Text(
                            unit ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // DEPARTMENT LIST
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 16),
                itemCount: departments.length,
                itemBuilder: (_, index) {
                  final item = departments[index];

                  final actions = getActionsForMenu(item.title);

                  return ListTile(
                    leading: Container(
                      width: isMobile ? 42 : 48,
                      height: isMobile ? 42 : 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [C.appBar4, C.appBar3],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        item.icon,
                        color: Colors.white,
                        size: isMobile ? 20 : 24,
                      ),
                    ),

                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 14 : 16,
                      ),
                    ),

                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                    onTap: () {
                      Navigator.pop(context);

                      setState(() {
                        selectedDepartment = item.title;
                      });
                    },
                  );
                },
              ),
            ),

            // FOOTER
            Padding(
              padding: EdgeInsets.all(isMobile ? 14 : 18),
              child: Column(
                children: [
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),

                    leading: const Icon(Icons.person_outline, color: C.appBar3),

                    title: const Text(
                      "Profile",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(
                            user: user,
                            unit: unit,
                            department: department,
                            userType: userType,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 6),

                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),

                    leading: const Icon(Icons.logout, color: Colors.red),

                    title: const Text(
                      "Logout",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),

                    onTap: () async {
                      await AppSession.clearSession();

                      Get.offAllNamed(AppRoutes.login);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData getActionIcon(MenuAction action) {
    switch (action) {
      case MenuAction.IN:
        return Icons.login;

      case MenuAction.OUT:
        return Icons.logout;

      case MenuAction.report:
        return Icons.bar_chart;

      case MenuAction.stock:
        return Icons.inventory_2;

      case MenuAction.entry:
        return Icons.edit_note;

      case MenuAction.dispatch:
        return Icons.local_shipping;

      case MenuAction.scan:
        return Icons.qr_code_scanner;

      default:
        return Icons.arrow_forward_ios;
    }
  }

  Widget buildDepartmentGrid(String department, bool isMobile) {
    final actions = getActionsForMenu(department);

    return GridView.builder(
      padding: const EdgeInsets.all(16),

      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),

      itemCount: actions.length,

      itemBuilder: (context, index) {
        final action = actions[index];

        return InkWell(
          borderRadius: BorderRadius.circular(18),

          onTap: () {
            navigateAction(context, department, action);
          },

          child: Container(
            decoration: BoxDecoration(
              color: C.primary,

              borderRadius: BorderRadius.circular(18),
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  getActionIcon(action),
                  color: Colors.white,
                  size: isMobile ? 30 : 36,
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),

                  child: Text(
                    action.name.replaceAll("_", " ").toUpperCase(),

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardItem {
  final String title;
  final IconData icon;

  const _DashboardItem({required this.title, required this.icon});
}
