import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:verify_clone/data/services/photo/photo_service.dart';
import 'package:verify_clone/domain/entities/photo_model.dart';
import 'package:verify_clone/presentation/plant_page/riverpod/provider/tree_list_provider.dart';

final photoServiceProvider = Provider<PhotoService>(
  (ref) => PhotoService(ref.read(dbProvider)),
);

Map<int, List<Photo>> _groupByTreeId(List<Photo> all) {
  final map = <int, List<Photo>>{};
  for (final p in all) {
    (map[p.treeId] ??= <Photo>[]).add(p);
  }
  return map;
}

final photosByTreeProvider = FutureProvider.autoDispose
    .family<Map<int, List<Photo>>, int>((ref, userId) async {
  final svc = ref.read(photoServiceProvider);
  final allPhotos = await svc.getAllPhotosByUserId(userId);
  return _groupByTreeId(allPhotos);
});
