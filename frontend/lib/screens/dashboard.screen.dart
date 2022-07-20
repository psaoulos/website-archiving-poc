import 'package:flutter/material.dart';
import 'package:frontend/screens/actions.screen.dart';
import 'package:frontend/screens/results.screen.dart';
import 'package:frontend/services/crawler.services.dart';
import 'package:frontend/widgets/centered_outlined_button.widget.dart';
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

  void getCrawlerStatus() {
    CrawlerApiService().getCrawlerStatus().then((response) {
      setState(() {
        _running = response.running;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getCrawlerStatus();
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
                          buttonLabel: "Start Crawler",
                          buttonWidth: 150,
                          buttonOnClick: () {
                            Navigator.of(context).pushReplacementNamed(
                                ActionsScreen.routeName,
                                arguments: CrawlerActions.start);
                          },
                        ),
                        CenteredOutlinedButton(
                          buttonLabel: "Stop Crawler",
                          buttonWidth: 150,
                          buttonOnClick: () {
                            Navigator.of(context).pushReplacementNamed(
                                ActionsScreen.routeName,
                                arguments: CrawlerActions.stop);
                          },
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
          ],
        );
      }),
    );
  }
}
