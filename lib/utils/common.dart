import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/core/config/router/router_name.dart';
import 'package:verify_clone/core/network/module.dart';
import 'package:verify_clone/domain/locals/prefs_service.dart';
import 'package:verify_clone/gen/translations.g.dart';
import 'package:verify_clone/utils/style_utils.dart';

void exitApp() async {
  PrefsService.clearAuthData().then((_) {
    final context = getIt.get<GlobalKey<NavigatorState>>().currentContext;
    if (context != null && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: Dimens.d50.w,
            vertical: Dimens.d240.h,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(33),
              color: colorHexadecimal.withOpacity(0.4),
            ),
            padding: EdgeInsets.symmetric(vertical: Dimens.d15.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  LocaleKeys.exit_app_title.tr(),
                  style: AppTextStyle.interBoldText,
                ),
                spaceH15,
                Text(
                  LocaleKeys.exit_app_sub_title.tr(),
                  style: AppTextStyle.interText,
                ),
                spaceH28,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        LocaleKeys.exit_app_cancel.tr(),
                        style: AppTextStyle.interText,
                      ),
                    ),
                    spaceW18,
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        context.goNamed(RoutesName.login.name);
                      },
                      child: Text(
                        LocaleKeys.exit_app_yes.tr(),
                        style: AppTextStyle.interText,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      );
    }
  });
}

Future<void> showDialogConfirm({
  required String title,
  required String text,
  required String subText1,
  required String subText2,
  required String cancel,
  required String confirm,
  Future<void> Function()? onShowdialog,
  required Color colorConfirm,
}) async {
  final context = getIt.get<GlobalKey<NavigatorState>>().currentContext;
  if (context != null && context.mounted) {
    showDialog(
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.d20.w,
          vertical: Dimens.d168.h,
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
              mainAxisSize: MainAxisSize.min,
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
                Text(
                  title,
                  style: AppTextStyle.interMediumText.copyWith(
                    fontSize: Dimens.d20.sp,
                    color: colorRavenBlack,
                    decoration: TextDecoration.none,
                  ),
                ),
                spaceH24,
                Text.rich(
                  TextSpan(
                    text: text,
                    style: AppTextStyle.interText.copyWith(
                      fontSize: Dimens.d16.sp,
                      color: colorDarkNavy,
                      decoration: TextDecoration.none,
                    ),
                    children: [
                      TextSpan(
                        text: subText1,
                        style: AppTextStyle.interMediumText.copyWith(
                          fontSize: Dimens.d16.sp,
                          color: colorDarkNavy,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      TextSpan(
                        text: subText2,
                        style: AppTextStyle.interText.copyWith(
                          fontSize: Dimens.d16.sp,
                          color: colorDarkNavy,
                          decoration: TextDecoration.none,
                        ),
                      )
                    ],
                  ),
                ),
                spaceH48,
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorWhite,
                          side: const BorderSide(color: colorBlue),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: Dimens.d16.h,
                          ),
                          child: Text(
                            cancel,
                            style: AppTextStyle.interMediumText.copyWith(
                              color: colorBlue,
                              fontSize: Dimens.d15.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                    spaceW10,
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorConfirm,
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          if (onShowdialog != null) {
                            await Future.delayed(
                                const Duration(milliseconds: 150));
                            await onShowdialog();
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: Dimens.d16.h,
                            horizontal: Dimens.d8.w,
                          ),
                          child: Text(
                            confirm,
                            style: AppTextStyle.interMediumText.copyWith(
                              color: colorWhite,
                              fontSize: Dimens.d16.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                spaceH16,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showDialogConfirms({
  required String title,
  required String text,
  required String subText1,
  required String subText2,
  required String cancel,
  required String confirm,
  required VoidCallback? onShowdialog,
  required Color colorConfirm,
}) async {
  final context = getIt.get<GlobalKey<NavigatorState>>().currentContext;
  if (context != null && context.mounted) {
    showDialog(
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.d20.w,
          vertical: Dimens.d168.h,
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
              mainAxisSize: MainAxisSize.min,
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
                Text(
                  title,
                  style: AppTextStyle.interMediumText.copyWith(
                    fontSize: Dimens.d20.sp,
                    color: colorRavenBlack,
                    decoration: TextDecoration.none,
                  ),
                ),
                spaceH24,
                Text.rich(
                  TextSpan(
                    text: text,
                    style: AppTextStyle.interText.copyWith(
                      fontSize: Dimens.d16.sp,
                      color: colorDarkNavy,
                      decoration: TextDecoration.none,
                    ),
                    children: [
                      TextSpan(
                        text: subText1,
                        style: AppTextStyle.interMediumText.copyWith(
                          fontSize: Dimens.d16.sp,
                          color: colorDarkNavy,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      TextSpan(
                        text: subText2,
                        style: AppTextStyle.interText.copyWith(
                          fontSize: Dimens.d16.sp,
                          color: colorDarkNavy,
                          decoration: TextDecoration.none,
                        ),
                      )
                    ],
                  ),
                ),
                spaceH48,
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorWhite,
                          side: const BorderSide(color: colorBlue),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: Dimens.d16.h,
                          ),
                          child: Text(
                            cancel,
                            style: AppTextStyle.interMediumText.copyWith(
                              color: colorBlue,
                              fontSize: Dimens.d15.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                    spaceW10,
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorConfirm,
                        ),
                        onPressed: onShowdialog,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: Dimens.d16.h,
                            horizontal: Dimens.d8.w,
                          ),
                          child: Text(
                            confirm,
                            style: AppTextStyle.interMediumText.copyWith(
                              color: colorWhite,
                              fontSize: Dimens.d16.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                spaceH16,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showToast(String message,
    {Toast? toastLength = Toast.LENGTH_SHORT,
    ToastGravity gravity = ToastGravity.TOP,
    double? fontSize}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: toastLength,
    gravity: gravity,
    fontSize: fontSize,
  );
}
