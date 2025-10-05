import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/core/config/router/router_name.dart';
import 'package:verify_clone/data/request/photo_request.dart';
import 'package:verify_clone/data/services/database_helper.dart';
import 'package:verify_clone/data/services/photo/photo_service.dart';
import 'package:verify_clone/domain/entities/tree_items.dart';
import 'package:verify_clone/gen/assets.gen.dart';
import 'package:verify_clone/presentation/tree_detail_screen/widgets/lastest_photo_card.dart';
// import 'package:verify_clone/presentation/tree_page/riverpod/counters_provider.dart';
import 'package:verify_clone/presentation/widgets/button/app_button.dart';
import 'package:verify_clone/utils/style_utils.dart';

class TreeDetailScreen extends ConsumerWidget {
  final int treeId;
  final TreeItem? item;

  PhotoService get _photoSvc => PhotoService(DatabaseHelper.instance);

  const TreeDetailScreen({
    super.key,
    required this.treeId,
    this.item,
  });

  String _fmt(int? millis) {
    if (millis == null) return '—';
    final dt = DateTime.fromMillisecondsSinceEpoch(millis);
    return DateFormat('dd/MM/yy h:mma').format(dt);
  }

  Future<void> _openMaps(double lat, double lng) async {
    if (Platform.isAndroid) {
      final geo = Uri.parse('geo:$lat,$lng?z=18&q=$lat,$lng(Tree)');
      if (await canLaunchUrl(geo)) {
        await launchUrl(geo, mode: LaunchMode.externalApplication);
        return;
      }
    }
    final web = Uri.parse(
        'https://www.google.com/maps/@?api=1&map_action=map&center=$lat,$lng&zoom=18');
    await launchUrl(web, mode: LaunchMode.externalApplication);
  }

  Future<({int? prev, int? next})> _neighborIds(int currentId) async {
    final db = await DatabaseHelper.instance.db;

    final prevRows = await db.rawQuery(
      'SELECT treeId AS id FROM trees WHERE treeId > ? ORDER BY treeId ASC LIMIT 1',
      [currentId],
    );

    final nextRows = await db.rawQuery(
      'SELECT treeId AS id FROM trees WHERE treeId < ? ORDER BY treeId DESC LIMIT 1',
      [currentId],
    );

    final int? prev =
        prevRows.isNotEmpty ? (prevRows.first['id'] as num).toInt() : null;
    final int? next =
        nextRows.isNotEmpty ? (nextRows.first['id'] as num).toInt() : null;

    return (prev: prev, next: next);
  }

  void _goToTree(BuildContext context, int id) {
    context.goNamed(
      RoutesName.treeDetail.name,
      pathParameters: {'id': id.toString()},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayName = item?.name ?? 'Tree #$treeId';
    final status = item?.status;
    final updatedAt = item?.updatedAt;
    final dateStr =
        updatedAt != null ? DateFormat('dd/MM/yy').format(updatedAt) : '—';
    final timeStr =
        updatedAt != null ? DateFormat('hh:mm a').format(updatedAt) : '—';
    // final latestAsync = ref.watch(latestTreeFromPhotosProvider);
    final futureBefore = _photoSvc.getLatestForTreeByKind(treeId, 'before');
    final futureAfter = _photoSvc.getLatestForTreeByKind(treeId, 'after');
    final futureLatLng = _photoSvc.getLatestLatLngForTree(treeId);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => context.pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              iconSize: 14,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            const SizedBox(width: 3),
            Text(
              'Back to Tree List',
              style: AppTextStyle.interMediumText
                  .copyWith(fontSize: Dimens.d14.sp),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: Dimens.d20.w),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(height: Dimens.d1.h),
              spaceH24,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Assets.icons.icTrees.svg(color: primaryDarkGreen),
                  spaceW8,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: AppTextStyle.interMediumText
                              .copyWith(fontSize: Dimens.d18.sp),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Tecoma stan',
                          style: AppTextStyle.interText.copyWith(
                            fontSize: Dimens.d14.sp,
                            color: colorDarkGrayBlue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              spaceH24,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Logged on: ',
                                style: AppTextStyle.interMediumText.copyWith(
                                  fontSize: Dimens.d14.sp,
                                  color: colorBlack,
                                ),
                              ),
                              TextSpan(
                                text: dateStr,
                                style: AppTextStyle.interMediumText
                                    .copyWith(fontSize: Dimens.d14.sp),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Tree Age: ',
                                style: AppTextStyle.interMediumText.copyWith(
                                  fontSize: Dimens.d14.sp,
                                  color: colorBlack,
                                ),
                              ),
                              TextSpan(
                                text: timeStr,
                                style: AppTextStyle.interMediumText
                                    .copyWith(fontSize: Dimens.d14.sp),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Next Protection Date: ',
                                style: AppTextStyle.interMediumText.copyWith(
                                  fontSize: Dimens.d14.sp,
                                  color: colorBlack,
                                ),
                              ),
                              TextSpan(
                                text: '12/01/23',
                                style: AppTextStyle.interMediumText
                                    .copyWith(fontSize: Dimens.d14.sp),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        spaceH8,
                        if (status != null)
                          StatusPill(status: status)
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _TreeNoPill(no: '$treeId'),
                ],
              ),
              spaceH24,
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimens.d16.r),
                  border: Border.all(color: colorBlue),
                  color: colorLightBlue,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: Dimens.d10.w, vertical: Dimens.d12.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Assets.icons.icProtectPlant.svg(),
                      spaceW8,
                      Text(
                        'Protect this seedling from being\ntrampled or eaten while it’s still growing',
                        style: AppTextStyle.interMediumText
                            .copyWith(fontSize: Dimens.d14.sp),
                      )
                    ],
                  ),
                ),
              ),
              spaceH24,
              Divider(height: Dimens.d1.h),
              spaceH24,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Latest Images',
                    style: AppTextStyle.interMediumText
                        .copyWith(fontSize: Dimens.d18.sp),
                  ),
                  TextButton(
                    onPressed: () => context.goNamed(
                      RoutesName.viewTree.name,
                      pathParameters: {'id': treeId.toString()},
                    ),
                    child: Text(
                      'View all',
                      style: AppTextStyle.interMediumText.copyWith(
                        fontSize: Dimens.d14.sp,
                        decoration: TextDecoration.underline,
                        color: colorBlue,
                        decorationColor: colorBlue,
                      ),
                    ),
                  )
                ],
              ),
              spaceH24,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FutureBuilder<PhotoRequest?>(
                      future: futureBefore,
                      builder: (context, snap) {
                        final data = snap.data;
                        return LatestPhotoCard(
                          title: 'Area',
                          takenMillis:
                              (data?.capturedAt ?? data?.photo.takenAt),
                          path: data?.photo.path,
                          fmt: _fmt,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FutureBuilder<PhotoRequest?>(
                      future: futureAfter,
                      builder: (context, snap) {
                        final data = snap.data;
                        return LatestPhotoCard(
                          title: 'After',
                          takenMillis:
                              (data?.capturedAt ?? data?.photo.takenAt),
                          path: data?.photo.path,
                          fmt: _fmt,
                        );
                      },
                    ),
                  ),
                ],
              ),
              spaceH24,
              Text(
                'Location',
                style: AppTextStyle.interMediumText
                    .copyWith(fontSize: Dimens.d18.sp),
              ),
              spaceH24,
              FutureBuilder<(double, double)?>(
                future: futureLatLng,
                builder: (context, snap) {
                  final latLng = snap.data;
                  final borderColor = colorBlue.withOpacity(0.45);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(Dimens.d16.r),
                        onTap: latLng == null
                            ? null
                            : () => _openMaps(latLng.$1, latLng.$2),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimens.d16.r),
                            border: Border.all(color: borderColor, width: 1.5),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: (latLng == null)
                                ? Container(
                                    color: Colors.blueGrey[50],
                                    child: const Center(
                                      child: Icon(Icons.map_outlined, size: 40),
                                    ),
                                  )
                                : Stack(
                                    children: [
                                      IgnorePointer(
                                        child: MapWidget(
                                          styleUri: MapboxStyles.LIGHT,
                                          cameraOptions: CameraOptions(
                                            center: Point(
                                              coordinates: Position(
                                                  latLng.$2, latLng.$1),
                                            ),
                                            zoom: 16.0,
                                          ),
                                          onMapCreated: (mapboxMap) {
                                            mapboxMap.gestures.updateSettings(
                                              GesturesSettings(
                                                scrollEnabled: false,
                                                pinchPanEnabled: false,
                                                rotateEnabled: false,
                                                pinchToZoomEnabled: false,
                                                pitchEnabled: false,
                                                quickZoomEnabled: false,
                                                doubleTapToZoomInEnabled: false,
                                                doubleTouchToZoomOutEnabled:
                                                    false,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          child: Assets.icons.icLocation.svg(),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: Dimens.d12.h),
                      AppButton(
                        width: double.infinity,
                        borderRadius: Dimens.d33.r,
                        title: 'View on Google Maps',
                        iconLeft: const Icon(Icons.open_in_new_rounded,
                            size: 18, color: Colors.white),
                        style: AppTextStyle.interMediumText.copyWith(
                          fontSize: Dimens.d14.sp,
                          color: colorWhite,
                        ),
                        color: colorBlue,
                        onTap: latLng == null
                            ? null
                            : () => _openMaps(latLng.$1, latLng.$2),
                      ),
                    ],
                  );
                },
              ),
              spaceH24,
              FutureBuilder<({int? prev, int? next})>(
                future: _neighborIds(treeId),
                builder: (context, snap) {
                  final prevId = snap.data?.prev;
                  final nextId = snap.data?.next;

                  final prevDisabled = prevId == null;
                  final nextDisabled = nextId == null;

                  final prevColor = prevDisabled ? colorDisabled : colorBlue;
                  final nextColor = nextDisabled ? colorDisabled : colorBlue;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Opacity(
                        opacity: prevDisabled ? 0.5 : 1.0,
                        child: AbsorbPointer(
                          absorbing: prevDisabled,
                          child: AppButton(
                            padding: EdgeInsets.symmetric(
                                horizontal: Dimens.d22.w,
                                vertical: Dimens.d10.h),
                            borderRadius: Dimens.d33.r,
                            title: '← Previous Tree',
                            style: AppTextStyle.interMediumText.copyWith(
                              fontSize: Dimens.d14.sp,
                              color: prevColor,
                            ),
                            border: Border.all(color: prevColor),
                            onTap: prevDisabled
                                ? null
                                : () => _goToTree(context, prevId),
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: nextDisabled ? 0.5 : 1.0,
                        child: AbsorbPointer(
                          absorbing: nextDisabled,
                          child: AppButton(
                            padding: EdgeInsets.symmetric(
                                horizontal: Dimens.d35.w,
                                vertical: Dimens.d10.h),
                            borderRadius: Dimens.d33.r,
                            title: 'Next Tree →',
                            style: AppTextStyle.interMediumText.copyWith(
                              fontSize: Dimens.d14.sp,
                              color: nextColor,
                            ),
                            border: Border.all(color: nextColor),
                            onTap: nextDisabled
                                ? null
                                : () => _goToTree(context, nextId),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              spaceH44,
            ],
          ),
        ],
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
        fg = lushLeafGreen;
        bg = softMint;
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
          Text(label,
              style: TextStyle(
                  color: fg, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}

class _TreeNoPill extends StatelessWidget {
  final String no;
  const _TreeNoPill({required this.no});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          const Text('Tree No.',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          Text(no,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class InfoLine extends StatelessWidget {
  final String label, value;
  const InfoLine({
    super.key,
    required this.label,
    required this.value,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class NotePill extends StatelessWidget {
  final String text;
  const NotePill({
    super.key,
    required this.text,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: const TextStyle(color: Colors.blue)),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});
  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));
  }
}

class ImageRow extends StatelessWidget {
  final List<String> images;
  const ImageRow({
    super.key,
    required this.images,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(images[i],
              width: 160, height: 110, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class CardImage extends StatelessWidget {
  final String title, subtitle, url;
  const CardImage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.url,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(url,
              height: 160, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
            ]),
          )
        ],
      ),
    );
  }
}
