class LoomOrder {
  final int id;
  final String articleNo;
  final String bom;
  final String poNumber;
  final String orderNo;
  final String loomOrderNo;
  final String woNo;
  final String fabricCode;
  final String requiredFabricCode;

  final double requiredQuantityKg;
  final double requiredQuantityMtr;
  final double productionKg;
  final double productionMtr;
  final double balanceKg;
  final double balanceMtr;

  final bool status;
  final String customerName;

  LoomOrder({
    required this.id,
    required this.articleNo,
    required this.bom,
    required this.poNumber,
    required this.orderNo,
    required this.loomOrderNo,
    required this.woNo,
    required this.fabricCode,
    required this.requiredFabricCode,
    required this.requiredQuantityKg,
    required this.requiredQuantityMtr,
    required this.productionKg,
    required this.productionMtr,
    required this.balanceKg,
    required this.balanceMtr,
    required this.status,
    required this.customerName,
  });

  factory LoomOrder.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }


    return LoomOrder(
      id: json['id'] ?? 0,
      articleNo: json['articlE_NUM']?.toString() ?? "",
        poNumber: json['pO_NUM']?.toString() ?? '',
      bom: json['boM_NO']?.toString() ?? '',
      orderNo: json['orderNo']?.toString() ?? '',
      loomOrderNo: json['loomOrderNo']?.toString() ?? '',
      woNo: json['woNo']?.toString() ?? '',
      fabricCode: json['fabricCode']?.toString() ?? '',
      requiredFabricCode: json['requiredFabricCode']?.toString() ?? '',

      requiredQuantityKg: toDouble(json['requiredQuantityKg']),
      requiredQuantityMtr: toDouble(json['requiredQuantityMtr']),
      productionKg: toDouble(json['productionKg']),
      productionMtr: toDouble(json['productionMtr']),
      balanceKg: toDouble(json['balanceKg']),
      balanceMtr: toDouble(json['balanceMtr']),

      status: json['status'] ?? false,
      customerName: json['partyName']?.toString() ?? '',
    );
  }
}

class LoomDropdownData {
  final List<String> partyNames;
  final List<String> workOrders;
  final List<String> orderNos;
  final List<String> requiredFabrics;
  final List<String> operators;
  final List<String> loomTypes;
  final List<String> fabricWidthList;
  final List<String> fabricBaffaleType;
  final List<String> fabrictype;
  final List<String> fabricGSm;
  final List<String> laminationType;
  final List<String> color;
  final List<String> cutType;
  final List<String> specialID;

  LoomDropdownData({
    required this.partyNames,
    required this.workOrders,
    required this.orderNos,
    required this.requiredFabrics,
    required this.operators,
    required this.loomTypes,
    required this.fabricWidthList,
    required this.fabricBaffaleType,
    required this.fabrictype,
    required this.fabricGSm,
    required this.laminationType,
    required this.color,
    required this.cutType,
    required this.specialID,
  });

  factory LoomDropdownData.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic value) {
      if (value == null) return [];
      return List<String>.from(value.map((e) => e.toString()));
    }

    return LoomDropdownData(
      partyNames: parseList(json['partyNames']),
      workOrders: parseList(json['workOrders']),
      orderNos: parseList(json['orderNos']),
      requiredFabrics: parseList(json['requiredFabrics']),
      operators: parseList(json['operators']),
      loomTypes: parseList(json['loomTypes']),
      fabricWidthList: parseList(json['fabricWidthList']),
      fabricBaffaleType: parseList(json['fabricBaffaleType']),
      fabrictype: parseList(json['fabrictype']),
      fabricGSm: parseList(json['fabricGSm']),
      laminationType: parseList(json['laminationType']),
      color: parseList(json['color']),
      cutType: parseList(json['cutType']),
      specialID: parseList(json['specialID']),
    );
  }
}


class LoomOrderResponse {
  final String status;
  final int count;
  final List<LoomOrder> data;

  LoomOrderResponse({
    required this.status,
    required this.count,
    required this.data,
  });

  factory LoomOrderResponse.fromJson(Map<String, dynamic> json) {
    return LoomOrderResponse(
      status: json['status'] ?? '',
      count: json['count'] ?? 0,
      data: (json['data'] as List? ?? [])
          .map((e) => LoomOrder.fromJson(e))
          .toList(),
    );
  }
}