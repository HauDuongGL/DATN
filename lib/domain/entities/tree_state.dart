// tree_state.dart (update)
import 'package:verify_clone/domain/entities/tree_model.dart';
import 'package:verify_clone/domain/entities/photo_model.dart';

class TreeValidationState {
  final bool isValid;
  final bool missingType;
  final bool missingBefore;
  final bool missingAfter;

  bool get hasMissingFields => missingType || missingBefore || missingAfter;

  TreeValidationState({
    required this.isValid,
    required this.missingType,
    required this.missingBefore,
    required this.missingAfter,
  });

  static TreeValidationState fromTree(TreeModel tree, List<Photo> photos) {
    final typeOk = tree.type?.trim().isNotEmpty ?? false;
    final hasBefore = photos.any((p) => p.kind.toLowerCase() == 'before');
    final hasAfter = photos.any((p) => p.kind.toLowerCase() == 'after');
    final valid = typeOk && hasBefore && hasAfter;

    return TreeValidationState(
      isValid: valid,
      missingType: !typeOk,
      missingBefore: !hasBefore,
      missingAfter: !hasAfter,
    );
  }
}
