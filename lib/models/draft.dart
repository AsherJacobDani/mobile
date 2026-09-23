class Draft {
  final int id;

  final String category;

  final List<String> imagePaths;

  final String caption;

  final List<String> hashtags;

  final String status;

  final String? instagramPostUrl;

  Draft({
    required this.id,
    required this.category,
    required this.imagePaths,
    required this.caption,
    required this.hashtags,
    required this.status,
    this.instagramPostUrl,
  });

  factory Draft.fromJson(
  Map<String, dynamic> json,
) {
  return Draft(
    id: json["id"],

    category: json["category"],

    imagePaths: List<String>.from(
      (json["image_paths"] ?? []).map(
        (path) => path.toString().startsWith("http")
            ? path.toString()
            : "https://instaai-production.up.railway.app/${path.toString().replaceAll("\\", "/")}",
      ),
    ),

    caption: json["caption"],

    hashtags: List<String>.from(
      json["hashtags"] ?? [],
    ),

    status: json["status"],

    instagramPostUrl:
        json["instagram_post_url"],
  );
}

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "category": category,
      "image_paths": imagePaths,
      "caption": caption,
      "hashtags": hashtags,
      "status": status,
      "instagram_post_url": instagramPostUrl,
    };
  }
}