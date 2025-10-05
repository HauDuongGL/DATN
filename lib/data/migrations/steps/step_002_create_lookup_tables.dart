import 'package:sqflite/sqflite.dart';
import 'package:verify_clone/data/migrations/steps/steps.dart';

class Step002CreateLookupTables implements MigrationStepUp {
  @override
  int get fromVersion => 2;

  @override
  int get toVersion => 3;

  @override
  Future<void> apply(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS treesStyle (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        commonName TEXT NOT NULL,
        scientificName TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS planter (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        planter TEXT NOT NULL
      )
    ''');

    final treesStyleCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM treesStyle'),
        ) ??
        0;

    if (treesStyleCount == 0) {
      await db.insert('treesStyle', {
        'commonName': 'Muna/Aningeria',
        'scientificName': 'Scientific Name',
      });
      await db.insert('treesStyle', {
        'commonName': 'Winged Bersema',
        'scientificName': 'Scientific Name',
      });
      await db.insert('treesStyle', {
        'commonName': 'Star Apple/Caimito',
        'scientificName': 'Achras Caimito',
      });
      await db.insert('treesStyle', {
        'commonName': 'Horsewood',
        'scientificName': 'Clausinia',
      });
      await db.insert('treesStyle', {
        'commonName': 'Abyssinian Gooseberry',
        'scientificName': 'Wild Apricot',
      });
      await db.insert('treesStyle', {
        'commonName': 'Dombeya',
        'scientificName': 'Mukeu',
      });
    }

    final planterCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM planter'),
        ) ??
        0;

    if (planterCount == 0) {
      await db.insert('planter', {'planter': 'Myself'});
      await db.insert('planter', {'planter': 'Family'});
      await db.insert('planter', {'planter': 'Arborist'});
      await db.insert('planter', {'planter': 'Other'});
    }
  }
}
