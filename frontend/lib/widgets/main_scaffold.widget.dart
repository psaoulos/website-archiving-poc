import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/screens/actions.screen.dart';
import 'package:frontend/screens/dashboard.screen.dart';
import 'package:frontend/screens/results.screen.dart';
import 'package:frontend/screens/status.screen.dart';
import 'package:frontend/widgets/main_drawer.widget.dart';

class MainScaffold extends StatefulWidget {
  final Widget? childWidget;
  final String title;
  const MainScaffold({Key? key, this.childWidget, required this.title})
      : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  String _routeToNavigate = '';
  CrawlerActions _optionAction = CrawlerActions.start;

  void _setOptionPressed(Options option) {
    setState(() {
      switch (option) {
        case Options.status:
          _routeToNavigate = StatusScreen.routeName;
          break;
        case Options.start:
          _routeToNavigate = ActionsScreen.routeName;
          _optionAction = CrawlerActions.start;
          break;
        case Options.stop:
          _routeToNavigate = ActionsScreen.routeName;
          _optionAction = CrawlerActions.stop;
          break;
        case Options.results:
          _routeToNavigate = ResultsScreen.routeName;
          break;
        default:
          _routeToNavigate = DashboardScreen.routeName;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: MainDrawer(
        setOptionPressed: _setOptionPressed,
      ),
      onDrawerChanged: (isOpen) {
        if (!isOpen && _routeToNavigate != '') {
          Timer(const Duration(milliseconds: 200), () {
            if (_routeToNavigate == ActionsScreen.routeName) {
              Navigator.of(context).pushReplacementNamed(_routeToNavigate,
                  arguments: _optionAction);
            } else {
              Navigator.of(context).pushReplacementNamed(_routeToNavigate);
            }
          });
        }
      },
      body: widget.childWidget ?? Container(),
    );
  }
}
