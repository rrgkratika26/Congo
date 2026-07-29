class FabricDropdownModel {
  final String code;
  final String name;

  FabricDropdownModel({
    required this.code,
    required this.name,
  });

  factory FabricDropdownModel.fromJson(
      Map<String,dynamic> json){
    return FabricDropdownModel(
      code: json["code"] ?? "",
      name: json["name"] ?? "",
    );
  }
}

class FabricCategoryModel {
  final String type;
  final List<FabricDropdownModel> data;

  FabricCategoryModel({
    required this.type,
    required this.data,
  });

  factory FabricCategoryModel.fromJson(
      Map<String,dynamic> json){

    return FabricCategoryModel(
      type: json["type"],

      data: (json["data"] as List)
          .map((e)=>FabricDropdownModel.fromJson(e))
          .toList(),
    );
  }
}