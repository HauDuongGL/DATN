class RoutesName {
  static RoutesGen get login => const RoutesGen('login', 'login');
  static RoutesGen get main => const RoutesGen('main');
  static RoutesGen get popUp => const RoutesGen('popUp', 'popUp');

  // ---- main screen ---- //
  static RoutesGen get home => const RoutesGen('home', 'home');
  static RoutesGen get treeView => const RoutesGen('treeView', 'treeView');
  static RoutesGen get second => const RoutesGen('second', 'second');
  static RoutesGen get seedlingScreen =>
      const RoutesGen('seedlingScreen', 'seedlingScreen');
  static RoutesGen get achievements =>
      const RoutesGen('achievements', 'achievements');

  static RoutesGen get trees => const RoutesGen('trees', 'trees');
  static RoutesGen get plants => const RoutesGen('plants', 'plants');
  static RoutesGen get seedlings => const RoutesGen('seedlings', 'seedlings');
  static RoutesGen get camera => const RoutesGen('camera', 'camera');

  static RoutesGen get treeDetail =>
      const RoutesGen('treeDetail', 'treeDetail');

  static RoutesGen get getSelling =>
      const RoutesGen('getSelling', 'getSelling');
  static RoutesGen get plantTrees =>
      const RoutesGen('plantTrees', 'plantTrees');
  static RoutesGen get protectTrees =>
      const RoutesGen('protectTrees', 'protectTrees');
  static RoutesGen get group => const RoutesGen('group', 'group');
  static RoutesGen get helpCenter =>
      const RoutesGen('helpCenter', 'helpCenter');
  static RoutesGen get enableLocation =>
      const RoutesGen('enableLocation', 'enableLocation');

  static RoutesGen get leave => const RoutesGen('leave', 'leave');
  static RoutesGen get viewTree => const RoutesGen('viewTree', 'viewTree');
}

class RoutesGen {
  final String value;
  final String? pathValue;
  const RoutesGen(this.value, [this.pathValue]);

  String get name => value;
  String get path => '/${pathValue ?? value}';
}
