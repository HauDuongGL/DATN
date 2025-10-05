import 'package:verify_clone/data/services/database_helper.dart';
import 'package:verify_clone/domain/entities/tree_model.dart';

class TreesCrud {
  final DatabaseHelper dbHelper;
  TreesCrud(this.dbHelper);

  Future<int> addTree(TreeModel tree) async {
    final db = await dbHelper.db;
    return await db.insert('trees', tree.toMap()..remove('treeId'));
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
}
