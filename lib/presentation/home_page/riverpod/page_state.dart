import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:verify_clone/presentation/home_page/common/enumPage.dart';

part 'page_state.freezed.dart';

@freezed
class PageState with _$PageState {
  const factory PageState({
    required PageTypeBtn currentPage,
  }) = _PageState;

  factory PageState.initial() =>
      const PageState(currentPage: PageTypeBtn.getSeedlings);
}
