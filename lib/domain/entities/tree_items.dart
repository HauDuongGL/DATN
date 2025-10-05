import 'package:flutter/foundation.dart';

enum TreeStatus { verified, pending, invalid }

@immutable
class TreeItem {
  final int id;
  final String name;
  final DateTime updatedAt;
  final TreeStatus status;

  const TreeItem({
    required this.id,
    required this.name,
    required this.updatedAt,
    required this.status,
  });
}
