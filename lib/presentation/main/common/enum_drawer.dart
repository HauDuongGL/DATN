import 'package:verify_clone/gen/assets.gen.dart';

enum EnumDrawer {
  myTrees,
  mitiPoints,
  settings,
  helpCentre,
  learningHub,
  logout,
  yourLanguage,
}

extension EnumDrawerExtension on EnumDrawer {
  String get name {
    switch (this) {
      case EnumDrawer.myTrees:
        return "My Trees";
      case EnumDrawer.mitiPoints:
        return "Miti Points";
      case EnumDrawer.settings:
        return "Settings";
      case EnumDrawer.helpCentre:
        return "Help Centre";
      case EnumDrawer.learningHub:
        return "Learning Hub";
      case EnumDrawer.logout:
        return "Logout";
      case EnumDrawer.yourLanguage:
        return "Your Language";
    }
  }

  String? get nameRouter {
    switch (this) {
      case EnumDrawer.myTrees:
        return "My Trees";
      case EnumDrawer.mitiPoints:
        return "Miti Points";
      case EnumDrawer.settings:
        return "Settings";
      case EnumDrawer.helpCentre:
        return "Help Centre";
      case EnumDrawer.learningHub:
        return "Learning Hub";
      case EnumDrawer.logout:
        return null;
      case EnumDrawer.yourLanguage:
        return null;
    }
  }

  SvgGenImage get svgGenIcons {
    switch (this) {
      case EnumDrawer.myTrees:
        return Assets.icons.icPlantTrees;
      case EnumDrawer.mitiPoints:
        return Assets.icons.icPoints;
      case EnumDrawer.settings:
        return Assets.icons.icSettings;
      case EnumDrawer.helpCentre:
        return Assets.icons.icHelp;
      case EnumDrawer.learningHub:
        return Assets.icons.icLearningHubCopy;
      case EnumDrawer.logout:
        return Assets.icons.icLogout;
      case EnumDrawer.yourLanguage:
        return Assets.icons.icLanguage;
    }
  }

  bool get hasDividerAbove =>
      this == EnumDrawer.settings || this == EnumDrawer.logout;
  bool get isLogout => this == EnumDrawer.logout;
}
