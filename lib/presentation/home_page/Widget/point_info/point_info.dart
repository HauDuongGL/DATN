import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/gen/assets.gen.dart';
import 'package:verify_clone/gen/translations.g.dart';
import 'package:verify_clone/utils/style_utils.dart';

class PointInfoWidget extends StatelessWidget {
  final VoidCallback? onTap;
  const PointInfoWidget({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.earnPoints.provider(),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(
          Dimens.d16.r,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.d16.w,
          vertical: Dimens.d24.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              LocaleKeys.home_page_point_info_title.tr(),
              style: AppTextStyle.regularText.copyWith(
                fontSize: Dimens.d12.sp,
                color: colorWhite,
              ),
            ),
            spaceH10,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Assets.icons.icCoin.svg(
                  width: Dimens.d39.w,
                  height: Dimens.d39.h,
                ),
                spaceW8,
                Text(
                  LocaleKeys.home_page_point_info_sub_title.tr(),
                  style: AppTextStyle.interBoldText.copyWith(
                    fontSize: Dimens.d24.sp,
                    color: colorWhite,
                  ),
                ),
              ],
            ),
            spaceH28,
            GestureDetector(
              onTap: () => onTap,
              child: Container(
                width: Dimens.d114.w,
                decoration: BoxDecoration(
                  color: colorWhite,
                  borderRadius: BorderRadius.circular(
                    Dimens.d33.r,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: Dimens.d8.h,
                    horizontal: Dimens.d16.w,
                  ),
                  child: Row(
                    children: [
                      Text(
                        LocaleKeys.home_page_point_info_title_btn.tr(),
                        style: AppTextStyle.interMediumText.copyWith(
                          color: colorBlue,
                          fontSize: Dimens.d12.sp,
                        ),
                      ),
                      spaceW1,
                      Icon(
                        CupertinoIcons.arrow_right,
                        size: Dimens.d12.sp,
                        color: colorBlue,
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
