import 'dart:convert';

import 'package:frontend/constants/crawler_service.constants.dart';
import 'package:frontend/models/crawler_status_response.model.dart';
import 'package:frontend/models/crawler_start_response.model.dart';
import 'package:frontend/models/crawler_stop_response.model.dart';
import 'package:http/http.dart' as http;

class CrawlerApiService {
  Future<CrawlerStatus> getCrawlerStatus() async {
    final response =
        await http.get(Uri.parse(backendAddress + backendStatusEndpoint));

    if (response.statusCode == 200) {
      return CrawlerStatus.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load crawler status');
    }
  }

  Future<CrawlerStart> startCrawler(
    String repeatTimes,
    String intervalSeconds,
    String diffThreshold,
    String crawlUrl,
    bool forceStart,
  ) async {
    final queryParameters = {
      'repeat_times': repeatTimes,
      'interval_seconds': intervalSeconds,
      'diff_threshold': diffThreshold,
      'crawl_url': crawlUrl,
      'force_start': forceStart,
    };
    final jsonString = json.encode(queryParameters);
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    final response = await http.post(
      Uri.parse(backendAddress + backendStartEndpoint),
      headers: headers,
      body: jsonString,
    );

    if (response.statusCode == 200) {
      return CrawlerStart.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to start crawler');
    }
  }

  Future<CrawlerStop> stopCrawler() async {
    final response =
        await http.get(Uri.parse(backendAddress + backendStopEndpoint));

    if (response.statusCode == 200) {
      return CrawlerStop.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to stop crawler');
    }
  }
}
