import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'BagDesignScreen.dart';
import 'ModelFIBCBag/BagModel.dart' hide FibcBagSpecification;

class FibcConstructionPainter extends CustomPainter {
  final FibcBagSpecification specification;
  final Color loopColor;

  const FibcConstructionPainter({
    required this.specification,
    required this.loopColor,
  });

  static const Color bodyColor = Color(0xFFF8F8F8);
  static const Color bodySideColor = Color(0xFFEDEDED);
  static const Color topColor = Color(0xFFFFD9AE);

  static const Color lineColor = Color(0xFF30343B);
  static const Color dimensionColor = Color(0xFF2563EB);
  static const Color extensionColor = Color(0xFFB8BCC6);

  // ------------------------------------------------------------
  // Projection
  // ------------------------------------------------------------

  Offset _project(
      double x,
      double y,
      double z,
      double scale,
      Offset origin,
      ) {
    const angle = 26.0;

    final rad = angle * math.pi / 180;

    return Offset(
      origin.dx + (x - y) * math.cos(rad) * scale,
      origin.dy -
          z * scale +
          (x + y) * math.sin(rad) * scale,
    );
  }

  @override
  @override
  void paint(Canvas canvas, Size size) {
    final double L = specification.length.toDouble() <= 0
        ? 90.0
        : specification.length.toDouble();

    final double W = specification.width.toDouble() <= 0
        ? 90.0
        : specification.width.toDouble();

    final double H = specification.height.toDouble() <= 0
        ? 110.0
        : specification.height.toDouble();

    final double loopH = specification.loopFreeHeight.toDouble() > 0
        ? specification.loopFreeHeight.toDouble()
        : 25.0;

    final double longLeg =
    specification.longLegHeight.toDouble() > 0
        ? specification.longLegHeight.toDouble()
        : loopH;

    final double shortLeg =
    specification.shortLegHeight.toDouble() > 0
        ? specification.shortLegHeight.toDouble()
        : loopH;

    final double fillDia =
    specification.fillingSpoutDiameter.toDouble();

    final double fillHeight =
    specification.fillingSpoutHeight.toDouble();

    final double dischargeDia =
    specification.dischargeSpoutDiameter.toDouble();

    final double dischargeHeight =
    specification.dischargeSpoutHeight.toDouble();

    // ----------------------------------------------------------
    // SCALING
    // ----------------------------------------------------------

    final double availableWidth =
    math.max(size.width - 210.0, 1.0);

    final double availableHeight =
    math.max(size.height - 170.0, 1.0);

    final double verticalRequired =
        H + math.max(loopH, longLeg) + fillHeight;

    final double horizontalRequired =
        L + W;

    final double scale = math.min(
      availableWidth / math.max(horizontalRequired, 1.0),
      availableHeight / math.max(verticalRequired, 1.0),
    ).clamp(0.65, 5.0).toDouble();

    final Offset origin = Offset(
      size.width * .50,
      size.height * .58,
    );

    Offset p(double x, double y, double z) {
      return _project(
        x,
        y,
        z,
        scale,
        origin,
      );
    }

    // ----------------------------------------------------------
    // BODY CORNERS
    // ----------------------------------------------------------

    final Offset frontBottom = p(L, W, 0);
    final Offset leftBottom = p(L, 0, 0);
    final Offset rightBottom = p(0, W, 0);

    final Offset frontTop = p(L, W, H);
    final Offset leftTop = p(L, 0, H);
    final Offset rightTop = p(0, W, H);
    final Offset backTop = p(0, 0, H);

    // ----------------------------------------------------------
    // SHADOW
    // ----------------------------------------------------------

    _drawShadow(
      canvas,
      frontBottom,
      leftBottom,
      rightBottom,
    );

    // ----------------------------------------------------------
    // REAR LOOPS
    // ----------------------------------------------------------

    _drawLoop(
      canvas,
      backTop,
      loopH,
      scale,
      longLeg,
      shortLeg,
      opacity: .30,
      isLeft: true,
    );

    // ----------------------------------------------------------
    // RIGHT BODY PANEL
    // ----------------------------------------------------------

    _panel(
      canvas,
      [
        rightTop,
        frontTop,
        frontBottom,
        rightBottom,
      ],
      bodySideColor,
    );

    // ----------------------------------------------------------
    // LEFT BODY PANEL
    // ----------------------------------------------------------

    _panel(
      canvas,
      [
        leftTop,
        frontTop,
        frontBottom,
        leftBottom,
      ],
      bodyColor,
    );

    // ----------------------------------------------------------
    // TOP FACE
    // ----------------------------------------------------------

    _panel(
      canvas,
      [
        backTop,
        leftTop,
        frontTop,
        rightTop,
      ],
      topColor,
    );

    // ----------------------------------------------------------
    // BODY SEAMS
    // ----------------------------------------------------------

    _seam(
      canvas,
      leftBottom,
      leftTop,
    );

    _seam(
      canvas,
      rightBottom,
      rightTop,
    );

    _seam(
      canvas,
      frontBottom,
      frontTop,
    );

    // ----------------------------------------------------------
    // BAFFLE
    // ----------------------------------------------------------

    if (specification.bagType == FibcBagType.baffled) {
      _drawBaffle(
        canvas,
        p,
        L,
        W,
        H,
        scale,
      );
    }

    // ----------------------------------------------------------
    // TOP FILLING SPOUT
    // ----------------------------------------------------------

    if (fillDia > 0 && fillHeight > 0) {
      _drawSpout(
        canvas,
        p(
          L / 2,
          W / 2,
          H,
        ),
        p(
          L / 2,
          W / 2,
          H + fillHeight,
        ),
        fillDia,
        scale,
        Colors.white,
      );
    }

    // ----------------------------------------------------------
    // BOTTOM DISCHARGE SPOUT
    // ----------------------------------------------------------

    if (dischargeDia > 0 && dischargeHeight > 0) {
      _drawSpout(
        canvas,
        p(
          L / 2,
          W / 2,
          0,
        ),
        p(
          L / 2,
          W / 2,
          -dischargeHeight,
        ),
        dischargeDia,
        scale,
        const Color(0xFFE9EBEF),
      );
    }

    // ----------------------------------------------------------
    // FOUR LIFTING LOOPS
    // ----------------------------------------------------------

    _drawLoop(
      canvas,
      leftTop,
      loopH,
      scale,
      longLeg,
      shortLeg,
      opacity: 1,
      isLeft: true,
    );

    _drawLoop(
      canvas,
      rightTop,
      loopH,
      scale,
      shortLeg,
      longLeg,
      opacity: 1,
      isLeft: false,
    );

    _drawLoop(
      canvas,
      frontTop,
      loopH,
      scale,
      longLeg,
      shortLeg,
      opacity: 1,
      isLeft: true,
    );

    // ----------------------------------------------------------
    // DIMENSIONS
    // ----------------------------------------------------------

    _dimension(
      canvas,
      from: leftBottom,
      to: leftTop,
      label: 'H: ${_fmt(H)} cm',
      side: DimensionSide.left,
      offset: 48,
    );

    _dimension(
      canvas,
      from: frontBottom,
      to: leftBottom,
      label: 'L: ${_fmt(L)} cm',
      side: DimensionSide.bottomRight,
      offset: 42,
    );

    _dimension(
      canvas,
      from: frontBottom,
      to: rightBottom,
      label: 'W: ${_fmt(W)} cm',
      side: DimensionSide.bottomLeft,
      offset: 42,
    );

    // ----------------------------------------------------------
    // LOOP DIMENSION
    // ----------------------------------------------------------

    _verticalDimension(
      canvas,
      base: leftTop,
      height: loopH,
      scale: scale,
      label: 'Loop: ${_fmt(loopH)} cm',
      dx: 38,
    );

    // ----------------------------------------------------------
    // FILL SPOUT DIMENSION
    // ----------------------------------------------------------

    if (fillHeight > 0) {
      _verticalDimension(
        canvas,
        base: p(L / 2, W / 2, H),
        height: fillHeight,
        scale: scale,
        label: 'FS: ${_fmt(fillHeight)} cm',
        dx: -40,
      );
    }

    // ----------------------------------------------------------
    // DISCHARGE SPOUT DIMENSION
    // ----------------------------------------------------------

    if (dischargeHeight > 0) {
      _verticalDimension(
        canvas,
        base: p(L / 2, W / 2, 0),
        height: dischargeHeight,
        scale: scale,
        label: 'DS: ${_fmt(dischargeHeight)} cm',
        dx: 42,
      );
    }
  }
  // ============================================================
  // PANEL
  // ============================================================

  void _panel(
      Canvas canvas,
      List<Offset> points,
      Color color,
      ) {
    final path = Path()
      ..moveTo(
        points.first.dx,
        points.first.dy,
      );

    for (final point in points.skip(1)) {
      path.lineTo(
        point.dx,
        point.dy,
      );
    }

    path.close();

    canvas.drawPath(
      path,
      Paint()..color = color,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  // ============================================================
  // BAFFLE
  // ============================================================

  void _drawBaffle(
      Canvas canvas,
      Offset Function(double, double, double) p,
      double L,
      double W,
      double H,
      double scale,
      ) {
    final paint = Paint()
      ..color = const Color(0xFF9EA3AA).withOpacity(.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, scale * .7);

    // Internal vertical baffle indication.
    final left = p(
      L * .50,
      0,
      H,
    );

    final right = p(
      L * .50,
      W,
      H,
    );

    final leftBottom = p(
      L * .50,
      0,
      0,
    );

    final rightBottom = p(
      L * .50,
      W,
      0,
    );

    _dashedLine(
      canvas,
      left,
      leftBottom,
      paint,
    );

    _dashedLine(
      canvas,
      right,
      rightBottom,
      paint,
    );

    // Horizontal baffle indication.
    final topA = p(
      0,
      W * .50,
      H,
    );

    final topB = p(
      L,
      W * .50,
      H,
    );

    _dashedLine(
      canvas,
      topA,
      topB,
      paint,
    );
  }

  // ============================================================
  // LOOP
  // ============================================================

  void _drawLoop(
      Canvas canvas,
      Offset base,
      double loopHeight,
      double scale,
      double longLeg,
      double shortLeg, {
        required double opacity,
        required bool isLeft,
      }) {
    final heightPx =
        loopHeight * scale;

    final longPx =
        longLeg * scale;

    final shortPx =
        shortLeg * scale;

    final leftLeg =
    isLeft ? longPx : shortPx;

    final rightLeg =
    isLeft ? shortPx : longPx;

    final inset =
    math.max(scale * 2, 2);

    final leftX =
        base.dx - inset;

    final rightX =
        base.dx + inset;

    final peakY =
        base.dy - heightPx;

    final archWidth =
    math.max(scale * 10, 8);

    final path = Path()
      ..moveTo(
        leftX,
        base.dy,
      )
      ..lineTo(
        leftX,
        base.dy + leftLeg,
      )
      ..cubicTo(
        leftX - archWidth * .30,
        base.dy - heightPx * .25,
        leftX - archWidth * .65,
        peakY,
        base.dx,
        peakY,
      )
      ..cubicTo(
        rightX + archWidth * .65,
        peakY,
        rightX + archWidth * .30,
        base.dy - heightPx * .25,
        rightX,
        base.dy + rightLeg,
      )
      ..lineTo(
        rightX,
        base.dy,
      );

    canvas.drawPath(
      path,
      Paint()
        ..color = loopColor.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(scale * 3.2, 3)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withOpacity(
          .35 * opacity,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(scale, 1)
        ..strokeCap = StrokeCap.round,
    );
  }

  // ============================================================
  // SPOUT
  // ============================================================

  void _drawSpout(
      Canvas canvas,
      Offset base,
      Offset tip,
      double diameter,
      double scale,
      Color color,
      ) {
    final double radius =
    math.max(diameter * scale / 2, 3);

    final body = Path()
      ..moveTo(
        base.dx - radius,
        base.dy,
      )
      ..lineTo(
        tip.dx - radius,
        tip.dy,
      )
      ..lineTo(
        tip.dx + radius,
        tip.dy,
      )
      ..lineTo(
        base.dx + radius,
        base.dy,
      )
      ..close();

    canvas.drawPath(
      body,
      Paint()..color = color,
    );

    canvas.drawPath(
      body,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );

    final oval = Rect.fromCenter(
      center: tip,
      width: radius * 2,
      height: radius,
    );

    canvas.drawOval(
      oval,
      Paint()..color = color,
    );

    canvas.drawOval(
      oval,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );

    // Blue tie/cord line
    final tieY =
        base.dy +
            (tip.dy - base.dy) * .55;

    canvas.drawLine(
      Offset(
        tip.dx - radius * .75,
        tieY,
      ),
      Offset(
        tip.dx + radius * .75,
        tieY,
      ),
      Paint()
        ..color = const Color(0xFF1976D2)
        ..strokeWidth = math.max(
          scale * 1.5,
          1.5,
        )
        ..strokeCap = StrokeCap.round,
    );
  }

  // ============================================================
  // SEAM
  // ============================================================

  void _seam(
      Canvas canvas,
      Offset a,
      Offset b,
      ) {
    _dashedLine(
      canvas,
      a,
      b,
      Paint()
        ..color = Colors.black.withOpacity(.15)
        ..strokeWidth = 1,
    );
  }

  void _dashedLine(
      Canvas canvas,
      Offset a,
      Offset b,
      Paint paint,
      ) {
    final vector = b - a;
    final total = vector.distance;

    if (total <= 0) return;

    final direction =
        vector / total;

    double distance = 0;
    bool draw = true;

    const dashLength = 5.0;
    const gapLength = 3.0;

    while (distance < total) {
      final length = draw
          ? dashLength
          : gapLength;

      final end = math.min(
        distance + length,
        total,
      );

      if (draw) {
        canvas.drawLine(
          a + direction * distance,
          a + direction * end,
          paint,
        );
      }

      distance = end;
      draw = !draw;
    }
  }

  // ============================================================
  // DIMENSION
  // ============================================================

  void _dimension(
      Canvas canvas, {
        required Offset from,
        required Offset to,
        required String label,
        required DimensionSide side,
        required double offset,
      }) {
    late Offset dimFrom;
    late Offset dimTo;

    switch (side) {
      case DimensionSide.left:
        dimFrom = Offset(
          math.min(from.dx, to.dx) - offset,
          from.dy,
        );

        dimTo = Offset(
          dimFrom.dx,
          to.dy,
        );
        break;

      case DimensionSide.bottomLeft:
        dimFrom =
            from + Offset(-offset, offset);

        dimTo =
            to + Offset(-offset, offset);
        break;

      case DimensionSide.bottomRight:
        dimFrom =
            from + Offset(offset, offset);

        dimTo =
            to + Offset(offset, offset);
        break;
    }

    final extensionPaint = Paint()
      ..color = extensionColor
      ..strokeWidth = 1;

    _dashedLine(
      canvas,
      from,
      dimFrom,
      extensionPaint,
    );

    _dashedLine(
      canvas,
      to,
      dimTo,
      extensionPaint,
    );

    final dimensionPaint = Paint()
      ..color = dimensionColor
      ..strokeWidth = 1.4;

    canvas.drawLine(
      dimFrom,
      dimTo,
      dimensionPaint,
    );

    final direction =
        dimTo - dimFrom;

    final length = direction.distance;

    final unit = length == 0
        ? const Offset(0, 1)
        : direction / length;

    _arrow(
      canvas,
      dimFrom,
      -unit,
      dimensionPaint,
    );

    _arrow(
      canvas,
      dimTo,
      unit,
      dimensionPaint,
    );

    final middle =
    Offset.lerp(
      dimFrom,
      dimTo,
      .5,
    )!;

    _label(
      canvas,
      middle,
      label,
      right: side == DimensionSide.left,
    );
  }

  // ============================================================
  // VERTICAL DIMENSION
  // ============================================================

  void _verticalDimension(
      Canvas canvas, {
        required Offset base,
        required double height,
        required double scale,
        required String label,
        required double dx,
      }) {
    final top = Offset(
      base.dx,
      base.dy - height * scale,
    );

    final lineX =
        base.dx + dx;

    final extensionPaint = Paint()
      ..color = extensionColor
      ..strokeWidth = 1;

    _dashedLine(
      canvas,
      base,
      Offset(
        lineX,
        base.dy,
      ),
      extensionPaint,
    );

    _dashedLine(
      canvas,
      top,
      Offset(
        lineX,
        top.dy,
      ),
      extensionPaint,
    );

    final dimensionPaint = Paint()
      ..color = dimensionColor
      ..strokeWidth = 1.4;

    canvas.drawLine(
      Offset(
        lineX,
        base.dy,
      ),
      Offset(
        lineX,
        top.dy,
      ),
      dimensionPaint,
    );

    _arrow(
      canvas,
      Offset(
        lineX,
        base.dy,
      ),
      const Offset(0, 1),
      dimensionPaint,
    );

    _arrow(
      canvas,
      Offset(
        lineX,
        top.dy,
      ),
      const Offset(0, -1),
      dimensionPaint,
    );

    _label(
      canvas,
      Offset(
        lineX,
        (base.dy + top.dy) / 2,
      ),
      label,
      right: dx < 0,
    );
  }

  // ============================================================
  // ARROW
  // ============================================================

  void _arrow(
      Canvas canvas,
      Offset tip,
      Offset direction,
      Paint paint,
      ) {
    const size = 6.0;

    final angle =
    math.atan2(
      direction.dy,
      direction.dx,
    );

    final p1 = tip -
        Offset(
          math.cos(angle - .45),
          math.sin(angle - .45),
        ) *
            size;

    final p2 = tip -
        Offset(
          math.cos(angle + .45),
          math.sin(angle + .45),
        ) *
            size;

    final path = Path()
      ..moveTo(
        tip.dx,
        tip.dy,
      )
      ..lineTo(
        p1.dx,
        p1.dy,
      )
      ..lineTo(
        p2.dx,
        p2.dy,
      )
      ..close();

    canvas.drawPath(
      path,
      Paint()..color = paint.color,
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  void _label(
      Canvas canvas,
      Offset center,
      String text, {
        bool right = false,
      }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E3A8A),
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final paddingH = 7.0;
    final paddingV = 4.0;

    final rect = Rect.fromCenter(
      center: Offset(
        center.dx +
            (right
                ? -textPainter.width / 2
                : 0),
        center.dy,
      ),
      width:
      textPainter.width +
          paddingH * 2,
      height:
      textPainter.height +
          paddingV * 2,
    );

    final rrect =
    RRect.fromRectAndRadius(
      rect,
      const Radius.circular(4),
    );

    canvas.drawRRect(
      rrect,
      Paint()..color = Colors.white,
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFFE2E5EC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8,
    );

    textPainter.paint(
      canvas,
      Offset(
        rect.left + paddingH,
        rect.top + paddingV,
      ),
    );
  }

  // ============================================================
  // SHADOW
  // ============================================================

  void _drawShadow(
      Canvas canvas,
      Offset front,
      Offset left,
      Offset right,
      ) {
    final center = Offset(
      (left.dx + right.dx) / 2,
      front.dy + 10,
    );

    final width =
        (right.dx - left.dx).abs() * .8;

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: width,
        height: 16,
      ),
      Paint()
        ..color =
        Colors.black.withOpacity(.12)
        ..maskFilter =
        const MaskFilter.blur(
          BlurStyle.normal,
          9,
        ),
    );
  }

  String _fmt(num value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value
        .toStringAsFixed(1)
        .replaceFirst(
      RegExp(r'\.?0+$'),
      '',
    );
  }

  @override
  bool shouldRepaint(
      covariant FibcConstructionPainter oldDelegate,
      ) {
    return oldDelegate.specification !=
        specification ||
        oldDelegate.loopColor != loopColor;
  }
}

enum DimensionSide {
  left,
  bottomLeft,
  bottomRight,
}
