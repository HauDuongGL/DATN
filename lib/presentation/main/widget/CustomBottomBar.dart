import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/theme/app_theme.dart';
import 'package:verify_clone/presentation/main/common/enum.dart';
import 'package:verify_clone/utils/extensions/color_ext.dart';
import 'package:verify_clone/utils/style_utils.dart';

class CustomBottomBar extends ConsumerWidget {
  final PageType currentPage;
  final void Function(PageType) onPageSelected;

  const CustomBottomBar({
    super.key,
    required this.currentPage,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: Dimens.d79.h,
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.d8.w,
      ),
      decoration: const BoxDecoration(
        color: colorWhite,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: PageType.values.asMap().entries.map((entry) {
                final i = entry.key;
                final page = entry.value;

                if (i == 2) return spaceW70;

                return _buildNavItem(page, currentPage, onPageSelected);
              }).toList(),
            ),
          ),
          Positioned(
            bottom: Dimens.d8.h,
            child: GestureDetector(
              onTap: () => onPageSelected(
                PageType.values[2],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorDarkOliveGreen,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: Dimens.d6.r,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Dimens.d15),
                  child: Center(
                    child: PageType.values[2].svgGenImage.svg(
                      colorFilter: colorWhite.toColorFilter,
                      width: Dimens.d26.w,
                      height: Dimens.d26.h,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      PageType page, PageType current, void Function(PageType) onTap) {
    final isSelected = page == current;
    final theme = AppTheme.getInstance();

    return GestureDetector(
      onTap: () => onTap(page),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          page.svgGenImage.svg(
            width: 24,
            height: 24,
            colorFilter: isSelected ? null : theme.barrierColor.toColorFilter,
          ),
        ],
      ),
    );
  }
}
