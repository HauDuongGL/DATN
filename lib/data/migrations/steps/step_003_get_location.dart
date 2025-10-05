import 'package:sqflite/sqflite.dart';
import 'package:verify_clone/data/migrations/steps/steps.dart';

class Step003GetLocation implements MigrationStepUp {
  @override
  int get fromVersion => 3;
  @override
  int get toVersion => 4;

  @override
  Future<void> apply(DatabaseExecutor db) async {
    await db.execute("ALTER TABLE trees ADD COLUMN latBefore REAL");
    await db.execute("ALTER TABLE trees ADD COLUMN lngBefore REAL");
    await db.execute("ALTER TABLE trees ADD COLUMN capturedAtBefore INTEGER");
  }
}
