import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:verify_clone/core/base/base.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/core/config/router/router_name.dart';
import 'package:verify_clone/gen/assets.gen.dart';
import 'package:verify_clone/presentation/main/common/enum_drawer.dart';
import 'package:verify_clone/presentation/main/riverpod/main_riverpod.dart';
import 'package:verify_clone/presentation/main/widget/drawer.dart';
import 'package:verify_clone/utils/style_utils.dart';

class Group extends ConsumerWidget {
  const Group({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppHomeScaffold(
      showInternet: true,
      preferredSize: Dimens.d95,
      logoColor: colorBlack,
      backgroundColor: colorLightOrange,
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
        context.goNamed(RoutesName.treeView.name);
      },
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.d20.w,
          vertical: Dimens.d32.h,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Women in the Wild',
                  style: AppTextStyle.interBoldText.copyWith(
                    fontSize: Dimens.d20.sp,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Assets.icons.icSettings.svg(
                    color: colorBlack,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Assets.icons.icGroups.svg(
                  color: colorBlack,
                ),
                spaceW5,
                Text(
                  '1,000',
                  style: AppTextStyle.interMediumText.copyWith(
                    fontSize: Dimens.d12.sp,
                  ),
                ),
                spaceW8,
              ],
            )
          ],
        ),
      ),
    );
  }
}
