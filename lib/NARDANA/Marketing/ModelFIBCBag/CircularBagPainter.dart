import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

class CircularBagPainter extends CustomPainter {
  final double diameter;
  final double bagHeight;
  final double loopHeight;
  final double longLeg;
  final double shortLeg;
  final Color loopColor;

  CircularBagPainter({
    required this.diameter,
    required this.bagHeight,
    required this.loopHeight,
    required this.longLeg,
    required this.shortLeg,
    required this.loopColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double D = diameter <= 0 ? 90 : diameter;
    final double H = bagHeight <= 0 ? 120 : bagHeight;
    final double LH = loopHeight <= 0 ? 25 : loopHeight;
    final double LL = longLeg > 0 ? longLeg : LH;
    final double SL = shortLeg > 0 ? shortLeg : LH * .4;

    final scale = math.min(
      (size.width - 220) / D,
      (size.height - 160) / (H + LL),
    ).clamp(0.6, 5.0);

    final w = D * scale;
    final h = H * scale;
    final ellipseH = w * .28;

    final center = Offset(size.width / 2, size.height / 2 + h * .15);
    final topCenter = Offset(center.dx, center.dy - h / 2);
    final bottomCenter = Offset(center.dx, center.dy + h / 2);

    // body (cylinder side)
    final bodyRect = Rect.fromLTRB(
      topCenter.dx - w / 2, topCenter.dy,
      topCenter.dx + w / 2, bottomCenter.dy,
    );
    final bodyPath = Path()
      ..moveTo(bodyRect.left, bodyRect.top)
      ..lineTo(bodyRect.left, bodyRect.bottom)
      ..arcToPoint(Offset(bodyRect.right, bodyRect.bottom),
          radius: Radius.elliptical(w / 2, ellipseH / 2))
      ..lineTo(bodyRect.right, bodyRect.top)
      ..arcToPoint(Offset(bodyRect.left, bodyRect.top),
          radius: Radius.elliptical(w / 2, ellipseH / 2), clockwise: false);

    canvas.drawPath(
      bodyPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFF3F4F6), Color(0xFFD5D9E0), Color(0xFFF3F4F6)],
        ).createShader(bodyRect),
    );
    canvas.drawPath(bodyPath,
        Paint()..color = const Color(0xFF30343B).withOpacity(.5)
          ..style = PaintingStyle.stroke..strokeWidth = 1.4);

    // top ellipse (peach) — fill opening
    final topOval = Rect.fromCenter(center: topCenter, width: w, height: ellipseH);
    canvas.drawOval(topOval, Paint()..color = const Color(0xFFFFE6C7));
    canvas.drawOval(topOval,
        Paint()..color = const Color(0xFFF8D39B)..style = PaintingStyle.stroke..strokeWidth = 1.4);

    // 4 loops around the rim
    final loopOffsets = [-w * .32, -w * .08, w * .08, w * .32];
    for (int i = 0; i < loopOffsets.length; i++) {
      final base = Offset(topCenter.dx + loopOffsets[i], topCenter.dy - ellipseH * .12);
      final isLongSide = i.isOdd;
      _drawLoop(canvas, base, LH * scale, isLongSide ? LL * scale : SL * scale);
    }

    _drawDimensions(canvas, topCenter, bottomCenter, w, h, LH * scale, LL * scale, SL * scale, D, H, LH, LL, SL);
  }

  void _drawLoop(Canvas canvas, Offset base, double loopHpx, double legPx) {
    final peak = base - Offset(0, loopHpx);
    final path = Path()
      ..moveTo(base.dx - 6, base.dy)
      ..lineTo(base.dx - 6, base.dy + legPx)
      ..quadraticBezierTo(base.dx - 6, peak.dy, base.dx, peak.dy)
      ..quadraticBezierTo(base.dx + 6, peak.dy, base.dx + 6, base.dy + legPx)
      ..lineTo(base.dx + 6, base.dy);
    canvas.drawPath(path,
        Paint()..color = loopColor..style = PaintingStyle.stroke
          ..strokeWidth = 4..strokeCap = StrokeCap.round);
  }

  void _drawDimensions(Canvas canvas, Offset topCenter, Offset bottomCenter,
      double w, double h, double lh, double ll, double sl,
      double D, double H, double LH, double LL, double SL) {
    // H (left side)
    _dimLine(canvas, Offset(topCenter.dx - w / 2 - 40, topCenter.dy),
        Offset(topCenter.dx - w / 2 - 40, bottomCenter.dy), 'H  ${_fmt(H)} cm');
    // Diameter (bottom)
    _dimLine(canvas, Offset(bottomCenter.dx - w / 2, bottomCenter.dy + 40),
        Offset(bottomCenter.dx + w / 2, bottomCenter.dy + 40), 'ø ${_fmt(D)} cm');
  }

  void _dimLine(Canvas canvas, Offset a, Offset b, String label) {
    final paint = Paint()..color = const Color(0xFF2563EB)..strokeWidth = 1.4;
    canvas.drawLine(a, b, paint);
    final tp = TextPainter(
      text: TextSpan(text: label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF1E3A8A))),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset.lerp(a, b, .5)! - Offset(tp.width / 2, tp.height / 2));
  }

  String _fmt(num v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  bool shouldRepaint(covariant CircularBagPainter oldDelegate) => true;
}