import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../BagDesignScreen.dart';
import 'BagModel.dart' hide FibcBagSpecification;
import 'CircularBagPainter.dart';

class FibcConstructionPainter extends CustomPainter {
  final FibcBagSpecification specification;
  final Color loopColor;

  const FibcConstructionPainter({
    required this.specification,
    required this.loopColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final type = FibcBagType.fromConstructionCode(
      specification.construction.isNotEmpty
          ? specification.construction
          : specification.bagType,
    );

    if (type == FibcBagType.circular) {
      CircularBagPainter(
        diameter: specification.width.toDouble() > 0
            ? specification.width.toDouble()
            : specification.length.toDouble(),
        bagHeight: specification.height.toDouble(),
        loopHeight: specification.loopFreeHeight.toDouble(),
        longLeg: specification.longLegHeight.toDouble(),
        shortLeg: specification.shortLegHeight.toDouble(),
        loopColor: loopColor,
      ).paint(canvas, size);
    } else {
      RectangularStandardBagPainter(
        length: specification.length.toDouble(),
        width: specification.width.toDouble(),
        bagHeight: specification.height.toDouble(),
        loopHeight: specification.loopFreeHeight.toDouble(),
        longLeg: specification.longLegHeight.toDouble(),
        shortLeg: specification.shortLegHeight.toDouble(),
        fillSpoutDia: specification.fillingSpoutDiameter.toDouble(),
        fillSpoutHeight: specification.fillingSpoutHeight.toDouble(),
        dischargeSpoutDia: specification.dischargeSpoutDiameter.toDouble(),
        dischargeSpoutHeight: specification.dischargeSpoutHeight.toDouble(),
        loopColor: loopColor,
        constructionType: type,
      ).paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant FibcConstructionPainter oldDelegate) => true;
}