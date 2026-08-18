import 'package:IMS/AdminDashBoard/DepartmentDashboard.dart';
import 'package:IMS/JBL/JBLDispatch/DispatchDetailScreen.dart';
import 'package:IMS/JBL/JBL_BailingReport/JBLBailingReportScreen.dart';
import 'package:IMS/NARDANA/LoomReprts/ManualLoomReports.dart';
import 'package:IMS/NARDANA/RmdINReports/RmdRollENtryScreen.dart';
import 'package:IMS/NARDANA/WebbingsReports/WebInReportScreen.dart';
import 'package:IMS/NARDANA/WebbingsReports/WebStockReprtScreen.dart';

import 'package:IMS/ScannedItem/Cutting/Cut_pieces.dart';
import 'package:IMS/ScannedItem/TAPELINE/Reports/InReports.dart';
import 'package:IMS/ScannedItem/Webbing/WebbingEntry.dart';
import 'package:IMS/screen/Printing/PrintingRollList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../AdminDashBoard/AsiaDashBoard/DashboardTab.dart';
import '../AdminDashBoard/AsiaDashBoard/DepartmentdashboardBottom.dart';
import '../JBL/JBLWebbing/ReportsScreen/StockScreen.dart';
import '../JBL/JBL_BagProduction/ReportModel/ReortScreen.dart';
import '../JBL/JBL_Loom/FiBCLoomList_1screen.dart';
import '../JBL/JBL_Loom/LoomFormENtry.dart';
import '../JBL/JBL_Loom/SavedListScreenLomm.dart';
import '../JBL/JBL_RMD/AllReportScreen.dart';
import '../DynamicWrapper.dart' hide DynamicReportScreen;
import '../JBL/JBLBailing/BailingEntry.dart';
import '../JBL/JBLBailing/PrintScreen.dart';
import '../JBL/JBLDispatch/JblDispatchReport.dart';
import '../JBL/JBLWebbing/WebbingInStock.dart';
import '../JBL/JBLWebbing/WebbingOutEntry.dart';
import '../JBL/JBL_BagProduction/FIBC_store_entry.dart';

import '../JBL/JBL_BagProduction/PackingDepart/PackingDepartScreen.dart';
import '../JBL/JBL_Cutting/CUTTING_screen.dart';
import '../JBL/JBL_RMD/StockReportsScreen.dart';
import '../JBL/JBL_RMD/screens/Jbl_Rmd_In.dart';
import '../JBL/JBL_RMD/screens/Jbl_Rmd_Out.dart';
import '../JBL/Lamination/LaminationReportscreen.dart';
import '../JBL/Lamination/lamination_Instock_screen.dart';
import '../JBL/PrintSample.dart';

import '../Login/InquiryReportScreen.dart';
import '../Login/LoginNardanaScreen.dart';
import '../Login/LoginScreen.dart';
import '../NARDANA/BaleNardana/BaleStockGroup.dart';
import '../NARDANA/CUTTING_Stock/Reports/ComponetReportScreen.dart';
import '../NARDANA/CUTTING_Stock/Reports/Cut_InReports.dart';
import '../NARDANA/CUTTING_Stock/Reports/Cutting_InReportScreen.dart';
import '../NARDANA/CUTTING_Stock/Reports/ReportSliderScreen.dart';
import '../NARDANA/CUTTING_Stock/Reports/RollWiseReportScreen.dart';
import '../NARDANA/CUTTING_Stock/Stockreports.dart';
import '../NARDANA/LaminationReports/LamOutScreen.dart';
import '../NARDANA/LaminationReports/LamReportsSlider.dart';
import '../NARDANA/LaminationReports/LaminationScreen.dart';
import '../NARDANA/LoomReprts/LoomReports.dart';
import '../NARDANA/Marketing/BomListScreen.dart';
import '../NARDANA/Marketing/BomReportscreen.dart';
import '../NARDANA/Marketing/InquiryReportScreen.dart';
import '../NARDANA/Marketing/IssueToQCScreen.dart';

import '../NARDANA/Planning/CombineToLoom.dart';
import '../NARDANA/Planning/ManualPlanningToLoom.dart';
import '../NARDANA/Planning/OrderCompositionScreen.dart';
import '../NARDANA/Planning/OrderPlanningScreen.dart';
import '../NARDANA/Planning/ToLOomPlanningGenCode.dart';
import '../NARDANA/RmdINReports/InOutSliderScreen.dart';
import '../NARDANA/RmdINReports/RMD_Transfer.dart';
import '../NARDANA/RmdINReports/RmdOutReportScreen.dart';
import '../NARDANA/RmdINReports/RmdReportsIn.dart';
import '../NARDANA/RmdINReports/RmdSavedListForPrint.dart';
import '../NARDANA/StockLedger/Web_LedgerStock.dart';
import '../NARDANA/WebbingsReports/WebStockSliderScreen.dart';
import '../NARDANA/WebbingsReports/WebbingSliderReports.dart';
import '../ScannedItem/Cutting/CutPcs_IssuedScreen.dart';
import '../ScannedItem/Cutting/NardanaCutting/NaradanCutOutList.dart';
import '../ScannedItem/Cutting/OutStock/Cut_OutStock.dart';
import '../ScannedItem/Cutting/CuttinIN/CuttinInStock.dart';
import '../ScannedItem/Cutting/NardanaCutting/CutPcsIssueNardana.dart';
import '../ScannedItem/Cutting/NardanaCutting/ReceiveCutPcs.dart';
import '../ScannedItem/Cutting/OutStock/OutSavedList.dart';
import '../ScannedItem/Cutting/recutPcsIssue/recurPcsIssues.dart';
import '../ScannedItem/Folding/Folding_In.dart';
import '../ScannedItem/Lamination/lAMINATION_OUTsTOCK/OutStock.dart';
import '../ScannedItem/Loom/LoomSliderScreen.dart';
import '../ScannedItem/RmdIn/RMDStockIn.dart';
import '../ScannedItem/RmdIn/RMDscreen.dart';
import '../ScannedItem/RmdIn/RmDInUpdateLocationScreen.dart';
import '../ScannedItem/RmdOut/RmdOutScreen.dart';
import '../ScannedItem/RMDStock/RMDstockScreen.dart';
import '../ScannedItem/Lamination/LaminationScreen.dart';
import '../ScannedItem/Cutting/CuttinIN/CuttingScreen.dart';
import '../ScannedItem/TAPELINE/OutStockList.dart';
import '../ScannedItem/TAPELINE/RecentEntryScreen.dart';
import '../ScannedItem/TAPELINE/Reports/TapeOutReports.dart';
import '../ScannedItem/TAPELINE/Reports/TapeStockReport.dart';
import '../ScannedItem/TAPELINE/TApeline_IN.dart';
import '../ScannedItem/TAPELINE/TapeInEnrtyList.dart';
import '../ScannedItem/Webbing/WebSaveEntries.dart';
import '../ScannedItem/Webbing/WebbingInStock.dart';
import '../ScannedItem/Webbing/WebbingOutStock.dart';
import '../ScannedItem/Webbing/WebbingScreen.dart';
import '../Visa/Loom/FiBCLoomList_1screen.dart';
import '../screen/BagProduction/BagProduction/BagProductionEntryScreen.dart';
import '../screen/BagProduction/BagReport/BagReportScreen.dart';
import '../screen/Baling/BailingReportScreen.dart';
import '../screen/Baling/BaleInReportScreen.dart';
import '../screen/Baling/BailingSliderScreen.dart';
import '../screen/Baling/BailingDispatchScreen.dart';
import '../JBL/JBLDispatch/DispatchEntry.dart';
import '../screen/Baling/BaleSliderScreen.dart';
import '../screen/Baling/StockReportScreen.dart';
import '../screen/Baling/dispatch/DispatchEntryScreen.dart';
import '../screen/MachineDepartment/MachineDepartmment.dart';

// class AppRoutes {
//   static const String login = '/login';
//   static const String inStock = '/instock';
//   static const String jblDispatchScreen = '/jblDispatchReport';
//   static const String loomIn = '/loom-in';
//   static const String loomReports = '/loomReports';
//   static const String loomSaveList = '/loomSaveList';
//   static const String rmdIn = '/rmd-in';
//   static const String rmdOut = '/rmd-out';
//   static const String rmdtransfer = '.rmdTransfer';
//   static const String rmdNardanaStock = '/rmdNardanaStock';
//   static const String lamination = '/lamination';
//   static const String dynamicReport = '/dynamicReport';
//   static const String rmdInReport = '/rmdInReport';
//   static const String rmdOutReport = '/rmdOutReport';
//   static const String jblLamination = '/JBL_lamination';
//   static const String reccutpcscutting = '/recutpcscutting';
//   static const String cuttingnardana = '/cutting';
//   static const String nardanaInReport = '/nardanaInReport';
//   static const String rollWisereport = '/rollWiseReport';
//   static const String cuttingIssuenardana = '/cuttingIssuenardana';
//   static const String jblBagStoreIssue = '/jblBagStoreIssue';
//   static const String jblPackingReport = '/jblProductionReport';
//   static const String cuttingIn = '/cuttingIn';
//   static const String foldingIn = '/foldingIn';
//   static const String tapelineIn = '/tapelineIn';
//
//   static const String jblCuttingIn = '/jblCuttingIn';
//   static const String baleStockgroup = '/baleStockGroup';
//   static const String laminationReports = '/laminationReports';
//   static const String lamNaradanaReports = '/lamNaradanaReports';
//   static const String reCutIssue = '/reCutIssue';
//   static const String cuttingIssue = '/cuttingIssue';
//   static const String webbingIn = '/webbing-in';
//   static const String webbingOut = '/webbing-out';
//   static const String bagEntry = '/bag-entry';
//   static const String bagReport = '/bag-report';
//   static const String baleEntry = '/bale-entry';
//   static const String baleReport = '/bale-report';
//   static const String baleDispatch = '/bale-dispatch';
//   static const String jblScan = '/jbl-scan';
//   static const String machine = '/machine';
//   static const String jblBailing = '/jbl-Webbing';
//   static const String blePrinterScan = '/ble-printer-scan';
//   static const String jblBailingReport = '/jblBailingReport';
//   static const String jblDispatchReport = '/jblDispatchReport';
//   static const String jblDispatchDetail = '/jblDispatchDetail';
//   static const String jblRmdIn = '/jblRmdIn';
//   static const String jblRmdOut = 'jblRmdOut';
//   static const String jblRmdStockReports = '/jblRmdStockReports';
//   static const String webbingStockReport = '/webbingStockReport';
//   static const String loomList = '/loomList';
//   static const String visaLoomList = '/visaLoomList';
//   static const String orderPlanning = '/orderPlanning';
//   static const String inquiryReport = '/inquiryreport';
//   static const String orderComposition = '/orderComposition';
//   static const String toLoom = '/toLoom';
//
//   static const String laminationOutStock = '/laminationOutStock';
//   static const String visaCutOutStock = '/visaCutOutStock';
//   static const String nardanaCutOutList = '/nardanaCutOutList';
//   static const String rmdInreportsNardana = '/rmdInreportsNardana';
//   // static const String laminationOutReports = '/laminationOutReports';
//   // static const String laminationInReports = '/laminationInReports';
//   // static const String laminationReports = '/laminationReports';
//   static const String laminationVisaReports = '/laminationReports';
//   // static const String jblreportIn = '/jblreportIn';
//   static const String jblWebbIn = '/jblWebbingStockIn';
//   static const String jblWebbOut = '/jblWebbOut';
//   static const String webbNardanaReport = '/webbNardanaReport';
//   static const String webStockReport = '/webStockReport';
//   static const String webStockSlider = '/webStockSlider';
//   static const String lamReportScreen = '/lamReportScreen';
//   static const String rmdNardanaReports = '/rmdNardanaReports';
//   static const String cutGroupStock = '/cutGroupStock';
//   static const String stockLedger = '/stockLedger';
//   static const String InquiryPannel = '/InquireyPannel';
//   static const String bomReport = '/bomReport';
//   static const String bomList = '/bomList';
//   static const String Issue_to_QC = '/Issue_to_QC';
//
//   static Map<String, WidgetBuilder> routes = {
//     loomIn: (_) => const LoomSliderScreen(screenType: 'IN'),
//     loomReports: (_) => const LoomReportScreen(),
//     loomSaveList: (_) => const SavedListScreen(),
//     rmdIn: (_) => const RmdScreen(screenType: 'IN'),
//
//     rmdOut: (_) => const RmdOutScreen(screenType: 'OUT'),
//     rmdtransfer: (_) => const RmdTransferScreen(),
//     rmdNardanaStock: (_) => const RmdStockReportScreen(),
//     lamination: (_) => const LaminationScreen(),
//     cuttingIn: (_) => const CuttingScreen(),
//     foldingIn: (_) => const FoldingIn(),
//     tapelineIn: (_) => const TapeLineApp(),
//     // jblCuttingIn: (_) => const JblCuttingScreen(),
//     reccutpcscutting: (_) => const ReceiveCutPcsScreen(),
//     cuttingnardana: (_) => const ReceiveCutPcsNardana(),
//     nardanaInReport: (_) => const CuttingInReport(),
//     cuttingIssuenardana: (_) => const CutPieceIssuedScreenNardana(),
//     cuttingIssue: (_) => const CutPieceIssuedScreen(),
//     reCutIssue: (_) => const RecutPcsIssueScreen(),
//     webbingIn: (_) => const WebbingScreen(screenType: 'IN'),
//     webbingOut: (_) => const WebbingScreen(screenType: 'OUT'),
//     rollWisereport: (_) => const ReportDashboardScreen(),
//     bagEntry: (_) => BagEntryScreen(),
//     bagReport: (_) => BagReportScreen(),
//     baleEntry: (_) => BaleInReportsScreen(),
//     baleReport: (_) => BailingSliderScreen(),
//     baleDispatch: (_) => DispatchScreen(),
//     // jblScan: (_) => PackingEntryScreen(),
//     login: (_) => LoginPage(),
//     inStock: (_) => RMDStockIn(),
//     // jblDispatchScreen: (_) => PackingEntryScreen(),
//     jblWebbIn: (_) => JblWebbingStockIn(screenType: 'IN'),
//     // jblWebbOut: (_) => WebbingOut(),
//     machine: (_) => MchineList(screenType: 'Scan'),
//     jblBailing: (_) => JblBailingEntry(screenType: 'IN'),
//     baleStockgroup: (_) => BaleStockGroupScreen(),
//     // jblBailingReport: (_) => JBLBalingReportScreen(),
//     // jblDispatchReport: (_) => JblDispatchReportScreen(),
//     jblPackingReport: (_) => PackingBagReportScreen(),
//     jblBagStoreIssue: (_) => StoreEntryListScreen(),
//     // jblRmdIn: (_) => const JBLRmdIn(screenType: 'IN'),
//     jblLamination: (_) => const LaminationInStockScreen(),
//     // jblRmdOut: (_) => const JBLRmdOut(screenType: 'OUT'),
//     // jblRmdStockReports: (_) => const RmdStockScreen(),
//     // rmdInReport: (context) => const DynamicReportScreenWrapper(),
//     // rmdOutReport: (context) => const DynamicReportScreenWrapper(),
//     rmdInreportsNardana: (context) => const RmdInReportScreen(),
//     // laminationInReports: (context) => const DynamicReportScreenWrapper(),
//     // laminationOutReports: (context) => const DynamicReportScreenWrapper(),
//     // laminationReports: (context) => const DynamicReportScreenWrapper(),
//     // webbingStockReport: (context) => const WebbingStockScreen(),
//     webbNardanaReport: (context) => const WebbingSliderScreen(),
//     webStockReport: (context) => const WebNardanaStockScreen(),
//     webStockSlider: (context) => const WebbingSliderStockScreen(),
//     lamReportScreen: (context) => const LaminationSliderScreen(),
//     cutGroupStock: (context) => const CuttingStockScreen(),
//     stockLedger: (context) => const StockLedgerScreen(),
//
//     InquiryPannel: (context) => const InquiryReportScreen(),
//     bomReport: (context) => const BomReportScreen(),
//     bomList: (context) => const BomListScreen(),
//     Issue_to_QC: (context) => const IssueToQualityScreen(),
//
//     // loomList: (context) => const LOOMList(),
//     visaLoomList: (context) => const VisaLOOMList(),
//
//     orderPlanning: (context) => const OrderPlanningScreen(),
//     inquiryReport: (contexr) => const InquiryReportScreen(),
//     orderComposition: (context) => const OrderCompositionScreen(),
//     toLoom: (context) => const CombineToLoomScreen(),
//
//     laminationOutStock: (context) => const RollListScreen(),
//     laminationVisaReports: (context) => const LaminationReportScreen(
//       title: '',
//       endpoint: '',
//       initialParams: {},
//     ),
//     lamNaradanaReports: (context) => const LaminationSliderScreen(),
//
//     rmdNardanaReports: (context) => const RmdSliderScreen(),
//     visaCutOutStock: (context) =>
//         const CuttingOutStockSavedList(title: 'OUT STOCK List'),
//     nardanaCutOutList: (context) => const CutOutSavedListNardana(),
//
//     // jblDispatchDetail: (context) {
//     //   final args = ModalRoute.of(context)!.settings.arguments;
//     //
//     //   if (args == null || args is! int) {
//     //     return const Scaffold(
//     //       body: Center(child: Text("Invalid Dispatch Number")),
//     //     );
//     //   }
//     //
//     //   return DispatchDetailScreen(dispatchNo: args);
//     // },
//     // blePrinterScan: (_) => const ShowPrintDocPage(),
//   };
// }

import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../ScannedItem/Cutting/NardanaCutting/NaradanCutOutList.dart';
import '../ScannedItem/Cutting/OutStock/OutSavedList.dart';
import '../screen/Printing/PrintingIn.dart';
import '../screen/Printing/PrintingInReportScreen.dart';
import '../screen/Printing/PrintingOutReport.dart';
import '../screen/Slitting/SlittingInStock.dart';

// Import all your screens here

class AppRoutes {
  AppRoutes._();
  static const String dashboard = '/dashboard';

  static const String login = '/login';
  static const String inStock = '/instock';
  static const String loomIn = '/loom-in';
  static const String loomReports = '/loomReports';
  static const String loomSaveList = '/loomSaveList';
  static const String manualPlanningReports = '/manualPlanningreports';
  static const String rmdIn = '/rmd-in';
  static const String rmdOut = '/rmd-out';
  static const String rollEntry = '/rollEntry';
  static const String rmdRollSavedList = '/rmdRollSavedList';
  static const String rmdtransfer = '/rmdTransfer';
  static const String rmdNardanaStock = '/rmdNardanaStock';
  static const String rmdUpdateLocation = '/rmdUpdateLocation';
  static const String lamination = '/lamination';
  static const String cuttingIn = '/cuttingIn';
  static const String foldingIn = '/foldingIn';
  static const String tapelineIn = '/tapelineIn';
  static const String printingIn = '/printingIn';
  static const String printingInReport = '/printingInReport';

  static const String printingOutReport = '/printingOutReport';
  static const String printingOut = '/printingOut';

  static const String slittingIn = '/slittingIn';
  static const String tapelineOut = '/tapelineOut';
  static const String tapelineRecentEntries = '/tapelineRecentEntries';
  static const String tapeInReport = '/tapeInReport';
  static const String tapeOutReport = '/tapeOutReport';
  static const String tapeStockReport = '/tapeStockReport';
  static const String reccutpcscutting = '/recutpcscutting';
  static const String cuttingnardana = '/cutting';
  static const String nardanaInReport = '/nardanaInReport';
  static const String cuttingIssuenardana = '/cuttingIssuenardana';
  static const String cuttingIssue = '/cuttingIssue';
  static const String reCutIssue = '/reCutIssue';
  static const String webbingIn = '/webbing-in';
  static const String webbingOut = '/webbing-out';
  static const String webEntryScreen = '/webEntryScreen';
  static const String webSaveEntryScreen = '/webSaveEntryScreen';

  static const String rollWiseReport = '/rollWiseReport';
  static const String componentWiseReport = '/componentWiseReport';
  static const String cuttingWiseReport = '/cuttingWiseReport';
  static const String bagEntry = '/bag-entry';
  static const String bagReport = '/bag-report';
  static const String baleEntry = '/bale-entry';
  static const String baleStockReport = '/baleStockReport';

  static const String balingReport = '/balingReport';
  // static const String baleStockReport = '/bale-report';
  static const String baleDispatch = '/bale-dispatch';
  static const String dispatchEntry = '/dispatchEntry';
  static const String dispatchReport = '/dispatchReport';
  static const String jblWebbIn = '/jblWebbingStockIn';
  static const String machine = '/machine';
  static const String jblBailing = '/jbl-Webbing';
  static const String jblScan = '/jbl-scan';
  static const String jblCuttingIn = '/jblCuttingIn';
  static const String loomList = '/loomList';
  static const String jblRmdIn = '/jblRmdIn';
  static const String jblRmdOut = 'jblRmdOut';
  static const String jblRmdStockReports = '/jblRmdStockReports';

  static const String baleStockgroup = '/baleStockGroup';
  static const String jblPackingReport = '/jblProductionReport';
  static const String jblBagStoreIssue = '/jblBagStoreIssue';
  static const String jblLamination = '/JBL_lamination';
  static const String rmdInreportsNardana = '/rmdInreportsNardana';
  static const String webbNardanaReport = '/webbNardanaReport';
  static const String webStockReport = '/webStockReport';
  static const String webStockSlider = '/webStockSlider';
  static const String lamReportScreen = '/lamReportScreen';
  static const String cutGroupStock = '/cutGroupStock';
  static const String stockLedger = '/stockLedger';
  static const String InquiryMarketingReport = '/InquireyPannel';
  static const String bomReport = '/bomReport';
  static const String bomList = '/bomList';
  static const String Issue_to_QC = '/Issue_to_QC';
  static const String visaLoomList = '/visaLoomList';
  static const String orderPlanning = '/orderPlanning';
  static const String inquiryReport = '/inquiryreport';
  static const String orderComposition = '/orderComposition';
  static const String toLoom = '/toLoom';
  static const String manualToLoom = '/manualToLoom';
  static const String laminationOutStock = '/laminationOutStock';
  static const String laminationVisaReports = '/laminationReports';
  static const String lamNaradanaInReport = '/lamNaradanaInReport';

  static const String lamNaradanaOutReport = '/lamNaradanaOutReport';
  static const String rmdNardanaReports = '/rmdNardanaReports';
  static const String rmdNardanaInReports = '/rmdNardanaInReports';
  static const String rmdNardanaOutReports = '/rmdNardanaOutReports';
  static const String visaCutOutStock = '/visaCutOutStock';
  static const String nardanaCutOutList = '/nardanaCutOutList';
  static const String jblDispatchDetail = '/jblDispatchDetail';

  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: loomIn,
      page: () => const LoomSliderScreen(screenType: 'IN'),
    ),

    GetPage(name: loomReports, page: () => const LoomReportScreen()),
    GetPage(
      name: manualPlanningReports,
      page: () => const ManualPlanningReports(),
    ),

    GetPage(name: loomSaveList, page: () => const SavedListScreen()),

    GetPage(
      name: rmdIn,
      page: () => const RmdScreen(screenType: 'IN'),
    ),

    GetPage(
      name: rmdOut,
      page: () => const RmdOutScreen(),
    ),

    GetPage(name: rmdtransfer, page: () => const RmdTransferScreen()),
    GetPage(name: rollEntry, page: () => const RmdRollENtryScreen()),
    GetPage(name: rmdRollSavedList, page: () => const RmdRollSavedList()),

    GetPage(name: rmdNardanaStock, page: () => const RmdStockReportScreen()),
    GetPage(name: rmdUpdateLocation, page: () => const UpdateLocationScreen()),
    GetPage(name: lamination, page: () => const LaminationScreen()),

    GetPage(name: cuttingIn, page: () => const CuttingScreen()),

    // GetPage(name: foldingIn, page: () => const FoldingIn()),
    GetPage(name: printingIn, page: () => PrintingInStockScreen()),
    GetPage(name: printingOutReport, page: () => PrintingOutReportScreen()),

    GetPage(name: printingInReport, page: () => const PrintingInReportScreen(),
    ),
    GetPage(name: printingOut, page: () => PrintingRollList()),
    GetPage(name: slittingIn, page: () => SlittingInScreen()),

    GetPage(name: tapelineIn, page: () => TapeInEnrtyList()),
    GetPage(name: tapelineOut, page: () => const TapelineOutStockScreen()),

    GetPage(
      name: tapelineRecentEntries,
      page: () => const RecentEntriesScreen(),
    ),
    GetPage(name: tapeInReport, page: () => const TapeInReports()),
    GetPage(name: tapeOutReport, page: () => const TapeOutReports()),
    GetPage(name: tapeStockReport, page: () => const TapeStockScreen()),

    GetPage(name: reccutpcscutting, page: () => const ReceiveCutPcsScreen()),

    GetPage(name: cuttingnardana, page: () => const ReceiveCutPcsNardana()),

    GetPage(name: nardanaInReport, page: () => const CuttingInReport()),

    GetPage(
      name: cuttingIssuenardana,
      page: () => const CutPieceIssuedScreenNardana(),
    ),

    GetPage(name: cuttingIssue, page: () => const CutPieceIssuedScreen()),

    GetPage(name: reCutIssue, page: () => const RecutPcsIssueScreen()),

    GetPage(name: webbingIn, page: () => const WebbingInStock()),

    GetPage(name: webbingOut, page: () => const WebOutStock()),
    GetPage(
      name: AppRoutes.webSaveEntryScreen,
      page: () => const WebSaveEntriesScreen(),
    ),
    GetPage(
      name: AppRoutes.webEntryScreen,
      page: () => const WebbingEntryScreen(),
    ),

    GetPage(name: rollWiseReport, page: () => RollWiseReportScreen()),

    GetPage(name: componentWiseReport, page: () => ComponentReportScreen()),
    GetPage(name: cuttingWiseReport, page: () => Cutting_InReportSCreen()),

    GetPage(name: bagEntry, page: () => BagEntryScreen()),

    GetPage(name: bagReport, page: () => BagReportScreen()),

    GetPage(name: baleEntry, page: () => BaleInReportsScreen()),

    GetPage(name: baleStockReport, page: () => StockReportScreen()),
    // StockReportScreen(), BailingReportScreen()
    GetPage(name: balingReport, page: () => BailingReportScreen()),

    GetPage(name: baleDispatch, page: () => DispatchScreen()),
    GetPage(name: dispatchEntry, page: () => BalingDispatchScreen()),

    GetPage(name: dispatchReport, page: () => DispatchScreen()),

    GetPage(name: login, page: () => LoginPage()),
    // GetPage(name: dashboard, page: () => NewAdminDashboard()),

    GetPage(name: AppRoutes.dashboard, page: () => const DeptDashboard()),
    GetPage(name: inStock, page: () => RMDStockIn()),

    GetPage(
      name: jblWebbIn,
      page: () => JblWebbingStockIn(screenType: 'IN'),
    ),

    GetPage(
      name: machine,
      page: () => MchineList(screenType: 'Scan'),
    ),

    GetPage(
      name: jblBailing,
      page: () => JblBailingEntry(screenType: 'IN'),
    ),

    GetPage(name: baleStockgroup, page: () => BaleStockGroupScreen()),

    GetPage(name: jblPackingReport, page: () => PackingBagReportScreen()),

    GetPage(name: jblBagStoreIssue, page: () => StoreEntryListScreen()),

    GetPage(name: jblLamination, page: () => const LaminationInStockScreen()),

    GetPage(name: rmdInreportsNardana, page: () => const RmdInReportScreen()),

    GetPage(name: webbNardanaReport, page: () => const WebbingSliderScreen()),

    GetPage(name: webStockReport, page: () => const WebNardanaStockScreen()),

    GetPage(name: webStockSlider, page: () => const WebbingSliderStockScreen()),

    GetPage(name: lamReportScreen, page: () => const LaminationSliderScreen()),

    GetPage(name: cutGroupStock, page: () => const CuttingStockScreen()),

    GetPage(name: stockLedger, page: () => const StockLedgerScreen()),

    GetPage(
      name: InquiryMarketingReport,
      page: () => const InquiryMarketingReportScreen(),
    ),

    GetPage(name: bomReport, page: () => const BomReportScreen()),

    GetPage(name: bomList, page: () => const BomListScreen()),

    GetPage(name: Issue_to_QC, page: () => const IssueToQualityScreen()),

    GetPage(name: visaLoomList, page: () => const VisaLOOMList()),

    GetPage(name: orderPlanning, page: () => const OrderPlanningScreen()),

    GetPage(name: inquiryReport, page: () => const InquiryReportScreen()),

    GetPage(name: orderComposition, page: () => const OrderCompositionScreen()),

    GetPage(name: toLoom, page: () => const CombineToLoomScreen()),

    GetPage(name: manualToLoom, page: () => ManualToLoomScreen()),

    GetPage(name: laminationOutStock, page: () => const RollListScreen()),

    GetPage(
      name: laminationVisaReports,
      page: () => const LaminationReportScreen(
        title: '',
        endpoint: '',
        initialParams: {},
      ),
    ),
    // LamInReportScreen(),
    // LamOutScreen(),
    GetPage(name: lamNaradanaInReport, page: () => const LamInReportScreen()),
    GetPage(name: lamNaradanaOutReport, page: () => const LamOutScreen()),

    GetPage(name: rmdNardanaReports, page: () => const RmdSliderScreen()),
    // RmdInReportScreen
    GetPage(name: rmdNardanaInReports, page: () => const RmdInReportScreen()),
    // rmdNardanaOutReports
    GetPage(name: rmdNardanaOutReports, page: () => const RmdOutReportScreen()),

    GetPage(
      name: visaCutOutStock,
      page: () => const CuttingOutStockSavedList(title: 'OUT STOCK List'),
    ),

    GetPage(
      name: nardanaCutOutList,
      page: () => const CutOutSavedListNardana(),
    ),

    // GetPage(
    //   name: jblDispatchDetail,
    //   page: () {
    //     final dispatchNo = Get.arguments as int;
    //     return DispatchDetailScreen(dispatchNo: dispatchNo);
    //   },
    // ),

    // GetPage(
    //   name: AppRoutes.jblRmdIn,
    //   page: () => const JBLRmdIn(
    //     screenType: 'IN',
    //   ),
    // ),
    GetPage(
      name: AppRoutes.jblLamination,
      page: () => const LaminationInStockScreen(),
    ),

    // GetPage(
    //   name: AppRoutes.jblRmdOut,
    //   page: () => const JBLRmdOut(
    //     screenType: 'OUT',
    //   ),
    // ),

    // GetPage(
    //   name: AppRoutes.jblRmdStockReports,
    //   page: () => const RmdStockScreen(),
    // ),
  ];
}
