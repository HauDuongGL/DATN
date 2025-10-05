import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/gen/assets.gen.dart';
import 'package:verify_clone/utils/style_utils.dart';

class LearningHub extends StatelessWidget {
  final VoidCallback? onTap;
  const LearningHub({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorPastelPurple,
        borderRadius: BorderRadius.circular(
          Dimens.d16.r,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.d16.w,
          vertical: Dimens.d16.h,
        ),
        child: Column(
          children: [
            Text(
              'Become tree planting experts with our learning hub!',
              softWrap: true,
              overflow: TextOverflow.clip,
              style: AppTextStyle.interMediumText.copyWith(
                fontSize: 20,
              ),
            ),
            spaceH22,
            Row(
              children: [
                Assets.icons.icLearningHub.svg(),
                GestureDetector(
                  onTap: () => onTap,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: Dimens.d12.w,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Explore now',
                          style: AppTextStyle.interMediumText.copyWith(
                            color: colorBlue,
                            fontSize: Dimens.d14.sp,
                          ),
                        ),
                        spaceW5,
                        Icon(
                          CupertinoIcons.arrow_right,
                          size: Dimens.d14.sp,
                          color: colorBlue,
                        )
                      ],
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
