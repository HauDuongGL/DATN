import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/presentation/widgets/pylygon/level_badge.dart';
import 'package:verify_clone/presentation/widgets/tree_progress/tree_progress.dart';
import 'package:verify_clone/utils/style_utils.dart';

class LevelUser extends StatelessWidget {
  const LevelUser({
    super.key,
    required this.levelProgressBarUser,
    required this.levelUser,
  });

  final Widget? levelProgressBarUser;
  final Widget? levelUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: levelProgressBarUser ??
              LevelProgressBar(
                current: 1,
                total: 4,
                nextLevelLabel: 'Level 2',
                height: Dimens.d14.h,
                progressColor: colorPending,
                backgroundColor: colorWhite,
              ),
        ),
        spaceW8,
        levelUser ??
            const LevelBadge(
              level: 2,
              reached: false,
            ),
      ],
    );
  }
}
