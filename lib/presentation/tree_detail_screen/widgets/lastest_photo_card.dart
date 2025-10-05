import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/utils/style_utils.dart';

class LatestPhotoCard extends StatelessWidget {
  final String title;
  final int? takenMillis;
  final String? path;
  final String Function(int?) fmt;
  final BoxBorder? boxBorder;

  const LatestPhotoCard({
    super.key,
    required this.title,
    required this.takenMillis,
    required this.path,
    required this.fmt,
    this.boxBorder,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        path != null && path!.isNotEmpty && File(path!).existsSync();

    return Container(
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(Dimens.d16.r),
        border: boxBorder ?? Border.all(color: colorBlue),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimens.d10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(CupertinoIcons.camera,
                  size: Dimens.d13.sp, color: colorBlue),
              spaceW6,
              Text(
                title,
                style: AppTextStyle.interMediumText
                    .copyWith(fontSize: Dimens.d14.sp),
              ),
            ]),
            Text(
              fmt(takenMillis),
              style: AppTextStyle.interText.copyWith(fontSize: Dimens.d12.sp),
            ),
            SizedBox(
              width: double.infinity,
              height: Dimens.d159.h,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimens.d8.r),
                child: hasPhoto
                    ? Image.file(File(path!), fit: BoxFit.cover)
                    : Container(
                        color: colorNeutralGray,
                        child: Center(
                          child: Text(
                            'No Photo Yet',
                            style: AppTextStyle.interText.copyWith(
                              fontSize: Dimens.d12.sp,
                              color: colorDisabled,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
