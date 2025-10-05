import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verify_clone/presentation/home_page/common/enumPage.dart';
import 'package:verify_clone/presentation/home_page/riverpod/page_state.dart';

class PageNotifier extends StateNotifier<PageState> {
  PageNotifier() : super(PageState.initial());

  void changePage(PageTypeBtn page) {
    if (state.currentPage == page) {
      state = state.copyWith(currentPage: page);
    }
  }
}

final pageNotifierProvider = StateNotifierProvider<PageNotifier, PageState>(
  (ref) => PageNotifier(),
);
