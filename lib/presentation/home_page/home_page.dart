import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/gen/translations.g.dart';
import 'package:verify_clone/presentation/home_page/Widget/first_plant/first_plant.dart';
import 'package:verify_clone/presentation/home_page/Widget/help_center/help_center.dart';
import 'package:verify_clone/presentation/home_page/Widget/learning_hub/learning_hub.dart';
import 'package:verify_clone/presentation/home_page/Widget/point_info/point_info.dart';
import 'package:verify_clone/presentation/home_page/Widget/status/level_user.dart';
import 'package:verify_clone/presentation/home_page/Widget/status/status_user.dart';
import 'package:verify_clone/core/base/home_scafold/base_home_scafold.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/router/router_name.dart';
import 'package:verify_clone/gen/assets.gen.dart';
import 'package:verify_clone/presentation/home_page/Widget/welcome/welcome.dart';
import 'package:verify_clone/presentation/home_page/Widget/your_trees/your_trees.dart';
import 'package:verify_clone/presentation/home_page/common/enumPage.dart';
import 'package:verify_clone/presentation/main/common/enum_drawer.dart';
import 'package:verify_clone/presentation/main/riverpod/main_riverpod.dart';
import 'package:verify_clone/presentation/main/widget/drawer.dart';
import 'package:verify_clone/presentation/widgets/pylygon/level_badge.dart';
import 'package:verify_clone/presentation/widgets/pylygon/polygon_common.dart';
import 'package:verify_clone/presentation/widgets/tree_progress/tree_progress.dart';
import 'package:verify_clone/utils/style_utils.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppHomeScaffold(
      showBackButton: false,
      onDrawerChanged: (isOpen) {
        ref.read(drawerOpenProvider.notifier).state = isOpen;
      },
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
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: Assets.images.homepageHeader.provider(),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimens.d22.w),
                  child: Column(
                    children: [
                      spaceH40,
                      StatusUser(
                        avatarUser: PolygonCommon(
                          imagePath: 'assets/test.jpg',
                          size: Dimens.d65.sp,
                          borderRadius: Dimens.d4.r,
                          padding: Dimens.d4,
                          borderWidth: Dimens.d6.r,
                          borderColor: colorWhite,
                        ),
                        userName: 'Alex Brown',
                        coin: 100,
                      ),
                      spaceH16,
                      LevelUser(
                        levelProgressBarUser: LevelProgressBar(
                          current: 1,
                          total: 4,
                          nextLevelLabel: 'Level 2',
                          height: Dimens.d14.h,
                          progressColor: colorPending,
                          backgroundColor: colorWhite,
                        ),
                        levelUser: const LevelBadge(
                          level: 2,
                          reached: false,
                        ),
                      ),
                      spaceH22,
                    ],
                  ),
                ),
              ),
              spaceH26,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimens.d22.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: Dimens.d77.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: PageTypeBtn.values.length,
                        itemBuilder: (context, index) {
                          final page = PageTypeBtn.values[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              right: Dimens.d13.w,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                context.goNamed(page.goRouterPage);
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(
                                      Dimens.d16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorBlue,
                                      borderRadius: BorderRadius.circular(
                                        Dimens.d16.r,
                                      ),
                                    ),
                                    child: Center(
                                      child: page.svgGenImage.svg(),
                                    ),
                                  ),
                                  Text(page.pageName)
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    spaceH24,
                    const WelcomeWidget(),
                    spaceH24,
                    const PointInfoWidget(),
                    spaceH24,
                    const FirstPlantWidget(),
                    spaceH32,
                    Text(
                      LocaleKeys.home_page_your_trees_title.tr(),
                      style: AppTextStyle.interMediumText.copyWith(
                        fontSize: Dimens.d18.sp,
                      ),
                    ),
                    spaceH16,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        YourTreesWidget(
                          backgourdColor: colorLightPastelGreen,
                          title: LocaleKeys
                              .home_page_your_trees_trees_planted_title
                              .tr(),
                          subTitle: LocaleKeys
                              .home_page_your_trees_trees_planted_sub_title
                              .tr(),
                          titleBtn: LocaleKeys
                              .home_page_your_trees_trees_planted_title_btn
                              .tr(),
                        ),
                        YourTreesWidget(
                          icon: Assets.icons.icProtectPlant.svg(),
                          backgourdColor: colorBabyBlue,
                          title: LocaleKeys
                              .home_page_your_trees_trees_protect_title
                              .tr(),
                          subTitle: LocaleKeys
                              .home_page_your_trees_trees_protect_sub_title
                              .tr(),
                          titleBtn: LocaleKeys
                              .home_page_your_trees_trees_protect_title_btn
                              .tr(),
                        ),
                      ],
                    ),
                    spaceH24,
                    Text(
                      LocaleKeys.home_page_help_center_title_info.tr(),
                      style: AppTextStyle.interMediumText.copyWith(
                        fontSize: Dimens.d18.sp,
                      ),
                    ),
                    spaceH16,
                    GestureDetector(
                      onTap: () => context.goNamed(RoutesName.helpCenter.name),
                      child: const HelpCenterWidget(),
                    ),
                    spaceH24,
                    Text(
                      LocaleKeys.home_page_learning_hub_title_info.tr(),
                      style: AppTextStyle.interMediumText.copyWith(
                        fontSize: Dimens.d18.sp,
                      ),
                    ),
                    spaceH16,
                    const LearningHub(),
                    spaceH144,
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
