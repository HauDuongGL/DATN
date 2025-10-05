import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/gen/assets.gen.dart';
import 'package:verify_clone/gen/translations.g.dart';
import 'package:verify_clone/utils/style_utils.dart';

class StatusUser extends StatelessWidget {
  const StatusUser({
    super.key,
    required this.avatarUser,
    required this.userName,
    required this.coin,
  });

  final Widget avatarUser;
  final String userName;
  final int coin;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        avatarUser,
        spaceW8,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName,
              style: AppTextStyle.interMediumText,
            ),
            Row(
              children: [
                Assets.icons.icCoin.svg(),
                spaceW5,
                Text(
                  '$coin ${LocaleKeys.home_page_app_bar_sub_text_coin.tr()}',
                  style: AppTextStyle.interMediumText.copyWith(
                    fontSize: Dimens.d14.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
