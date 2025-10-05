import 'package:verify_clone/data/services/database_helper.dart';

import '../../../domain/entities/model.dart';

class GetDraftTreesByUserid {
  final DatabaseHelper dbHelper;
  GetDraftTreesByUserid(this.dbHelper);

  Future<List<TreeModel>> getDraftTreesByUserId(int userId) async {
    final db = await dbHelper.db;
    final res = await db.query('trees',
        where: 'userId = ? AND isDraft = 1',
        whereArgs: [userId],
        orderBy: 'treeId ASC');
    return res.map((e) => TreeModel.fromMap(e)).toList();
  }
}
