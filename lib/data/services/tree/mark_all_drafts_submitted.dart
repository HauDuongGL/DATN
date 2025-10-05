import 'package:verify_clone/data/services/database_helper.dart';

class MarkAllDraftsSubmitted {
  final DatabaseHelper dbHelper;
  MarkAllDraftsSubmitted(this.dbHelper);

  Future<void> markAllDraftsSubmitted(int userId) async {
    final db = await dbHelper.db;
    await db.update('trees', {'isDraft': 0},
        where: 'userId = ? AND isDraft = 1', whereArgs: [userId]);
  }
}
