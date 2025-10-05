import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/gen/assets.gen.dart';
import 'package:verify_clone/utils/style_utils.dart';

class FirstPlantWidget extends StatelessWidget {
  const FirstPlantWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorLightGray),
        borderRadius: BorderRadius.circular(Dimens.d16.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.d16.w,
          vertical: Dimens.d16.h,
        ),
        child: Row(
          children: [
            Assets.icons.icPlantPot.svg(),
            spaceW16,
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Got your seedlings?',
                  style: AppTextStyle.interMediumText.copyWith(
                    fontSize: Dimens.d18.sp,
                  ),
                ),
                spaceH10,
                GestureDetector(
                  onTap: () => print('Get Stated'),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorBlue,
                      borderRadius: BorderRadius.circular(
                        Dimens.d33.r,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: Dimens.d10.h,
                        horizontal: Dimens.d16.w,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Plant your first tree',
                            style: AppTextStyle.interMediumText.copyWith(
                              color: colorWhite,
                              fontSize: Dimens.d12.sp,
                            ),
                          ),
                          spaceW5,
                          Icon(
                            CupertinoIcons.arrow_right,
                            size: Dimens.d12.sp,
                            color: colorWhite,
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
