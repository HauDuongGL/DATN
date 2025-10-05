import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:verify_clone/core/base/base.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/core/config/router/router_name.dart';
import 'package:verify_clone/gen/assets.gen.dart';
import 'package:verify_clone/presentation/main/common/enum_drawer.dart';
import 'package:verify_clone/presentation/main/riverpod/main_riverpod.dart';
import 'package:verify_clone/presentation/main/widget/drawer.dart';
import 'package:verify_clone/presentation/widgets/button/app_button.dart';
import 'package:verify_clone/utils/style_utils.dart';

class EnableLocationScreen extends ConsumerWidget {
  const EnableLocationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppHomeScaffold(
      showInternet: true,
      preferredSize: Dimens.d95,
      logoColor: colorBlack,
      backgroundColor: colorMediumHex.withOpacity(0.72),
      drawer: Drawer(
        width: double.infinity,
        child: DrawerCommon(
          currentPage: ref.watch(drawerPageProvider),
          onSelected: (EnumDrawer selected) {
            ref.read(drawerPageProvider.notifier).setPage(selected);
          },
        ),
      ),
      showAppBar: true,
      customBackAction: () {
        context.goNamed(RoutesName.popUp.name);
      },
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.d40.w,
          vertical: Dimens.d64.h,
        ),
        child: Center(
          child: Column(
            children: [
              Text(
                'Use your location',
                style: AppTextStyle.interBoldText.copyWith(
                  fontSize: Dimens.d24.sp,
                ),
              ),
              spaceH32,
              Assets.icons.icMap.svg(),
              spaceH32,
              Text(
                'Sisi na miti collects location data to verify the journey of the seedlings and when they are planted or protected, even when the app is closed or not in use.',
                textAlign: TextAlign.center,
                style: AppTextStyle.interMediumText.copyWith(
                  fontSize: Dimens.d16.sp,
                ),
              ),
              spaceH32,
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      padding: EdgeInsets.symmetric(
                        vertical: Dimens.d14.h,
                      ),
                      border: Border.all(
                        color: colorBlue,
                      ),
                      borderRadius: Dimens.d48.r,
                      title: 'DENNY',
                      style: AppTextStyle.interMediumText.copyWith(
                        fontSize: Dimens.d16.sp,
                        color: colorBlue,
                      ),
                      onTap: () => context.goNamed(RoutesName.popUp.name),
                    ),
                  ),
                  spaceW10,
                  Expanded(
                    child: AppButton(
                      padding: EdgeInsets.symmetric(
                        vertical: Dimens.d14.h,
                      ),
                      border: Border.all(
                        color: colorBlue,
                      ),
                      borderRadius: Dimens.d48.r,
                      title: 'ACCEPT',
                      style: AppTextStyle.interMediumText.copyWith(
                        fontSize: Dimens.d16.sp,
                        color: colorWhite,
                      ),
                      color: colorBlue,
                      onTap: () async {
                        final status =
                            await Permission.locationWhenInUse.request();

                        if (status.isGranted) {
                          if (!context.mounted) return;
                          context.goNamed(RoutesName.plantTrees.name);
                        }
                      },
                    ),
                  ),
                ],
              ),
              spaceH32,
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Read our ',
                      style: AppTextStyle.interMediumText.copyWith(
                        fontSize: Dimens.d14.sp,
                      ),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {},
                        child: Text(
                          'Privacy Policy',
                          style: AppTextStyle.interMediumText.copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: colorBlue,
                            fontSize: Dimens.d14.sp,
                            color: colorBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
