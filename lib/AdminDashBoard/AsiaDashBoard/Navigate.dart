// ─────────────────────────────────────────────
//  NAVIGATION HELPER
// ─────────────────────────────────────────────
import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../ScannedItem/Cutting/CuttinIN/CuttingScreen.dart';
import '../../routes/app_routes.dart';
import '../ActionButtonWidget.dart';

void navigate(BuildContext ctx, String dept, MenuAction action) {
  final isJBL = dept.toUpperCase().contains('JBL');

  if (isJBL) {
    switch (dept.toUpperCase()) {
      case 'JBL LOOM':
        if (action == MenuAction.IN)
          Get.toNamed(AppRoutes.loomList);
        else if (action == MenuAction.report)
          Get.toNamed(AppRoutes.loomIn);
        break;
      case 'JBL RMD':
        if (action == MenuAction.IN)
          Get.toNamed(AppRoutes.jblRmdIn);
        else if (action == MenuAction.OUT)
          Get.toNamed(AppRoutes.jblRmdOut);
        else if (action == MenuAction.Stock_Report)
          Get.toNamed(AppRoutes.jblRmdStockReports);
        break;
      case 'JBL LAMINATION':
        if (action == MenuAction.IN) Get.toNamed(AppRoutes.jblLamination);
        break;
      case 'JBL CUTTING':
        if (action == MenuAction.IN) Get.toNamed(AppRoutes.jblCuttingIn);
        break;
      case 'JBL BAG':
        if (action == MenuAction.entry) Get.toNamed(AppRoutes.jblBagStoreIssue);
        break;
      case 'JBL BALING':
        if (action == MenuAction.entry) Get.toNamed(AppRoutes.jblBailing);
        break;
      case 'JBL DISPATCH':
        if (action == MenuAction.entry) Get.toNamed(AppRoutes.jblScan);
        break;
      case 'JBL WEBBING':
        if (action == MenuAction.IN) Get.toNamed(AppRoutes.jblWebbIn);
        break;
    }
    return;
  }

  switch (dept.toUpperCase()) {
    case 'MARKETING':
      if (action == MenuAction.Inquirey_Report)
        Get.toNamed(AppRoutes.InquiryMarketingReport);
      if (action == MenuAction.Bom_Report) Get.toNamed(AppRoutes.bomReport);

      if (action == MenuAction.Bom_List_remain) {
        Get.toNamed(AppRoutes.bomList);
      }
      if (action == MenuAction.Issue_to_QC) Get.toNamed(AppRoutes.Issue_to_QC);

      break;
    case 'PLANNING':
      if (action == MenuAction.Order_Planning)
        Get.toNamed(AppRoutes.orderPlanning);
      else if (action == MenuAction.Order_Composition)
        Get.toNamed(AppRoutes.orderComposition);
      else if (action == MenuAction.combine_To_Loom)
        Get.toNamed(AppRoutes.toLoom);
      else if (action == MenuAction.manual_Planning)
        Get.toNamed(AppRoutes.manualToLoom);
      break;
    case 'LOOM':
      if (action == MenuAction.IN)
        Get.toNamed(AppRoutes.loomIn);
      else if (action == MenuAction.saved_List)
        Get.toNamed(AppRoutes.loomSaveList);
      else if (action == MenuAction.Out_Report)
        Get.toNamed(AppRoutes.loomReports);
      else if (action == MenuAction.loom_forward_Report)
        Get.toNamed(AppRoutes.manualPlanningReports);
      break;
    case 'RMD':
      if (action == MenuAction.IN)
        Get.toNamed(AppRoutes.rmdIn);
      else if (action == MenuAction.OUT)
        Get.toNamed(AppRoutes.rmdOut);
      else if (action == MenuAction.Roll_Entry)
        Get.toNamed(AppRoutes.rollEntry);
      else if (action == MenuAction.saved_List)
        Get.toNamed(AppRoutes.rmdRollSavedList);
      else if (action == MenuAction.In_Report)
        Get.toNamed(AppRoutes.rmdNardanaInReports);
      else if (action == MenuAction.Out_Report)
        Get.toNamed(AppRoutes.rmdNardanaOutReports);
      else if (action == MenuAction.stock)
        Get.toNamed(AppRoutes.rmdNardanaStock);
      else if (action == MenuAction.update_Location)
        Get.toNamed(AppRoutes.rmdUpdateLocation);
      // else if (action == MenuAction.transfer)
      //   Get.toNamed(AppRoutes.rmdtransfer);
      break;
    case 'LAMINATION':
      if (action == MenuAction.IN)
        Get.toNamed(AppRoutes.lamination);
      else if (action == MenuAction.OUT)
        Get.toNamed(AppRoutes.laminationOutStock);
      else if (action == MenuAction.In_Report)
        Get.toNamed(AppRoutes.lamNaradanaInReport);
      else if (action == MenuAction.Out_Report)
        Get.toNamed(AppRoutes.lamNaradanaOutReport);
      break;
    case 'CUTTING':
      if (action == MenuAction.IN)
        Get.to(() => CuttingScreen());
      else if (action == MenuAction.In_Report)
        Get.toNamed(AppRoutes.nardanaInReport);
      else if (action == MenuAction.OUT)
        Get.toNamed(AppRoutes.nardanaCutOutList);
      else if (action == MenuAction.rollWise)
        Get.toNamed(AppRoutes.rollWiseReport);
      else if (action == MenuAction.component_Wise)
        Get.toNamed(AppRoutes.componentWiseReport);
      else if (action == MenuAction.cutting_Wise)
        Get.toNamed(AppRoutes.cuttingWiseReport);
      else if (action == MenuAction.stock)
        Get.toNamed(AppRoutes.cutGroupStock);
      else if (action == MenuAction.Approval)
        Get.toNamed(AppRoutes.cuttingnardana);
      else if (action == MenuAction.Pcs_Issue)
        Get.toNamed(AppRoutes.cuttingIssuenardana);
      break;
    case 'PRINTING':
      if (action == MenuAction.IN)
        Get.toNamed(AppRoutes.printingIn);
      else if (action == MenuAction.OUT)
        Get.toNamed(AppRoutes.printingOut);
      else if (action == MenuAction.In_Report)
        Get.toNamed(AppRoutes.printingInReport);
      else if (action == MenuAction.Out_Report)
        Get.toNamed(AppRoutes.printingOutReport);
      break;
  // case 'SLITTING':
  //   if (action == MenuAction.IN) Get.toNamed(AppRoutes.slittingIn);
  // else if (action == MenuAction.OUT)
  //   Get.toNamed(AppRoutes.printingOut);
  // else if (action == MenuAction.In_Report)
  //   Get.toNamed(AppRoutes.lamNaradanaInReport);
  // else if (action == MenuAction.Out_Report)
  //   Get.toNamed(AppRoutes.lamNaradanaOutReport);
  // break;

    case 'BAG':
      if (action == MenuAction.entry)
        Get.toNamed(AppRoutes.bagEntry);
      else if (action == MenuAction.report)
        Get.toNamed(AppRoutes.bagReport);
      break;
    case 'BALING':
      if (action == MenuAction.entry)
        Get.toNamed(AppRoutes.baleEntry);
      else if (action == MenuAction.bail_Stock)
        Get.toNamed(AppRoutes.baleStockReport);
      else if (action == MenuAction.bailing_Report)
        Get.toNamed(AppRoutes.balingReport);
      else if (action == MenuAction.dispatch)
        Get.toNamed(AppRoutes.baleDispatch);
      else if (action == MenuAction.stock)
        Get.toNamed(AppRoutes.baleStockgroup);
      break;
    case 'WEBBING':
      if (action == MenuAction.entry)
        Get.toNamed(AppRoutes.webEntryScreen);
      else if (action == MenuAction.saved_List)
        Get.toNamed(AppRoutes.webSaveEntryScreen);
      else if (action == MenuAction.IN)
        Get.toNamed(AppRoutes.webbingIn);
      else if (action == MenuAction.OUT)
        Get.toNamed(AppRoutes.webbingOut);
      else if (action == MenuAction.report)
        Get.toNamed(AppRoutes.webbNardanaReport);
      // else if (action == MenuAction.stock)
      //   Get.toNamed(AppRoutes.webStockSlider);
      break;
    case 'LEDGER':
      if (action == MenuAction.Webbing_Ledger)
        Get.toNamed(AppRoutes.stockLedger);
      break;
    case 'TAPELINE':
      if (action == MenuAction.IN)
        Get.toNamed(AppRoutes.tapelineIn);
      else if (action == MenuAction.recent_entries)
        Get.toNamed(AppRoutes.tapelineRecentEntries);
      else if (action == MenuAction.OUT)
        Get.toNamed(AppRoutes.tapelineOut);
      else if (action == MenuAction.In_Report)
        Get.toNamed(AppRoutes.tapeInReport);
      else if (action == MenuAction.Out_Report)
        Get.toNamed(AppRoutes.tapeOutReport);
      else if (action == MenuAction.Stock_Report)
        Get.toNamed(AppRoutes.tapeStockReport);

      break;
  // case 'MARKETING':
  //   if (action == MenuAction.Inquirey_Report)
  //     Get.toNamed(AppRoutes.InquiryMarketingReport);
  //   else if (action == MenuAction.Issue_to_QC)
  //     Get.toNamed(AppRoutes.Issue_to_QC);
  //   else if (action == MenuAction.Bom_Report)
  //     Get.toNamed(AppRoutes.bomReport);
  //   if (action == MenuAction.Bom_List_remain) Get.toNamed(AppRoutes.bomList);
  //
  //   break;
  }
}