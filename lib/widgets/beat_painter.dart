import 'package:flutter/material.dart';

// خط نبض القلب
class BeatPainter extends CustomPainter {
  final double t;
  BeatPainter(this.t);
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final path = Path()
      ..moveTo(0, h / 2)
      ..lineTo(w * .3, h / 2)
      ..lineTo(w * .38, h * .1)
      ..lineTo(w * .47, h * .95)
      ..lineTo(w * .55, h * .3)
      ..lineTo(w * .6, h / 2)
      ..lineTo(w, h / 2);
    final m = path.computeMetrics().first;
    canvas.drawPath(
      m.extractPath(0, m.length * t),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(BeatPainter o) => o.t != t;
}
