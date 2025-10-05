import 'package:verify_clone/data/services/database_helper.dart';
import 'package:verify_clone/data/services/tree/get_recent_trees_from_photos.dart';
import 'package:verify_clone/domain/entities/tree_items.dart';

class GetLatestTreeFromPhotos {
  final DatabaseHelper dbHelper;
  GetLatestTreeFromPhotos(this.dbHelper);

  Future<TreeItem?> getLatestTreeFromPhotos() async {
    final list = await GetRecentTreesFromPhotos(dbHelper)
        .getRecentTreesFromPhotos(limit: 1);
    return list.isNotEmpty ? list.first : null;
  }

  Future<int> countExistingTrees() async {
    final db = await dbHelper.db;
    final r =
        await db.rawQuery('SELECT COUNT(DISTINCT tree_id) AS c FROM photos');
    return (r.first['c'] as int?) ?? 0;
  }
}
