import 'package:flutter/material.dart';

enum Options {
  status,
  start,
  stop,
  results
}

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
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Crawler status'),
            onTap: () {
              setOptionPressed(Options.status);
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
        ],
      ),
    );
  }
}
