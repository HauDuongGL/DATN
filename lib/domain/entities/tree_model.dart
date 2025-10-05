class TreeModel {
  final int? treeId;
  final String name;
  final String? type;
  final String? planter;

  final int userId;
  final bool isDraft;

  TreeModel({
    this.treeId,
    required this.name,
    this.type,
    this.planter,
    required this.userId,
    this.isDraft = true,
  });

  TreeModel copyWith({
    int? treeId,
    String? name,
    String? type,
    String? planter,
    String? photoBefore,
    String? photoAfter,
    String? photoBeforeTimer,
    String? photoAfterTimer,
    int? userId,
    bool? isDraft,
  }) {
    return TreeModel(
      treeId: treeId ?? this.treeId,
      name: name ?? this.name,
      type: type ?? this.type,
      planter: planter ?? this.planter,
      userId: userId ?? this.userId,
      isDraft: isDraft ?? this.isDraft,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'treeId': treeId,
      'name': name,
      'type': type,
      'planter': planter,
      'userId': userId,
      'isDraft': isDraft ? 1 : 0,
    };
  }

  factory TreeModel.fromMap(Map<String, dynamic> map) {
    return TreeModel(
      treeId: map['treeId'] as int?,
      name: (map['name'] ?? '') as String,
      type: map['type'] as String?,
      planter: map['planter'] as String?,
      userId: map['userId'] as int,
      isDraft: (map['isDraft'] ?? 1) == 1,
    );
  }
}
