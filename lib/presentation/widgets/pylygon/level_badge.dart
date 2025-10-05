import 'package:flutter/material.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/presentation/widgets/pylygon/polygon_common.dart';

class LevelBadge extends StatelessWidget {
  final int level;
  final bool reached;
  final double size;
  final double padding;

  const LevelBadge({
    super.key,
    required this.level,
    this.reached = false,
    this.size = 43,
    this.padding = 2,
  });

  @override
  Widget build(BuildContext context) {
    return PolygonCommon(
        size: size,
        borderRadius: 1,
        padding: padding,
        borderWidth: 3,
        borderColor: Colors.white,
        child: PolygonCommon(
          size: size,
          borderRadius: 1,
          padding: padding + 2,
          borderWidth: 3,
          borderColor: colorLightOrange,
          child: PolygonCommon(
            size: size,
            borderRadius: 1,
            padding: padding - 1,
            borderWidth: 3,
            borderColor: colorPending,
            child: Text(
              '$level',
              style: AppTextStyle.interBoldText.copyWith(
                fontSize: 18,
                color: colorWhite,
              ),
            ),
          ),
        ));
  }
}
