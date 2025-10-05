import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verify_clone/data/services/database_helper.dart';
import 'package:verify_clone/data/services/tree/count_protected_trees.dart';

final protectedTreesCount = Provider<CountProtectedTrees>(
  (ref) => CountProtectedTrees(DatabaseHelper.instance),
);

final protectedTreesCountProvider = FutureProvider<int>(
  (ref) => ref.read(protectedTreesCount).countProtectedTrees(),
);
