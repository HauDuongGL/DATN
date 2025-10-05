import 'package:verify_clone/data/services/database_helper.dart';

class CountProtectedTrees {
  final DatabaseHelper dbHelper;
  CountProtectedTrees(this.dbHelper);

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
