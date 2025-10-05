import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/gen/translations.g.dart';
import 'package:verify_clone/utils/style_utils.dart';

class LevelProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final double height;
  final double width;
  final Color backgroundColor;
  final Color progressColor;
  final double borderRadius;
  final String? nextLevelLabel;

  const LevelProgressBar({
    super.key,
    required this.current,
    required this.total,
    this.height = 12,
    this.width = 218,
    this.backgroundColor = Colors.white,
    this.progressColor = Colors.orange,
    this.borderRadius = 6,
    this.nextLevelLabel,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
    final remaining = (total - current).clamp(0, total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          remaining == 0
              ? LocaleKeys.home_page_level_status_reach
                  .tr(gender: 'level_status.reached', namedArgs: {
                  'level': nextLevelLabel ?? tr('level_status.default_level'),
                })
              : LocaleKeys.home_page_level_status_remaining
                  .tr(gender: 'level_status.remaining', namedArgs: {
                  'count': '$remaining',
                  'level': nextLevelLabel ?? tr('level_status.default_level'),
                  'plural': remaining > 1 ? 's' : '',
                }),
          style: AppTextStyle.interMediumText.copyWith(
            fontSize: Dimens.d12.sp,
          ),
        ),
        spaceH6,
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            children: [
              Container(
                height: height,
                width: width,
                color: backgroundColor,
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(Dimens.d33.r),
                      bottomRight: Radius.circular(Dimens.d33.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
