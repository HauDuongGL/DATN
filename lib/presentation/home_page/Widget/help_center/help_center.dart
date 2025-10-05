import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/gen/assets.gen.dart';
import 'package:verify_clone/utils/style_utils.dart';

class HelpCenterWidget extends StatelessWidget {
  const HelpCenterWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorLightGray),
        borderRadius: BorderRadius.circular(
          Dimens.d16.r,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.d16.w,
          vertical: Dimens.d16.h,
        ),
        child: Row(
          children: [
            Assets.icons.icHelpCenter.svg(),
            spaceW16,
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Need some help?',
                    style: AppTextStyle.interMediumText.copyWith(
                      fontSize: Dimens.d18.sp,
                    ),
                  ),
                  spaceH10,
                  Text(
                    'View some useful resources to help you on your planting journey or contact our support team',
                    softWrap: true,
                    overflow: TextOverflow.clip,
                    style: AppTextStyle.interText.copyWith(
                      fontSize: Dimens.d12.sp,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
