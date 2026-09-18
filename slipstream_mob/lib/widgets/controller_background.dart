import 'package:flutter/material.dart';

class ControllerBackground extends StatelessWidget {
  const ControllerBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ControllerBackgroundPainter(),
    );
  }
}

class ControllerBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint diagonalPaint = Paint()
      ..color = const Color(0xFF142234)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (
      double x = -size.height;
      x < size.width;
      x += 100
    ) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(
          x + size.height,
          size.height,
        ),
        diagonalPaint,
      );
    }

    final Paint horizontalPaint = Paint()
      ..color = const Color(0xFF101C2A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (
      double y = 0;
      y < size.height;
      y += 70
    ) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        horizontalPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
