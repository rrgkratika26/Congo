import 'dart:convert';

import 'package:http/http.dart' as http;

class BagComponent {
  final String rowList;
  final String gsm;
  final String material;

  const BagComponent({
    required this.rowList,
    required this.gsm,
    required this.material,
  });

  factory BagComponent.fromJson(Map<String, dynamic> json) {
    return BagComponent(
      rowList: json['roW_LIST']?.toString() ?? '',
      gsm: json['gsm']?.toString() ?? '',
      material: json['material']?.toString() ?? '',
    );
  }
}


class DashboardBagSpecification {
  final double length;
  final double width;
  final double height;

  final double loopFreeHeight;
  final double longLegHeight;
  final double shortLegHeight;

  final double fillingSpoutDiameter;
  final double fillingSpoutHeight;

  final double dischargeSpoutDiameter;
  final double dischargeSpoutHeight;

  final String loopColor;
  final String construction;
  final String bagType;

  final double safeWorkingLoad;
  final double total;
  final String safetyFactor;

  final List<BagComponent> components;

  const DashboardBagSpecification({
    required this.length,
    required this.width,
    required this.height,
    required this.loopFreeHeight,
    required this.longLegHeight,
    required this.shortLegHeight,
    required this.fillingSpoutDiameter,
    required this.fillingSpoutHeight,
    required this.dischargeSpoutDiameter,
    required this.dischargeSpoutHeight,
    required this.loopColor,
    required this.construction,
    required this.bagType,
    required this.safeWorkingLoad,
    required this.total,
    required this.safetyFactor,
    required this.components,
  });

  factory DashboardBagSpecification.fromJson(
      Map<String, dynamic> bagDetails,
      List<dynamic> componentJson,
      ) {
    return DashboardBagSpecification(
      length: _toDouble(bagDetails['sizE_L']),
      width: _toDouble(bagDetails['sizE_W']),
      height: _toDouble(bagDetails['sizE_H']),

      loopFreeHeight: _toDouble(
        bagDetails['looP_FREE_HEIGHT'],
      ),

      longLegHeight: _toDouble(
        bagDetails['looP_LL'],
      ),

      shortLegHeight: _toDouble(
        bagDetails['looP_SL'],
      ),

      fillingSpoutDiameter: _toDouble(
        bagDetails['f_S_SIZE_D'],
      ),

      fillingSpoutHeight: _toDouble(
        bagDetails['f_S_SIZE_H'],
      ),

      dischargeSpoutDiameter: _toDouble(
        bagDetails['d_S_SIZE_D'],
      ),

      dischargeSpoutHeight: _toDouble(
        bagDetails['d_S_SIZE_H'],
      ),

      loopColor: bagDetails['looP_COLOR']?.toString() ?? '',

      construction: bagDetails['typee']?.toString() ?? '',

      bagType: bagDetails['baG_TYPE']?.toString() ?? '',

      safeWorkingLoad: _toDouble(
        bagDetails['swl'],
      ),

      total: _toDouble(
        bagDetails['total'],
      ),

      safetyFactor: bagDetails['sf']?.toString() ?? '',

      components: componentJson
          .whereType<Map>()
          .map(
            (e) => BagComponent.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString().trim(),
    ) ??
        0;
  }
}
