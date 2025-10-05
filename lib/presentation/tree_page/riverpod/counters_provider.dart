import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verify_clone/data/services/database_helper.dart';
import 'package:verify_clone/data/services/tree/tree_service.dart';
import 'package:verify_clone/domain/entities/tree_items.dart';

final treeLocalServiceProvider = Provider<TreeService>(
  (ref) => TreeService(DatabaseHelper.instance),
);

final recentTreesFromPhotosProvider = FutureProvider<List<TreeItem>>(
  (ref) =>
      ref.read(treeLocalServiceProvider).getRecentTreesFromPhotos(limit: 3),
);

final latestTreeFromPhotosProvider = FutureProvider<TreeItem?>(
  (ref) => ref.read(treeLocalServiceProvider).getLatestTreeFromPhotos(),
);

final existingTreesCountProvider = FutureProvider<int>(
  (ref) => ref.read(treeLocalServiceProvider).countExistingTrees(),
);
final protectedTreesCountProvider = FutureProvider<int>(
  (ref) => ref.read(treeLocalServiceProvider).countProtectedTrees(),
);
