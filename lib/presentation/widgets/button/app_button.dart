import 'package:flutter/material.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/core/config/theme/app_theme.dart';

class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Widget? iconLeft;
  final Widget? iconRight;
  final TextStyle? style;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? color;
  final LinearGradient? gradient;
  final double? width;
  final bool? enabled;
  final Border? border;

  const AppButton({
    super.key,
    required this.title,
    this.onTap,
    this.borderRadius,
    this.padding,
    this.style,
    this.color,
    this.gradient,
    this.width,
    this.enabled,
    this.border,
    this.iconLeft,
    this.iconRight,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled == false ? null : onTap?.call,
      child: Container(
        width: width,
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
        decoration: BoxDecoration(
          color: enabled == false ? colorBrown : color,
          border: border ??
              Border.all(
                color: (color != null || gradient != null)
                    ? Colors.transparent
                    : AppTheme.getInstance().primaryColor,
              ),
          borderRadius: BorderRadius.circular(
            borderRadius ?? 8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconRight != null)
              Padding(
                padding: EdgeInsets.only(right: 4),
                child: iconRight!,
              ),
            Flexible(
              child: FittedBox(
                child: Text(
                  title,
                  style: style ??
                      AppTextStyle.boldText.copyWith(
                        color: AppTheme.getInstance().secondaryColor,
                        fontSize: 12,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            if (iconLeft != null)
              Padding(
                padding: EdgeInsets.only(left: 4),
                child: iconLeft!,
              ),
          ],
        ),
      ),
    );
  }
}
