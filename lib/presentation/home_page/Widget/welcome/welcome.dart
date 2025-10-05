import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/gen/assets.gen.dart';
import 'package:verify_clone/gen/translations.g.dart';
import 'package:verify_clone/utils/style_utils.dart';

class WelcomeWidget extends StatelessWidget {
  final VoidCallback? onTap;
  const WelcomeWidget({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.welcome.provider(),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(Dimens.d16.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.d16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            spaceH123,
            Text(
              LocaleKeys.home_page_welcome_title.tr(),
              style: AppTextStyle.interBoldText.copyWith(
                fontSize: Dimens.d32.sp,
                color: colorWhite,
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: LocaleKeys.home_page_welcome_sub_title_1.tr(),
                  ),
                  TextSpan(
                    text: LocaleKeys.home_page_welcome_sub_title_2.tr(),
                    style: AppTextStyle.interBoldText.copyWith(
                      color: colorWhite,
                    ),
                  ),
                ],
              ),
              style: AppTextStyle.interText.copyWith(
                fontSize: Dimens.d16.sp,
                color: colorWhite,
              ),
            ),
            spaceH10,
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
                        LocaleKeys.home_page_welcome_title_btn.tr(),
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
            ),
            spaceH32,
          ],
        ),
      ),
    );
  }
}
