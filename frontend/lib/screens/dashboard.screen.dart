import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/models/crawler_status_response.model.dart';
import 'package:frontend/screens/actions.screen.dart';
import 'package:frontend/screens/results.screen.dart';
import 'package:frontend/services/crawler.services.dart';
import 'package:frontend/widgets/centered_outlined_button.widget.dart';
import 'package:frontend/widgets/crawler_progress_bar.widget.dart';
import 'package:frontend/widgets/main_scaffold.widget.dart';
import 'package:frontend/widgets/running_indicator_chip.widget.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _running = false;
  CrawlerStatusResponse? _crawlerStatus;
  Timer? _timer;

  void getCrawlerStatus() {
    CrawlerApiService().getCrawlerStatus().then((response) {
      setState(() {
        _running = response.running;
        _crawlerStatus = response;
      });
      if (response.running) {
        int iteration = 10;
        if (response.crawlerInfo[0].iterationInterval > 10) {
          iteration = response.crawlerInfo[0].iterationInterval;
        }
        _timer = Timer(Duration(seconds: iteration), () {
          getCrawlerStatus();
        });
      }
    });
  }

  @override
  void initState() {
    getCrawlerStatus();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Dashboard',
      childWidget: Builder(builder: (context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Text('Crawler Status: '),
                        ),
                        RunningIndicatorChip(
                          isRunning: _running,
                          refreshFunction: getCrawlerStatus,
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Available crawler actions:"),
                        ),
                        CenteredOutlinedButton(
                          buttonLabel: "Start the Crawler",
                          buttonWidth: 150,
                          buttonOnClick: () {
                            Navigator.of(context).pushReplacementNamed(
                              ActionsScreen.routeName,
                              arguments: CrawlerActions.start,
                            );
                          },
                          padding: const EdgeInsets.only(bottom: 2.5),
                        ),
                        CenteredOutlinedButton(
                          buttonLabel: "Stop the Crawler",
                          buttonWidth: 150,
                          buttonOnClick: () {
                            Navigator.of(context).pushReplacementNamed(
                              ActionsScreen.routeName,
                              arguments: CrawlerActions.stop,
                            );
                          },
                          padding: const EdgeInsets.only(bottom: 2.5),
                        ),
                        CenteredOutlinedButton(
                          buttonLabel: "See some Results",
                          buttonWidth: 150,
                          buttonOnClick: () {
                            Navigator.of(context).pushReplacementNamed(
                              ResultsScreen.routeName,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            if (_crawlerStatus != null && _crawlerStatus!.totalCrawlers > 0)
              CrawlerProgressBar(
                width: 500,
                status: _crawlerStatus as CrawlerStatusResponse,
              ),
          ],
        );
      }),
    );
  }
}
