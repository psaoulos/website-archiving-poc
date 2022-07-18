import 'package:flutter/material.dart';
import 'package:frontend/widgets/main_scaffold.widget.dart';

enum CrawlerActions {
  start,
  stop,
}

class ActionsScreen extends StatelessWidget {
  static const routeName = '/actions';
  final CrawlerActions action;
  const ActionsScreen({Key? key, required this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: action == CrawlerActions.start ? 'Start' : 'Stop',
      childWidget: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(action == CrawlerActions.start ? 'Start' : 'Stop'),
            ],
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    );
  }
}
