class Recommendation {

  final String imagePath;

  final int score;

  final String grade;

  final String category;

  final double confidence;

  Recommendation({

    required this.imagePath,

    required this.score,

    required this.grade,

    required this.category,

    required this.confidence,

  });

  factory Recommendation.fromJson(
      Map<String, dynamic> json) {

    return Recommendation(

      imagePath:
    "https://instaai-production.up.railway.app/${json["image_path"].replaceAll("\\", "/")}",

      score: json["image_score"]["score"],

      grade: json["image_score"]["grade"],

      category: json["scene"]["category"],

      confidence:
          (json["scene"]["confidence"] as num)
              .toDouble(),

    );
  }

}