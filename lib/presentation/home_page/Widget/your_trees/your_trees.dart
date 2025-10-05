import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/gen/assets.gen.dart';
import 'package:verify_clone/utils/style_utils.dart';

class YourTreesWidget extends StatelessWidget {
  final Color? backgourdColor;
  final Widget? icon;
  final String title;
  final String subTitle;
  final int count;
  final bool isCount;
  final VoidCallback? onTap;
  final String titleBtn;
  const YourTreesWidget({
    required this.title,
    required this.titleBtn,
    required this.subTitle,
    super.key,
    this.backgourdColor,
    this.icon,
    this.count = 14,
    this.isCount = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dimens.d160.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimens.d16.r),
        color: backgourdColor,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.d11.w,
          vertical: Dimens.d20.h,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon ??
                    Assets.icons.icPlantTrees.svg(
                      // ignore: deprecated_member_use_from_same_package
                      color: colorDarkOliveGreen,
                    ),
                Text(
                  title,
                  style: AppTextStyle.interMediumText.copyWith(
                    fontSize: Dimens.d14.sp,
                  ),
                ),
              ],
            ),
            spaceH23,
            Text(
              isCount ? count.toString() : subTitle,
              textAlign: TextAlign.center,
              style: AppTextStyle.regularText.copyWith(
                fontSize: Dimens.d12.sp,
              ),
            ),
            spaceH23,
            GestureDetector(
              onTap: () => onTap,
              child: Container(
                width: Dimens.d130.w,
                height: Dimens.d32.h,
                decoration: BoxDecoration(
                  color: colorBlue,
                  borderRadius: BorderRadius.circular(
                    Dimens.d33.r,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      titleBtn,
                      style: AppTextStyle.interMediumText.copyWith(
                        color: colorWhite,
                        fontSize: Dimens.d9.sp,
                      ),
                    ),
                    spaceW1,
                    Icon(
                      CupertinoIcons.arrow_right,
                      size: Dimens.d9.sp,
                      color: colorWhite,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
