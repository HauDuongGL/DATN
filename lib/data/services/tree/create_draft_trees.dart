import 'package:verify_clone/data/services/database_helper.dart';

import '../../../domain/entities/model.dart';
import 'trees_service.dart';

class CreateDraftTrees {
  final DatabaseHelper dbHelper;
  CreateDraftTrees(this.dbHelper);

  Future<TreeModel> createDraftTree(int userId) async {
    final insertedId = await TreesCrud(dbHelper).addTree(
      TreeModel(name: 'Tree 1', userId: userId),
    );
    return await GetByTreesId(dbHelper).getTreeById(insertedId);
  }
}
