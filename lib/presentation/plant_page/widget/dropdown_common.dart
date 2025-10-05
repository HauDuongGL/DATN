import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/utils/style_utils.dart';

class DropDownSearchCommon<T> extends StatelessWidget {
  const DropDownSearchCommon({
    super.key,
    required this.items,
    required this.itemAsString,
    this.selectedItem,
    this.onChanged,
    required this.itemBuilder,
    this.hintText = 'Type to search...',
    this.titleText = 'Select an item',
    this.errorText = '',
    this.filled = false,
    this.fillColor,
  });

  final List<T> items;
  final T? selectedItem;
  final ValueChanged<T?>? onChanged;
  final String Function(T) itemAsString;
  final Widget Function(BuildContext, T, bool) itemBuilder;
  final String hintText;
  final String? errorText;
  final String titleText;
  final bool filled;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: Dimens.d32.h,
        top: Dimens.d8.h,
      ),
      child: DropdownSearch<T>(
        items: items,
        selectedItem: selectedItem,
        itemAsString: itemAsString,
        onChanged: onChanged,
        compareFn: (a, b) => itemAsString(a) == itemAsString(b),
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            filled: filled,
            fillColor: fillColor,
            hintText: hintText,
            hintStyle: AppTextStyle.interText.copyWith(
              fontSize: Dimens.d16.sp,
            ),
            errorText: errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimens.d24.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimens.d24.r),
              borderSide: const BorderSide(color: colorBlue),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimens.d24.r),
              borderSide: const BorderSide(color: colorBlue),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimens.d24.r),
              borderSide: const BorderSide(color: errorColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimens.d24.r),
              borderSide: const BorderSide(color: errorColor),
            ),
          ),
        ),
        popupProps: PopupProps.bottomSheet(
          searchDelay: const Duration(milliseconds: 100),
          bottomSheetProps: BottomSheetProps(
            enableDrag: true,
            backgroundColor: colorWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(Dimens.d16.r),
              ),
            ),
          ),
          showSearchBox: true,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                spaceH12,
                Center(
                  child: Container(
                    height: Dimens.d2.h,
                    width: Dimens.d80.w,
                    color: colorDarkGrayBlue,
                  ),
                ),
                spaceH12,
                Text(
                  titleText,
                  style: AppTextStyle.interMediumText.copyWith(
                    fontSize: Dimens.d20.sp,
                  ),
                ),
              ],
            ),
          ),
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: 'Type to search...',
              prefixIcon: Icon(
                CupertinoIcons.search,
                color: colorDarkGrayBlue,
                size: Dimens.d18.sp,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Dimens.d24.r),
                borderSide: const BorderSide(color: colorBlue),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Dimens.d24.r),
                borderSide: const BorderSide(color: colorBlue),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Dimens.d24.r),
                borderSide: const BorderSide(color: colorBlue),
              ),
            ),
          ),
          itemBuilder: itemBuilder,
        ),
      ),
    );
  }
}
