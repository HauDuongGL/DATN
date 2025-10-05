import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/gen/assets.gen.dart';
import 'package:verify_clone/gen/translations.g.dart';
import 'package:verify_clone/presentation/widgets/toggle_switch/toggle_switch_common.dart';
import 'package:verify_clone/utils/style_utils.dart';

class AppLogoScaffold extends StatelessWidget {
  final bool showAppBar;
  final String title;
  final Widget body;
  final Widget? bottomNavigationBar;
  final VoidCallback? customBackAction;
  final Color? backgroundColor;
  final bool showBackButton;
  final List<Widget>? appbarAction;
  final FloatingActionButton? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool resizeToAvoidBottomInset;
  final Widget? toggleSwitch;
  final bool extendBody;

  const AppLogoScaffold({
    super.key,
    this.showAppBar = true,
    this.title = '',
    required this.body,
    this.toggleSwitch,
    this.bottomNavigationBar,
    this.customBackAction,
    this.showBackButton = true,
    this.resizeToAvoidBottomInset = true,
    this.appbarAction,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBody = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      extendBody: extendBody,
      appBar: showAppBar
          ? PreferredSize(
              preferredSize: Size.fromHeight(Dimens.d100.h),
              child: AppBar(
                flexibleSpace: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          Dimens.d18.w,
                          Dimens.d13.h,
                          Dimens.d18.w,
                          0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Assets.images.logo.image(),
                            toggleSwitch ??
                                ToggleSwitchCommon(
                                  labels: [
                                    LocaleKeys.app_bar_eng.tr(),
                                    LocaleKeys.app_bar_eng.tr(),
                                  ],
                                  onToggle: (index) {},
                                  borderSideColor: colorStroke,
                                  width: Dimens.d104.w,
                                  height: Dimens.d34.h,
                                  fontSize: Dimens.d14.sp,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Inter',
                                ),
                          ],
                        ),
                      ),
                      if (showBackButton)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimens.d18.w,
                            vertical: Dimens.d8.h,
                          ),
                          child: GestureDetector(
                              onTap: customBackAction ??
                                  () {
                                    if (context.canPop()) {
                                      context.pop();
                                    }
                                  },
                              child: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.arrow_left,
                                    color: colorBlack,
                                    size: Dimens.d20.sp,
                                  ),
                                  spaceW5,
                                  Text(
                                    LocaleKeys.app_bar_back.tr(),
                                    style: AppTextStyle.interText,
                                  ),
                                ],
                              )),
                        ),
                    ],
                  ),
                ),
                centerTitle: false,
                backgroundColor: backgroundColor,
                actions: appbarAction,
              ),
            )
          : null,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
