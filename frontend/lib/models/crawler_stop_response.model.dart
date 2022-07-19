class CrawlerStop {
  final bool success;
  final bool stopped;

  const CrawlerStop({
    required this.success,
    required this.stopped,
  });

  factory CrawlerStop.fromJson(Map<String, dynamic> json) {
    return CrawlerStop(
      success: json['success'],
      stopped: json['stopped'],
    );
  }

  @override
  String toString() {
    return "CrawlerStop - success: $success, stopped: $stopped";
  }
}