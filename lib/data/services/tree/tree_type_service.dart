import 'package:verify_clone/data/services/database_helper.dart';
import 'package:verify_clone/domain/entities/tree_type_model.dart';
import 'package:sqflite/sqflite.dart';

class TreeTypeService {
  static final TreeTypeService instance =
      TreeTypeService._(DatabaseHelper.instance);

  final DatabaseHelper dbHelper;
  TreeTypeService._(this.dbHelper);

  static const _tableTreesStyle = 'treesStyle';
  static const _tablePlanter = 'planter';

  Future<void> seedIfEmpty() async {
    final db = await dbHelper.db;

    final treesStyleCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $_tableTreesStyle'),
        ) ??
        0;

    if (treesStyleCount == 0) {
      final batch = db.batch();
      batch.insert(
          _tableTreesStyle,
          TreeTypeModel(
                  commonName: 'Muna/Aningeria',
                  scientificName: 'Scientific Name')
              .toMap());
      batch.insert(
          _tableTreesStyle,
          TreeTypeModel(
                  commonName: 'Winged Bersema',
                  scientificName: 'Scientific Name')
              .toMap());
      batch.insert(
          _tableTreesStyle,
          TreeTypeModel(
                  commonName: 'Star Apple/Caimito',
                  scientificName: 'Achras Caimito')
              .toMap());
      batch.insert(
          _tableTreesStyle,
          TreeTypeModel(commonName: 'Horsewood', scientificName: 'Clausinia')
              .toMap());
      batch.insert(
          _tableTreesStyle,
          TreeTypeModel(
                  commonName: 'Abyssinian Gooseberry',
                  scientificName: 'Wild Apricot')
              .toMap());
      batch.insert(
          _tableTreesStyle,
          TreeTypeModel(commonName: 'Dombeya', scientificName: 'Mukeu')
              .toMap());
      await batch.commit(noResult: true);
    }

    final planterCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $_tablePlanter'),
        ) ??
        0;

    if (planterCount == 0) {
      final batch = db.batch();
      batch.insert(_tablePlanter, PlanterModel(planter: 'Myself').toMap());
      batch.insert(_tablePlanter, PlanterModel(planter: 'Family').toMap());
      batch.insert(_tablePlanter, PlanterModel(planter: 'Arborist').toMap());
      batch.insert(_tablePlanter, PlanterModel(planter: 'Other').toMap());
      await batch.commit(noResult: true);
    }
  }

  Future<List<TreeTypeModel>> getAllTrees() async {
    final db = await dbHelper.db;
    final result = await db.query(_tableTreesStyle, orderBy: 'id ASC');
    return result.map(TreeTypeModel.fromMap).toList();
  }

  Future<List<PlanterModel>> getAllPlanter() async {
    final db = await dbHelper.db;
    final result = await db.query(_tablePlanter, orderBy: 'id ASC');
    return result.map(PlanterModel.fromMap).toList();
  }
}
