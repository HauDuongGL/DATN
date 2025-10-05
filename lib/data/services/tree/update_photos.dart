import 'package:verify_clone/data/services/database_helper.dart';

class UpdatePhotos {
  final DatabaseHelper dbHelper;
  UpdatePhotos(this.dbHelper);

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
}
