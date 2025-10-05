import 'package:sqflite/sqflite.dart';
import 'package:verify_clone/data/migrations/steps/steps.dart';

Future<void> runMigrationsUp(
    Database db, int oldVersion, int newVersion) async {
  if (oldVersion >= newVersion) return;

  for (int v = oldVersion; v < newVersion; v++) {
    final step = migrationStepsUp.firstWhere(
      (s) => s.fromVersion == v && s.toVersion == v + 1,
      orElse: () => throw StateError('$v -> ${v + 1}'),
    );
    await db.transaction(
      (e) async {
        await e.execute('PRAGMA foreign_keys = ON;');
        await step.apply(e);
      },
    );
  }
}
