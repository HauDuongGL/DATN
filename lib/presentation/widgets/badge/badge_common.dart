import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';

class NotificationBell extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;
  final Color? colorIconBell;

  const NotificationBell({
    super.key,
    required this.count,
    this.onTap,
    this.colorIconBell,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            CupertinoIcons.bell,
            color: colorIconBell,
          ),
          onPressed: onTap,
        ),
        if (count > 0)
          Positioned(
            right: Dimens.d6.w,
            top: Dimens.d6.h,
            child: Container(
              padding: const EdgeInsets.all(Dimens.d4),
              decoration: const BoxDecoration(
                color: colorFail,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: Dimens.d18.w,
                minHeight: Dimens.d18.h,
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: TextStyle(
                    color: colorChip,
                    fontSize: Dimens.d10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
