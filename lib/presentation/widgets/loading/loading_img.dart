import 'package:flutter/material.dart';

class LoadingImg extends StatelessWidget {
  final ImageProvider imgProvider;
  final BoxFit fit;
  final Widget? placeHolder;
  final Widget? error;
  final BorderRadius? borderRadius;
  const LoadingImg({
    super.key,
    required this.imgProvider,
    required this.fit,
    this.placeHolder,
    this.error,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget img = Image(
      image: imgProvider,
      fit: fit,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSync) {
        if (wasSync) return child;
        final isLoading = frame != null;
        return AnimatedSwitcher(
          duration: const Duration(microseconds: 200),
          child: isLoading
              ? child
              : Center(
                  child: placeHolder ?? CircularProgressIndicator(),
                ),
        );
      },
      errorBuilder: (context, _, __) =>
          error ?? const Icon(Icons.broken_image_outlined),
    );
    if (borderRadius != null) {
      img = ClipRRect(borderRadius: borderRadius!, child: img);
    }
    return img;
  }
}
