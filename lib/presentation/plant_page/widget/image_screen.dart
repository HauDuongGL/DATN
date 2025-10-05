import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/utils/style_utils.dart';

class ImageScreen extends StatelessWidget {
  final BoxBorder? border;
  final String? title;
  final String? timer;
  final Widget image;
  final String? titleBtn;
  final VoidCallback? ontap;
  final Color? iconColor;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? colorBg;
  final BoxBorder? borderBtn;
  const ImageScreen({
    super.key,
    required this.image,
    this.border,
    this.title,
    this.timer,
    this.titleBtn,
    this.ontap,
    this.iconColor,
    this.textColor,
    this.backgroundColor,
    this.borderBtn,
    this.colorBg,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Text('error');
        }
        return Container(
          decoration: BoxDecoration(
            color: colorBg,
            borderRadius: BorderRadius.circular(
              Dimens.d16.r,
            ),
            border: border ??
                Border.all(
                  color: colorSuccessGreen,
                ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(Dimens.d10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.camera,
                      size: Dimens.d13.sp,
                      color: colorBlue,
                    ),
                    spaceW6,
                    Text(
                      title ?? '',
                      style: AppTextStyle.interMediumText.copyWith(
                        fontSize: Dimens.d14.sp,
                      ),
                    )
                  ],
                ),
                Text(
                  timer ?? '',
                  style: AppTextStyle.interText.copyWith(
                    fontSize: Dimens.d12.sp,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: Dimens.d159.h,
                  child: image,
                ),
                spaceH6,
                GestureDetector(
                  onTap: ontap,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimens.d18.w,
                      vertical: Dimens.d12.h,
                    ),
                    decoration: BoxDecoration(
                      border: borderBtn ?? Border.all(color: colorBlue),
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(Dimens.d33.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.camera,
                          color: iconColor ?? colorBlue,
                          size: Dimens.d16.sp,
                        ),
                        spaceW4,
                        Text(
                          titleBtn ?? '',
                          style: AppTextStyle.interMediumText.copyWith(
                            fontSize: Dimens.d11.sp,
                            color: textColor ?? colorBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
