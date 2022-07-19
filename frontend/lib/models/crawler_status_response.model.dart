class CrawlerStatus {
  final bool success;
  final bool running;

  const CrawlerStatus({
    required this.success,
    required this.running,
  });

  factory CrawlerStatus.fromJson(Map<String, dynamic> json) {
    return CrawlerStatus(
      success: json['success'],
      running: json['running'],
    );
  }

  @override
  String toString() {
    return "CrawlerStatus - success: $success, running: $running";
  }
}