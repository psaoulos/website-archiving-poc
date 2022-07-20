import 'package:flutter/material.dart';
import 'package:frontend/screens/actions.screen.dart';
import 'package:frontend/screens/dashboard.screen.dart';
import 'package:frontend/screens/results.screen.dart';
import 'package:frontend/screens/status.screen.dart';
import 'package:provider/provider.dart';

import 'package:frontend/providers/dashboard.provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const String appName = 'WebCrawler Console';

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashBoardProvider(),
        ),
      ],
      child: MaterialApp(
        title: appName,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: DashboardScreen.routeName,
        onGenerateRoute: (settings) {
          final arguments = settings.arguments;
          if (settings.name == DashboardScreen.routeName) {
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => DashboardScreen(),
              settings: settings,
            );
          } else if (settings.name == StatusScreen.routeName) {
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => StatusScreen(),
              settings: settings,
            );
          } else if (settings.name == ActionsScreen.routeName) {
            if (arguments != null && arguments != '') {
              final action = settings.arguments as CrawlerActions;
              return PageRouteBuilder(
                pageBuilder: (_, __, ___) => ActionsScreen(action: action),
                settings: settings,
              );
            }
          } else if (settings.name == ResultsScreen.routeName) {
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => ResultsScreen(),
              settings: settings,
            );
          }
          return null;
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (ctx) => DashboardScreen(),
            settings: settings,
          );
        },
      ),
    );
  }
}
