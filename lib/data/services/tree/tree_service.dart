import 'package:verify_clone/data/services/database_helper.dart';
import 'package:verify_clone/domain/entities/tree_items.dart';
import 'package:verify_clone/domain/entities/tree_model.dart';

class TreeService {
  final DatabaseHelper dbHelper;
  TreeService(this.dbHelper);

  Future<int> addTree(TreeModel tree) async {
    final db = await dbHelper.db;
    return await db.insert('trees', tree.toMap()..remove('treeId'));
  }

  Future<TreeModel> getTreeById(int id) async {
    final db = await dbHelper.db;
    final res =
        await db.query('trees', where: 'treeId = ?', whereArgs: [id], limit: 1);
    return TreeModel.fromMap(res.first);
  }

  Future<List<TreeModel>> getDraftTreesByUserId(int userId) async {
    final db = await dbHelper.db;
    final res = await db.query('trees',
        where: 'userId = ? AND isDraft = 1',
        whereArgs: [userId],
        orderBy: 'treeId ASC');
    return res.map((e) => TreeModel.fromMap(e)).toList();
  }

  Future<void> markAllDraftsSubmitted(int userId) async {
    final db = await dbHelper.db;
    await db.update('trees', {'isDraft': 0},
        where: 'userId = ? AND isDraft = 1', whereArgs: [userId]);
  }

  Future<TreeModel> createDraftTree(int userId) async {
    final insertedId = await addTree(TreeModel(name: 'Tree 1', userId: userId));
    return await getTreeById(insertedId);
  }

  Future<List<TreeModel>> getTreesByUserId(int userId) async {
    try {
      final db = await dbHelper.db;
      final maps = await db.query(
        'trees',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'treeId ASC',
      );
      return maps.map((e) => TreeModel.fromMap(e)).toList();
    } catch (e) {
      print('Error getTreesByUserId: $e');
      return [];
    }
  }

  Future<void> deleteTree(int treeId) async {
    final db = await dbHelper.db;
    await db.delete('trees', where: 'treeId = ?', whereArgs: [treeId]);
  }

  Future<void> updateTree(TreeModel tree) async {
    final db = await dbHelper.db;
    await db.update(
      'trees',
      tree.toMap(),
      where: 'treeId = ?',
      whereArgs: [tree.treeId],
    );
  }

  Future<void> updatePhotoBefore(int treeId, String imagePath) async {
    final db = await dbHelper.db;
    await db.update(
      'trees',
      {
        'photoBefore': imagePath,
        'photoBeforeTimer': DateTime.now().toIso8601String(),
      },
      where: 'treeId = ?',
      whereArgs: [treeId],
    );
  }

  Future<void> updatePhotoAfter(int treeId, String imagePath) async {
    final db = await dbHelper.db;
    await db.update(
      'trees',
      {
        'photoAfter': imagePath,
        'photoAfterTimer': DateTime.now().toIso8601String(),
      },
      where: 'treeId = ?',
      whereArgs: [treeId],
    );
  }

  Future<List<TreeItem>> getRecentTreesFromPhotos({int limit = 3}) async {
    final db = await dbHelper.db;
    final rows = await db.rawQuery('''
      SELECT 
        CAST(p.tree_id AS INTEGER) AS treeId,
        MAX(p.taken_at) AS updatedAt,
        -- đếm số ảnh theo kind để có thể suy ra status nếu cần
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
          ? TreeStatus.verified
          : (beforeCount > 0 ? TreeStatus.pending : TreeStatus.pending);

      return TreeItem(
        id: id,
        name: 'Tree #$id',
        updatedAt: DateTime.fromMillisecondsSinceEpoch(updated),
        status: status,
      );
    }).toList();
  }

  Future<TreeItem?> getLatestTreeFromPhotos() async {
    final list = await getRecentTreesFromPhotos(limit: 1);
    return list.isNotEmpty ? list.first : null;
  }

  Future<int> countExistingTrees() async {
    final db = await dbHelper.db;
    final r =
        await db.rawQuery('SELECT COUNT(DISTINCT tree_id) AS c FROM photos');
    return (r.first['c'] as int?) ?? 0;
  }

  Future<int> countProtectedTrees() async {
    final db = await dbHelper.db;
    final r = await db.rawQuery('''
      SELECT COUNT(*) AS c
      FROM (
        SELECT p.tree_id
        FROM photos p
        WHERE p.kind = 'protected'
        GROUP BY p.tree_id
      )
    ''');
    return (r.first['c'] as int?) ?? 0;
  }
}
