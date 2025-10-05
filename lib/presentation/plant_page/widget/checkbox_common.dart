import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/gen/assets.gen.dart';
import 'package:verify_clone/presentation/widgets/button/common_btn.dart';
import 'package:verify_clone/utils/style_utils.dart';

class CheckBoxCommon extends StatelessWidget {
  const CheckBoxCommon({
    super.key,
    required this.isCheck,
    required this.ref,
    required this.onChanged,
    this.permissionText,
    this.permissionStyle,
    this.colorActive,
    this.colorCheck,
  });

  final bool isCheck;
  final WidgetRef ref;
  final String? permissionText;
  final TextStyle? permissionStyle;
  final Color? colorActive;
  final Color? colorCheck;
  final Function(bool?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: isCheck,
          onChanged: onChanged,
          activeColor: colorActive ?? colorBlue,
          checkColor: colorCheck ?? colorWhite,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        spaceH8,
        Expanded(
          child: Text(
            permissionText ?? '',
            style: permissionStyle ??
                AppTextStyle.interText.copyWith(
                  fontSize: Dimens.d16.sp,
                  color: colorDarkNavy,
                ),
          ),
        ),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.d20.w,
                  vertical: Dimens.d80.h,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorWhite,
                    borderRadius: BorderRadius.circular(Dimens.d8.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: Dimens.d20.h,
                      right: Dimens.d20.w,
                      bottom: Dimens.d48.h,
                      left: Dimens.d20.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Icon(
                              CupertinoIcons.clear,
                              color: colorDarkGrayBlue,
                              size: Dimens.d18.sp,
                            ),
                          ),
                        ),
                        spaceH10,
                        Assets.icons.icStop.svg(),
                        spaceH24,
                        Text(
                          'You need permission to plant on property you don’t own.',
                          style: AppTextStyle.interMediumText.copyWith(
                            fontSize: Dimens.d20.sp,
                            color: colorRavenBlack,
                          ),
                        ),
                        spaceH24,
                        GestureDetector(
                          onTap: () {},
                          child: Text.rich(
                            TextSpan(
                              text:
                                  'Speak to the person who owns this land to ask plant trees on this property or find a ',
                              style: AppTextStyle.interText.copyWith(
                                fontSize: Dimens.d16.sp,
                                color: colorDarkGrayBlue,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Verified Planting Area ->',
                                  style: AppTextStyle.interText.copyWith(
                                      fontSize: Dimens.d16.sp,
                                      color: colorBlue,
                                      decoration: TextDecoration.underline,
                                      decorationColor: colorBlue),
                                ),
                              ],
                            ),
                          ),
                        ),
                        spaceH48,
                        CommonBtn(
                          text: "I have permission to plant here",
                          styleBtn: ElevatedButton.styleFrom(
                              backgroundColor: colorWhite,
                              foregroundColor: colorBlue,
                              side: const BorderSide(
                                color: colorBlue,
                              ),
                              textStyle: AppTextStyle.interMediumText.copyWith(
                                fontSize: Dimens.d14.sp,
                                color: colorBlue,
                              )),
                        ),
                        spaceH16,
                        CommonBtn(
                          text: "Find a Planting Area ->",
                          styleBtn: ElevatedButton.styleFrom(
                            backgroundColor: colorBlue,
                            foregroundColor: colorWhite,
                            textStyle: AppTextStyle.interMediumText.copyWith(
                              fontSize: Dimens.d14.sp,
                              color: colorBlue,
                            ),
                          ),
                          textStyle: AppTextStyle.interMediumText.copyWith(
                            fontSize: Dimens.d14.sp,
                            color: colorWhite,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          child: const Icon(
            CupertinoIcons.question_circle,
            size: 20,
            color: colorDarkGrayBlue,
          ),
        ),
      ],
    );
  }
}
