import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/providers/main.provider.dart';
import 'package:frontend/screens/actions.screen.dart';
import 'package:frontend/screens/dashboard.screen.dart';
import 'package:frontend/screens/logs.screen.dart';
import 'package:frontend/screens/results.screen.dart';
import 'package:frontend/widgets/main_drawer.widget.dart';
import 'package:provider/provider.dart';

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
        case Options.dashboard:
          _routeToNavigate = DashboardScreen.routeName;
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
        case Options.backendLogs:
          _routeToNavigate = LogsScreen.routeName;
          break;
        default:
          _routeToNavigate = DashboardScreen.routeName;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String? currentPage = ModalRoute.of(context)?.settings.name;
    final mainProvider = Provider.of<MainProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      mainProvider.darkMode ? Icons.nightlight : Icons.wb_sunny,
                      color: Colors.white,
                    ),
                    onPressed: null,
                  ),
                  Switch(
                    value: mainProvider.darkMode,
                    onChanged: (value) {
                      mainProvider.toggleTheme();
                    },
                  ),
                ],
              )),
        ],
      ),
      drawer: MainDrawer(
        setOptionPressed: _setOptionPressed,
      ),
      onDrawerChanged: (isOpen) {
        if (!isOpen && _routeToNavigate != '') {
          String? currentRoute = ModalRoute.of(context)?.settings.name;
          if (currentRoute != null) {
            Timer(const Duration(milliseconds: 200), () {
              if (_routeToNavigate == ActionsScreen.routeName) {
                Navigator.of(context).pushReplacementNamed(_routeToNavigate,
                    arguments: _optionAction);
              } else {
                Navigator.of(context).pushReplacementNamed(_routeToNavigate);
              }
            });
          }
        }
      },
      floatingActionButton: currentPage != DashboardScreen.routeName
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(
                  DashboardScreen.routeName,
                );
              },
              tooltip: 'Go Back',
              child: const Icon(
                Icons.arrow_back,
              ),
            )
          : Container(),
      body: widget.childWidget ?? Container(),
    );
  }
}
