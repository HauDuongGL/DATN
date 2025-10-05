import 'package:verify_clone/gen/assets.gen.dart';

enum Enumquestion {
  getSeedlings,
  plantMyTrees,
  plantATrees,
  earnPoints,
}

extension QuestionExtension on Enumquestion {
  String get titleQuestion {
    switch (this) {
      case Enumquestion.getSeedlings:
        return "Where can I get seedlings?";
      case Enumquestion.plantMyTrees:
        return "Where can I plant my trees?";
      case Enumquestion.plantATrees:
        return "How do I plant a tree?";
      case Enumquestion.earnPoints:
        return "How do I earn points?";
    }
  }

  String get subTitle {
    switch (this) {
      case Enumquestion.getSeedlings:
        return "Find seedlings at a local nursery or agrovet near you";
      case Enumquestion.plantMyTrees:
        return "Use our interactive map to find areas that need more trees";
      case Enumquestion.plantATrees:
        return "Learn how to plant and look after your seedlings";
      case Enumquestion.earnPoints:
        return "How to earn points for planting and protecting trees";
    }
  }

  SvgGenImage get image {
    switch (this) {
      case Enumquestion.getSeedlings:
        return Assets.icons.icPlantPot;
      case Enumquestion.plantMyTrees:
        return Assets.icons.icPlantMyTrees;
      case Enumquestion.plantATrees:
        return Assets.icons.icPlantATrees;
      case Enumquestion.earnPoints:
        return Assets.icons.icEarnPoints;
    }
  }

  String get titleBtn {
    switch (this) {
      case Enumquestion.getSeedlings:
        return "Find seedling providers";
      case Enumquestion.plantMyTrees:
        return "Find tree planting areas";
      case Enumquestion.plantATrees:
        return "Learn more";
      case Enumquestion.earnPoints:
        return "Learn about rewards";
    }
  }
}
