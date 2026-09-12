// import 'package:flutter/cupertino.dart';
//
// import '../BagDesignScreen.dart';
// import 'BagModel.dart' hide FibcBagSpecification;
//
// CustomPainter createBagPainter(FibcBagSpecification spec) {
//   switch (FibcBagType.fromConstructionCode(spec.construction)) {
//
//     case FibcBagType.uPanelBaffle:
//       return UPanelBaffle3DPainter(
//         specification: spec,
//         loopColor: parseLoopColor(spec.loopColor),
//       );
//
//     case FibcBagType.uPanel:
//       return UPanel3DPainter(
//         specification: spec,
//         loopColor: parseLoopColor(spec.loopColor),
//       );
//
//     case FibcBagType.fourPanel:
//       return FourPanel3DPainter(
//         specification: spec,
//         loopColor: parseLoopColor(spec.loopColor),
//       );
//
//     default:
//       return RectangularStandardBagPainter(
//         length: spec.length.toDouble(),
//         width: spec.width.toDouble(),
//         bagHeight: spec.height.toDouble(),
//         loopHeight: spec.loopFreeHeight.toDouble(),
//         longLeg: spec.longLegHeight.toDouble(),
//         shortLeg: spec.shortLegHeight.toDouble(),
//         fillSpoutDia: spec.fillingSpoutDiameter.toDouble(),
//         fillSpoutHeight: spec.fillingSpoutHeight.toDouble(),
//         dischargeSpoutDia: spec.dischargeSpoutDiameter.toDouble(),
//         dischargeSpoutHeight: spec.dischargeSpoutHeight.toDouble(),
//         loopColor: parseLoopColor(spec.loopColor),
//       );
//   }
// }