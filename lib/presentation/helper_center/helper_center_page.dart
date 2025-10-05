import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:verify_clone/core/base/base_helpcenter_scafold.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/core/config/router/router_name.dart';
import 'package:verify_clone/presentation/helper_center/enum/enumQuestion.dart';
import 'package:verify_clone/utils/style_utils.dart';

class HelperCenterPage extends StatelessWidget {
  const HelperCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppHelpcenterScafold(
      drawer: Drawer(
        width: double.infinity,
        child: ListView(
          children: const [
            ListTile(
              title: Text('data'),
            )
          ],
        ),
      ),
      backgroundColor: colorBlue,
      customBackAction: () => context.goNamed(RoutesName.home.name),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.d20.w,
          vertical: Dimens.d34.w,
        ),
        child: ListView.builder(
          itemCount: Enumquestion.values.length,
          itemBuilder: (context, index) {
            final page = Enumquestion.values[index];
            return Padding(
              padding: EdgeInsets.only(bottom: Dimens.d16.h),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colorLightGray),
                  borderRadius: BorderRadius.circular(
                    Dimens.d16.r,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.d16.w,
                    vertical: Dimens.d16.h,
                  ),
                  child: Row(
                    children: [
                      page.image.svg(),
                      spaceW16,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              page.titleQuestion,
                              style: AppTextStyle.interMediumText.copyWith(
                                fontSize: Dimens.d18.sp,
                              ),
                            ),
                            spaceH10,
                            Text(
                              page.subTitle,
                              softWrap: true,
                              overflow: TextOverflow.clip,
                              style: AppTextStyle.interText.copyWith(
                                fontSize: Dimens.d12.sp,
                              ),
                            ),
                            spaceH11,
                            GestureDetector(
                              onTap: () => print('ok'),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    page.titleBtn,
                                    style:
                                        AppTextStyle.interMediumText.copyWith(
                                      fontSize: Dimens.d14.sp,
                                      color: colorBlue,
                                    ),
                                  ),
                                  spaceW2,
                                  const Icon(
                                    CupertinoIcons.arrow_right,
                                    size: Dimens.d16,
                                    color: colorBlue,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
