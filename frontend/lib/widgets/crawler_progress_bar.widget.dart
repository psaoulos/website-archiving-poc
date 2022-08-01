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
  bool _finished = false;
  String _estimatedTimeLeft = "";

  int get _totalSeconds {
    final CrawlerProccess crawler = widget.status.crawlerInfo[0];
    return (crawler.iterations - 1) *
            (crawler.iterationInterval + 1.2).toInt() +
        1;
    // Assuming each crawl takes ≈ 1.2 seconds
  }

  int get _timeLeft {
    final CrawlerProccess crawler = widget.status.crawlerInfo[0];
    final DateTime startedTimestamp = crawler.startedTimestamp;
    final DateTime nowTimestamp = DateTime.now();
    final int timeElapsed = nowTimestamp.difference(startedTimestamp).inSeconds;
    return _totalSeconds - timeElapsed;
  }

  int get _currentIteration {
    final CrawlerProccess crawler = widget.status.crawlerInfo[0];
    double temp = _timeLeft / (crawler.iterationInterval + 1);
    return crawler.iterations - temp.toInt();
  }

  String get _estimatedDatetimeFinish {
    final CrawlerProccess crawler = widget.status.crawlerInfo[0];
    if (crawler.iterationInterval == 1) {
      return "2 Seconds";
    }
    final DateTime startedTimestamp = crawler.startedTimestamp;
    final DateTime estimate =
        startedTimestamp.add(Duration(seconds: _totalSeconds));
    return DateFormat().format(estimate);
  }

  int get _estimatedSecondsLeft {
    final CrawlerProccess crawler = widget.status.crawlerInfo[0];
    final DateTime startedTimestamp = crawler.startedTimestamp;
    final DateTime nowTimestamp = DateTime.now();
    final DateTime estimateFinishTimestamp =
        startedTimestamp.add(Duration(seconds: _totalSeconds));
    return estimateFinishTimestamp.difference(nowTimestamp).inSeconds;
  }

  String getTimeRangeFromSeconds(int secs) {
    if (secs <= 0) {
      return "Done";
    }
    final Duration duration = Duration(seconds: secs);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    String approx = "";
    if (days > 0) {
      approx = "$days Days";
    }
    if (hours > 0) {
      approx = "$approx $hours Hours";
    }
    if (minutes > 0) {
      approx = "$approx $minutes Minutes";
    }
    if (seconds > 0) {
      approx = "$approx $seconds Seconds";
    }
    return approx.trim();
  }

  @override
  void initState() {
    final double startingPercentage =
        1 - (_estimatedSecondsLeft / _totalSeconds);
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _totalSeconds),
    )
      ..addListener(() {
        setState(() {
          _estimatedTimeLeft = getTimeRangeFromSeconds(_estimatedSecondsLeft);
        });
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _finished = true;
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
                  color: _finished ? Colors.green : Colors.blue,
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
                            const TextSpan(text: ' ('),
                            TextSpan(
                              text: getTimeRangeFromSeconds(widget
                                  .status.crawlerInfo[0].iterationInterval),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: ' interval).'),
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
                            const TextSpan(text: 'Left: '),
                            TextSpan(
                              text: _estimatedTimeLeft,
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
                            const TextSpan(text: 'Finish on: '),
                            TextSpan(
                              text: _estimatedDatetimeFinish,
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
