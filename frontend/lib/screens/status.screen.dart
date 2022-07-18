import 'package:flutter/material.dart';
import 'package:frontend/widgets/main_drawer.widget.dart';

import 'package:frontend/widgets/main_scaffold.widget.dart';

class StatusScreen extends StatelessWidget {
  static const routeName = '/status';
  const StatusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Crawler Status',
      childWidget: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('SOME STATUS HERE'),
            ],
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    );
  }
}
