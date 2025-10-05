import 'package:verify_clone/core/config/router/router_name.dart';
import 'package:verify_clone/gen/assets.gen.dart';

enum PageTypeBtn {
  getSeedlings(0),
  plantTrees(1),
  protectTrees(2),
  groups(3);

  final int pageIndex;
  const PageTypeBtn(this.pageIndex);

  static getPageFromIndex(int index) {
    try {
      return PageTypeBtn.values.firstWhere(
        (element) => element.pageIndex == index,
      );
    } catch (_) {
      return PageTypeBtn.getSeedlings;
    }
  }
}

extension PageTypeExtension on PageTypeBtn {
  String get pageName {
    switch (this) {
      case PageTypeBtn.getSeedlings:
        return "Get Seedlings";
      case PageTypeBtn.plantTrees:
        return "Plant Trees";
      case PageTypeBtn.protectTrees:
        return "Protect Trees";
      case PageTypeBtn.groups:
        return "Groups";
    }
  }

  SvgGenImage get svgGenImage {
    switch (this) {
      case PageTypeBtn.getSeedlings:
        return Assets.icons.icGetSelling;
      case PageTypeBtn.plantTrees:
        return Assets.icons.icPlantTrees;
      case PageTypeBtn.protectTrees:
        return Assets.icons.icProtectTrees;
      case PageTypeBtn.groups:
        return Assets.icons.icGroups;
    }
  }

  String get goRouterPage {
    switch (this) {
      case PageTypeBtn.getSeedlings:
        return RoutesName.getSelling.name;
      case PageTypeBtn.plantTrees:
        return RoutesName.popUp.name;
      case PageTypeBtn.protectTrees:
        return RoutesName.protectTrees.name;
      case PageTypeBtn.groups:
        return RoutesName.group.name;
    }
  }
}
