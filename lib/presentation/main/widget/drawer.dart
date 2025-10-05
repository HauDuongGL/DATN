import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/language.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/core/config/router/router_name.dart';
import 'package:verify_clone/gen/assets.gen.dart';
import 'package:verify_clone/gen/translations.g.dart';
import 'package:verify_clone/presentation/main/common/enum_drawer.dart';
import 'package:verify_clone/presentation/widgets/pylygon/polygon_common.dart';
import 'package:verify_clone/presentation/widgets/toggle_switch/toggle_switch_common.dart';
import 'package:verify_clone/utils/style_utils.dart';

class DrawerCommon extends StatelessWidget {
  final EnumDrawer currentPage;
  final void Function(EnumDrawer selected) onSelected;

  const DrawerCommon({
    super.key,
    required this.currentPage,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: Assets.images.drawerBg.provider(),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Brian Surname',
                      style: AppTextStyle.interMediumText.copyWith(
                        fontSize: Dimens.d16.sp,
                        color: colorWhite,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: colorWhite,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              PolygonCommon(
                                imagePath: 'assets/test.jpg',
                                size: Dimens.d65.sp,
                                borderRadius: Dimens.d4.r,
                                padding: Dimens.d4,
                                borderWidth: Dimens.d6.r,
                                borderColor: colorWhite,
                              ),
                              spaceW8,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Level 1",
                                      style: AppTextStyle.interBoldText
                                          .copyWith(
                                              fontSize: Dimens.d14.sp,
                                              color: colorWhite)),
                                  Text("Habitat",
                                      style: AppTextStyle.interBoldText
                                          .copyWith(
                                              fontSize: Dimens.d14.sp,
                                              color: colorWhite)),
                                  Text("Hero",
                                      style: AppTextStyle.interBoldText
                                          .copyWith(
                                              fontSize: Dimens.d14.sp,
                                              color: colorWhite)),
                                ],
                              ),
                            ],
                          ),
                          spaceH9,
                          GestureDetector(
                            onTap: () {},
                            child: Row(
                              children: [
                                Text(
                                  'Go To Miti Points',
                                  style: AppTextStyle.interMediumText.copyWith(
                                    fontSize: Dimens.d14.sp,
                                    color: colorWhite,
                                  ),
                                ),
                                spaceW4,
                                Icon(
                                  Icons.arrow_right,
                                  size: Dimens.d16.sp,
                                  color: colorWhite,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: colorWhite),
                          borderRadius: BorderRadius.circular(Dimens.d16.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimens.d16.w,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Available Points',
                              style: AppTextStyle.interMediumText.copyWith(
                                fontSize: Dimens.d14.sp,
                                color: colorWhite,
                              ),
                            ),
                            Text(
                              '10',
                              style: AppTextStyle.interBoldText.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: Dimens.d36.sp,
                                color: colorWhite,
                              ),
                            ),
                            Text(
                              '1 Tree = 10 Points',
                              style: AppTextStyle.regularText.copyWith(
                                fontSize: Dimens.d14.sp,
                                color: colorWhite,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimens.d8.w),
            child: ListView(
              children: [
                Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: EnumDrawer.values.length,
                      itemBuilder: (context, index) {
                        final item = EnumDrawer.values[index];
                        if (item == EnumDrawer.yourLanguage) {
                          return const SizedBox.shrink();
                        }

                        final isSelected = item == currentPage;

                        return Column(
                          children: [
                            if (item.hasDividerAbove)
                              const Divider(indent: 16, endIndent: 16),
                            InkWell(
                              borderRadius: BorderRadius.circular(Dimens.d16.r),
                              highlightColor: colorBabyBlue,
                              onTap: () async {
                                onSelected(item);
                                if (item.isLogout) {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.clear();
                                  context.goNamed(RoutesName.login.name);
                                } else {
                                  context.pushNamed(item.nameRouter!);
                                }
                              },
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(Dimens.d16.r),
                                ),
                                selected: isSelected,
                                leading: item.svgGenIcons.svg(
                                  color: isSelected ? colorBlue : colorBlack,
                                ),
                                title: Text(
                                  item.name,
                                  style: isSelected
                                      ? AppTextStyle.interBoldText.copyWith(
                                          fontSize: Dimens.d16.sp,
                                          color: colorBlue,
                                        )
                                      : AppTextStyle.interMediumText.copyWith(
                                          fontSize: Dimens.d16.sp,
                                          color: colorBlack,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    spaceH70,
                    const Divider(indent: 16, endIndent: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimens.d16.r),
                      ),
                      leading: EnumDrawer.yourLanguage.svgGenIcons
                          .svg(color: colorBlack),
                      title: Text(
                        EnumDrawer.yourLanguage.name,
                        style: AppTextStyle.interMediumText.copyWith(
                          fontSize: Dimens.d16.sp,
                          color: colorBlack,
                        ),
                      ),
                      trailing: ToggleSwitchCommon(
                        labels: [
                          LocaleKeys.app_bar_eng.tr(),
                          LocaleKeys.app_bar_swa.tr(),
                        ],
                        onToggle: (index) {
                          final language =
                              index == 0 ? AppLanguages.en : AppLanguages.sw;
                          context.setLocale(language);
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.setString('language', language.languageCode);
                          });
                        },
                        borderSideColor: colorStroke,
                        width: Dimens.d104.w,
                        height: Dimens.d34.h,
                        fontSize: Dimens.d14.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    Padding(
                      padding: EdgeInsets.all(Dimens.d16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Version 1.1',
                            style: AppTextStyle.interText.copyWith(
                              fontSize: Dimens.d12.sp,
                              color: colorDarkGrayBlue,
                            ),
                          ),
                          Text(
                            "Powered by Verity Nature & CCB Corridors",
                            style: AppTextStyle.interText.copyWith(
                              fontSize: Dimens.d12.sp,
                              color: colorDarkGrayBlue,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
