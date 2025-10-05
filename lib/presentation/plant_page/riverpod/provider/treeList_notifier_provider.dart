import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verify_clone/data/services/tree/get_trees_by_userId.dart';
import 'package:verify_clone/data/services/tree/trees_service.dart';
import 'package:verify_clone/data/services/tree/update_photos.dart';
import 'package:verify_clone/domain/entities/photo_model.dart';
import 'package:verify_clone/domain/entities/tree_model.dart';
import 'package:verify_clone/domain/entities/tree_state.dart';

class TreeListNotifier extends StateNotifier<List<TreeModel>> {
  final int userId;
  final TreesCrud treesCrud;
  final UpdatePhotos updatePhotos;
  final GetTreesByUserid getTreesByUserid;
  final GetDraftTreesByUserid getDraftTreesByUserid;
  final GetByTreesId getByTreesId;
  final CreateDraftTrees createDraftTrees;
  bool _isDisposed = false;

  TreeListNotifier(
    this.userId,
    this.updatePhotos,
    this.getTreesByUserid,
    this.treesCrud,
    this.getDraftTreesByUserid,
    this.getByTreesId,
    this.createDraftTrees,
  ) : super([]) {
    _init();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _init() async {
    final drafts = await getDraftTreesByUserid.getDraftTreesByUserId(userId);
    if (_isDisposed) return;

    if (drafts.isEmpty) {
      final insertedId = await treesCrud.addTree(
        TreeModel(name: 'Tree 1', userId: userId, isDraft: true),
      );
      if (_isDisposed) return;
      final fresh = await getByTreesId.getTreeById(insertedId);
      if (_isDisposed) return;
      state = [fresh];
    } else {
      state = drafts;
    }
  }

  Future<void> resetAndCreateFresh() async {
    final fresh = await createDraftTrees.createDraftTree(userId);
    if (_isDisposed) return;
    state = [fresh];
  }

  Future<void> addTree() async {
    if (state.length >= 10) return;
    final nextName = 'Tree ${state.length + 1}';
    final insertedId =
        await treesCrud.addTree(TreeModel(name: nextName, userId: userId));
    final newTree = await getByTreesId.getTreeById(insertedId);
    final updated = [...state, newTree];
    if (_isDisposed) return;
    state = updated;
  }

  Future<void> removeTree(int index) async {
    final tree = state[index];
    if (tree.treeId != null) {
      await treesCrud.deleteTree(tree.treeId!);
    }
    final updated = [...state]..removeAt(index);
    if (_isDisposed) return;
    state = updated;
  }

  Future<void> updateTree(int index, TreeModel updatedTree) async {
    if (updatedTree.treeId != null) {
      await treesCrud.updateTree(updatedTree);
    }
    final newList = [...state];
    newList[index] = updatedTree;
    if (_isDisposed) return;
    state = newList;
  }

  Future<void> updatePhotoBefore(int treeId, String imagePath) async {
    await updatePhotos.updatePhotoBefore(treeId, imagePath);
    final updatedList = await getTreesByUserid.getTreesByUserId(userId);
    if (_isDisposed) return;
    state = updatedList;
  }

  Future<void> updatePhotoAfter(int treeId, String imagePath) async {
    await updatePhotos.updatePhotoAfter(treeId, imagePath);
    final updatedList = await getTreesByUserid.getTreesByUserId(userId);
    if (_isDisposed) return;
    state = updatedList;
  }

  Future<void> saveAllTrees(List<TreeModel> trees) async {
    for (final tree in trees) {
      if (tree.treeId != null) {
        await treesCrud.updateTree(tree);
      } else {
        await treesCrud.addTree(tree);
      }
    }
    final updatedList = await getTreesByUserid.getTreesByUserId(userId);
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
