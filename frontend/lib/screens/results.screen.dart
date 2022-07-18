import 'package:flutter/material.dart';
import 'package:frontend/widgets/main_scaffold.widget.dart';

class ResultsScreen extends StatelessWidget {
  static const routeName = '/results';
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Crawler Status',
      childWidget: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('SOME RESULTS HERE'),
            ],
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    );
  }
}
