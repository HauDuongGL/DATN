import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:verify_clone/data/migrations/init.dart';
import 'package:verify_clone/data/migrations/runner.dart';
import 'package:verify_clone/data/migrations/steps/steps.dart';

class DatabaseHelper {
  final databaseName = "app_data.db";

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static int get _databaseVersion {
    const initialSchemaVersion = 1;

    if (migrationStepsUp.isEmpty) return initialSchemaVersion;
    return migrationStepsUp.last.toVersion;
  }

  static Database? _db;
  DatabaseHelper._internal();

  Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: (db, version) async {
        await createSchemaV1(db);
        await runMigrationsUp(db, 1, version);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await runMigrationsUp(db, oldVersion, newVersion);
      },
      onDowngrade: (db, oldVersion, newVersion) async {},
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Future<void> resetDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_data.db');

    if (await File(path).exists()) {
      await deleteDatabase(path);
      print('Database deleted: $path');
    }
  }
}
