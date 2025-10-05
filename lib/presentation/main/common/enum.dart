import 'package:verify_clone/gen/assets.gen.dart';

enum PageType {
  home(0),
  trees(1),
  plant(2),
  seedlings(3),
  achievements(4);

  final int pageIndex;
  const PageType(this.pageIndex);

  static getPageFromIndex(int index) {
    try {
      return PageType.values.firstWhere(
        (element) => element.pageIndex == index,
      );
    } catch (_) {
      return PageType.home;
    }
  }
}

extension PageTypeExtension on PageType {
  SvgGenImage get svgGenImage {
    switch (this) {
      case PageType.home:
        return Assets.icons.icHome;
      case PageType.trees:
        return Assets.icons.icTrees;
      case PageType.plant:
        return Assets.icons.icPlant;
      case PageType.seedlings:
        return Assets.icons.icSeedlings;
      case PageType.achievements:
        return Assets.icons.icAchievements;
    }
  }
}
