import 'package:flutter/material.dart';

enum Options { start, stop, results, dashboard, backendLogs }

class MainDrawer extends StatelessWidget {
  final Function setOptionPressed;
  const MainDrawer({Key? key, required this.setOptionPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('Available actions'),
            automaticallyImplyLeading: false,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Dashboard'),
            onTap: () {
              setOptionPressed(Options.dashboard);
              Scaffold.of(context).closeDrawer();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.not_started),
            title: const Text('Start crawler'),
            onTap: () {
              setOptionPressed(Options.start);
              Scaffold.of(context).closeDrawer();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.stop_circle),
            title: const Text('Stop crawler'),
            onTap: () {
              setOptionPressed(Options.stop);
              Scaffold.of(context).closeDrawer();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Results'),
            onTap: () {
              setOptionPressed(Options.results);
              Scaffold.of(context).closeDrawer();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Backend Logs'),
            onTap: () {
              setOptionPressed(Options.backendLogs);
              Scaffold.of(context).closeDrawer();
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
