import 'package:verify_clone/utils/extensions/helper.dart';

class Photo {
  final String photoId;
  final int treeId;
  final String kind;
  final String path;
  final int takenAt;
  final int? createdAt;
  final int? updatedAt;

  const Photo({
    required this.photoId,
    required this.treeId,
    required this.kind,
    required this.path,
    required this.takenAt,
    this.createdAt,
    this.updatedAt,
  });

  Photo copyWith({
    String? photoId,
    int? treeId,
    String? kind,
    String? path,
    int? takenAt,
    int? createdAt,
    int? updatedAt,
  }) {
    return Photo(
      photoId: photoId ?? this.photoId,
      treeId: treeId ?? this.treeId,
      kind: kind ?? this.kind,
      path: path ?? this.path,
      takenAt: takenAt ?? this.takenAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Photo.fromMap(Map<String, Object?> map) {
    return Photo(
      photoId: map['photo_id'] as String,
      treeId: map.asInt('tree_id'),
      kind: (map['kind'] as String).toLowerCase(),
      path: map['path'] as String,
      takenAt: map.asInt('taken_at'),
      createdAt: map.asIntOrNull('created_at'),
      updatedAt: map.asIntOrNull('updated_at'),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'photo_id': photoId,
      'tree_id': treeId,
      'kind': kind,
      'path': path,
      'taken_at': takenAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
