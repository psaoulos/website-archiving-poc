class CrawlerProccess {
  final int iterations;
  final int iterationInterval;
  final int currentIteration;
  final DateTime startedTimestamp;

  const CrawlerProccess({
    required this.iterations,
    required this.iterationInterval,
    required this.currentIteration,
    required this.startedTimestamp,
  });

  factory CrawlerProccess.fromJson(Map<String, dynamic> json) {
    return CrawlerProccess(
      iterations: 1,
      iterationInterval: 1,
      currentIteration: 1,
      startedTimestamp: DateTime.now()
    );
  }

  @override
  String toString() {
    return "CrawlerProccess - ";
  }
}
