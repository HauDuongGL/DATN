import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verify_clone/data/request/photo_request.dart';
import 'package:verify_clone/data/services/database_helper.dart';
import 'package:verify_clone/data/services/photo/photo_service.dart';
import 'package:verify_clone/utils/extensions/date_formay.dart';

final photoServiceProvider = Provider<PhotoService>((ref) {
  return PhotoService(DatabaseHelper.instance);
});

final latestPhotoByKindProvider = FutureProvider.autoDispose
    .family<PhotoRequest?, ({int treeId, String kind})>((ref, args) async {
  final svc = PhotoService(DatabaseHelper.instance);
  return svc.getLatestForTreeByKind(args.treeId, args.kind);
});

final dateFormatterProvider = Provider<DateFormatter>((ref) {
  return const DateFormatter();
});

typedef ItemRec = ({String title, String kind});
final itemsProvider = Provider<List<ItemRec>>((ref) => const [
      (title: 'Protected', kind: 'before'),
      (title: 'Protected', kind: 'after'),
    ]);
