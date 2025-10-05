import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';

class ToggleSwitchCommon extends StatefulWidget {
  final List<String> labels;
  final Function(int) onToggle;
  final int initialIndex;
  final double width;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;
  final String? fontFamily;
  final TextStyle turnOnStyle;
  final TextStyle turnOffStyle;
  final Color? borderSideColor;
  final bool isBorder;

  ToggleSwitchCommon({
    super.key,
    required this.labels,
    required this.onToggle,
    this.initialIndex = 0,
    this.width = Dimens.d125,
    this.height = Dimens.d46,
    this.fontSize = Dimens.d14,
    this.fontWeight = FontWeight.w600,
    this.isBorder = true,
    TextStyle? turnOnStyle,
    TextStyle? turnOffStyle,
    this.fontFamily,
    this.borderSideColor,
  })  : turnOnStyle = turnOnStyle ?? AppTextStyle.boldText,
        turnOffStyle = turnOffStyle ?? AppTextStyle.boldText;

  @override
  State<ToggleSwitchCommon> createState() => _ToggleSwitchCommonState();
}

class _ToggleSwitchCommonState extends State<ToggleSwitchCommon> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final int count = widget.labels.length;
    final double itemWidth = widget.width / count;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.height / Dimens.d2),
        border: widget.isBorder
            ? Border.all(
                color: widget.borderSideColor ?? colorBorder,
                width: Dimens.d1.w)
            : null,
        color: Colors.transparent,
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            left: selectedIndex * itemWidth,
            top: 0,
            bottom: 0,
            child: Container(
              width: itemWidth - Dimens.d2,
              height: widget.height,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(widget.height / Dimens.d2),
              ),
            ),
          ),
          Row(
            children: List.generate(count, (index) {
              final isSelected = index == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                    widget.onToggle(index);
                  },
                  child: Center(
                    child: Text(
                      widget.labels[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[600],
                        fontSize: widget.fontSize,
                        decoration: TextDecoration.none,
                        fontFamily: widget.fontFamily,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
