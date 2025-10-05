import 'dart:math';
import 'package:flutter/material.dart';

class HexagonPainter extends CustomPainter {
  final int sides;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final Color shadowColor;
  final double shadowBlur;

  HexagonPainter({
    required this.sides,
    required this.borderRadius,
    required this.borderWidth,
    required this.borderColor,
    required this.shadowColor,
    required this.shadowBlur,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createRoundedPolygonPath(size, sides, borderRadius);

    canvas.drawShadow(path, shadowColor, shadowBlur, true);

    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  Path _createRoundedPolygonPath(Size size, int sides, double radius) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final angleStep = 2 * pi / sides;

    final points = List.generate(sides, (i) {
      final angle = angleStep * i - pi / 2;
      return Offset(center.dx + r * cos(angle), center.dy + r * sin(angle));
    });

    final path = Path();
    for (int i = 0; i < sides; i++) {
      final current = points[i];
      final next = points[(i + 1) % sides];
      final prev = points[(i - 1 + sides) % sides];
      final v1 = (current - prev).normalize();
      final v2 = (current - next).normalize();
      final p1 = current - v1 * radius;
      final p2 = current - v2 * radius;

      if (i == 0) {
        path.moveTo(p1.dx, p1.dy);
      } else {
        path.lineTo(p1.dx, p1.dy);
      }

      path.quadraticBezierTo(current.dx, current.dy, p2.dx, p2.dy);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HexagonClipper extends CustomClipper<Path> {
  final int sides;
  final double borderRadius;
  final double padding;

  HexagonClipper({
    required this.sides,
    required this.borderRadius,
    required this.padding,
  });

  @override
  Path getClip(Size size) {
    final innerSize = Size(size.width - 2 * padding, size.height - 2 * padding);
    final center = Offset(size.width / 2, size.height / 2);
    final r = innerSize.width / 2;
    final angleStep = 2 * pi / sides;

    final points = List.generate(sides, (i) {
      final angle = angleStep * i - pi / 2;
      return Offset(center.dx + r * cos(angle), center.dy + r * sin(angle));
    });

    final path = Path();
    for (int i = 0; i < sides; i++) {
      final current = points[i];
      final next = points[(i + 1) % sides];
      final prev = points[(i - 1 + sides) % sides];
      final v1 = (current - prev).normalize();
      final v2 = (current - next).normalize();
      final p1 = current - v1 * borderRadius;
      final p2 = current - v2 * borderRadius;

      if (i == 0) {
        path.moveTo(p1.dx, p1.dy);
      } else {
        path.lineTo(p1.dx, p1.dy);
      }

      path.quadraticBezierTo(current.dx, current.dy, p2.dx, p2.dy);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

extension NormalizeOffset on Offset {
  Offset normalize() {
    final len = distance;
    return len == 0 ? this : this / len;
  }
}
