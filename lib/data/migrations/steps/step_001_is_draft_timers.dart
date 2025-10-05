import 'package:sqflite/sqflite.dart';
import 'package:verify_clone/data/migrations/steps/steps.dart';

class Step001IsDraftTimers implements MigrationStepUp {
  @override
  int get fromVersion => 1;
  @override
  int get toVersion => 2;

  @override
  Future<void> apply(DatabaseExecutor db) async {
    await db.execute(
      "ALTER TABLE trees ADD COLUMN isDraft INTEGER NOT NULL DEFAULT 1",
    );
  }
}
