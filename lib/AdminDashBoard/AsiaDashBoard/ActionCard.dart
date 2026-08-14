import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ActionButtonWidget.dart';

class ActionCard extends StatelessWidget {
  final MenuAction action;
  final bool isMobile;
  final VoidCallback onTap;
  const ActionCard({
    required this.action,
    required this.isMobile,
    required this.onTap,
  });

  IconData get _icon {
    switch (action) {
      case MenuAction.IN:
        return Icons.login_rounded;
      case MenuAction.OUT:
        return Icons.logout_rounded;
      case MenuAction.report:
        return Icons.find_in_page_sharp;
      case MenuAction.bailing_Report:
        return Icons.find_in_page_sharp;
      case MenuAction.In_Report:
      case MenuAction.Stock_Report:
      case MenuAction.loom_forward_Report:
      case MenuAction.Out_Report:
        return Icons.bar_chart_rounded;
      case MenuAction.stock:
        return Icons.inventory_2_rounded;
      case MenuAction.bail_Stock:
        return Icons.inventory_2_rounded;
      case MenuAction.entry:
        return Icons.edit_note_rounded;
      case MenuAction.dispatch:
        return Icons.local_shipping_rounded;
      case MenuAction.scan:
        return Icons.qr_code_scanner_rounded;
      case MenuAction.Approval:
        return Icons.check_circle_outline_rounded;
      case MenuAction.Pcs_Issue:
        return Icons.assignment_rounded;
      case MenuAction.Inquirey_Report:
        return Icons.question_answer_rounded;
      case MenuAction.Order_Planning:
        return Icons.next_plan_rounded;
      case MenuAction.Order_Composition:
        return Icons.reorder_rounded;
      case MenuAction.combine_To_Loom:
        return Icons.arrow_forward_rounded;
      case MenuAction.manual_Planning:
        return Icons.queue_play_next;
      case MenuAction.Webbing_Ledger:
        return Icons.menu_book_rounded;
      case MenuAction.saved_List:
        return Icons.save_alt_rounded;
      default:
        return Icons.arrow_forward_ios_rounded;
    }
  }

  Color get _color {
    switch (action) {
      case MenuAction.IN:
        return const Color(0xFF3D8EF7);
      case MenuAction.OUT:
        return const Color(0xFFEF6C6C);
      case MenuAction.report:
      case MenuAction.In_Report:
      case MenuAction.Stock_Report:
        return const Color(0xFF5BB8A0);
      case MenuAction.stock:
        return const Color(0xFFB47FD8);
      case MenuAction.dispatch:
        return const Color(0xFFFF9A3C);
      case MenuAction.Approval:
        return const Color(0xFF4CAF9A);
      default:
        return const Color(0xFF6B7FD4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _color.withOpacity(.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isMobile ? 52 : 62,
              height: isMobile ? 52 : 62,
              decoration: BoxDecoration(
                color: _color.withOpacity(.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(_icon, color: _color, size: isMobile ? 26 : 30),
            ),
            SizedBox(height: isMobile ? 10 : 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                action.name.replaceAll('_', ' ').toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: isMobile ? 11 : 13,
                  color: const Color(0xFF1A1A2E),
                  letterSpacing: .3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}