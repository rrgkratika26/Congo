import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────────────────────
class _DT {
  static const Color primary = Color(0xFF1B4FD8);
  static const Color bg = Color(0xFFF8F9FC);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE8EAEF);
  static const Color textHigh = Color(0xFF0F1523);
  static const Color textMid = Color(0xFF5A6478);
  static const Color textLow = Color(0xFF9AA3B2);
}

// ─────────────────────────────────────────────────────────────
//  ACTION CONFIG
// ─────────────────────────────────────────────────────────────
class _ActionConfig {
  final String label;
  final String description;
  final Color color;
  final Color bgColor;

  const _ActionConfig({
    required this.label,
    required this.description,
    required this.color,
    required this.bgColor,
  });
}

const Map<MenuAction, _ActionConfig> _configs = {
  MenuAction.IN: _ActionConfig(
    label: 'IN',
    description: 'Record incoming',
    color: Color(0xFF3B82F6),
    bgColor: Color(0xFFF0FDF4),
  ),
  MenuAction.OUT: _ActionConfig(
    label: 'OUT',
    description: 'Record outgoing',
    color: Color(0xFF3B82F6),
    bgColor: Color(0xFFFEF2F2),
  ),
  MenuAction.stock: _ActionConfig(
    label: 'STOCK',
    description: 'View stock report',
    color: Color(0xFF8B5CF6),
    bgColor: Color(0xFFF5F3FF),
  ),
  MenuAction.entry: _ActionConfig(
    label: 'ENTRY',
    description: 'New entry',
    color: Color(0xFF3B82F6),
    bgColor: Color(0xFFEFF6FF),
  ),
  MenuAction.report: _ActionConfig(
    label: 'REPORT',
    description: 'View reports',
    color: Color(0xFF3B82F6),
    bgColor: Color(0xFFFFFBEB),
  ),
  MenuAction.dispatch: _ActionConfig(
    label: 'DISPATCH',
    description: 'Dispatch items',
    color: Color(0xFF3B82F6),
    bgColor: Color(0xFFFFF7ED),
  ),
  MenuAction.scan: _ActionConfig(
    label: 'SCAN',
    description: 'Scan items',
    color: Color(0xFF3B82F6),
    bgColor: Color(0xFFECFEFF),
  ),
};

// ─────────────────────────────────────────────────────────────
//  ENUM
// ─────────────────────────────────────────────────────────────
enum MenuAction {
  IN,
  LOOM,
  OUT,
  stock,
  entry,
  report,
  Bag_Report,
  Stock_Report,
  dispatch,
  scan,
  Pcs_Issue,
  OverAll_Report,
  Approval,
  Re_cut_Issue,
  StoreIssue,
  FIBC_Store,
  Packing_Department,
  Packing_Report,
  In_Report,
  Out_Report,
  Pcs_Report,
  Rollwise_Report,
  OUT__,
  transfer,
  Inquirey_Report,
Bom_Report,
  Bom_List,
  Webbing_Ledger,
  Issue_to_QC,
  Order_Planning,
  Order_Composition,
  To_Loom
}

// ─────────────────────────────────────────────────────────────
//  SINGLE ACTION TILE
// ─────────────────────────────────────────────────────────────
class ActionButton extends StatefulWidget {
  final MenuAction action;
  final VoidCallback onPressed;

  const ActionButton({Key? key, required this.action, required this.onPressed})
    : super(key: key);

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _configs[widget.action]!;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _DT.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _DT.border),
            boxShadow: [
              BoxShadow(
                color: cfg.color.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cfg.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _DT.textHigh,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cfg.description,
                      style: const TextStyle(fontSize: 11, color: _DT.textLow),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: cfg.color.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  BUILDER
// ─────────────────────────────────────────────────────────────
Widget buildActionButtons(
  BuildContext context,
  List<MenuAction> actions,
  void Function(MenuAction action) onActionTap,
) {
  if (actions.isEmpty) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text('No actions available', style: TextStyle(fontSize: 13)),
      ),
    );
  }

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: actions
        .map(
          (a) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ActionButton(action: a, onPressed: () => onActionTap(a)),
          ),
        )
        .toList(),
  );
}

// ─────────────────────────────────────────────────────────────
//  MENU MAPPING
// ─────────────────────────────────────────────────────────────
List<MenuAction> getActionsForMenu(String label) {
  switch (label) {
    case 'INQUIRY':
      return [MenuAction.Inquirey_Report,];
    case 'PLANNING':
      return [MenuAction.Order_Planning, MenuAction.Order_Composition,MenuAction.To_Loom];
    case 'LOOM':
      return [
        MenuAction.IN,
        MenuAction.In_Report,
      MenuAction.report];
    case 'LAMINATION':
      return [
        MenuAction.IN,
        MenuAction.report,

        MenuAction.OUT
      ];
    case 'CUTTING':
      return [
        MenuAction.IN,
        MenuAction.OUT,
        MenuAction.Approval,
        MenuAction.Pcs_Issue,
        MenuAction.stock,

        MenuAction.In_Report,
        MenuAction.report,
      ];
    case 'RMD':
      return [
        MenuAction.IN,
        MenuAction.OUT,
        MenuAction.report,
        MenuAction.stock,
        // MenuAction.transfer,
      ];
    // case 'FOLDING':
    //   return [
    //     MenuAction.IN,
    //
    //     // MenuAction.OUT,
    //     MenuAction.report,MenuAction.stock
    //   ];
    case 'FOLDING':
      return [MenuAction.IN, MenuAction.report, MenuAction.stock];
    case 'BAG':
      return [MenuAction.entry, MenuAction.report];
    case 'BALING':
      return [
        MenuAction.entry,
        MenuAction.report,
        MenuAction.dispatch,
        MenuAction.stock,
      ];
    case 'WEBBING':
      return [
        MenuAction.IN,
        MenuAction.OUT,
        MenuAction.report,
        MenuAction.stock,
      ];
    case 'LEDGER':
      return [MenuAction.Webbing_Ledger];
    case 'MARKETING':
      return [MenuAction.Inquirey_Report,
        MenuAction.Bom_Report,
      MenuAction.Bom_List,
  MenuAction.Issue_to_QC];

    case 'TAPELINE':
      return [MenuAction.IN,MenuAction.OUT,];
    case 'MACHINE':
      return [MenuAction.scan];

    case 'JBL LOOM':
      return [MenuAction.LOOM, MenuAction.report];

    case 'JBL RMD':
      return [
        MenuAction.IN,
        MenuAction.OUT,
        MenuAction.report,
        MenuAction.Stock_Report,
      ];
    case 'JBL LAMINATION':
      return [MenuAction.IN, MenuAction.report];
    case 'JBL Dispatch':
      return [MenuAction.entry, MenuAction.report];
    case 'JBL Webbing':
      return [
        MenuAction.IN,
        MenuAction.OUT,
        MenuAction.In_Report,
        MenuAction.Out_Report,
        // MenuAction.OUT__,
        MenuAction.Stock_Report,
      ];
    case 'JBL Baling':
      return [
        MenuAction.entry,
        MenuAction.report,
        MenuAction.Stock_Report,
        MenuAction.OverAll_Report,
      ];
    case 'JBL Cutting':
      return [
        MenuAction.IN,
        MenuAction.In_Report,
        MenuAction.Approval,
        MenuAction.Pcs_Issue,
        MenuAction.Re_cut_Issue,
        MenuAction.Pcs_Report,
        MenuAction.Rollwise_Report,
      ];
    case 'JBL BAG':
      return [
        MenuAction.FIBC_Store,

        MenuAction.Bag_Report,
        MenuAction.entry,
        MenuAction.Packing_Department,

        MenuAction.Packing_Report,
      ];

    default:
      return [];
  }
}
