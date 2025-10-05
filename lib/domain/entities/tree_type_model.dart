class TreeTypeModel {
  final String commonName;
  final String scientificName;

  TreeTypeModel({
    required this.commonName,
    required this.scientificName,
  });

  Map<String, dynamic> toMap() => {
        'commonName': commonName,
        'scientificName': scientificName,
      };

  factory TreeTypeModel.fromMap(Map<String, dynamic> map) => TreeTypeModel(
        commonName: map['commonName'],
        scientificName: map['scientificName'],
      );
}

class PlanterModel {
  final String planter;

  PlanterModel({
    required this.planter,
  });
  Map<String, dynamic> toMap() => {
        'planter': planter,
      };

  factory PlanterModel.fromMap(Map<String, dynamic> map) => PlanterModel(
        planter: map['planter'],
      );
}
