import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verify_clone/data/services/database_helper.dart';
import 'package:verify_clone/data/services/tree/get_latest_tree_from_photos.dart';
import 'package:verify_clone/domain/entities/tree_items.dart';

final latestTreeFromPhotos = Provider<GetLatestTreeFromPhotos>(
  (ref) => GetLatestTreeFromPhotos(DatabaseHelper.instance),
);

final latestTreeFromPhotosProvider = FutureProvider<TreeItem?>(
  (ref) => ref.read(latestTreeFromPhotos).getLatestTreeFromPhotos(),
);
