import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verify_clone/data/services/database_helper.dart';
import 'package:verify_clone/data/services/tree/get_latest_tree_from_photos.dart';

final existingTreesCount = Provider<GetLatestTreeFromPhotos>(
  (ref) => GetLatestTreeFromPhotos(DatabaseHelper.instance),
);

final existingTreesCountProvider = FutureProvider<int>(
  (ref) => ref.read(existingTreesCount).countExistingTrees(),
);
