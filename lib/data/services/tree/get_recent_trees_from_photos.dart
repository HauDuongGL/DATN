import 'package:verify_clone/data/services/database_helper.dart';
import 'package:verify_clone/domain/entities/tree_items.dart';

class GetRecentTreesFromPhotos {
  final DatabaseHelper dbHelper;
  GetRecentTreesFromPhotos(this.dbHelper);

  Future<List<TreeItem>> getRecentTreesFromPhotos({int limit = 3}) async {
    final db = await dbHelper.db;
    final rows = await db.rawQuery('''
      SELECT 
        CAST(p.tree_id AS INTEGER) AS treeId,
        MAX(p.taken_at) AS updatedAt,
        SUM(CASE WHEN p.kind = 'before' THEN 1 ELSE 0 END) AS beforeCount,
        SUM(CASE WHEN p.kind = 'after' THEN 1 ELSE 0 END)  AS afterCount,
        SUM(CASE WHEN p.kind = 'protected' THEN 1 ELSE 0 END) AS protectedCount
      FROM photos p
      GROUP BY p.tree_id
      ORDER BY updatedAt DESC
      LIMIT ?
    ''', [limit]);

    return rows.map((r) {
      final id = (r['treeId'] as int);
      final updated =
          (r['updatedAt'] as int?) ?? DateTime.now().millisecondsSinceEpoch;

      final afterCount = (r['afterCount'] as int?) ?? 0;
      final beforeCount = (r['beforeCount'] as int?) ?? 0;
      final status = afterCount > 0
          ? TreeStatus.pending
          : (beforeCount > 0 ? TreeStatus.verified : TreeStatus.verified);

      return TreeItem(
        id: id,
        name: 'Tree #$id',
        updatedAt: DateTime.fromMillisecondsSinceEpoch(updated),
        status: status,
      );
    }).toList();
  }
}
