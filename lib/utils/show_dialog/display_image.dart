import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/core/network/module.dart';

void showImageFullScreen({
  required String path,
  String? title,
  int? millis,
}) async {
  final context = getIt.get<GlobalKey<NavigatorState>>().currentContext;
  final t = title ?? '';
  final timeStr = (millis == null)
      ? ''
      : DateFormat('dd/MM/yy h:mma')
          .format(DateTime.fromMillisecondsSinceEpoch(millis));

  if (context != null && context.mounted) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: colorBlack,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogCtx, __, ___) {
        return GestureDetector(
          onTap: () => Navigator.of(dialogCtx).maybePop(),
          child: Scaffold(
            backgroundColor: colorBlack.withOpacity(0.95),
            body: SafeArea(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4,
                      child: path.startsWith('http')
                          ? Image.network(path, fit: BoxFit.cover)
                          : Image.file(File(path), fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.only(
                        left: Dimens.d20.w,
                        top: Dimens.d15.h,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colorBlack,
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (t.isNotEmpty)
                                Text(
                                  'Protected',
                                  style: AppTextStyle.interBoldText.copyWith(
                                    fontSize: Dimens.d24.sp,
                                    color: colorWhite,
                                  ),
                                ),
                              if (timeStr.isNotEmpty)
                                Text(
                                  timeStr,
                                  style: AppTextStyle.interMediumText.copyWith(
                                    fontSize: Dimens.d14.sp,
                                    color: colorWhite,
                                  ),
                                ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: colorWhite,
                            ),
                            onPressed: () => Navigator.of(dialogCtx).maybePop(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
