import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verify_clone/data/services/database_helper.dart';
import 'package:verify_clone/data/services/tree/tree_service.dart';
import 'package:verify_clone/domain/entities/photo_model.dart';
import 'package:verify_clone/domain/entities/tree_model.dart';
import 'package:verify_clone/domain/entities/tree_state.dart';

final dbProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper.instance);

final treesServiceProvider = Provider<TreeService>(
  (ref) => TreeService(ref.read(dbProvider)),
);

final treeListProvider = StateNotifierProvider.autoDispose
    .family<TreeListNotifier, List<TreeModel>, int>((ref, userId) {
  final treeService = ref.read(treesServiceProvider);
  return TreeListNotifier(userId, treeService);
});

class TreeListNotifier extends StateNotifier<List<TreeModel>> {
  final int userId;
  final TreeService treeService;
  bool _isDisposed = false;

  TreeListNotifier(
    this.userId,
    this.treeService,
  ) : super([]) {
    _init();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _init() async {
    final drafts = await treeService.getDraftTreesByUserId(userId);
    if (_isDisposed) return;

    if (drafts.isEmpty) {
      final insertedId = await treeService.addTree(
        TreeModel(name: 'Tree 1', userId: userId, isDraft: true),
      );
      if (_isDisposed) return;
      final fresh = await treeService.getTreeById(insertedId);
      if (_isDisposed) return;
      state = [fresh];
    } else {
      state = drafts;
    }
  }

  Future<void> resetAndCreateFresh() async {
    final fresh = await treeService.createDraftTree(userId);
    if (_isDisposed) return;
    state = [fresh];
  }

  Future<void> addTree() async {
    if (state.length >= 10) return;
    final nextName = 'Tree ${state.length + 1}';
    final insertedId =
        await treeService.addTree(TreeModel(name: nextName, userId: userId));
    final newTree = await treeService.getTreeById(insertedId);
    final updated = [...state, newTree];
    if (_isDisposed) return;
    state = updated;
  }

  Future<void> removeTree(int index) async {
    final tree = state[index];
    if (tree.treeId != null) {
      await treeService.deleteTree(tree.treeId!);
    }
    final updated = [...state]..removeAt(index);
    if (_isDisposed) return;
    state = updated;
  }

  Future<void> updateTree(int index, TreeModel updatedTree) async {
    if (updatedTree.treeId != null) {
      await treeService.updateTree(updatedTree);
    }
    final newList = [...state];
    newList[index] = updatedTree;
    if (_isDisposed) return;
    state = newList;
  }

  // NOTE: Nếu bạn đã chuyển sang bảng `photos`, hãy refactor 2 hàm dưới
  // để gọi repo/service liên quan tới `photos` thay vì update trực tiếp `trees`.
  Future<void> updatePhotoBefore(int treeId, String imagePath) async {
    await treeService.updatePhotoBefore(treeId, imagePath);
    final updatedList = await treeService.getTreesByUserId(userId);
    if (_isDisposed) return;
    state = updatedList;
  }

  Future<void> updatePhotoAfter(int treeId, String imagePath) async {
    await treeService.updatePhotoAfter(treeId, imagePath);
    final updatedList = await treeService.getTreesByUserId(userId);
    if (_isDisposed) return;
    state = updatedList;
  }

  Future<void> saveAllTrees(List<TreeModel> trees) async {
    for (final tree in trees) {
      if (tree.treeId != null) {
        await treeService.updateTree(tree);
      } else {
        await treeService.addTree(tree);
      }
    }
    final updatedList = await treeService.getTreesByUserId(userId);
    if (_isDisposed) return;
    state = updatedList;
  }
}

final treeValidationMapProvider =
    StateProvider<Map<int, TreeValidationState>>((ref) => {});

void onSubmitAllTrees(
  WidgetRef ref,
  List<TreeModel> treeList,
  Map<int, List<Photo>> photosByTree,
) {
  final validations = <int, TreeValidationState>{};
  for (final tree in treeList) {
    if (tree.treeId == null) continue;
    final p = photosByTree[tree.treeId!] ?? const <Photo>[];
    validations[tree.treeId!] = TreeValidationState.fromTree(tree, p);
  }
  ref.read(treeValidationMapProvider.notifier).state = validations;
}
