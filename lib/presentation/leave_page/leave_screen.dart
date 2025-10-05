import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/core/config/router/router_name.dart';
import 'package:verify_clone/gen/assets.gen.dart';
import 'package:verify_clone/presentation/widgets/button/app_button.dart';
import 'package:verify_clone/utils/style_utils.dart';

typedef OnSaveAndExit = Future<void> Function(BuildContext context);

class LeaveScreen extends StatelessWidget {
  const LeaveScreen({
    super.key,
    required this.onSaveAndExit,
  });

  final OnSaveAndExit onSaveAndExit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.leaveBg.provider(),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                spaceH70,
                GestureDetector(
                  onTap: () => context.goNamed(RoutesName.plantTrees.name),
                  child: Icon(
                    CupertinoIcons.clear,
                    color: colorBlack,
                    size: Dimens.d24.sp,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimens.d20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  spaceH200,
                  Text(
                    'Leave Page',
                    style: AppTextStyle.interBoldText.copyWith(
                      fontSize: Dimens.d32.sp,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  spaceH16,
                  Text(
                    "Your progress has been saved. Come back anytime to complete the flow whenever it's convenient for you.",
                    textAlign: TextAlign.center,
                    style: AppTextStyle.interMediumText.copyWith(
                      fontSize: Dimens.d18.sp,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  spaceH24,

                  Material(
                    borderRadius: BorderRadius.circular(Dimens.d48.r),
                    child: AppButton(
                      onTap: () async {
                        await onSaveAndExit(context);
                      },
                      color: colorBlue,
                      width: double.infinity,
                      border: Border.all(color: colorBlue),
                      borderRadius: 19,
                      title: 'Save progress and exit',
                      style: AppTextStyle.interMediumText.copyWith(
                        fontSize: Dimens.d16.sp,
                        color: colorWhite,
                      ),
                    ),
                  ),

                  spaceH16,
                  // Cancel
                  Material(
                    borderRadius: BorderRadius.circular(Dimens.d48.r),
                    child: AppButton(
                      onTap: () => context.goNamed(RoutesName.plantTrees.name),
                      enabled: true,
                      width: double.infinity,
                      border: Border.all(color: colorWhite),
                      borderRadius: 19,
                      title: 'Cancel',
                      style: AppTextStyle.interMediumText.copyWith(
                        fontSize: Dimens.d16.sp,
                        color: colorBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
