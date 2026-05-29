class PartyNameModel {
  final String articleNum;
  final String poNum;
  final String partyName;

  PartyNameModel({
    required this.articleNum,
    required this.poNum,
    required this.partyName,
  });

  factory PartyNameModel.fromJson(Map<String, dynamic> json) {
    return PartyNameModel(
      articleNum: json["articlE_NO"]?.toString() ?? "",
      poNum: json["extrA13"]?.toString() ?? "",
      partyName: json["customeR_NAME"]?.toString() ?? "",
    );
  }
}