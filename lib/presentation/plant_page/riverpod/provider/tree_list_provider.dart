import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verify_clone/data/services/database_helper.dart';
import 'package:verify_clone/data/services/tree/get_trees_by_userId.dart';
import 'package:verify_clone/data/services/tree/mark_all_drafts_submitted.dart';
import 'package:verify_clone/data/services/tree/trees_service.dart';
import 'package:verify_clone/data/services/tree/update_photos.dart';
import 'package:verify_clone/domain/entities/tree_model.dart';

import 'package:verify_clone/presentation/plant_page/riverpod/provider/treeList_notifier_provider.dart';

final dbProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper.instance);

final treesCrudProvider = Provider<TreesCrud>(
  (ref) => TreesCrud(ref.read(dbProvider)),
);
final updatePhotosPd = Provider<UpdatePhotos>(
  (ref) => UpdatePhotos(ref.read(dbProvider)),
);

final getTreesByUserid = Provider<GetTreesByUserid>(
  (ref) => GetTreesByUserid(ref.read(dbProvider)),
);

final getDraftTreesByUserIdProvider = Provider<GetDraftTreesByUserid>(
  (ref) => GetDraftTreesByUserid(ref.read(dbProvider)),
);

final getByTreesIdProvider = Provider<GetByTreesId>(
  (ref) => GetByTreesId(ref.read(dbProvider)),
);

final createDraftTreesProvider = Provider<CreateDraftTrees>(
  (ref) => CreateDraftTrees(ref.read(dbProvider)),
);

final markAllDraftsSubmittedProvider = Provider<MarkAllDraftsSubmitted>(
  (ref) => MarkAllDraftsSubmitted(ref.read(dbProvider)),
);

final treeListProvider = StateNotifierProvider.autoDispose
    .family<TreeListNotifier, List<TreeModel>, int>((ref, userId) {
  final treesCrud = ref.read(treesCrudProvider);
  final updatePhotos = ref.read(updatePhotosPd);
  final getTreesByUser = ref.read(getTreesByUserid);
  final getDraftTreesByUserId = ref.read(getDraftTreesByUserIdProvider);
  final getByTrees = ref.read(getByTreesIdProvider);
  final createDraftTrees = ref.read(createDraftTreesProvider);
  return TreeListNotifier(
    userId,
    updatePhotos,
    getTreesByUser,
    treesCrud,
    getDraftTreesByUserId,
    getByTrees,
    createDraftTrees,
  );
});
