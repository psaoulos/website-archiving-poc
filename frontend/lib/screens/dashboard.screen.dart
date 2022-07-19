import 'package:flutter/material.dart';
import 'package:frontend/services/crawler.services.dart';
import 'package:frontend/widgets/main_scaffold.widget.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _running = true;

  @override
  void initState() {
    super.initState();
    CrawlerApiService().getCrawlerStatus().then((response) {
      print(response.toString());
      setState(() {
        _running = response.running;
      });
    });
  }

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
                    child: Text(_running ? 'true' : 'false'))
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
