import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/gen/assets.gen.dart';
import 'package:verify_clone/gen/translations.g.dart';
import 'package:verify_clone/presentation/widgets/badge/badge_common.dart';
import 'package:verify_clone/utils/style_utils.dart';

class ViewYourTreeScaffold extends StatelessWidget {
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
  final Drawer? drawer;
  final Widget? notification;
  final double preferredSize;

  final ImageProvider? backgroundImage;

  final ImageProvider? appBarBackgroundImage;

  final Function(bool)? onDrawerChanged;
  final Color? logoColor;
  final bool showInternet;

  const ViewYourTreeScaffold({
    super.key,
    required this.body,
    this.showAppBar = true,
    this.title = '',
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
    this.drawer,
    this.notification,
    this.onDrawerChanged,
    this.preferredSize = Dimens.d90,
    this.logoColor,
    this.showInternet = false,
    this.backgroundImage,
    this.appBarBackgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      extendBody: extendBody,
      drawer: drawer,
      onDrawerChanged: onDrawerChanged,
      appBar: showAppBar
          ? PreferredSize(
              preferredSize: Size.fromHeight(preferredSize.h),
              child: AppBar(
                automaticallyImplyLeading: false,
                elevation: 0,
                backgroundColor: appBarBackgroundImage != null
                    ? Colors.transparent
                    : (backgroundColor ?? Colors.transparent),
                surfaceTintColor: Colors.transparent,
                flexibleSpace: SizedBox(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (appBarBackgroundImage != null)
                        Image(
                          image: appBarBackgroundImage!,
                          fit: BoxFit.cover,
                        ),
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: Dimens.d22.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: Dimens.d28.h),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Assets.images.logo.image(color: logoColor),
                                    Row(
                                      children: [
                                        if (showInternet)
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimens.d8.r),
                                              color: colorBlue,
                                            ),
                                            padding:
                                                const EdgeInsets.all(Dimens.d9),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  CupertinoIcons.wifi_slash,
                                                  size: Dimens.d16.sp,
                                                  color: colorWhite,
                                                ),
                                                spaceW5,
                                                Text(
                                                  'Offline',
                                                  style: AppTextStyle
                                                      .interMediumText
                                                      .copyWith(
                                                    fontSize: Dimens.d10.sp,
                                                    color: colorWhite,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        notification ??
                                            const NotificationBell(
                                              count: 3,
                                              colorIconBell: colorBlack,
                                            ),
                                        Builder(
                                          builder: (context) {
                                            return IconButton(
                                              onPressed: () =>
                                                  Scaffold.of(context)
                                                      .openDrawer(),
                                              icon: Icon(
                                                CupertinoIcons.bars,
                                                size: Dimens.d28.sp,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              if (showBackButton)
                                GestureDetector(
                                  onTap: customBackAction ??
                                      () {
                                        Navigator.of(context).pop();
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
                                        style: AppTextStyle.interMediumText
                                            .copyWith(
                                          fontSize: Dimens.d14.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              spaceH3,

                              // Title + optional toggleSwitch bên phải
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title.isEmpty ? 'Your Trees' : title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          AppTextStyle.interBoldText.copyWith(
                                        fontSize: Dimens.d32.sp,
                                      ),
                                    ),
                                  ),
                                  if (toggleSwitch != null) ...[
                                    spaceW10,
                                    toggleSwitch!,
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                centerTitle: false,
                actions: appbarAction,
              ),
            )
          : null,
      body: Stack(
        children: [
          if (backgroundImage != null)
            Positioned.fill(
              child: Image(
                image: backgroundImage!,
                fit: BoxFit.cover,
              ),
            ),
          Positioned.fill(child: body),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
