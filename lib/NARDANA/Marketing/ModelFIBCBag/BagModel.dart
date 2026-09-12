enum FibcBagType {
  fourPanel,
  uPanel,
  uPanelBaffle,
  circular,
  baffled,
  crossCorner,
  dPanel,
  tunnelLift,
  unknown;

  static FibcBagType fromConstructionCode(String code) {
    final c = code.trim().toUpperCase();

    if (c.isEmpty) {
      return FibcBagType.unknown;
    }

    // U+2 = U Panel with 2 baffles
    if (RegExp(r'^U\+2$').hasMatch(c)) {
      return FibcBagType.uPanelBaffle;
    }

    if (c.startsWith('U')) {
      return FibcBagType.uPanel;
    }

    if (c.startsWith('D')) {
      return FibcBagType.dPanel;
    }

    if (c.contains('CIRC')) {
      return FibcBagType.circular;
    }

    if (c.contains('CROSS')) {
      return FibcBagType.crossCorner;
    }

    if (c.contains('TUNNEL')) {
      return FibcBagType.tunnelLift;
    }

    if (c.contains('BAFFLE')) {
      return FibcBagType.baffled;
    }

    if (c.startsWith('4') || c.contains('FOUR')) {
      return FibcBagType.fourPanel;
    }

    return FibcBagType.unknown;
  }

  String get label {
    switch (this) {
      case FibcBagType.fourPanel:
        return '4-Panel';

      case FibcBagType.uPanel:
        return 'U-Panel';

      case FibcBagType.uPanelBaffle:
        return 'U-Panel + 2 Baffle';

      case FibcBagType.circular:
        return 'Circular';

      case FibcBagType.baffled:
        return 'Baffled';

      case FibcBagType.crossCorner:
        return 'Cross-Corner';

      case FibcBagType.dPanel:
        return 'D-Panel';

      case FibcBagType.tunnelLift:
        return 'Tunnel-Lift';

      case FibcBagType.unknown:
        return 'Standard';
    }
  }
}


class BagComponent {
  final String name;
  final String gsm;
  final String material;

  const BagComponent({
    required this.name,
    required this.gsm,
    required this.material,
  });

  factory BagComponent.fromJson(Map<String, dynamic> json) {
    String s(dynamic v) => v?.toString().trim() ?? '';

    return BagComponent(
      name: s(json['roW_LIST'] ?? json['ROW_LIST'] ?? json['row_list']),
      gsm: s(json['gsm'] ?? json['GSM']),
      material: s(json['material'] ?? json['MATERIAL']),
    );
  }

  bool get isApplicable => gsm.trim() != '0' && gsm.trim().isNotEmpty;

  bool get isCoated {
    final m = material.toLowerCase();
    return m.contains('coat') && !m.contains('uncoat');
  }
}


class FibcBagSpecification {
  final num length;
  final num width;
  final num height;

  final num loopHeight;
  final num longLegHeight;
  final num shortLegHeight;

  final num fillingSpoutDiameter;
  final num fillingSpoutHeight;

  final num dischargeSpoutDiameter;
  final num dischargeSpoutHeight;

  final String constructionCode;

  final FibcBagType bagType;

  final String businessBagType;

  final num? safeWorkingLoad;
  final num total;
  final String safetyFactor;
  final String loopColor;
  bool get hasBaffle {
    final c = constructionCode.trim().toUpperCase();

    return c.contains('+') ||
        c.contains('BAFFLE') ||
        components.any(
              (component) =>
          component.name.toUpperCase().contains('BAFFLE') &&
              component.isApplicable,
        );
  }
  final List<BagComponent> components;
  const FibcBagSpecification({
    required this.length,
    required this.width,
    required this.height,
    this.loopHeight = 0,
    this.longLegHeight = 0,
    this.shortLegHeight = 0,
    this.fillingSpoutDiameter = 0,
    this.fillingSpoutHeight = 0,
    this.dischargeSpoutDiameter = 0,
    this.dischargeSpoutHeight = 0,
    this.constructionCode = '',
    this.bagType = FibcBagType.unknown,
    this.businessBagType = '',
    this.safeWorkingLoad,
    this.total = 0,
    this.safetyFactor = '',
    this.loopColor = '',
    this.components = const [],
  });

  factory FibcBagSpecification.fromJson(Map<String, dynamic> json) {

    final Map<String, dynamic> details =
    (json['bagDetails'] is Map)
        ? Map<String, dynamic>.from(json['bagDetails'] as Map)
        : json;

    final rawComponents = json['components'] is List
        ? json['components'] as List
        : const [];

    num n(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v;
      return num.tryParse(v.toString()) ?? 0;
    }

    String s(dynamic v) => v?.toString().trim() ?? '';

    dynamic pick(Map<String, dynamic> m, List<String> keys) {
      for (final k in keys) {
        if (m.containsKey(k) && m[k] != null) return m[k];
      }
      return null;
    }

    final construction = s(pick(details, ['typee', 'TYPEE', 'Typee']));

    return FibcBagSpecification(
      length: n(pick(details, ['sizE_L', 'SIZE_L'])),
      width: n(pick(details, ['sizE_W', 'SIZE_W'])),
      height: n(pick(details, ['sizE_H', 'SIZE_H'])),
      loopHeight: n(pick(details, ['looP_FREE_HEIGHT', 'LOOP_FREE_HEIGHT'])),
      longLegHeight: n(pick(details, ['looP_LL', 'LOOP_LL'])),
      shortLegHeight: n(pick(details, ['looP_SL', 'LOOP_SL'])),
      fillingSpoutDiameter: n(pick(details, ['f_S_SIZE_D', 'F_S_SIZE_D'])),
      fillingSpoutHeight: n(pick(details, ['f_S_SIZE_H', 'F_S_SIZE_H'])),
      dischargeSpoutDiameter: n(pick(details, ['d_S_SIZE_D', 'D_S_SIZE_D'])),
      dischargeSpoutHeight: n(pick(details, ['d_S_SIZE_H', 'D_S_SIZE_H'])),
      constructionCode: construction,
      bagType: FibcBagType.fromConstructionCode(construction),
      businessBagType: s(pick(details, ['baG_TYPE', 'BAG_TYPE'])),

      safeWorkingLoad: n(pick(details, ['swl', 'SWL'])),
      total: n(pick(details, ['total', 'TOTAL'])),
      safetyFactor: s(pick(details, ['sf', 'SF'])),
      loopColor: s(pick(details, ['looP_COLOR', 'LOOP_COLOR'])),

      components: rawComponents
          .whereType<Map>()
          .map((e) => BagComponent.fromJson(Map<String, dynamic>.from(e)))
          .where((c) => c.name.isNotEmpty)
          .toList(),
    );
  }
}