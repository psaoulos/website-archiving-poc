import 'package:flutter/material.dart';
import 'package:frontend/widgets/main_drawer.widget.dart';
import 'package:frontend/widgets/main_scaffold.widget.dart';

class DashboardScreen extends StatelessWidget {
  static const routeName = '/dashboard';
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Dashboard',
      childWidget: Builder(builder: (context) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Press to open drawer!'),
                OutlinedButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: Text('Press me'))
              ],
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
        );
      }),
    );
  }
}
