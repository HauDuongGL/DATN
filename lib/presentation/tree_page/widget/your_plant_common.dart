import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/gen/assets.gen.dart';
import 'package:verify_clone/utils/style_utils.dart';

class ContainerYourPlantCommon extends StatelessWidget {
  final Color? bgColor;
  final TextStyle? textStylePlant;
  final TextStyle? countStylePlant;
  final Widget? iconAsset;
  final String? countTree;
  final String? titlePlant;
  const ContainerYourPlantCommon({
    super.key,
    this.bgColor,
    this.iconAsset,
    this.countTree,
    this.titlePlant,
    this.textStylePlant,
    this.countStylePlant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(
          Dimens.d16.r,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: Dimens.d18.h,
          bottom: Dimens.d18.h,
          left: Dimens.d13.w,
          right: Dimens.d12.w,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                iconAsset ?? Assets.icons.icTrees.svg(),
                Text(
                  titlePlant ?? 'Trees Planted',
                  style: textStylePlant ??
                      AppTextStyle.interMediumText.copyWith(
                        fontSize: Dimens.d14.sp,
                        color: primaryDarkGreen,
                      ),
                ),
              ],
            ),
            spaceH18,
            Text(
              countTree ?? '140',
              style: countStylePlant ??
                  AppTextStyle.interBoldText.copyWith(
                    fontSize: Dimens.d48.sp,
                    color: primaryDarkGreen,
                  ),
            )
          ],
        ),
      ),
    );
  }
}
