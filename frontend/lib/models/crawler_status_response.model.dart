import 'package:frontend/models/crawler_Proccess.model.dart';
import 'package:intl/intl.dart';

class CrawlerStatusResponse {
  final bool success;
  final bool running;
  final List<CrawlerProccess> crawlerInfo;
  final int totalCrawlers;

  const CrawlerStatusResponse({
    required this.success,
    required this.running,
    required this.crawlerInfo,
    required this.totalCrawlers,
  });

  factory CrawlerStatusResponse.fromJson(Map<String, dynamic> json) {
    List<CrawlerProccess> tempCrawlerList = [];
    json['crawlers'].forEach((crawler) {
      DateTime startedTime =
          DateFormat('E, d MMM yyyy hh:mm:ss Z', 'en_US').parse(crawler[3]);
      tempCrawlerList.add(
        CrawlerProccess(
          iterations: crawler[0],
          iterationInterval: crawler[1],
          currentIteration: crawler[2],
          startedTimestamp: startedTime,
        ),
      );
    });

    return CrawlerStatusResponse(
      success: json['success'],
      running: json['running'],
      crawlerInfo: tempCrawlerList,
      totalCrawlers: tempCrawlerList.length,
    );
  }

  @override
  String toString() {
    return "CrawlerStatusResponse - success: $success, running: $running, totalCrawlers: $totalCrawlers ";
  }
}
