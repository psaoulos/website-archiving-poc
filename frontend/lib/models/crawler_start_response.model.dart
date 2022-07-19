class CrawlerStart {
  final bool success;
  final bool started;

  const CrawlerStart({
    required this.success,
    required this.started,
  });

  factory CrawlerStart.fromJson(Map<String, dynamic> json) {
    return CrawlerStart(
      success: json['success'],
      started: json['started'],
    );
  }

  @override
  String toString() {
    return "CrawlerStart - success: $success, started: $started";
  }
}