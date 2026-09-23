class InstagramStatus {
  final bool connected;
  final String? username;

  // New fields
  final bool personalizationReady;
  final DateTime? lastUpdated;

  const InstagramStatus({
    required this.connected,
    this.username,
    required this.personalizationReady,
    this.lastUpdated,
  });

  factory InstagramStatus.fromJson(Map<String, dynamic> json) {
    return InstagramStatus(
      connected: json["connected"] ?? false,
      username: json["username"],
      personalizationReady:
          json["personalization_ready"] ?? false,
      lastUpdated: json["last_updated"] != null
          ? DateTime.parse(json["last_updated"])
          : null,
    );
  }

  factory InstagramStatus.notConnected() {
    return const InstagramStatus(
      connected: false,
      username: null,
      personalizationReady: false,
      lastUpdated: null,
    );
  }
}