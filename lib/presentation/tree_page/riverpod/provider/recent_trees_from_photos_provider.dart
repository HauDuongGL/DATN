import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verify_clone/data/services/database_helper.dart';
import 'package:verify_clone/data/services/tree/get_recent_trees_from_photos.dart';
import 'package:verify_clone/domain/entities/tree_items.dart';

final recentTreesFromPhotos = Provider<GetRecentTreesFromPhotos>(
  (ref) => GetRecentTreesFromPhotos(DatabaseHelper.instance),
);

final recentTreesFromPhotosProvider = FutureProvider<List<TreeItem>>(
  (ref) => ref.read(recentTreesFromPhotos).getRecentTreesFromPhotos(limit: 3),
);
