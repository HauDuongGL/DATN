import 'package:verify_clone/data/services/database_helper.dart';
import 'package:verify_clone/domain/entities/model.dart';

class GetByTreesId {
  final DatabaseHelper dbHelper;
  GetByTreesId(this.dbHelper);

  Future<TreeModel> getTreeById(int id) async {
    final db = await dbHelper.db;
    final res =
        await db.query('trees', where: 'treeId = ?', whereArgs: [id], limit: 1);
    return TreeModel.fromMap(res.first);
  }
}
