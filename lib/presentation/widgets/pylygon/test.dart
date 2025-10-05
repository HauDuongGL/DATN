import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xFFD1E69B),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HexagonContainer(
                imagePath: 'assets/test.jpg',
              ),
              SizedBox(height: 20),
              HexagonContainer(
                size: Dimens.d65,
                borderRadius: Dimens.d4,
                padding: Dimens.d4,
                borderWidth: Dimens.d6,
                borderColor: colorWhite,
                child: HexagonContainer(
                  size: Dimens.d65,
                  borderRadius: Dimens.d4,
                  padding: Dimens.d4,
                  borderWidth: Dimens.d6,
                  borderColor: colorBlack,
                  child: Text(
                    '42',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              HexagonContainer(
                imagePath: 'assets/tree.png',
                child: Text(
                  '🌳',
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HexagonContainer extends StatefulWidget {
  final String? imagePath;
  final Widget? child;
  final double size;
  final double borderRadius;
  final double padding;
  final double borderWidth;
  final Color borderColor;
  final Color shadowColor;
  final double shadowBlur;
  final BoxFit fit;

  const HexagonContainer({
    super.key,
    this.imagePath,
    this.child,
    this.size = 120,
    this.borderRadius = 20,
    this.padding = 8,
    this.borderWidth = 6,
    this.borderColor = Colors.white,
    this.shadowColor = Colors.black26,
    this.shadowBlur = 8,
    this.fit = BoxFit.cover,
  });

  @override
  State<HexagonContainer> createState() => _HexagonContainerState();
}

class _HexagonContainerState extends State<HexagonContainer> {
  ui.Image? image;

  @override
  void initState() {
    super.initState();
    _loadIfNeeded();
  }

  Future<void> _loadIfNeeded() async {
    if (widget.imagePath != null) {
      final data = await rootBundle.load(widget.imagePath!);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      setState(() => image = frame.image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: _HexagonBackgroundPainter(
          sides: 6,
          borderRadius: widget.borderRadius,
          borderWidth: widget.borderWidth,
          borderColor: widget.borderColor,
          shadowColor: widget.shadowColor,
          shadowBlur: widget.shadowBlur,
        ),
        child: ClipPath(
          clipper: _HexagonClipper(
            sides: 6,
            borderRadius: widget.borderRadius,
            padding: widget.padding,
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.padding),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (image != null)
                  RawImage(
                    image: image,
                    fit: widget.fit,
                  ),
                if (widget.child != null) Center(child: widget.child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HexagonBackgroundPainter extends CustomPainter {
  final int sides;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final Color shadowColor;
  final double shadowBlur;

  _HexagonBackgroundPainter({
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

class _HexagonClipper extends CustomClipper<Path> {
  final int sides;
  final double borderRadius;
  final double padding;

  _HexagonClipper({
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
