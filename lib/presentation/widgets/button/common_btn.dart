import 'package:flutter/material.dart';
import 'package:verify_clone/core/config/resources/color.dart';

class CommonBtn extends StatelessWidget {
  final double? width;
  final VoidCallback? onPressed;
  final ButtonStyle? styleBtn;
  final TextStyle? textStyle;
  final String? text;
  const CommonBtn({
    super.key,
    this.width,
    this.onPressed,
    this.styleBtn,
    this.text,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: styleBtn ??
            ElevatedButton.styleFrom(
              backgroundColor: colorWhite,
              foregroundColor: colorBlue,
              side: const BorderSide(
                color: colorBlue,
              ),
            ),
        child: Text(
          text ?? "",
          style: textStyle,
        ),
      ),
    );
  }
}
