import 'package:sqflite_common/sqlite_api.dart';
import 'package:verify_clone/data/migrations/steps/steps.dart';

class Step003MergePhotosLocation implements MigrationStepUp {
  @override
  int get fromVersion => 3;

  @override
  int get toVersion => 4;

  Future<bool> _hasColumn(DatabaseExecutor db, String table, String col) async {
    final rows = await db.rawQuery('PRAGMA table_info($table)');
    return rows.any((r) => r['name'] == col);
  }

  Future<bool> _tableExists(DatabaseExecutor db, String table) async {
    final res = await db.rawQuery(
      "SELECT 1 FROM sqlite_master WHERE type='table' AND name=? LIMIT 1",
      [table],
    );
    return res.isNotEmpty;
  }

  @override
  Future<void> apply(DatabaseExecutor db) async {
    try {
      // 1) Bổ sung cột thiếu (idempotent)
      if (!await _hasColumn(db, 'photos', 'captured_at')) {
        await db.execute('ALTER TABLE photos ADD COLUMN captured_at INTEGER');
      }
      if (!await _hasColumn(db, 'photos', 'lat')) {
        await db.execute('ALTER TABLE photos ADD COLUMN lat REAL');
      }
      if (!await _hasColumn(db, 'photos', 'lng')) {
        await db.execute('ALTER TABLE photos ADD COLUMN lng REAL');
      }
      if (!await _hasColumn(db, 'photos', 'accuracy')) {
        await db.execute('ALTER TABLE photos ADD COLUMN accuracy REAL');
      }
      if (!await _hasColumn(db, 'photos', 'source')) {
        await db.execute('ALTER TABLE photos ADD COLUMN source TEXT');
      }

      // 2) Merge dữ liệu nếu từng có bảng photo_locations
      if (await _tableExists(db, 'photo_locations')) {
        await db.execute('''
          UPDATE photos
          SET
            lat         = COALESCE((SELECT pl.lat         FROM photo_locations pl WHERE pl.photo_id = photos.photo_id), lat),
            lng         = COALESCE((SELECT pl.lng         FROM photo_locations pl WHERE pl.photo_id = photos.photo_id), lng),
            accuracy    = COALESCE((SELECT pl.accuracy    FROM photo_locations pl WHERE pl.photo_id = photos.photo_id), accuracy),
            source      = COALESCE((SELECT pl.source      FROM photo_locations pl WHERE pl.photo_id = photos.photo_id), source),
            captured_at = COALESCE((SELECT pl.captured_at FROM photo_locations pl WHERE pl.photo_id = photos.photo_id), captured_at)
          WHERE EXISTS (SELECT 1 FROM photo_locations pl WHERE pl.photo_id = photos.photo_id);
        ''');
      }

      // 3) Dọn bảng cũ (không lỗi nếu không tồn tại)
      await db.execute('DROP TABLE IF EXISTS photo_locations;');

      // 4) Điền captured_at từ taken_at nếu thiếu
      if (await _hasColumn(db, 'photos', 'taken_at')) {
        await db.execute('''
          UPDATE photos
          SET captured_at = COALESCE(captured_at, taken_at)
          WHERE captured_at IS NULL AND taken_at IS NOT NULL;
        ''');
      }

      // 5) Index phục vụ truy vấn thời gian
      await db.execute(
        'CREATE INDEX IF NOT EXISTS ix_photo_captured_at ON photos(captured_at);',
      );
    } catch (e, st) {
      throw Exception('Step004MergePhotosLocation failed: $e\n$st');
    }
  }
}
