import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/core/config/router/router_name.dart';
import 'package:verify_clone/presentation/tree_detail_screen/widgets/lastest_photo_card.dart';
import 'package:verify_clone/presentation/tree_page/riverpod/tree_riverpod.dart';
import 'package:verify_clone/presentation/view_all_tree_page/riverpod/reverpod_provider.dart';
import 'package:verify_clone/utils/show_dialog/display_image.dart';
import 'package:verify_clone/utils/style_utils.dart';

class ViewAllTreeScreen extends ConsumerWidget {
  final int treeId;
  final int? millis;
  const ViewAllTreeScreen({
    required this.treeId,
    this.millis,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatTime = ref.read(dateFormatterProvider);
    final time = formatTime.call;
    final latestAsync = ref.watch(latestTreeFromPhotosProvider);
    final items = ref.watch(itemsProvider);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: latestAsync.maybeWhen(
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
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: Dimens.d20.w,
                minHeight: Dimens.d20.h,
              ),
              visualDensity: const VisualDensity(
                horizontal: -4,
                vertical: -4,
              ),
              iconSize: Dimens.d14.sp,
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
              ),
            ),
            spaceW3,
            Text(
              'Back to Tree List',
              style: AppTextStyle.interMediumText.copyWith(
                fontSize: Dimens.d14.sp,
              ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cols =
              (constraints.maxWidth / Dimens.d500.w).floor().clamp(2, 6);

          return Padding(
            padding: const EdgeInsets.all(Dimens.d16),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: Dimens.d12,
                mainAxisSpacing: Dimens.d12,
                childAspectRatio: 6.5 / Dimens.d10,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                final asyncPhoto = ref.watch(
                  latestPhotoByKindProvider(
                    (
                      treeId: treeId,
                      kind: item.kind,
                    ),
                  ),
                );

                return asyncPhoto.when(
                  loading: () => LatestPhotoCard(
                    title: item.title,
                    takenMillis: null,
                    path: null,
                    fmt: time,
                  ),
                  error: (e, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: AppTextStyle.interMediumText),
                      spaceH8,
                      Text('Error: $e'),
                    ],
                  ),
                  data: (data) {
                    final path = data?.photo.path;
                    final millis = (data?.capturedAt ?? data?.photo.takenAt);

                    return GestureDetector(
                      onTap: (path == null || path.isEmpty)
                          ? null
                          : () => showImageFullScreen(
                                // context,
                                path: path,
                                title: item.title,
                                millis: millis,
                              ),
                      child: LatestPhotoCard(
                        boxBorder: Border.all(color: colorLightGray),
                        title: item.title,
                        takenMillis: millis,
                        path: path,
                        fmt: time,
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
