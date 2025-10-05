import 'package:verify_clone/data/services/database_helper.dart';
import 'package:verify_clone/domain/entities/tree_model.dart';

class GetTreesByUserid {
  final DatabaseHelper dbHelper;
  GetTreesByUserid(this.dbHelper);

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
}
