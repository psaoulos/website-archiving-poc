class CrawlerStopResponse {
  final bool success;
  final bool stopped;

  const CrawlerStopResponse({
    required this.success,
    required this.stopped,
  });

  factory CrawlerStopResponse.fromJson(Map<String, dynamic> json) {
    return CrawlerStopResponse(
      success: json['success'],
      stopped: json['stopped'],
    );
  }

  @override
  String toString() {
    return "CrawlerStopResponse - success: $success, stopped: $stopped";
  }
}
