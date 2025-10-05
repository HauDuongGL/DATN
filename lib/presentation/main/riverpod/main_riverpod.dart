// main_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verify_clone/presentation/main/common/enum.dart';
import 'package:verify_clone/presentation/main/common/enum_drawer.dart';

class MainState {
  final PageType currentPageType;

  MainState({this.currentPageType = PageType.home});

  MainState copyWith({PageType? currentPageType}) {
    return MainState(currentPageType: currentPageType ?? this.currentPageType);
  }
}

class MainNotifier extends StateNotifier<MainState> {
  MainNotifier() : super(MainState());

  void changePage(PageType page) {
    state = state.copyWith(currentPageType: page);
  }
}

final mainProvider = StateNotifierProvider<MainNotifier, MainState>((ref) {
  return MainNotifier();
});

final drawerOpenProvider = StateProvider<bool>((ref) => false);

final drawerPageProvider =
    StateNotifierProvider<DrawerPageNotifier, EnumDrawer>(
  (ref) => DrawerPageNotifier(),
);

class DrawerPageNotifier extends StateNotifier<EnumDrawer> {
  DrawerPageNotifier() : super(EnumDrawer.myTrees);

  void setPage(EnumDrawer page) {
    if (page != state) {
      state = page;
    }
  }
}
