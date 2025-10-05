import 'package:sqflite/sqflite.dart';
import 'package:verify_clone/data/migrations/steps/step_001_is_draft_timers.dart';
import 'package:verify_clone/data/migrations/steps/step_002_create_lookup_tables.dart';
import 'package:verify_clone/data/migrations/steps/step_003_merge_photos_location.dart';

abstract class MigrationStepUp {
  int get fromVersion;
  int get toVersion;
  Future<void> apply(DatabaseExecutor db);
}

final List<MigrationStepUp> migrationStepsUp = [
  Step001IsDraftTimers(),
  Step002CreateLookupTables(),
  Step003MergePhotosLocation(),
];
