class BailingEntry {
  final String partyName;
  final String bomNo;
  final String articleNo;
  final int totalPacket;
  final double totalPcs;
  final double totalWt;

  BailingEntry({
    required this.partyName,
    required this.bomNo,
    required this.articleNo,
    required this.totalPacket,
    required this.totalPcs,
    required this.totalWt,
  });

  factory BailingEntry.fromJson(Map<String, dynamic> json) {
    return BailingEntry(
      partyName: json['partY_NAME']?.toString() ?? '',
      bomNo: json['boM_NO']?.toString() ?? '',
      articleNo: json['articlE_NO']?.toString() ?? '',

      totalPacket: _parseInt(json['totaL_PACKET']),
      totalPcs: _parseDouble(json['totaL_PCS']),
      totalWt: _parseDouble(json['totaL_WT']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
class BailingDetail {
  final String partyName;
  final String bomNo;
  final String bag_size;
  final String articleNo;
  final String packingNo;
  final int pcsPerPacking;
  final double packingNetWt;

  BailingDetail({
    required this.partyName,
    required this.bomNo,
     required this.bag_size,
    required this.articleNo,
    required this.packingNo,
    required this.pcsPerPacking,
    required this.packingNetWt,
  });

  factory BailingDetail.fromJson(Map<String, dynamic> json) {
    return BailingDetail(
      partyName: json['partY_NAME'] ?? '',
      bomNo: json['boM_NO'] ?? '',
      bag_size: json['baG_SIZE'] ?? '',
      articleNo: json['articlE_NO'] ?? '',
      packingNo: json['packinG_NO'] ?? '',
      pcsPerPacking: json['nO_OF_PCS_PER_PACKING'] ?? 0,
      packingNetWt:
      (json['packinG_NET_WT'] ?? 0).toDouble(),
    );
  }
}