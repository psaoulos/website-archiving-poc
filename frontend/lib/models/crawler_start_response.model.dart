class CrawlerStartResponse {
  final bool success;
  final bool started;

  const CrawlerStartResponse({
    required this.success,
    required this.started,
  });

  factory CrawlerStartResponse.fromJson(Map<String, dynamic> json) {
    return CrawlerStartResponse(
      success: json['success'],
      started: json['started'],
    );
  }

  @override
  String toString() {
    return "CrawlerStartResponse - success: $success, started: $started";
  }
}
