import 'package:arrow_path/arrow_path.dart';
import 'package:flutter/material.dart';

class ArrowPainter extends CustomPainter {
  double startX, startY;
  double endX, endY;
  String color;

  ArrowPainter(this.startX, this.startY, this.endX, this.endY, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Path path;

    Paint paint = Paint()
      ..color = Color(int.parse(color))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.0;

    /// Draw a single arrow.
    path = Path();
    path.moveTo(startX, startY);
    path.quadraticBezierTo(size.width / 2, size.height/2, endX, endY);

    path = ArrowPath.make(path: path);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ArrowPainter oldDelegate) => true;
}