import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/crawler_Proccess.model.dart';
import 'package:frontend/models/crawler_status_response.model.dart';

class CrawlerProgressBar extends StatefulWidget {
  final double width;
  final CrawlerStatusResponse status;
  const CrawlerProgressBar(
      {Key? key, required this.width, required this.status})
      : super(key: key);

  @override
  State<CrawlerProgressBar> createState() => _CrawlerProgressBarState();
}

class _CrawlerProgressBarState extends State<CrawlerProgressBar>
    with TickerProviderStateMixin {
  late AnimationController controller;
  bool finished = false;

  @override
  void initState() {
    final CrawlerProccess crawler = widget.status.crawlerInfo[0];
    final int totalSeconds =
        (crawler.iterations - 1) * (crawler.iterationInterval + 1.2).toInt() +
            1;
    // Assuming each crawl takes ≈ 1.2 seconds
    final DateTime startedTimestamp = crawler.startedTimestamp;
    final DateTime nowTimestamp = DateTime.now();
    final DateTime estimateFinishTimestamp =
        startedTimestamp.add(Duration(seconds: totalSeconds));
    final int secondsLeft =
        estimateFinishTimestamp.difference(nowTimestamp).inSeconds;

    final double startingPercentage = 1 - (secondsLeft / totalSeconds);
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: totalSeconds),
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            finished = true;
          });
        }
      });
    controller.forward(
      from: startingPercentage,
    );
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  int get _currentIteration {
    final CrawlerProccess crawler = widget.status.crawlerInfo[0];
    final int totalSeconds =
        (crawler.iterations - 1) * (crawler.iterationInterval + 1.2).toInt() +
            1;
    // Assuming each crawl takes ≈ 1.2 seconds
    final DateTime startedTimestamp = crawler.startedTimestamp;
    final DateTime nowTimestamp = DateTime.now();
    final int timeElapsed = nowTimestamp.difference(startedTimestamp).inSeconds;
    final int timeLeft = totalSeconds - timeElapsed;
    double temp = timeLeft / (crawler.iterationInterval + 1);
    return crawler.iterations - temp.toInt();
  }

  String get _estimatedFinish {
    final CrawlerProccess crawler = widget.status.crawlerInfo[0];
    if (crawler.iterationInterval == 1) {
      return "2 Seconds";
    }
    final int totalSeconds =
        (crawler.iterations - 1) * (crawler.iterationInterval + 1.2).toInt() +
            1;
    final DateTime startedTimestamp = crawler.startedTimestamp;
    final DateTime estimate =
        startedTimestamp.add(Duration(seconds: totalSeconds));
    return DateFormat().format(estimate);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.status.totalCrawlers != 0) {
      return SizedBox(
        width: widget.width,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('Approximate Crawl task progress:'),
                ),
                LinearProgressIndicator(
                  value: controller.value,
                  semanticsLabel: 'Linear progress indicator',
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey,
                          ),
                          children: <TextSpan>[
                            const TextSpan(text: 'Next iteration '),
                            TextSpan(
                              text: _currentIteration.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: ' out of '),
                            TextSpan(
                              text: widget.status.crawlerInfo[0].iterations
                                  .toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: ' on '),
                            TextSpan(
                              text: widget
                                  .status.crawlerInfo[0].iterationInterval
                                  .toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: ' seconds interval.'),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey,
                          ),
                          children: <TextSpan>[
                            const TextSpan(text: 'Finish on '),
                            TextSpan(
                              text: _estimatedFinish,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
