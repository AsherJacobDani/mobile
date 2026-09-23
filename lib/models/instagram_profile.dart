class InstagramProfile {
  final String username;
  final String accountType;
  final int followers;
  final int following;
  final int posts;
  final String? profilePicture;

  InstagramProfile({
    required this.username,
    required this.accountType,
    required this.followers,
    required this.following,
    required this.posts,
    this.profilePicture,
  });

  factory InstagramProfile.fromJson(Map<String, dynamic> json) {
    return InstagramProfile(
      username: json["username"] ?? "",
      accountType: json["account_type"] ?? "",
      followers: json["followers"] ?? 0,
      following: json["following"] ?? 0,
      posts: json["posts"] ?? 0,
      profilePicture: json["profile_picture"],
    );
  }
}