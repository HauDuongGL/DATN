import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:verify_clone/core/base/base_scafold.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/core/config/router/router_name.dart';
import 'package:verify_clone/gen/assets.gen.dart';
import 'package:verify_clone/gen/translations.g.dart';
import 'package:verify_clone/utils/style_utils.dart';

class PopUpPage extends StatelessWidget {
  const PopUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      toolBarHeight: 35,
      appbarAction: [
        Padding(
          padding: EdgeInsets.only(right: Dimens.d29.w),
          child: IconButton(
            onPressed: () {
              context.goNamed(RoutesName.home.name);
            },
            icon: Icon(
              CupertinoIcons.clear_thick,
              color: colorRavenBlack,
              size: Dimens.d28.sp,
            ),
          ),
        )
      ],
      backgroundColor: colorHexadecimal.withOpacity(0.4),
      showAppBar: true,
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: colorHexadecimal.withOpacity(0.4),
              child: Column(
                children: [
                  Text(
                    LocaleKeys.pop_up_page_title.tr(),
                    style: AppTextStyle.interBoldText.copyWith(
                      fontSize: Dimens.d24.sp,
                    ),
                  ),
                  spaceH24,
                  Text(
                    LocaleKeys.pop_up_page_sub_title.tr(),
                    style: AppTextStyle.interText.copyWith(
                      fontSize: Dimens.d14.sp,
                    ),
                  ),
                  spaceH20,
                  Text(
                    LocaleKeys.pop_up_page_change_title.tr(),
                    style: AppTextStyle.interBoldText.copyWith(
                      fontSize: Dimens.d24.sp,
                    ),
                  ),
                  spaceH11,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final status =
                              await Permission.locationWhenInUse.status;
                          if (status.isGranted) {
                            // ignore: use_build_context_synchronously
                            context.goNamed(RoutesName.plantTrees.name);
                          } else {
                            // ignore: use_build_context_synchronously
                            context.goNamed(RoutesName.enableLocation.name);
                          }
                        },
                        child: Assets.images.plantATree.image(),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: colorBabyBlue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  spaceH40,
                  GestureDetector(
                    onTap: () => context.goNamed(
                      RoutesName.enableLocation.name,
                    ),
                    child: Assets.images.protectATree.image(),
                  ),
                  // Assets.images.popUp.image(height: 209)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
