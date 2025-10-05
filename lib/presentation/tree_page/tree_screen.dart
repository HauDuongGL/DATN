import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:verify_clone/core/base/view_your_tree/base_view_your_tree.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/core/config/router/router_name.dart';
import 'package:verify_clone/domain/entities/tree_items.dart';
import 'package:verify_clone/gen/assets.gen.dart';
import 'package:verify_clone/presentation/tree_page/riverpod/tree_riverpod.dart';

import 'package:verify_clone/presentation/tree_page/widget/your_plant_common.dart';
import 'package:verify_clone/presentation/widgets/button/app_button.dart';
import 'package:verify_clone/utils/style_utils.dart';

class TreeScreen extends ConsumerStatefulWidget {
  const TreeScreen({super.key});

  @override
  ConsumerState<TreeScreen> createState() => _TreeScreenState();
}

class _TreeScreenState extends ConsumerState<TreeScreen> {
  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy hh:mm a');

    final recentAsync = ref.watch(recentTreesFromPhotosProvider);
    final latestAsync = ref.watch(latestTreeFromPhotosProvider);
    final existingCountAsync = ref.watch(existingTreesCountProvider);
    final protectedCountAsync = ref.watch(protectedTreesCountProvider);

    existingCountAsync.maybeWhen(data: (v) => v, orElse: () => null);
    final protectedCount =
        protectedCountAsync.maybeWhen(data: (v) => v, orElse: () => null);

    return ViewYourTreeScaffold(
      showAppBar: false,
      body: RefreshIndicator(
        color: colorBlue,
        onRefresh: () async {
          await Future.delayed(
            const Duration(seconds: 1),
          );
          setState(() {});
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: Dimens.d18.w,
              right: Dimens.d18.w,
              top: Dimens.d25.h,
              bottom: Dimens.d49.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Your Planted Trees",
                    style: AppTextStyle.interMediumText
                        .copyWith(fontSize: Dimens.d18.sp)),
                spaceH16,
                Row(
                  children: [
                    const Expanded(
                      child: ContainerYourPlantCommon(
                        bgColor: colorLightPastelGreen,
                        titlePlant: "Trees Planted",
                        countTree: '0',
                      ),
                    ),
                    spaceW10,
                    Expanded(
                      child: ContainerYourPlantCommon(
                        iconAsset: Assets.icons.icProtectTrees.svg(),
                        titlePlant: 'Trees Protected',
                        textStylePlant: AppTextStyle.interMediumText.copyWith(
                          fontSize: Dimens.d14.sp,
                          color: royalBlueDark,
                        ),
                        countTree: protectedCount?.toString() ?? '—',
                        countStylePlant: AppTextStyle.interBoldText.copyWith(
                          fontSize: Dimens.d48.sp,
                          color: royalBlueDark,
                        ),
                        bgColor: colorBabyBlue,
                      ),
                    ),
                  ],
                ),
                spaceH16,
                Padding(
                  padding: EdgeInsets.only(
                    right: Dimens.d174.w,
                  ),
                  child: const ContainerYourPlantCommon(
                    bgColor: colorLightPastelGreen,
                    titlePlant: "Existing\nTrees Logged",
                    countTree: '0',
                  ),
                ),
                spaceH24,
                Text(
                  'Tree List',
                  style: AppTextStyle.interMediumText.copyWith(
                    fontSize: Dimens.d18.sp,
                  ),
                ),
                spaceH16,
                recentAsync.when(
                  data: (items) => Column(
                    children: items
                        .map((item) => Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: colorLightPastelGreen,
                                    child: Text(
                                      '${item.id}',
                                      style:
                                          AppTextStyle.interMediumText.copyWith(
                                        fontSize: Dimens.d12.sp,
                                        color: colorBlack,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    item.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyle.interBoldText.copyWith(
                                      fontSize: Dimens.d16.sp,
                                    ),
                                  ),
                                  subtitle:
                                      Text(dateFmt.format(item.updatedAt)),
                                  trailing: StatusPill(status: item.status),
                                  onTap: () => context.goNamed(
                                    RoutesName.treeDetail.name,
                                    pathParameters: {'id': item.id.toString()},
                                    extra: item,
                                  ),
                                ),
                              ],
                            ))
                        .toList(),
                  ),
                  loading: () => Padding(
                    padding: EdgeInsets.symmetric(vertical: Dimens.d24.h),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Padding(
                    padding: EdgeInsets.symmetric(vertical: Dimens.d8.h),
                    child: Text(e.toString()),
                  ),
                ),
                spaceH8,
                InkWell(
                  onTap: latestAsync.maybeWhen(
                    data: (latest) {
                      if (latest == null) return null;
                      return () => context.goNamed(
                            RoutesName.treeDetail.name,
                            pathParameters: {'id': latest.id.toString()},
                            extra: latest,
                          );
                    },
                    orElse: () => null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Full Tree List',
                        style: AppTextStyle.interBoldText.copyWith(
                          color: colorBlue,
                          decoration: TextDecoration.underline,
                          decorationColor: colorBlue,
                        ),
                      ),
                      spaceW6,
                      Icon(
                        Icons.arrow_right_alt,
                        size: Dimens.d18.sp,
                        color: colorBlue,
                      ),
                    ],
                  ),
                ),
                spaceH16,
                const Divider(height: 1),
                spaceH24,
                Text(
                  'Your Planting Groups',
                  style: AppTextStyle.interMediumText
                      .copyWith(fontSize: Dimens.d18.sp),
                ),
                spaceH16,
                SizedBox(
                  height: Dimens.d230.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    padding: EdgeInsets.zero,
                    separatorBuilder: (_, __) => SizedBox(width: Dimens.d10.w),
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        width: Dimens.d259.w,
                        decoration: BoxDecoration(
                          border: Border.all(color: colorDarkGray),
                          borderRadius: BorderRadius.circular(Dimens.d16.r),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(Dimens.d16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Women in the Wild',
                                    style:
                                        AppTextStyle.interMediumText.copyWith(
                                      fontSize: Dimens.d18.sp,
                                    ),
                                  ),
                                  // Assets.icons.icLo.svg(),
                                ],
                              ),
                              Text(
                                'Nairobi, Kenya',
                                style: AppTextStyle.interText
                                    .copyWith(fontSize: Dimens.d12.sp),
                              ),
                              spaceH16,
                              Row(
                                children: [
                                  Assets.icons.icGroups.svg(color: colorBlack),
                                  spaceW6,
                                  Text('876 members',
                                      style: AppTextStyle.interText),
                                ],
                              ),
                              spaceH6,
                              Row(
                                children: [
                                  Assets.icons.icTrees.svg(color: colorBlack),
                                  spaceW6,
                                  Text('8,909 trees planted',
                                      style: AppTextStyle.interText),
                                ],
                              ),
                              spaceH26,
                              AppButton(
                                padding: EdgeInsets.symmetric(
                                    vertical: Dimens.d10.h),
                                width: double.infinity,
                                color: colorBlack,
                                border: Border.all(color: colorBlack),
                                borderRadius: Dimens.d33.r,
                                title: 'Join Group ->',
                                style: AppTextStyle.interMediumText.copyWith(
                                  fontSize: Dimens.d14.sp,
                                  color: colorWhite,
                                ),
                                onTap: () =>
                                    context.goNamed(RoutesName.group.name),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                spaceH24,
                AppButton(
                  width: double.infinity,
                  borderRadius: Dimens.d33.r,
                  color: colorBlue,
                  border: Border.all(color: colorBlue),
                  title: 'Join another Planting Group',
                  style: AppTextStyle.interMediumText.copyWith(
                    fontSize: Dimens.d16.sp,
                    color: colorWhite,
                  ),
                ),
                spaceH24,
                const Divider(height: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final TreeStatus status;
  const StatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    late final Color fg, bg;
    late final IconData icon;
    late final String label;

    switch (status) {
      case TreeStatus.verified:
        fg = const Color(0xFF16A34A);
        bg = const Color(0x3316A34A);
        icon = Icons.check_circle;
        label = 'Verified';
        break;
      case TreeStatus.pending:
        fg = const Color(0xFFF59E0B);
        bg = const Color(0x33F59E0B);
        icon = Icons.access_time;
        label = 'Pending';
        break;
      case TreeStatus.invalid:
        fg = const Color(0xFFEF4444);
        bg = const Color(0x33EF4444);
        icon = Icons.error_outline;
        label = 'Invalid';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12)
                .copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}
