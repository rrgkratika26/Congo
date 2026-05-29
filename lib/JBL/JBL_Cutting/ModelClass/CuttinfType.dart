enum CuttingType { rollwise, inwards, cutpcs }

String getTypeValue(CuttingType type) {
  switch (type) {
    case CuttingType.rollwise:
      return "ROLLWISE";
    case CuttingType.inwards:
      return "IN";
    case CuttingType.cutpcs:
      return "CUTPCS";
  }
}
abstract class BaseModel {
  Map<String, dynamic> toJson();
}