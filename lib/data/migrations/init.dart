import 'package:sqflite/sqflite.dart';

Future<void> createSchemaV1(Database db) async {
  await db.execute('PRAGMA foreign_keys = ON;');

  const users = '''
    CREATE TABLE IF NOT EXISTS users (
      usrId INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT UNIQUE,
      password TEXT,
      username TEXT
    )
  ''';
  await db.execute(users);

  const trees = '''
    CREATE TABLE IF NOT EXISTS trees (
      treeId INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      type TEXT,
      planter TEXT,
      userId INTEGER NOT NULL,
      FOREIGN KEY (userId) REFERENCES users(usrId)
        ON UPDATE CASCADE ON DELETE CASCADE
    )
  ''';
  await db.execute(trees);
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_trees_user ON trees(userId);',
  );

  const photos = '''
    CREATE TABLE IF NOT EXISTS photos (
      photo_id TEXT PRIMARY KEY,
      tree_id TEXT NOT NULL,
      kind TEXT NOT NULL,     
      step TEXT,              
      path TEXT NOT NULL,
      taken_at INTEGER NOT NULL,
      created_at INTEGER,
      updated_at INTEGER,
      FOREIGN KEY(tree_id) REFERENCES trees(treeId) ON DELETE CASCADE
    )
  ''';
  await db.execute(photos);
  await db
      .execute('CREATE INDEX IF NOT EXISTS ix_photos_tree ON photos(tree_id);');
  await db.execute(
      'CREATE INDEX IF NOT EXISTS ix_photos_taken_at ON photos(taken_at);');
  await db.execute('''
    CREATE UNIQUE INDEX IF NOT EXISTS ux_photos_tree_kind_limited
    ON photos(tree_id, kind)
    WHERE kind IN ('before','after')
  ''');
}
