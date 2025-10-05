import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:verify_clone/presentation/widgets/pylygon/hexagon_painter.dart';

class PolygonCommon extends StatefulWidget {
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
  final Color? backgroundColor;

  const PolygonCommon({
    super.key,
    this.imagePath,
    this.child,
    this.size = 120,
    this.borderRadius = 20,
    this.padding = 0,
    this.borderWidth = 6,
    this.borderColor = Colors.white,
    this.shadowColor = Colors.black26,
    this.shadowBlur = 8,
    this.fit = BoxFit.cover,
    this.backgroundColor,
  });

  @override
  State<PolygonCommon> createState() => _HexagonContainerState();
}

class _HexagonContainerState extends State<PolygonCommon> {
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
    return Container(
      color: widget.backgroundColor ?? Colors.transparent,
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: HexagonPainter(
          sides: 6,
          borderRadius: widget.borderRadius,
          borderWidth: widget.borderWidth,
          borderColor: widget.borderColor,
          shadowColor: widget.shadowColor,
          shadowBlur: widget.shadowBlur,
        ),
        child: ClipPath(
          clipper: HexagonClipper(
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
