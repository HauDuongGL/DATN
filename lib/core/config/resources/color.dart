import 'package:flutter/material.dart';

const colorPrimary = Color(0xffF17C9B);
const colorSnowGray = Color(0xffF6F6F6);
const colorLightPink = Color(0xffFCDDEC);
const colorMediumGray = Color(0xffAAAAAA);
const colorForm = Color(0xffE5F0F2);
const colorTextPrimary = Color(0xff2C2C2C);
const colorSecondary = Color(0xff9E9E9E);
const colorStroke = Color(0xff999999);
const colorComplete = Color(0xff0ACF97);
const colorPending = Color(0xffFAA500);
const colorLightOrange = Color(0xffFFDD99);
const colorFail = Color(0xffDE3138);
const colorHexadecimal = Color(0xffD1E59E);
const colorLeftLiner = Color(0xff2C9F78);
const colorRightLinear = Color(0xff00B67F);
const colorSystemLeft = Color(0xff2C9F78);
const colorSystemRight = Color(0xff00B67F);
const colorMediumHex = Color(0xffB9D175);
const colorDarkOliveGreen = Color(0xff4B6210);
const colorLightPastelGreen = Color(0xffE4F1C4);
const colorShadow6 = Color(0xff162731);
const colorShadow9 = Color(0xff162731);
const colorBorder = Color(0xffEDEDED);
const colorChip = Color(0xffF0F0F0);
const colorExchange = Color(0xff596E73);
const colorGrey88 = Color(0xffE0E0E0);
const colorGrey51 = Color(0xff828282);
const colorPastelPurple = Color(0xffEDEBFE);
const colorLightGray = Color(0xffE6E6E6);
const colorWhite = Color(0xffffffff);
const colorBlack = Color(0xff000000);
const colorRavenBlack = Color(0xff161921);
const colorEEEEEE = Color(0xffEEEEEE);
const colorBrown = Color(0xff993300);
const colorBlue = Color(0xff1D67F3);
const colorPure = Color(0xff3700FF);
const colorLightBlue = Color(0xffEEF7FF);
const colorBabyBlue = Color(0xffDAEBFF);
const colorDarkGray = Color(0xff565656);
const colorDarkGrayBlue = Color(0xff6B6F7B);
const colorDarkOlive = Color(0xff6B8715);
const colorNeutralGray = Color(0xffC4C4C4);
const colorExtraLightGray = Color(0xffEFEFEF);
const colorDarkNavy = Color(0xff262C3A);
const colorSuccessGreen = Color(0xff2AA42A);
const colorDisabled = Color(0xff9A9A9A);
const errorColor = Color(0xffDC362E);
const colorPastelPink = Color(0xFFFCEBEA);
const colorNeutralGray50 = Color(0xFFF9FAFB);
const primaryDarkGreen = Color(0xFF0B2C10);
const royalBlueDark = Color(0xFF193C8F);
const oliveGreen = Color(0xFF99AF4A);
const softMint = Color(0xFFEFFEF1);
const lushLeafGreen = Color(0xFF108526);

///=========== Using to make change app theme ================================
abstract class AppColor {
  Color get mediumGrayColor;
  Color get snowGrayColor;
  Color get grey88Color;
  Color get grey51Color;
  Color get lightPinkColor;
  Color get primaryColor;
  Color get formColor;
  Color get textPrimary;
  Color get textSecondary;
  Color get textStroke;
  Color get statusComplete;
  Color get statusPending;
  Color get statusFail;
  Color get shadow6;
  Color get shadow9;
  Color get secondaryColor;
  Color get dividerColor;
  Color get chipColor;
  Color get barrierColor;
  Color get exchangeColor;
  Color get hexadecimalcolor;
  List<Color> get linearhexadecimalcolor;
  List<Color> get linearOnboarding;
  List<Color> get linearToolbar;
  List<Color> get linearSystemWallet;
  List<Color> get linearButton;
}

class LightApp extends AppColor {
  @override
  Color get lightPinkColor {
    return colorLightPink;
  }

  @override
  Color get snowGrayColor {
    return colorSnowGray;
  }

  @override
  Color get mediumGrayColor {
    return colorMediumGray;
  }

  @override
  Color get grey88Color {
    return colorGrey88;
  }

  @override
  Color get grey51Color {
    return colorGrey51;
  }

  @override
  Color get primaryColor {
    return colorPrimary;
  }

  @override
  Color get hexadecimalcolor {
    return colorLightPink;
  }

  @override
  Color get formColor {
    return colorForm;
  }

  @override
  Color get statusComplete {
    return colorComplete;
  }

  @override
  Color get statusFail {
    return colorFail;
  }

  @override
  Color get statusPending {
    return colorPending;
  }

  @override
  Color get textPrimary {
    return colorTextPrimary;
  }

  @override
  Color get textSecondary {
    return colorSecondary;
  }

  @override
  List<Color> get linearOnboarding {
    return [colorForm, Colors.white];
  }

  @override
  List<Color> get linearToolbar => [
        colorLeftLiner.withOpacity(0.2),
        colorRightLinear.withOpacity(0.2),
      ];

  @override
  List<Color> get linearhexadecimalcolor => [
        colorHexadecimal.withOpacity(0.2),
        colorMediumHex.withOpacity(0.2),
      ];

  @override
  List<Color> get linearSystemWallet => [
        colorSystemLeft,
        colorSystemRight,
      ];
  @override
  List<Color> get linearButton => [
        colorPrimary,
        colorSecondary,
      ];

  @override
  Color get shadow6 => colorShadow6;

  @override
  Color get secondaryColor => Colors.white;

  @override
  Color get dividerColor => colorBorder;

  @override
  Color get chipColor => colorChip;

  @override
  Color get shadow9 => colorShadow9;

  @override
  Color get textStroke => colorStroke;

  @override
  Color get barrierColor => textSecondary.withOpacity(0.3);

  @override
  Color get exchangeColor => colorExchange;
}

class DarkApp extends AppColor {
  @override
  Color get lightPinkColor {
    return colorLightPink;
  }

  @override
  Color get snowGrayColor {
    return colorSnowGray;
  }

  @override
  Color get mediumGrayColor {
    return colorMediumGray;
  }

  @override
  Color get grey88Color {
    return colorGrey88;
  }

  @override
  Color get grey51Color {
    return colorGrey51;
  }

  @override
  Color get primaryColor {
    return colorPrimary;
  }

  @override
  Color get formColor {
    return colorForm;
  }

  @override
  Color get hexadecimalcolor {
    return colorLightPink;
  }

  @override
  Color get statusComplete {
    return colorComplete;
  }

  @override
  Color get statusFail {
    return colorFail;
  }

  @override
  Color get statusPending {
    return colorPending;
  }

  @override
  Color get textPrimary {
    return colorTextPrimary;
  }

  @override
  Color get textSecondary {
    return colorSecondary;
  }

  @override
  List<Color> get linearOnboarding {
    return [colorForm, Colors.white];
  }

  @override
  List<Color> get linearToolbar => [
        colorLeftLiner.withOpacity(0.2),
        colorRightLinear.withOpacity(0.2),
      ];

  @override
  List<Color> get linearhexadecimalcolor => [
        colorHexadecimal.withOpacity(0.2),
        colorMediumHex.withOpacity(0.2),
      ];

  @override
  List<Color> get linearSystemWallet => [
        colorSystemLeft,
        colorSystemRight,
      ];
  @override
  List<Color> get linearButton => [
        colorPrimary,
        colorSecondary,
      ];

  @override
  Color get shadow6 => colorShadow6;

  @override
  Color get secondaryColor => Colors.white;

  @override
  Color get dividerColor => colorBorder;

  @override
  Color get chipColor => colorChip;

  @override
  Color get shadow9 => colorShadow9;

  @override
  Color get textStroke => colorStroke;

  @override
  Color get barrierColor => textSecondary.withOpacity(0.3);

  @override
  Color get exchangeColor => colorExchange;
}

///============ End setup app theme ======================================
