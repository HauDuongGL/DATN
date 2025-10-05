import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/core/config/theme/app_theme.dart';

class TextFormFieldCommon extends StatelessWidget {
  final BorderSide? borderSide;
  final BorderRadius? borderRadius;
  final String? labelText;
  final String? counterText;
  final TextStyle? labelStyle;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextEditingController controller;
  final bool isPassword;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  final TextAlign? textAlign;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;

  final int? maxLines;
  final int? minLines;
  final int? maxLength;

  const TextFormFieldCommon({
    super.key,
    this.labelStyle,
    this.borderSide,
    this.borderRadius,
    this.labelText,
    this.counterText,
    this.isPassword = false,
    this.hintStyle,
    this.suffixIcon,
    this.maxLength,
    this.textAlign,
    this.keyboardType,
    required this.hintText,
    required this.controller,
    this.onChanged,
    this.validator,
    this.maxLines,
    this.minLines,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: true,
      keyboardType: keyboardType,
      onChanged: onChanged,
      textAlign: textAlign ?? TextAlign.start,
      validator: validator,
      controller: controller,
      maxLines: isPassword ? 1 : maxLines,
      minLines: isPassword ? 1 : minLines,
      maxLength: maxLength,
      obscureText: isPassword,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          borderSide: borderSide ??
              const BorderSide(
                color: colorBlue,
              ),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(33)),
          borderSide: BorderSide(color: colorFail, width: 1),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(33)),
          borderSide: BorderSide(color: colorFail, width: 1),
        ),
        errorStyle: TextStyle(
          color: Colors.redAccent,
          fontSize: 13.sp,
          height: 1.3,
        ),
        counterText: counterText,
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          borderSide: borderSide ??
              const BorderSide(
                color: colorBlue,
              ),
        ),
        labelText: labelText,
        labelStyle: labelStyle,
        hintText: hintText,
        hintStyle: hintStyle ??
            AppTextStyle.interText.copyWith(
              color: AppTheme.getInstance().grey51Color,
            ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
