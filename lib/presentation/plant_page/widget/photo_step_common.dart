import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/utils/style_utils.dart';

class PhotoStepCommon extends StatelessWidget {
  final String? step;
  final VoidCallback? onTap;
  final String? subtitle;
  final String? meg;
  final String? cameraText;
  final TextStyle? stepStyle;
  final TextStyle? subtitleStyle;
  final TextStyle? megStyle;
  final Color? borderSideColor;
  final Color? backgroundBtn;
  final Color? iconColor;
  final Color? textColor;
  final EdgeInsets? padding;
  final Widget? containerCustom;
  final bool loading;
  final BorderRadius? clipRadius;

  const PhotoStepCommon({
    super.key,
    this.step,
    this.subtitle,
    this.meg,
    this.onTap,
    this.stepStyle,
    this.subtitleStyle,
    this.megStyle,
    this.cameraText,
    this.borderSideColor,
    this.padding,
    this.containerCustom,
    this.backgroundBtn,
    this.iconColor,
    this.textColor,
    this.loading = false,
    this.clipRadius,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius =
        clipRadius ?? BorderRadius.circular(Dimens.d16.r);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: step ?? '',
            style: (stepStyle ?? AppTextStyle.interMediumText).copyWith(
              fontSize: Dimens.d16.sp,
              color: colorBlue,
            ),
            children: [
              TextSpan(
                text: "*",
                style: AppTextStyle.interText.copyWith(
                  fontSize: Dimens.d14.sp,
                  color: colorFail,
                ),
              ),
            ],
          ),
        ),
        spaceH6,
        Text(
          subtitle ?? '',
          style: (subtitleStyle ?? AppTextStyle.interMediumText).copyWith(
            fontSize: Dimens.d14.sp,
            color: colorDarkGrayBlue,
          ),
        ),
        spaceH6,
        Text(
          meg ?? '',
          style: megStyle ?? AppTextStyle.interText,
        ),
        spaceH12,
        ClipRRect(
          borderRadius: radius,
          child: Stack(
            children: [
              containerCustom ??
                  _DefaultCaptureCard(
                    onTap: loading ? null : onTap,
                    padding: padding,
                    borderSideColor: borderSideColor,
                    backgroundBtn: backgroundBtn,
                    iconColor: iconColor,
                    textColor: textColor,
                    cameraText: cameraText,
                  ),
              if (loading)
                const Positioned.fill(
                  child: AbsorbPointer(
                    absorbing: true,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: colorBlack),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
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

class _DefaultCaptureCard extends StatelessWidget {
  const _DefaultCaptureCard({
    required this.onTap,
    required this.padding,
    required this.borderSideColor,
    required this.backgroundBtn,
    required this.iconColor,
    required this.textColor,
    required this.cameraText,
  });

  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final Color? borderSideColor;
  final Color? backgroundBtn;
  final Color? iconColor;
  final Color? textColor;
  final String? cameraText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: Dimens.d8.w,
            vertical: Dimens.d35.h,
          ),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(Dimens.d16.r),
        border: Border.all(
          color: borderSideColor ?? colorBlue,
          width: Dimens.d1.w,
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.d18.w,
            vertical: Dimens.d12.h,
          ),
          decoration: BoxDecoration(
            color: backgroundBtn ?? colorBlue,
            borderRadius: BorderRadius.circular(Dimens.d16.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.camera,
                color: iconColor ?? colorWhite,
                size: Dimens.d16.sp,
              ),
              spaceW4,
              Text(
                cameraText ?? "Take photo",
                style: AppTextStyle.interMediumText.copyWith(
                  fontSize: Dimens.d12.sp,
                  color: textColor ?? colorWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
